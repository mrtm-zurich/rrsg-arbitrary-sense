function out = iterativeRecon(data, properties, reference)
% iterativeRecon Perform CG-SENSE image reconstruction
%
% USE
%   [out] = iterativeRecon(data, properties)
%
% IN
%   data      	 Structure that contains the trajectory and signal
%     .signal      Complex MR signal values
%                    (nSamplesPerRFPulse x nRFPulses x nCoils)
%     .k_scaled    K-space trajectory, scaled to interval [-0.5,0.5]
%                    (nSamplesPerRFPulse x nRFPulses x 2)
%     .nCoils      Number of coils
%     .sense.data  Sensitivity profiles of the coils
%                    (nImgOs x nImgOs x nCoils)
%     .sense.mask  Mask for reconstructed image
%                    (nImgOs x nImgOs)
%
%   properties   Structure that contains the settings for CG-SENSE
%                  As created in main.m
%
% OUT
%   out                 Structure that contains output data
%     .imagesSC           Single-coil images
%     .imageComb          Combined reconstructed image (cropped to FOV)
%     .imageComb_full     Combined reconstructed image (from oversampled k-space grid)
%     .sens_os            Sensitivity maps
%     .imagesIterSteps    Intermediate images from all CG iterations
%

if nargin < 3
    reference = [];
end

%% Load input
signal = data.signal;
k = data.k_scaled;
nCoils = data.nCoils;

Nimg = properties.Nimg;
doSense = properties.doSense;
R = properties.R;
nIterations = properties.nIterations;
os = properties.gridding.os;
width = properties.gridding.width;
getSCdata = properties.getSCdata;
doVis = properties.doVis;
saveIterSteps = properties.saveIterSteps;
doNoiseCov = properties.doNoiseCov;
calculateDelta = properties.calculateDelta;
dokspaceApodization = properties.dokspaceApodization;

%% Adjust signal and k according to SENSE factor
if length(R) == 1
    selection = 1:R:size(signal,2);
else
    selection = R;
end
signal = signal(:,selection,:);
signal = double(reshape(signal, size(signal,1)*size(signal,2), size(signal, 3)));
k = k(:,selection,:);
k = reshape(k, size(k,1)*size(k,2), size(k,3));

%% Set up Gridding
N = os*Nimg;  % Grid size including oversampling
griddingOp = prepare_gridding_operator(k', os, width, N);
center = N/2-Nimg/2+1:N/2+Nimg/2;

%% SENSE Map
if doSense
    sens_os = data.sense.data;
    mask    = data.sense.mask;
else
    sens_os = ones(os*Nimg, os*Nimg, size(signal,2));
    mask    = ones(os*Nimg, os*Nimg);
end

%% Noise Covariance Matrix
if doNoiseCov
    noiseCov = data.sense.noiseCov;
else
    noiseCov = eye(nCoils, nCoils);
end

%% Calculate k-space density for density compensation
CartKspace = griddingOp.H'*(ones(size(signal(:,1))));
CartKspace = reshape(CartKspace,[N,N]);
density = griddingOp.H*CartKspace(:);
D = zeros(size(signal,1),size(sens_os,3));
for coil = 1:size(sens_os,3)
    D(:,coil) = 1./density;
end

% -- k-space filter
% From k-space mask -- version 1
% kspFilter = ones(size(griddingOp.H'*signal(:,1)));
% kspFilter(griddingOp.H'*signal(:,1) == 0) = 0;
% griddingOp.kspFilter = kspFilter;

% Simply circular -- version 2
[xx, yy] = meshgrid(linspace(-N/2,N/2,N), linspace(-N/2,N/2,N));
kspFilter = zeros(N,N);
kspFilter(xx.^2 + yy.^2 < (N/2)^2) = 1;
griddingOp.kspFilter = reshape(kspFilter, [], 1);

if dokspaceApodization
    if getSCdata
        sigma = 120;
        exponent = (xx.^2 + yy.^2)/2/sigma;
        kspFilter = exp(-exponent);
        griddingOp.kspFilter = reshape(kspFilter, [], 1);
    end
end

%% Calculate root of sum of squares coil intensity for intentsity correction
% Could also be loaded from sense struct (sense.intensity)
I = sqrt((sum(conj(sens_os).*sens_os, 3))+1E-15);

%% Image reconstruction
if getSCdata
    imagesSC = zeros(N,N,nCoils);
end

if saveIterSteps
    imagesIterSteps = cell(nIterations+1,1);
end

if calculateDelta
    Deltas = zeros(nIterations+1,1);
end

deltas = zeros(nIterations+1,1);

% Perform CG-SENSE algorithm
for nCoil=1:nCoils
    if ~getSCdata
        coilsSelect=1:nCoils;
    else
        coilsSelect = nCoil;
        noiseCov = 1;
    end
    a = EH( signal(:,coilsSelect).*D(:,coilsSelect)*noiseCov, sens_os(:,:,coilsSelect), griddingOp)./I;
    
    if calculateDelta
        Deltas(1) = norm(reshape( reference.mask.* ((a(center,center)) - reference.image ),1,[]))./ norm(reshape(reference.mask.*reference.image, 1, []));
    end
    
    reconImage = mask.*a./I;
    b = zeros([N N]);
    p = a;
    r = a;
    if saveIterSteps
        imagesIterSteps{1} = a(center,center);
    end
    for counter = 1:nIterations
        deltas(counter) = r(:)'*r(:)/(a(:)'*a(:));
        q = EH( E(p./I , sens_os(:,:,coilsSelect), griddingOp).*D(:,coilsSelect)*noiseCov, sens_os(:,:,coilsSelect), griddingOp)./I;
        b = b + r(:)'*r(:)/(p(:)'*q(:))*p;
        r_new = r - r(:)'*r(:)/(p(:)'*q(:))*q;
        p = r_new + r_new(:)'*r_new(:)/(r(:)'*r(:))*p;
        r = r_new;
        previousReconImage = reconImage; % for difference plots
        reconImage = mask.*b./I;
        if doVis
            plotIteration(reconImage, deltas, center, counter, ...
                previousReconImage)
        end
        if saveIterSteps
            imagesIterSteps{counter+1} = reconImage(center,center);
        end
        if calculateDelta
            Deltas(counter+1) = norm(reshape( reference.mask.* ((reconImage(center,center)) - reference.image ),1,[]))./ norm(reshape(reference.mask.*reference.image, 1, []));
        end
    end
    if getSCdata
        imagesSC(:,:,nCoil) = reconImage;
    else
        break;
    end
end
deltas(nIterations+1) = r(:)'*r(:)/(a(:)'*a(:));

%% Output
if getSCdata
    imageComb = zeros(N,N);
    for nCoil = 1:nCoils
        imageComb = imageComb + imagesSC(:,:,nCoil);
    end
else
    imagesSC = 'not available for combined recon';
    imageComb = reconImage;
end

out.imagesSC = imagesSC;
out.imageComb = imageComb(center,center);
out.imageComb_full = imageComb;
out.sens_os = sens_os;
out.kspFilter = kspFilter;
out.center = center;
out.deltas = deltas;
if saveIterSteps
    out.imagesIterSteps = imagesIterSteps;
end
if calculateDelta
    out.Deltas = Deltas;
end

end
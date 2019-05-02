function data = loadData(path_root, dataset)

switch dataset
    case 'brain'
        datafile = fullfile(path_root,'data','rawdata_brain_radial_96proj_12ch.h5');
        isRadial = 1;
        N = 340;
    case 'heart'
        datafile = fullfile(path_root,'data','rawdata_heart_radial_55proj_34ch.h5');
        isRadial = 1;
        N = 360;
    case 'spiral'
        datafile = fullfile(path_root,'data','spiral.h5');
        isRadial = 0;
        N = 300;
end

rawdata_real    = h5read(datafile,'/rawdata');
trajectory      = h5read(datafile,'/trajectory');

rawdata = double(rawdata_real.r+1i*rawdata_real.i); clear rawdata_real;
signal = permute(rawdata, [3 2 1]);
[nFE,nSpokes,nCoils] = size(signal);
% signal = double(reshape(signal, size(signal,1)*size(signal,2), size(signal, 3)));

% -- Change k
k = permute(trajectory, [2 1 3]);
k(:,:,3) = [];
% Norm k to range from -0.5 to +0.5
k_scaled = zeros(size(k));
range = max(reshape(k, [], 2))-min(reshape(k, [], 2));
k_scaled(:,:,1) = k(:,:,1)/range(1);
k_scaled(:,:,2) = k(:,:,2)/range(2);
k_scaled(:,:,1) = k_scaled(:,:,1) - min(min(k_scaled(:,:,1))) - 0.5;
k_scaled(:,:,2) = k_scaled(:,:,2) - min(min(k_scaled(:,:,2))) - 0.5;

% Plot 3D signal over traj
% figure
% hold on
% for ic1=1:size(rawdata,2)
%     plot3(squeeze(k(:,ic1,1)), squeeze(k(:,ic1,2)), sum(abs(signal(:,ic1,:)),3))
%     pause(1)
% end

% -- Output
data.signal   = signal;
data.k        = k;
data.k_scaled = k_scaled;
data.nCoils   = nCoils;
data.nFE      = nFE;
data.nSpokes  = nSpokes;
data.Nimg     = N;
data.isRadial = isRadial;
data.dataset  = dataset;

end
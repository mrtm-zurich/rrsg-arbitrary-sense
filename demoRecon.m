% This script loads the provided data, loads (or creates SENSE maps) and
% reconstructs the data for different undersampling factors (R values).

clear;
paths = setupPaths();
doLoadSenseMap = 0;

%% Load Data
% Possible Datasets are: 'brain', 'heart'
properties.dataset = 'brain';
data = loadData(paths.root, properties.dataset);

%% Set up properties
properties.Nimg = data.Nimg;        % Number of voxels N
properties.doSense = 1;             % Do SENSE reconstruction?
properties.R = 2;                   % Undersampling factor (positive integer or range)
properties.nIterations = 10;        % Number of CG-SENSE iterations
properties.gridding.os = 2;         % Gridding oversampling factor
properties.gridding.width = 4;      % Gridding kernel width as a multiple of dk without oversampling
properties.getSCdata = 0;           % Return single-coil images?
properties.doVis = 0;               % Plot current image after each CG iteration?
properties.saveIterSteps = 0;       % Store images from all CG iterations?
properties.doNoiseCov = 1;          % Use noise covariance matrix?
properties.calculateDelta = 0;      % Calculate delta (normed difference of each iteration step to reference)?
properties.dokspaceApodization = 0; % Add additional k-space apodization? (used for SENSE map creation)

%% Calculate or load SENSE map
data.sense = getSenseMap(paths, properties, doLoadSenseMap, data);
 
%% Reconstruct Images
% -- R=1
properties.doSense = 1;
properties.R = 2;
properties.nIterations = 5;
properties.saveIterSteps = 1;
properties.doNoiseCov = 1;
properties.doVis = 1;

out = iterativeRecon(data, properties);

imageComb_full_FFT = TransformImageToKspace(out.imageComb_full);
imageComb_kspFilter_FFT = out.kspFilter.*imageComb_full_FFT;
mask_tmp = ones(size(out.kspFilter));
mask_tmp(out.kspFilter) = 0;
imageComb_nokspFilter_FFT = mask_tmp.*imageComb_full_FFT;
imageComb_kspFilter = TransformKspaceToImage(imageComb_kspFilter_FFT);
imageComb_nokspFilter = TransformKspaceToImage(imageComb_nokspFilter_FFT);

h1 = figure('Name', 'R=1');
subplot(1,3,1); imagesc(rot90(abs(out.imagesIterSteps{1}),2)); colormap(gray); axis image; axis off; title('0th iteration');
subplot(1,3,2); imagesc(rot90(abs(out.imagesIterSteps{5}),2)); colormap(gray); axis image; axis off; title('2nd iteration');
subplot(1,3,3); imagesc(rot90(abs(out.imagesIterSteps{9}),2)); colormap(gray); axis image; axis off; title('4th iteration');

% -- R=2
properties.R = 2;
properties.nIterations = 8;
out = iterativeRecon(data, properties);

h2 = figure('Name', 'R=2');
subplot(1,3,1); imagesc(rot90(abs(out.imagesIterSteps{1}),2)); colormap(gray); axis image; axis off; title('0th iteration');
subplot(1,3,2); imagesc(rot90(abs(out.imagesIterSteps{5}),2)); colormap(gray); axis image; axis off; title('4nd iteration');
subplot(1,3,3); imagesc(rot90(abs(out.imagesIterSteps{9}),2)); colormap(gray); axis image; axis off; title('8th iteration');
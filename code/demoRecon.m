% This script loads the provided data, loads (or creates SENSE maps) and
% reconstructs the data for different undersampling factors (R values).

clear;
paths = setupPaths();
doLoadSenseMap = 1;

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
% computation method for kspace filter
% 'gridding' - gridding of 1s on trajectory (for arbitrary traj) & mask
% 'disk'     - use circular disk (only useful for radials/spirals)
properties.kSpaceFilterMethod = 'disk'; 

%% Calculate or load SENSE map
data.sense = getSenseMap(paths, properties, doLoadSenseMap, data);
 
%% Reconstruct Images
% -- R=1

nIt = 100;
properties.doSense = 1;
properties.R = 1;
properties.nIterations = nIt;
properties.saveIterSteps = 1;
properties.doNoiseCov = 1;
properties.doVis = 1;

out = iterativeRecon(data, properties);

nItHalf = round(nIt/2);
fh = figure('Name', 'demoRecon: Iteration Results');
subplot(2,3,1); imagesc(rot90(abs(out.imagesIterSteps{1}),2)); colormap(gray); axis image; ylabel('R=1'); title('iteration 0');
subplot(2,3,2); imagesc(rot90(abs(out.imagesIterSteps{nItHalf}),2)); colormap(gray); axis image; axis off; title(sprintf('iteration %d', nItHalf));
subplot(2,3,3); imagesc(rot90(abs(out.imagesIterSteps{nIt}),2)); colormap(gray); axis image; axis off; title(sprintf('iteration %d', nIt));

%% -- R=2
properties.R = 2;
properties.nIterations = nIt;
out = iterativeRecon(data, properties);

nItHalf = round(nIt/2);
figure(fh);
subplot(2,3,4); imagesc(rot90(abs(out.imagesIterSteps{1}),2)); colormap(gray); axis image; ylabel('R=2'); title('iteration 0');
subplot(2,3,5); imagesc(rot90(abs(out.imagesIterSteps{round(nItHalf)}),2)); colormap(gray); axis image; axis off;  title(sprintf('iteration %d', nItHalf));
subplot(2,3,6); imagesc(rot90(abs(out.imagesIterSteps{nIt}),2)); colormap(gray); axis image; axis off;  title(sprintf('iteration %d', nIt));
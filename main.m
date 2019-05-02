% This script loads the provided data, loads (or creates SENSE maps) and
% reconstructs the data for different undersampling factors (R values).
% Reconstructions are done in the CreateFigure functions which are meant to
% replicate the Figures of the original paper.

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

%% Calculate or load SENSE map
data.sense = getSenseMap(paths, properties, doLoadSenseMap, data);

%% Create Figure 4 (brain data)
deltas = createFigure4(data, paths);

%% Create Figure 5 (brain data)
createFigure5(data, paths);

%% Create Figure 6 (heart data)
properties.dataset = 'heart';
data = loadData(paths.root, properties.dataset);
properties.Nimg = data.Nimg;
data.sense = getSenseMap(paths, properties, doLoadSenseMap, data);

createFigure6(data, paths);
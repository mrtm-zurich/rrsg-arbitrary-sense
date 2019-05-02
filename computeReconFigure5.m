function out = computeReconFigure5(data, R, doSingleCoil)
%reconstruct SENSE recon for figure 5 or single coil image
%   out = computeReconFigure5(input)
%
% IN
%   data            input data for recon
%   R               Undersampling factor
%   doSingleCoil    true or {false}. 
%                   If true, single coil recon without SENSE
%                   is performed
%                   If false, SENSE recon with undersampled data (R) is
%                   reconstructed
%
% OUT
%   out             output image structure
% EXAMPLE
%   computeReconFigure5
%
%   See also
 
% Author:  Lars Kasper
% Created:  2019-04-30
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%

if nargin < 2
    R = 2;
end

if nargin < 3
    doSingleCoil = false;
end

properties.calculateDelta = 0;
properties.dokspaceApodization = 0;
properties.Nimg = data.Nimg;        % For the phantom it should be 152, 340 for brain, 360 for heart
properties.R = R;                   % Undersampling factor (positive integer)
properties.gridding.os = 2;         % Gridding oversampling factor
properties.gridding.width = 4;      % Gridding kernel width as a multiple of dk without oversampling
properties.doVis = 0;               % Plot current image after each CG iteration?
properties.doNoiseCov = 0;

if doSingleCoil
    properties.nIterations = 1;        % Number of CG-SENSE iterations
    properties.doSense = 0;             % Do SENSE reconstruction?
    properties.getSCdata = 1;           % Return single-coil images?
    properties.saveIterSteps = 0;       % Store images from all CG iterations?
else
    properties.nIterations = 12;        % Number of CG-SENSE iterations
    properties.doSense = 1;             % Do SENSE reconstruction?
    properties.getSCdata = 0;           % Return single-coil images?
    properties.saveIterSteps = 1;       % Store images from all CG iterations?
end

out = iterativeRecon(data, properties);

function fh = createFigure5(data, paths)
% reproduces Figure 5 of paper Pruessmann et al, 2001
%
%   fh = createFigure5(data)
%
% IN
%
% OUT
%
% EXAMPLE
%   createFigure5
%
%   See also

% Author:   Franz Patzig, Thomas Ulrich, Maria Engel, Lars Kasper
% Created:  2019-04-30
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
%
iCoil = 12;

stringTitle = sprintf('Figure 5 Reproduction - Undersampled Recons Arbitrary SENSE');
fh(1) = figure('Name', [stringTitle, ' - part 1']);
fh(2) = figure('Name', [stringTitle, ' - part 2']);

RArray = [1 2 3 4];
nR = numel(RArray);

%% Compute single coil recons w/o SENSE (left column of plot) and SENSE recons%
for iR = 1:nR
    fprintf('Reconstruct Image with R = %d... (%d/%d)\n', RArray(iR), iR, nR);
    outSingle(iR) = computeReconFigure5(data, RArray(iR), true); % doSingleCoil = true;
    outSense(iR) = computeReconFigure5(data, RArray(iR), false); % SENSE!
end

%% Create Subplots for figure
bestIteration = [4 7 10 12];
intensityMaxPerColumn = [2e-15, 1.1e-6, 2.5e-7];
for iR = 1:nR
    R = RArray(iR);
    
    if iR < 3
        figure(fh(1))
    else
        figure(fh(2));
    end
    
    for iCol = 1:3
        
        switch iCol
            case 1
                center = outSingle(iR).center;
                out = outSingle(iR).imagesSC(center,center,iCoil);
            case 2
                out = outSense(iR).imagesIterSteps{1,1};
            case 3
                out = outSense(iR).imagesIterSteps{bestIteration(iR)+1,1};
        end
        
        subplot(2,3,3*(2-mod(iR,2)-1)+iCol);
        I = abs(out);
        imagesc(I);
        axis square
        %axis off
        axis image
        colormap gray
        caxis([0, intensityMaxPerColumn(iCol)]);
        switch iCol
            case 1
                ylabel(sprintf('R = %d', R));
                title(sprintf('single coil recon (coil %d)', iCoil));
            case 2
                title('Initial (E^H)');
            case 3
                title(sprintf('Final (%d)', bestIteration(iR)));
        end
        set(gca, 'XTick', [])
        set(gca, 'YTick', [])
    end
    
    
end

if exist('suptitle')
    suptitle(stringTitle);
end

%% save figure
for iPart = 1:2
    print(fh(iPart),[paths.results '/Figure5_' data.dataset '_undersamplingRecon_part' ...
        num2str(iPart)],'-dpng')
end
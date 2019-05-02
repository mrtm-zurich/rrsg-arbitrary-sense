function createFigure6(data, paths)

% This function creates Figure 6 of the original paper (reconstruction over 
% undersampled and fully sampled cardio data). It first sets properties 
% that are held constant for all of the following reconstructions. They are 
% very similar to the main script. Then reconstructions using only the
% first 11, 22, 33, 44 or all 55 spokes of the provided heart dataset are
% done (equal R=5,4,3,2,1 respectively).

properties.Nimg = data.Nimg;        
properties.gridding.os = 2;         
properties.gridding.width = 4;      
properties.doVis = 1;               
properties.saveIterSteps = 0;       
properties.doNoiseCov = 1;
properties.getSCdata = 0;
properties.calculateDelta = 0;
properties.dokspaceApodization = 0;
properties.doSense = 1;
cardioImages = zeros(properties.Nimg, properties.Nimg, 5);

% Reconstruction using the first 11 spokes
properties.R = 1:11;
properties.nIterations = 6;

out = iterativeRecon(data, properties);
cardioImages(:,:,1) = out.imageComb;

% Reconstruction using the first 22 spokes
properties.R = 1:22;
properties.nIterations = 6;

out = iterativeRecon(data, properties);
cardioImages(:,:,2) = out.imageComb;

% Reconstruction using the first 33 spokes
properties.R = 1:33;
properties.nIterations = 6;

out = iterativeRecon(data, properties);
cardioImages(:,:,3) = out.imageComb;

% Reconstruction using the first 44 spokes
properties.R = 1:44;
properties.nIterations = 6;

out = iterativeRecon(data, properties);
cardioImages(:,:,4) = out.imageComb;

% Reconstruction using all 55 spokes
properties.R = 1:55;
properties.nIterations = 6;

out = iterativeRecon(data, properties);
cardioImages(:,:,5) = out.imageComb;

% Plot the results and save the figure in results subfolder
fig6 = figure;
for ic1 = 1:5
    spokes = [11 22 33 44 55];
    subplot(1,5,ic1); imagesc(abs(cardioImages(:,:,ic1))); title([num2str(spokes(ic1)) ' spokes']); colormap(gray); axis image; axis off;
end
print(fig6,[paths.results '/Figure6_' data.dataset '_undersamplingRecon'],'-dpng')

end

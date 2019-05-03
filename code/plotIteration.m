function fh = plotIteration(currentIteration, deltas, center, iIteration, ...
    previousIteration)
%% Plots reconstructed image at specific iteration, both in image and k-space, 
% with magnitude and phase data, and difference to previous iteration
%
% USE
%   fh = plotIteration(currentIteration, deltas, center, iIteration, ...
%       previousIteration)
    
fh = figure(100);
set(fh, 'Name', 'Current Iteration');

I = currentIteration(center,center);
previousI = previousIteration(center,center);

subplot(2,3,1)
imagesc(abs(I)); axis image; colorbar; colormap(gray(256));
title('magnitude');

subplot(2,3,4)
imagesc(angle(I)); axis image; colorbar; colormap(gray(256));
title('phase');

subplot(2,3,2);
imagesc(abs(I).^0.1); axis image; colorbar; colormap(gray(256));
title('magnitude^{0.1}');

subplot(2,3,5);
imagesc(log(abs(transformImageToKspace(I)))); axis image; colorbar; colormap(gray(256));
title('k-space (log(abs))');

subplot(2,3,3);
imagesc(abs(I-previousI)); axis image; colorbar; colormap(gray(256));
title(sprintf('abs(diff iteration %d vs %d)', iIteration, iIteration - 1)); 

subplot(2,3,6);
nIterations = numel(deltas);
plot(0:iIteration,log10(deltas(1:(iIteration+1))), 'LineWidth', 2);
xlim([0 nIterations])
ylabel('$\log_{10} \delta$', 'Interpreter', 'latex', 'FontSize', 16)
xlabel('Iterations', 'Interpreter', 'latex', 'FontSize', 16)
box on;

drawnow;


end
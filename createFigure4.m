function deltas = createFigure4(data, paths)

% This function creates Figure 4 of the original paper (log(delta) over
% number of iterations). It first sets properties that are held constant for
% all of the following reconstructions. They are very similar to the main
% script. In the first step a reconstruction using all data (R=1) is made
% with 5 iterations. The number of iterations was chosen manually as we
% found that the brain dataset showed a good reconstruction after 5 steps.
% Then, reconstructions with undersampling factors of R=2,3,4,5 are done. A
% porperty called 'calculateDelta' is used and set to 1 to output the delta
% for each iteration step.

properties.Nimg = data.Nimg;        
properties.gridding.os = 2;  
properties.gridding.width = 4;   
properties.doVis = 0;            
properties.saveIterSteps = 0;  
properties.doNoiseCov = 1;
properties.getSCdata = 0;
properties.calculateDelta = 0;
properties.dokspaceApodization = 0;

% R=1 image
properties.doSense = 1;
properties.R = 1;
properties.nIterations = 5;

out = iterativeRecon(data, properties);
reference.image = out.imageComb;
mask_tmp = zeros(size(reference.image));
mask_tmp(abs(reference.image) > mean(mean(abs(reference.image)))) = 1;
se = strel('diamond',2);
mask_tmp = imopen(mask_tmp, se);
reference.mask = mask_tmp;

% Range of R
R = [1, 2, 3, 4, 5];
properties.nIterations = 30;
deltas = zeros(properties.nIterations+1, length(R));
for ic1=1:length(R)
    disp(['Reconstruct image with R = ' num2str(R(ic1)) '. (' num2str(ic1) '/' num2str(length(R)) ')']);
    properties.R = R(ic1);
    properties.saveIterSteps = 0;
    properties.doNoiseCov = 1;
    properties.getSCdata = 0;
    properties.calculateDelta = 1;
    
    out_tmp = iterativeRecon(data, properties, reference);
    deltas(:,ic1) = out_tmp.deltas;
end

% Plot the results and save the figure in results subfolder
% We decided to not plot the error for R=1
fig4 = figure;
hold on
% plot(log(deltas(:,1)), 'LineWidth', 2)
plot(log(deltas(:,2)), 'LineWidth', 2)
plot(log(deltas(:,3)), 'LineWidth', 2)
plot(log(deltas(:,4)), 'LineWidth', 2)
plot(log(deltas(:,5)), 'LineWidth', 2)
xlim([1 length(deltas)-1])
ylabel('$log_{10} \delta$', 'Interpreter', 'latex', 'FontSize', 16)
xlabel('Iterations', 'Interpreter', 'latex', 'FontSize', 16)
legend({'R=2', 'R=3', 'R=4', 'R=5'}, 'Location', 'NorthEast', 'Interpreter', 'latex', 'FontSize', 14)
box on
print(fig4,[paths.results '/Figure4_' data.dataset '_logDeltaOverIterations'],'-djpeg')

end
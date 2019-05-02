function mask_combined_smooth = createMask(input, maskmode)
% Create improved mask
% Input: data array

% Create mask(s)
if maskmode
    
    mask = zeros(size(input));
    for ic1=1:size(input,3)
        mean_tmp = mean(mean(abs(input(:,:,ic1))));
        mask_tmp = zeros(size(input(:,:,1)));
        mask_tmp(abs(input(:,:,ic1)) > 1.5*mean_tmp) = 1;
        se = strel('diamond',1);
        mask_tmp = imopen(mask_tmp, se);
        se = strel('diamond',2);
        mask_tmp = imclose(mask_tmp, se);
        mask_tmp = imfill(mask_tmp, 'holes');
        mask(:,:,ic1) = mask_tmp;
    end
    
    % Combine mask(s)
    mask_combined = zeros(size(mask,1), size(mask,2));
    for ic1=1:size(input,3)
        mask_combined = mask_combined | mask(:,:,ic1);
    end
    mask_combined = imfill(mask_combined, 'holes');
    se = strel('diamond',2);
    mask_combined = imopen(mask_combined, se);
    
else
    
    image_comb = sum(abs(input),3);
    mean_tmp = mean(mean(image_comb));
    mask_tmp = zeros(size(input(:,:,1)));
    mask_tmp(image_comb > 1.2*mean_tmp) = 1;
    se = strel('diamond',1);
    mask_tmp = imopen(mask_tmp, se);
    se = strel('diamond',2);
    mask_tmp = imclose(mask_tmp, se);
    mask_combined = imfill(mask_tmp, 'holes');
    
end

% Smooth mask
se = strel('diamond',4);
mask_combined_tmp = imdilate(mask_combined, se);
mask_combined_smooth = imgaussfilt(double(mask_combined_tmp), 4);
mask_combined_smooth(logical(mask_combined)) = 1;

end
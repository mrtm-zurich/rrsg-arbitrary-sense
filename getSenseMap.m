function sense = getSenseMap(paths, properties, doLoadSenseMap, data)
% computes SENSE maps or loads precalculated one from disk

if nargin < 4
    data = [];
    doLoadSenseMap = true; % no data to compute it...
end

if doLoadSenseMap
    name = [paths.data '/' properties.dataset 'SENSEmap.mat'];
    load(name);
    % Adjust size if sense map was created on another size
    if (size(sense.data,1) ~= properties.gridding.os*properties.Nimg)
        center = properties.gridding.os*properties.Nimg/2-size(sense.data,1)/2+1:properties.gridding.os*properties.Nimg/2+size(sense.data,1)/2;
        data_tmp = zeros(properties.gridding.os*properties.Nimg, properties.gridding.os*properties.Nimg, size(sense.data,3));
        for nCoil = 1:size(sense.data,3)
            data_tmp(center,center,nCoil) = sense.data(:,:,nCoil);
        end
        mask_tmp = zeros(properties.gridding.os*properties.Nimg, properties.gridding.os*properties.Nimg);
        mask_tmp(center,center) = sense.mask;
        sense.data = data_tmp;
        sense.mask = mask_tmp;
    end
else
    saveSENSE = 1;
    sense = calculateSENSEmaps(data, properties, saveSENSE, paths.data);
end
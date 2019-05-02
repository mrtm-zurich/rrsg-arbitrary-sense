% TransformKspaceToImage.m, | Wilm/Barmet, ETH, IBT
%
% function y=TransformKspaceToImage(array)

function y = TransformKspaceToImage(array)

% y = ifftshift(ifftn(fftshift(array)));
y = ifftshift(ifftn(fftshift(array)))*sqrt(prod(size(array)));
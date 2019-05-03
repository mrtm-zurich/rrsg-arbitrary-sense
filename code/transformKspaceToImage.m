% transformKspaceToImage.m, | Wilm/Barmet, ETH, IBT
%
% function y = transformKspaceToImage(array)

function y = transformKspaceToImage(array)

% y = ifftshift(ifftn(fftshift(array)));
y = ifftshift(ifftn(fftshift(array)))*sqrt(prod(size(array)));
% transformImageToKspace.m, | Wilm/Barmet ETH, IBT
%
% function y = transformImageToKspace(array)

function y = transformImageToKspace(array)

% y = ifftshift(fftn(fftshift(array)));
y = ifftshift(fftn(fftshift(array)))/sqrt(prod(size(array)));
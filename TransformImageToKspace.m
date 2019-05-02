% TransformImageToKspace.m, | Wilm/Barmet ETH, IBT
%
% function y=TransformImageToKspace(array)

function y = TransformImageToKspace(array)

% y = ifftshift(fftn(fftshift(array)));
y = ifftshift(fftn(fftshift(array)))/sqrt(prod(size(array)));
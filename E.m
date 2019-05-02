% E.m | Wilm, ETH, IBT
% E x using the Gridding Operator from Felix Breuer
% Function that calculates the multiplication of the encoding matrix E with 
% (spatial) image data vector.
%
% Input: 
% data_in = the orginal dicretized sample (image data)
% sensitivity = the coils sensitivities at the same resolution, 
% k = the k-space trajectory
%
% Output: k-space signal along the trajectory.

function data_out = E(data_in, sensitivity, griddingOp)

H = griddingOp.H;
W = griddingOp.W;
N_samples = griddingOp.N_samples;
kspFilter = griddingOp.kspFilter;

N_coils = size(sensitivity,3);

data_out = zeros(N_samples,N_coils);

for ind_coil = 1: N_coils
    cartKspace = fftshift(fft2(fftshift(data_in(:,:).*sensitivity(:,:,ind_coil)./W))); 
    % cartKspace = fftshift(fft2(fftshift(data_in(:,:).*sensitivity(:,:,ind_coil))));
    data_out(:,ind_coil) = H*(kspFilter.*cartKspace(:));
end


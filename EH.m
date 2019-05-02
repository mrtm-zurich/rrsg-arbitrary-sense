% EH.m | Wilm, ETH, IBT
% E^H x using the Gridding Operator from Felix Breuer
% Function that performs the multiplication of the Hermitian counterpart of the
% encoding matrix E^H with k-space data sampled on a arbitrary grid.
%
% Input: 
% data_in = the k-space samples along the trajectory 
% sensitivity = the coils sensitivities of the MR experiment 
% k = the k-space trajectory
%
% Output: image in spatial-domain.

function data_out = EH( data_in, sensitivity, griddingOp)

H = griddingOp.H;
W = griddingOp.W;
N_grid = griddingOp.N_grid;
kspFilter = griddingOp.kspFilter;

data_out = zeros(N_grid,N_grid);

N_coils = size(sensitivity,3);
for ind_coil = 1 : N_coils
    % Grid
    data = data_in(:,ind_coil);
    CartKspace = H'*(data(:));
    % Apply ksp-Filter
    CartKspace = kspFilter.*CartKspace;
    CartKspace = reshape(CartKspace,[N_grid,N_grid]);
    % And FFT
    data_out = data_out + conj(sensitivity(:,:,ind_coil)).*ifftshift(ifft2(ifftshift(CartKspace)))./W;
    % data_out = data_out + conj(sensitivity(:,:,ind_coil)).*ifftshift(ifft2(ifftshift(CartKspace)));
end

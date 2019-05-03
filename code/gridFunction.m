function OUT = gridFunction(IN,Traj,N,kernel,adjoint);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
% OUT = gridFunction(IN,Traj,N,kernel,adjoint)
% 
% -----------------------------------------------------------------------------------
% 
% Forward Gridding: adjoint = true
% Grids Non-Cartesian data onto a NxN Cartesian grid (adjoint operation:
% default) via convolution gridding 
% Density Compensation and Apodization correction are not considered.
% 
% INPUT: IN                 Non-Cartesian k-space data (nSamples)(adjoint operation)
%        Traj               (2 x nSamples) defined between -0.5 and 0.5 
%        N                  integer; Gridsize including oversampling
%        kernel             structure of the convolution kernel with
%                           kernel.values
%                           kernel.os
%                           kernel.width
%        adjoint            true
%
% OUTPUT: OUT               Cartesian K-space data (NxN)
%
% ------------------------------------------------------------------------------------
% 
% Reverse Gridding: adjoint = false
% Grids Cartesian data onto a Non-cartesian trajectory given in Traj 
% 
% INPUT: IN                 Cartesian k-space data NxN
%        Traj               (2 x nSamples) defined between -0.5 and 0.5 
%        N                  integer; Gridsize including oversampling
%        kernel             structure of the convolution kernel with
%                           kernel.values
%                           kernel.os
%                           kernel.width
%        adjoint            false
%
% OUTPUT: OUT               Non-Cartesian K-space data (nSamples)
%
% ------------------------------------------------------------------------------------
%
% Apodization Correction matrix W can be derived by calling 
% W = ifftshift(ifft2(ifftshift(gridFunction(1,[0;0],N,kernel,true))));
%
% written by Felix Breuer Fraunhofer IIS/MRB 23.02.2016
% Based on Code from Brian Hargreaves
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4;
    adjoint = true;
end

Traj = Traj(:,:);

nKernelpoints = length(kernel.values);
kwidth        = kernel.kwidth;
kerneltable   = kernel.values;
nSamples      = size(Traj,2);

if adjoint
    OUT = zeros(N,N);
else
    OUT = zeros(nSamples,1);
end

% Calculate the kernel extend on Cartesian grid for each sampled
% non-Cartesian location

iMin = floor((Traj-kwidth)*N + N/2+1);
iMax = floor((Traj+kwidth)*N + N/2+1);


for k = 1:nSamples,
    for x = iMin(1,k):iMax(1,k)
        dkx = (x - (N/2+1))/N - Traj(1,k);
        
        for y = iMin(2,k):iMax(2,k)
            dky = (y - (N/2+1))/N - Traj(2,k);
            
            dk = sqrt(dkx.^2+dky.^2);
            
            if (dk<kwidth)
                
                %Find index in kernel lookup table
                ind =  floor(dk/kwidth*(nKernelpoints-1))+1;
                kern = kerneltable(ind);
                % circular boundary condition
                y_ = mod(y-1,N)+1;
                x_ = mod(x-1,N)+1;
                                
                if adjoint
                    ind_out = (y_-1)*N + x_ ;
                    ind_in  = k;
                else
                    ind_out = k;
                    ind_in  = (y_-1)*N + x_;
                end
                
                
                OUT(ind_out) = OUT(ind_out) + kern*IN(ind_in);
                
            end
        end
        
    end
end



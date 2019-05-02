
function H = gridOperator(Traj,N,kernel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
% H = gridOperator(Traj,N,kernel)
% 
% INPUT: 2D Traj            (2 x Nsamples) defined between -0.5 and 0.5
%        N                  integer; Gridsize including oversampling 
%        kernel             structure of the convolution kernel with
%                           
%                           kernel.values
%                           kernel.kwidth     (kwidth = width/2/N*os)
%
%                          
%
% OUTPUT: H                 Sparse Matrix; Gridding Operator (Nsamples x N^2)
%
%
%         ----------------------------------------------------------------------------- 
%         S                 kernel values to build spares matrix 
%         I                 index of non-Cartesian data point 
%         J                 index of position in Cartesian K-space (J = (y-1)*N + x)) 
%
%         H = sparse(I,J,S,Nsamples,N*N,length(S)); 
%         -----------------------------------------------------------------------------
%
% written by Felix Breuer Fraunhofer IIS/MRB 23.02.2016
% Based on Code from Brian Hargreaves
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if mod(N,2) 
    error('Input N should be even')
end


Traj = Traj(:,:);

nKernelpoints = length(kernel.values);
kwidth        = kernel.kwidth;
kerneltable   = kernel.values;
nSamples      = size(Traj(:,:),2);

% Calculate the kernel extend on Cartesian grid for each sampled
% non-Cartesian location

iMin = floor((Traj-kwidth)*N + N/2+1);
iMax = floor((Traj+kwidth)*N + N/2+1);

% Allocate memory for variables in sparse matrix

nKernelVals = round((kwidth*N).^2*pi);

I = zeros(nSamples*nKernelVals,1);
J = zeros(nSamples*nKernelVals,1);
S = zeros(nSamples*nKernelVals,1);

cnt = 0;

for k = 1:nSamples,
    
    for x = iMin(1,k):iMax(1,k)
        dkx = (x - (N/2+1))/N - Traj(1,k);
        
        for y = iMin(2,k):iMax(2,k)
            dky = (y - (N/2+1))/N - Traj(2,k);
                        
            dk = sqrt(dkx.^2+dky.^2);
            
            if (dk<kwidth)
                cnt = cnt+1;
                %Find index in kernel lookup table
                ind =  floor(dk/kwidth*(nKernelpoints-1))+1;
                kern = kerneltable(ind);
                % circular boundary condition
                y_ = mod(y-1,N)+1;
                x_ = mod(x-1,N)+1;
                                
                J(cnt) = x_ + N*(y_-1);
                I(cnt) = k;
                S(cnt) = kern;
                
                
            end
        end
        
    end
end

I(cnt+1:end) = [];
J(cnt+1:end) = [];
S(cnt+1:end) = [];

H = sparse(I,J,S,nSamples,N*N,length(S)); 

end


function optimalinvfimg = OVST(fimg)
% Optimal inverse Anscombe Transform (AT) 
%
% References
% [1] M. Makitalo and A. Foi, "On the inversion of the Anscombe transformation in low-count Poisson image denoising", 
% Proc. Int. Workshop on Local and Non-Local Approx. in Image Process., LNLA 2009, Tuusula, Finland, pp. 26-32, August 2009.
% [2] M. Makitalo and A. Foi, "Optimal inversion of the Anscombe transformation in low-count Poisson image denoising",
% TIP 2010.

% Code slightly modified from the original code of  Alessandro Foi and Markku Makitalo
% Original Software can be downloaded from http://www.cs.tut.fi/~foi/invansc/
%
%  Alessandro Foi and Markku Makitalo - Tampere University of Technology - 2009
% -------------------------------------------------------------------------------

load OVSTtables.mat Efz Ez

% Estimation of the asympotic inv AT (Classical one)
asympinvfimg = (fimg / 2).^2 - 1/8;

% Estimation of the optimal inv AT (see paper [2]).
optimalinvfimg = interp1(Efz,Ez,fimg,'linear','extrap');  

% Detection of image areas under and above the validity range of the optimal inverse transform
asympmap = find(fimg > max(Efz(:)));
biasedmap = find(fimg < 2*sqrt(3/8));

% Filling of areas under and above validity range
optimalinvfimg(asympmap) = asympinvfimg(asympmap);
optimalinvfimg(biasedmap) = 0;


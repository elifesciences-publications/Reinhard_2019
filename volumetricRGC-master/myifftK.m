function f=myifftK(F,u)
% does the centering(shifts) and normalization
%needs a slight modification to actually support rectangular images
if nargin<2
f=ifftshift(ifft(ifftshift(F)))*sqrt(numel(F));
else
f=ifftshift(ifft(ifftshift(F)))*sqrt(u);
zoffset=ceil((size(f,1)-u)/2);
f=f(zoffset+1:zoffset+u);
end
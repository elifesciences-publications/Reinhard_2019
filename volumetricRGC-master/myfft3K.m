function F=myfft3(f,u,v,w)
% does the centering(shifts) and normalization
%needs a slight modification to actually support rectangular images
if nargin<4
F=fftshift(fftn(fftshift(f)))/sqrt(prod(size(f)));
else
F=zeros(u,v,w);
zoffset=(u-size(f,1))/2; xoffset=(v-size(f,2))/2; yoffset=(w-size(f,3))/2;
F(zoffset+1:zoffset+size(f,1),xoffset+1:xoffset+size(f,2),yoffset+1:yoffset+size(f,3))=f;
F=fftshift(fftn(fftshift(F)))/sqrt(prod(size(f)));
end
function [vol,somaCoord] = removeSoma_K(vol,xsoma,ysoma,dilationKernel)
% Software developed by: Uygar Sümbül <uygar@stat.columbia.edu, uygar@mit.edu>
% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE.
% IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DAMAGES WHATSOEVER.
%
% Remove the somata in the 3d binary image stack
soma = imdilate(imopen(vol,dilationKernel),dilationKernel);
xkeep = round(min(xsoma)):round(max(xsoma));
ykeep = round(min(ysoma)):round(max(ysoma));
realSoma2 = zeros(size(soma));
realSoma2(ykeep,xkeep,:)=soma(ykeep,xkeep,:);
indices = find(realSoma2==1);
[xind yind zind] = ind2sub(size(realSoma2),indices);
somaCoord = [median(yind) size(soma,1)-median(xind) median(zind)];
clear  realSoma2

vol = max(0,vol-soma);
clear soma

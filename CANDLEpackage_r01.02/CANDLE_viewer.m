% Pierrick Coupe - pierrick.coupe@gmail.com
% Brain Imaging Center, Montreal Neurological Institute.
% Mc Gill University
%
% Copyright (C) 2010 Pierrick Coupe.


clc;
clear all;
close all;


[namein, pathin, filterindex] = uigetfile({  '*.tif','TIFF image (*.tif)'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');
if isequal(namein,0) | isequal(pathin,0)
    disp('User pressed cancel')
else
    
    
    flag=1;
    
    if (flag==1)
        
        if (iscell(namein))
            nbfile = size(namein,2);
        else
            nbfile = 1;
        end
        
        for f = 1 : nbfile
            
            figure
            
            if(nbfile>1)
                filenamein = namein{f};
            else
                filenamein = namein;
            end
            
            disp(['Input file : ', fullfile(pathin, filenamein)])
            [pathstr, name_s, ext]=fileparts(fullfile(pathin, filenamein));
           
            info = imfinfo([pathin filenamein]);
            dim = numel(info);
            
            com = sprintf('\nNumber of slices: %d \n', dim);
            disp(com)
            
            % Image reading
            for i = 1:dim
                imgIn(:,:,i) = imread([pathin filenamein],i);
            end
            
            
            s=size(imgIn);
            if (size(s)~=3)
                error('Input image must be a 3-D array.')
            end
            
            
            % Substack Display
            slice = floor((s(3))/2);
            mini = min(imgIn(:));
            maxi = max(imgIn(:));
            subplot(1,2,1)
            imagesc(imgIn(:,:,slice),[mini maxi]); colormap('bone');
            axis image
            axis off
            title('Input image');
            
            
            MIPinput = max(imgIn, [], 3);
            
            subplot(1,2,2)
            imagesc(MIPinput); colormap('bone');
            axis image
            axis off
            title('MIP of Input image');
            
            
        end
        
        
    end
end
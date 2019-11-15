% Pierrick Coupe - pierrick.coupe@gmail.com
% Brain Imaging Center, Montreal Neurological Institute.
% Mc Gill University
%
% Copyright (C) 2010 Pierrick Coupe.
%

%                          Details on CANDLE filter                        */
%***************************************************************************
%	P. Coup�, M. Munz, J. V. Manjon, E. Ruthazer, D. L. Collins.
%   A CANDLE for a deeper in-vivo insight.
%   Medical Image Analysis.
%**************************************************************************
%*

addpath wavelet
addpath noise_estimation
addpath function
addpath mex
addpath GUI

clc;
clear all;
close all;

fprintf('%s \n', 'Welcome to CANDLE software:')
fprintf('%s \n', 'A new Collaborative Approach for eNhanced Denoising under Low-light Excitation')
fprintf('%s \n\n', 'Copyright (C) 2010 Pierrick Coupe')

fprintf('%s \n\n', 'This filter is dedicated to multiphoton microscopy image filtering')

fprintf('%s \n\n', 'Details on the method can be found in:')
fprintf('\t %s\n', 'P. Coupe, M. Munz, J. V. Manjon, E. Ruthazer, D. L. Collins.')
fprintf('\t %s\n', 'A CANDLE for a deeper in-vivo insight')
fprintf('\t %s\n\n\n\n', 'Medical Image Analysis')


[namein, pathin, filterindex] = uigetfile({  '*.tif','TIFF image (*.tif)'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');
if isequal(namein,0) | isequal(pathin,0)
    disp('User pressed cancel')
else
    
    
    [flag beta patchradius searchradius suffix background] = gui;
    
    
    
    fprintf('%s\n\n', 'Selected parameters')
    com = sprintf('beta: %0.3f', beta);
    disp(com)
    com = sprintf('patch size: %dx%dx%d voxels', 2*patchradius+1, 2*patchradius+1, 2*patchradius+1);
    disp(com)
    com = sprintf('search volume size: %dx%dx%d voxels', 2*searchradius+1, 2*searchradius+1, 2*searchradius+1);
    disp(com)
    if (background==1)
        com = sprintf('Fast processing of the background\n');
        disp(com)
    else
        com = sprintf('Accurate processing of the whole image\n');
        disp(com)
    end
    
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
            nout=[name_s suffix ext];
            pathout = pathin;
            
            disp(['Output file: ', fullfile(pathout, nout)])
            
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
            
            fact = 64-searchradius;
            
            substack = ceil(dim/fact);
            
            if (substack==2)
                fact=fact*2;
                substack=1;
            end
            
            if (substack==1)
                fact=dim;
            end
            
            
           
            for ind=1 : substack
                
                % To avoid out of memory the stack is processed by substacks of 64 images
                s_init = 1 + (ind-1)*fact; % beguinning of the substack
                s_end =  ind*fact; % end of the substack
                
                
                % Limits of the substack
                if (s_end>dim) s_end = dim; end
                if (s_end-s_init<12) s_init = s_end-12; end
                if (s_init<1) s_init = 1; end
                
                % Padding between substacks
                if ((s_init-searchradius)<=1)
                    pad_init = 0;
                else
                    pad_init = searchradius;
                end
                
                if((s_end+searchradius)>dim)
                    pad_end = 0;
                else
                    pad_end = searchradius;
                end
                
                
            
                com = sprintf('Processing of the slices: %d to %d', s_init,s_end);
                disp(com)
                
                % Subimg to denoise
                img = single(imgIn(:,:,s_init-pad_init:s_end+pad_end));
                
                
                com = sprintf('\n\t Preprocessing: 3D Median filter');
                disp(com)
                tic
                fimgMed = median3D(img,1);
                t = toc;
                com = sprintf('\t Elapsed time: %0.1f s', t);
                disp(com)
                
                % Background detection
                if (background==1)
                    mini = min(fimgMed(:));
                    maxi = max(fimgMed(:));
                    average_val = mean(fimgMed(:));
                    delta = (maxi-mini)/10000;
                    k=3;
                    N=k^3;
                    ConvMed=(convn(fimgMed,ones(k,k,k),'same')/N);
                    bins = double(mini):delta:double(maxi);
                    [nb,histb] = histc(ConvMed(:),bins);
                    [val loc] = max(nb);
                    Threshold = bins(loc);
                    smask = size(fimgMed);
                    mask = ones(smask);
                    map = find(ConvMed<(Threshold+5*delta));
                    mask(map) = 0;
                else
                    smask = size(fimgMed);
                    mask = ones(smask);
                end
                
               
                
                % Anscombe transform to convert Poisson noise into Gaussian noise
                img = 2 * sqrt(img + (3/8));
                fimgMed = 2 * sqrt(fimgMed + (3/8));
                
                % Estimation of std for Gaussian noise
                com = sprintf('\n\t Noise estimation: Wavelet-based local estimation');
                disp(com)
                tic
                [MAP,h] = GaussianSTD_MAP(img,2*searchradius);
                t = toc;
                com = sprintf('\t Elapsed time: %0.1f s', t);
                disp(com)
                
             
                 
                % Denoising
                com = sprintf('\n\t Denoising: 3D Optimized Nonlocal means filter');
                disp(com)
                tic
                fimg=adapt_onlm_collaborative(single(img),searchradius, patchradius,single(MAP),beta,single(fimgMed),single(mask));
                t = toc;
                com = sprintf('\t Elapsed time: %0.1f s \n', t);
                disp(com)
                
        
                
                % Optimal Inverse Anscombe Transform
                fimg = OVST(fimg);
                img =  OVST(img);
                fimgMed = OVST(fimgMed);
                
             
                % Convertion  
                % Since I do not want libTIFF dependencies (version issues, OS issues...), I cannot write in 24bit.
                % So I decided to write the output image in 16bit.   
                imgOut(:,:,s_init:s_end) = uint16(fimg(:,:,pad_init+1:end-pad_end));
               
                  
                
                % Substack Display
                slice = floor((s_end-s_init)/2);
                mini = min(imgOut(:));
                maxi = max(imgOut(:));
                subplot(1,2,1)
                imagesc(img(:,:,slice)); colormap('bone');
                axis image
                axis off
                title('Input image');
                subplot(1,2,2)
                imagesc(fimg(:,:,slice),[mini maxi-0.1*maxi]); colormap('bone');
                axis image
                axis off
                title('Denoised with CANDLE');
                drawnow;
                
            end
            
            % Display
            mini = min(imgOut(:));
            maxi = max(imgOut(:));
            MIPnoisy = max(imgIn, [], 3);
            MIPdenoised = max(imgOut, [], 3);
            figure;
            subplot(1,2,1)
            imagesc(MIPnoisy); colormap('bone');
            axis image
            axis off
            title('MIP of Input image');
            subplot(1,2,2)
            imagesc(MIPdenoised,[mini maxi-0.1*maxi]); colormap('bone');
            axis image
            axis off
            title('MIP of Denoised image');
            
            imwrite(imgOut(:,:,1),[pathout nout],'Compression','none');
            for k = 2:dim
                imwrite(imgOut(:,:,k),[pathout nout],'Compression','none','writemode', 'append');
            end
            
        end
    end
end
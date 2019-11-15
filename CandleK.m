function imgOut = CandleK(imgIn, pathname, namein)    
    pwdir = pwd;
    cdir = [pwdir filesep 'CANDLEpackage_r01.02'];
    cd(cdir);        

    %----- Initiate Parameters -----%    
    addpath wavelet
    addpath noise_estimation
    addpath function
    addpath mex
    addpath GUI
    flag = 1;
    beta = 0.8;
    patchradius = 1;
    searchradius = 3;
    suffix = '_denoised';
    background = 1;
    pathout = pathname;
    nbfile = 1;        

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

    %----- Run Candle -----%
    s=size(imgIn);
    fact = 64-searchradius;   
    dim = size(imgIn,3);
    substack = ceil(dim/fact);
    filenamein = namein;        
    if (substack==2); fact=fact*2; substack=1; end
    if (substack==1); fact=dim; end

    for ind = 1:substack

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
            cd([cdir filesep 'mex']);
            tic
            fimgMed = median3D(img,1);
            t = toc;
            cd(cdir)
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
            Display = 'No';
            switch Display
                case 'Yes'
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
                otherwise
            end                                        
    end
    switch Display
            case 'Yes'
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
        otherwise
    end    
    rmpath wavelet
    rmpath noise_estimation
    rmpath function
    rmpath mex
    rmpath GUI
    cd(pwdir);
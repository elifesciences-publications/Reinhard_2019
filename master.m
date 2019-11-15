% This is a master script for calling fuctions to turn raw lsm confocal
% images into arbor density quantifications.

%% Initate Parameters
clear; clc

    %---------- Define where code and data is ----------%
        
        %----- Data -----%
        datapath = 'Z:\\LabCode\\Anatomy\\matlab_v2\\TestData';
    
        %----- Code -----%
        codepath = 'Z:\\LabCode\\Anatomy\\matlab_v2';
        addpath(codepath);
        
            %--- lsm2tiff ---%
            addpath Z:\\LabCode\\Anatomy\\lsm\\lsm
            addpath Z:\\LabCode\\Anatomy\\lsm\\cstruct
            
            %---
    
    %---------- Define options for conversion and analysis ----------%
    
        %----- lsm2tiff -----%
        options.BigFile = 0; % If file is "too big" need to adjust loading data
        options.doCandle = 'Yes'; % Denoising.;
        options.Flip = 'Yes';
        options.Deconvolve = 'NO';
        options.Filter = 'Yes';
        options.Downsample = 'Yes';
    
        
        
%% Create list of files to analyze
current_directory = pwd;
cd(datapath);
if options.BigFile
    pathname = uigetdir(datapath,'Raw Confocal Stack');
    nfiles = 1;
    fileList = dir(fullfile(pathname,'*tif'));
    filename = fileList(1).name;
    ext = '.tif';
    tmp = regexp(filename,'_');
    filename = filename(1:tmp(end)-1);
else    
    extlist = {'.lsm'; '.nd'; '.tif'};
    [filename, pathname, ext] = uigetfile({'*.lsm'; '*.nd'; '*.tif'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');    
    ext = extlist{ext};
    if iscell(filename)
        nfiles = length(filename);
    else
        nfiles = 1;
    end
end
cd(current_directory);

%% Get information from lsm files and convert to mat files
for i = 1:nfiles 
    disp(['Processing file ' num2str(i) ' of ' num2str(nfiles) ' files.'])
    %---------- Get Stack ----------%
    if nfiles == 1
        fname = filename;
    else        
        fname = filename{i};
    end
    tic
    [VoxelSize{i}, resolution, Channels, nchannels, GFP, chAT, DAPI, TD, YFP, namein, nameout, options.ds{i}] = getstack(pathname, fname, ext, options.BigFile);              
    lt = toc;
%     save(fullfile('/media/areca_raid/LabPapers/SCRouter/Data/singleRGCs',[fname(1:end-4),'_res']),'resolution')
    disp([     'Image Stack Loaded in ' num2str(lt) ' seconds.']);

    %---------- CANDLE Noise Reduction ----------%
    switch options.doCandle
        case 'Yes'            
            for ch = 1:nchannels
                disp(['Denoising ' Channels{ch} ' using Candle.']);
                eval([Channels{ch} ' = CandleK(' Channels{ch} ', pathname, namein);']);
            end
            disp('Denoising complete.'); 
    end
    
    %--------------- DownSample ----------------%
    switch options.Downsample
    case 'Yes'
        method = 'bicubic';
        for ch = 1:nchannels
            disp(['Downsampling ' Channels{ch} '.']);
            eval(['imgIn = ' Channels{ch} ';']);
            for z = 1:nz
                if z == 1
                    eval([Channels{ch} ' = uint16(zeros(ceil(ny/options.ds), ceil(nx/options.ds), nz));']);
                end
                eval([Channels{ch} '(:,:,z) = imresize(imgIn(:,:,z), 1/options.ds, method);']);
            end
            eval(['size(' Channels{ch} ')'])
        end
    end
    disp('Downsampling complete.');
    
    %---------- Flip ----------%
    switch options.Flip
        case 'Yes'
            for ch = 1:nchannels
                disp(['Flipping ' Channels{ch} '.']);
                eval(['imgIn = ' Channels{ch} ';']);
                for z = 1:nz
                    eval([Channels{ch} '(:,:,z) = imgIn(:,:,nz + 1 - z);']);
                end
                clear imgIN
            end
        otherwise
    end
    
    
    %---------- Filter -----------%
    switch options.Filter
        case 'Yes'
            for ch = 1:nchannels
                disp(['Filtering ' Channels{ch} '.']);
                eval(['imgIn = ' Channels{ch} ';']);
                %eval([Channels{ch} ' = medfilt3(' Channels{ch} ');'])
                for z = 1:nz
                    switch Channels{ch}
                        case 'chAT'
                            eval([Channels{ch} '_STD(:,:,z) = movingstd2(imgIn(:,:,z),10);'])
                        otherwise
                    end
                end
                clear imgIN
            end
        otherwise
    end
    disp('Fitlering complete.');
    
    %----------- Save Imageing ------------%
    for ch = 1:nchannels
        disp(['Saving ' Channels{ch} '.']);
        savename = [savepathname filesep nameout '_' Channels{ch} '.tif'];
        soptions.compression = 'none';
        soptions.overwrite = 'true';
        switch Channels{ch}
            case 'chAT'
                eval(['saveastiff(uint16(' Channels{ch} '), savename, soptions);']);
                switch options.Filter
                    case 'Yes'
                        savename = [savepathname filesep nameout '_' Channels{ch} '_STD.tif'];
                        eval(['saveastiff(uint16(' Channels{ch} '_STD), savename, soptions);']);
                    otherwise
                end
            otherwise
                eval(['saveastiff(uint16(' Channels{ch} '), savename, soptions);']);
        end
    end
    disp('Saving complete.');
    disp('LSM Conversion complete.');

end


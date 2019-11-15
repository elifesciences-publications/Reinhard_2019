function ConvertLSMSumbul(stackname, Channels, handles, options, ds)
%[pathname filename],Channels{n},options, options.ds{n}
% Input needs to be a lsm filename + options of what you want to do.
%-------------------- Initiate --------------------%
clc
hdir = pwd;
addpath(genpath(handles.path2script))
if ~isempty(regexp(stackname,'.lsm')) || ~isempty(regexp(stackname,'.tif'))
    [pathname, filename, ext] = fileparts(stackname);
    nchannels = length(Channels);
    options.ds = ds;
else
    pathname = stackname;
    fileList = dir(fullfile(pathname,'*tif'));
    filename = fileList(1).name;
    ext = '.tif';
    tmp = regexp(filename,'_');
    filename = filename(1:tmp(end)-1);
    nchannels = length(Channels);
    options.ds = ds;
end
clear allFiles

datapath = handles.datapath;
rawpath = handles.rawpath;

%----- Get Options -----%
if nargin < 4
    options.doCandle = 'Yes';
    options.Flip = 'Yes';
    options.Deconvolve = 'Yes';
    options.Filter = 'Yes';
    options.Downsample = 'Yes';
    options.ds = 2;
end

addpath(genpath(handles.path2script))

cd(rawpath)
if regexp(ext,'lsm')
    %-------------------- Load LSM File --------------------%
    disp('Loading LSM Stacks ...')
    if isempty(stackname)
        [pathname, filename, ext] = uigetfile({  '*.lsm','Raw Confocal Stack'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');
    end
    if regexp(options.Deconvolve, 'Yes')
        savepathname = fullfile(datapath, '_deconv');
    else
        savepathname = datapath;
    end
    
    II = lsminfo([pathname filesep filename ext]);
    VoxelSize = [II.VoxelSizeX, II.VoxelSizeY, II.VoxelSizeZ];
    stack = tiffread([pathname filesep filename ext]);
    namein = [filename ext];
    nameout = filename;
else
    %-------------------- Load Tif File --------------------%
    disp('Loading single TIF files ...')
    clear allFiles
    numberOfFiles = length(fileList);
    for l = 1:length(fileList)
        currentFile = [filename '_Z' int2str(l-1) '.tif'];
        stack = tiffread([pathname filesep currentFile]);
        allFiles(l) = stack(1);
        allFiles(l).data = cell(2,1);
        allFiles(l).data{1} = stack(1).data;
        allFiles(l).data{2} = stack(2).data;
    end
    stack = allFiles;
    
    tmp = regexp(pathname,'/');
    rawpathname  = pathname(1:tmp(end)-1);
    II = lsminfo([rawpathname filesep filename '.lsm']);
    VoxelSize = [II.VoxelSizeX, II.VoxelSizeY, II.VoxelSizeZ];
    namein = [filename ext];
    nameout = filename;
    
    if regexp(options.Deconvolve, 'Yes')
        savepathname = fullfile(datapath, '_deconv');
    else
        savepathname = datapath;
    end
end

%----- Create Individual Stacks -----%
nx = stack(1).width;
ny = stack(1).height;
nz = length(stack);
for ch = 1:nchannels
    for z = 1:nz
        if z == 1
            switch stack(z).bits
                case 8
                    eval([Channels{ch} ' = uint8(zeros(ny,nx,nz));']);
                case 16
                    eval([Channels{ch} ' = uint16(zeros(ny,nx,nz));']);
                otherwise
                    eval([Channels{ch} ' = double(zeros(ny,nx,nz));']);
            end
        end
        if nchannels == 1
            eval([Channels{ch} '(:,:,z) = stack(z).data;']);
        else
            eval([Channels{ch} '(:,:,z) = stack(z).data{ch};']);
        end
    end
end
disp('Loading complete.');

cd(handles.path2script)
%-------------------- Candle --------------------%
% DOI: 10.106/j.media.2012.01.002
switch options.doCandle
    case 'Yes'
        for ch = 1:nchannels
            disp(['Denoising ' Channels{ch} ' using Candle.']);
            Display = 'No';
            eval([Channels{ch} ' = CandleK(' Channels{ch} ', pathname, namein);']);
        end
    otherwise
end
disp('Denoising complete.');


%-------------------- Deconvolve --------------------%
switch options.Deconvolve
    case 'Yes'
        %----- Get PSF -----%
        psf = tiffread('PSF_chAT.tif');
        iPSF = zeros(psf(1).width,psf(1).height,length(psf));
        for z = 1:length(psf); iPSF(:,:,z) = psf(z).data; end
        
        %----- Do Deconvolution -----%
        for ch = 1:nchannels
            disp(['Denconvolving ' Channels{ch} '.']);
            switch Channels{ch}
                case {'DAPI', 'GFP'}
                    eval([ Channels{ch} ' = edgetaper(' Channels{ch} ', iPSF);']);
                    eval([ '[' Channels{ch} ', nPSF] = deconvblind(' Channels{ch} ', iPSF, 25);']);
                case 'chAT'
                    if exist('nPSF', 'var')
                        eval([Channels{ch} ' = deconvlucy(' Channels{ch} ', nPSF, 25);']);
                    else
                        eval([ '[' Channels{ch} ', PSF] = deconvblind(' Channels{ch} ', iPSF, 25);']);
                    end
                otherwise
                    eval([ '[' Channels{ch} ', PSF] = deconvblind(' Channels{ch} ', iPSF, 25);']);
            end
            
        end
    otherwise
end
disp('Deconvolution complete.');


%--------------- DownSample ----------------%
% See Sumbul et al., 2014a and 2014b
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


%--------------- Flip ---------------%
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
disp('Flipping complete.');


%-------------------- Filter ---------------------%
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


%--------------------- Save Imageing ----------------------%
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







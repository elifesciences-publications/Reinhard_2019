
% % Get Files and Set Parameters
bigFiles = 0;

codepath = '/media/areca_raid/LabCode/Anatomy';
cd('/media/areca_raid/LabPapers/SCRouter/Data')
if bigFiles == 1
    pathname = uigetdir('/media/areca_raid/LabPapers/SCRouter/Data','Raw Confocal Stack');
    nfiles = 1;
    fileList = dir(fullfile(pathname,'*tif'));
    filename = fileList(1).name;
    ext = '.tif';
    tmp = regexp(filename,'_');
    filename = filename(1:tmp(end)-1);
else
    [filename, pathname, ext] = uigetfile({  '*.lsm','Raw Confocal Stack'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');
    if iscell(filename)
        nfiles = length(filename);
    else
        nfiles = 1;
    end
end

options.doCandle = 'Yes'; % Denoising.;
options.Flip = 'Yes';
options.Deconvolve = 'NO';
options.Filter = 'Yes';
options.Downsample = 'Yes';

addpath /media/areca_raid/LabCode/Anatomy/lsm/lsm
addpath /media/areca_raid/LabCode/Anatomy/lsm/cstruct


fileList = 1:nfiles;

ncnt = 0;
for n = fileList
    ncnt = ncnt+1;
    if nfiles == 1
        if bigFiles == 1
            tmp = regexp(pathname,'/');
            rawpathname  = pathname(1:tmp(end)-1);
            II = lsminfo([rawpathname filesep filename '.lsm']);
        else
            II = lsminfo([pathname filename]);
        end
        fname = filename;
    else
        II = lsminfo([pathname filename{n}]);
        fname = filename{n};
    end
    VoxelSize{ncnt} = [II.VoxelSizeX, II.VoxelSizeY, II.VoxelSizeZ] * 1000000;
    options.ds{ncnt} = .5/VoxelSize{ncnt}(1); % Make final image pixel size = 0.5 um.
    switch II.ChannelColors.NumberColors
        case 2
            Channels{ncnt} = {'GFP', 'chAT'};
        case 3
            Channels{ncnt} = {'GFP', 'td','chAT'};
        case 4
            Channels{ncnt} = {'DAPI', 'GFP', 'YFP', 'chAT'}; % Roska Lab Images
            
        otherwise
    end
    sizeX = (II.VoxelSizeX*1000000);
    sizeY= (II.VoxelSizeY*1000000);
    sizeZ = (II.VoxelSizeZ*1000000);
    resolution = [0.5 0.5 sizeZ];
    fname = fname(1:end-4);
    save(fullfile('/media/areca_raid/LabPapers/SCRouter/Data/singleRGCs',[fname,'_res']),'resolution')
end

%% Run Function
cd(codepath)
ncnt = 0;
for n = fileList
    ncnt = ncnt+1;
    if nfiles == 1
        if bigFiles == 1
            disp(['Converting ' filename '. Please wait ...'])
            ConvertLSMSumbul_KR(pathname,Channels{n},options, options.ds{n});
        else
            disp(['Converting ' filename '. Please wait ...'])
            ConvertLSMSumbul_KR([pathname filename],Channels{n},options, options.ds{n});
        end
    else
        disp(['Converting ' filename{n} '. Please wait ...'])
        ConvertLSMSumbul_KR([pathname filename{n}],Channels{n},options, options.ds{n});
    end
end

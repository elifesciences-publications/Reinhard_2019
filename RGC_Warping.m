function RGC_Warping(nfiles,namein, filename, listAnnotated, savepath, cpath2,datapath)
% WarpVolume (cluster or downstairs) => stage 4
for ff = 1:nfiles
    if nfiles>1
        fname = filename{ff};
        tmp = regexp(fname,'_');
        namein = fname(1:tmp(length(tmp)-1)-1);
    else
        fname = filename{1};
        tmp = regexp(fname,'_');
        if length(tmp) == 5
        namein = [fname(1:tmp(4)-1)];
        else
                namein = [fname(1:tmp(3)-1)];    
        end
    end
    disp(['warping cell ',namein])
    clear volNew
    load(fullfile(savepath,[namein,'_thr']))
    
    exl = 0;
    ee = 0;
    while ee<length(listAnnotated) && exl == 0
        ee = ee+1;
        if ~isempty(regexp(listAnnotated{ee},[namein '_OFF.xls']))
            exl = 1;
        end
    end
    if exl == 0
        OnSACFilename = fullfile(datapath, [namein '_ON.mat']);
        OffSACFilename = fullfile(datapath, [namein '_OFF.mat']);
    else
        OnSACFilename = fullfile(datapath, [namein '_ON.xls']);
        OffSACFilename = fullfile(datapath, [namein '_OFF.xls']);
    end
    
    
    tic
    cd(cpath2)
    [voxels,sMap] = rgcAnalyzer_modified(volNew,OnSACFilename,OffSACFilename,resolution,2);
    save(fullfile(savepath,[namein,'_warped']),'voxels','sMap','resolution','datatype')
    toc
end
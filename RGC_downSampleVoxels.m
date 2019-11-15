function RGC_downSampleVoxels(apath,doall)

% Downsample Script
N1 = 10;
N2 = 50;
radiusXY = 5;
radiusZ = .1;
method = 'SmoothTree';
t = 0;
%% Intiate
dList = dir(fullfile(apath,'*_zDist.mat'));

for i =1:length(dList)
    clear kvoxels25
    tst = load(fullfile(apath,dList(i).name), 'kvoxels25');
    
    if doall == 1
        go = 1;
    else
        if isfield(tst,'kvoxels25')
            go = 0;
        else
            go = 1;
        end
    end
    
    if go == 1
        disp(int2str(i))
        %% Load Downsample and Save kvoxels10
        
        
        
        %     clear kvoxels kvoxel05 kvoxels10 kvoxel25 kvoxels50 kvoxels100
        %----- Load -----%
        clear kvoxels
        load(fullfile(apath, dList(i).name), 'kvoxels');
        
        %----- DownSample -----%
        if exist('kvoxels','var')
            switch method
                case 'SmoothTree'
                    kvoxels25 = smoothtreeZ(kvoxels, N1, N2, radiusXY, radiusZ);
            end
        else
            continue
        end
        
        %----- Save -----%
        save(fullfile(apath, dList(i).name), 'kvoxels25', '-append');
        
    end
end

end

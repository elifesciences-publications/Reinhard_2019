function RGC_LoadParse(cpath2,nfiles,filename,suffix,savepath,namein,datapath)

% Load and Parse tiff Stacks (cluster or downstairs) => stage 1
cd(cpath2)
for ff = 1:nfiles
    if nfiles>1
        fname = filename{ff};
        tmp = regexp(fname,'_');
        namein = fname(1:tmp(3)-1);
    end
    disp(['Loading image stack for cell ',namein]);
    stack.gfp = tiffread(fullfile(datapath,[ namein suffix]));
    
    width = stack(1).gfp.width;
    height = stack(1).gfp.height;
    depth = length(stack.gfp);
    
    %----- Get GFP and CHaT -----%
    GFP = zeros(height,width,depth);
    for z = 1:depth
        GFP(:,:,z) = stack.gfp(z).data;
    end
    save(fullfile(savepath,[namein,'_GFP']),'GFP')
end

end
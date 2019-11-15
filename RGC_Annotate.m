function RGC_Annotate(filename,namein,nfiles,datapath)

files = struct;
for ff = 1:nfiles
    if nfiles>1
        fname = filename{ff};
        tmp = regexp(fname,'_');
        namein = [fname(1:tmp(end-1)-1)];
        files(ff).name = [namein,'_chAT_STD.tif'];
    else
         fname = filename{1,1};
        tmp = regexp(fname,'_');
        namein = [fname(1:tmp(end-1)-1)];
        files(1).name = [namein,'_chAT_STD.tif'];
    end
end
rgc_annotation(files,datapath)



end
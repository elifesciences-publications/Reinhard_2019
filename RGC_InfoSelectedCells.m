function [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlist,listOfCells,datapath)


cd(datapath)

    filename = listOfCells(IDlist,1);

if size(filename,1)>1
    nfiles = length(filename);
    namein = [];
else
    nfiles = 1;
    if iscell(filename)
        fname = filename{1};
    else
        fname = filename;
    end
    tmp = regexp(fname,'_');
    namein = fname(1:tmp(3)-1);
end

end
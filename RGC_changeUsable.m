function RGC_changeUsable(datapath,number,use)


load(fullfile(datapath,'usable'))
usable{1,2}(number) = use;
save(fullfile(datapath,'usable'),'usable')

end
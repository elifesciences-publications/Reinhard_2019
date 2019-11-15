function RGC_missingCoord(handles)

cpath = handles.path2script;
datapath = handles.datapath;
cd(cpath)
homepath = regexp(datapath,filesep);
homepath = datapath(1:homepath(end)-1);


% ==== load excel ====
load(fullfile(handles.xlsFile,'RGC_coord'));
load(fullfile(handles.xlsFile,'RGC_expInfo'));
load(fullfile(homepath,'database','database'))

exp = database.experiment;
mouse = database.mouse;
retina = database.retina;
scan = database.scan;

data2check = database.patched;
missing = find(isnan(data2check));

for m = 1:length(missing)
    dexp = exp(missing(m));
    dmouse = mouse(missing(m));
    dretina = retia(missing(m));
    dscan = scan(missing(m));
    
    found = 0; w = 1;
    while found == 0 && w<size(raw2,1)
        cexp = raw2{w,1};
        cmouse = raw2{w,2};
        cretina = raw2{w,3};
        cscan = raw2{w,4};
        
        if ~isempty(regexp(dexp,cexp))
            if dmouse == cmouse
                if dretina == cretina
                    if dscan == cscan
                        found = 1;
                    end
                end
            end
        end
    end
    
    if found == 1
        database(missing(m)).patched = raw{w,7};
        database(missing(m)).xCoord = raw{w,5};
        database(missing(m)).yCoord = raw{w,6};
        database(missing(m)).imaged = raw{w,8};
        database(missing(m)).SMI32 = raw{w,9};
        database(missing(m)).CART = raw{w,10};
        database(missing(m)).FOXP2 = raw{w,11};
        database(missing(m)).notes1 = raw{w,12};
        database(missing(m)).notes2 = raw{w,13};
    end
    
end

save(fullfile(homepath,'database'),'database')


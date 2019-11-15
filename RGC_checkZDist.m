function RGC_checkZDist(handles)

savepath = handles.datapath;
pixBetweenChats = handles.pixBetweenChats;
listNoSoma = dir(fullfile(savepath,'*_nosoma.mat'));
listZDist= dir(fullfile(savepath,'*_zDist.mat'));

for ff = 1:length(listNoSoma)
    fname = listNoSoma(ff).name;
    tmp = regexp(fname,'_');
    if length(tmp)==4
        namein = fname(1:tmp(3)-1);
    else
        namein = fname(1:tmp(4)-1);
    end
    
    
    nameins = cell(1,1);
    cnt = 0;
    for m = 1:length(listNoSoma)
        if ~isempty(regexp(listNoSoma(m).name,namein))
            cnt = cnt+1;
            nameins{cnt} = listNoSoma(m).name;
        end
    end
    
    nameins2 = cell(1,1);
    cnt = 0;
    for m = 1:length(listZDist)
        if ~isempty(regexp(listZDist(m).name,namein))
            cnt = cnt+1;
            nameins2{cnt} = listZDist(m).name;
        end
    end
    
    if isempty(nameins2{1,1}) || length(nameins) ~= length(nameins2)
        
        for nn = 1:length(nameins)
            
            if isempty(nameins2{1,1})
                found = 0;
            else
            found = 0;
            for m = 1:length(nameins2)
                if ~isempty(regexp(nameins{nn}(1:15),nameins2{m}(1:15)))
                    found = 1;
                end
            end
            end
            
            if found == 0
                clear voxels zDist
                load(fullfile(savepath,nameins{nn}))
                densities = voxels.density;
                vox = voxels.nodes;
                medVzmin = voxels.medVZmin; %in pixel
                medVzmax = voxels.medVZmax; %in pixel
                
                allZpos = (vox(:,3) - medVzmin)/(medVzmax - medVzmin); %0=ON-band, 1=OFF-band
                ids=find(allZpos>=-4); ids2 = find(allZpos<=4); ids = unique([ids;ids2]);
                allZpos = allZpos(ids);
                mmin = min(allZpos); mmax = max(allZpos); absmax=ceil(max(abs(mmin),mmax));
                zExt=8; %find the constant by which to devide allZpos to have values between -0.5 and 0.5
                allZpos = allZpos/zExt; %values need to be between -0.5 and 0.5
                gridPointCount = zExt*pixBetweenChats+1;
                
                zDist = gridder1d(allZpos,densities(ids),gridPointCount);%density is the same as weights
                %     zDist = sqrt(sum(densities))*zDist/sqrt(zDist(:)'*zDist(:)); %from original rgcAnalyzer
                
                bins =[-zExt/2:zExt/gridPointCount:zExt/2-zExt/gridPointCount];
                if ~exist('datatype','var')
                    datatype = 1;
                end
                if ~exist('Asoma','var')
                    Asoma = NaN;
                end
                save(fullfile(savepath,[nameins{nn}(1:15),'_zDist']),'bins','zDist','voxels','zExt','resolution','somaCoord','datatype','Asoma')
                disp(['saved as ', [nameins{nn}(1:15),'_zDist']])
            end
        end
    end
end
str = get(handles.logbox,'String');
if ~iscell(str)
    str = {str};
end
strnew = [str;'zDist checked'];
set(handles.logbox,'String',strnew)
end

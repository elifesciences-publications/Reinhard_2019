function RGC_Parameters(cpath,datapath,filename,savepath,~,nfiles,pixBetweenChats,handles)

% calculate different morphology parameters PART 2 (local, only 1 cell)
%==========peak(s) in z-distribution and relative soma position===========

mylist = {'areaHull','cellNumber','experiment','injectedHemisphere1',...
    'injectedHemisphere2','mouse','nasalAngle','nasalPositionCheck',...
    'patched','datatype','bistratType','retina','scan',...
    'xCoord','yCoord','zpeak1','zpeak2','type','usable','injectedTarget',...
    'conditional','mouseLine','imaged','SMI32','CART','FOXP2','notes1','notes2'};

cd(cpath)
homepath = regexp(datapath,filesep);
homepath = datapath(1:homepath(end)-1);
%listArborThere = dir(fullfile(datapath,'dendriticArbors','*zDist.mat'));


% ==== load excel ====
load(fullfile(handles.xlsFile,'RGC_expInfo'));
load(fullfile(handles.xlsFile,'RGC_coord'));
try
    load(fullfile(homepath,'database','database'))
    currNumberOfCells = size(database,1);
catch
    database = struct;
    for m = 1:length(mylist)
        eval(['database.' mylist{m} '= [];'])
    end
    currNumberOfCells = 0;
    
end
%===================


for ff = 1:nfiles
    listArborThere = dir(fullfile(homepath,'dendriticArbors',['00','*','zDist.mat']));
    try
        load(fullfile(homepath,'database','database'))
        currNumberOfCells = size(database,2);
    end
    %     if nfiles>1
    fname = filename{ff};
    tmp = regexp(fname,'_');
    if length(tmp)==4
        namein = fname(1:tmp(3)-1);
    else
        namein = fname(1:tmp(4)-1);
    end
    %     end
    clear voxels vox id id2
    
    reply = input(['Do you want to analyse ',namein,'? y/n [y]: '], 's');
    if reply=='y'
        
        listNoSoma = dir(fullfile(savepath,'*_zDist.mat'));
        
        nameins = cell(1,1);
        cnt = 0;
        for m = 1:length(listNoSoma)
            if ~isempty(regexp(listNoSoma(m).name,namein))
                cnt = cnt+1;
                nameins{cnt} = listNoSoma(m).name;
            end
        end
        
        for nnn = 1:size(nameins,1)
            namein = nameins{nnn};
            load(fullfile(savepath,namein))
            vox=voxels.nodes; keepVox = vox;
            vox(:,1) = vox(:,1)*0.5; vox(:,2) = vox(:,2)*0.5; vox(:,3) = vox(:,3)*resolution(3);
            x=vox(:,1);y=vox(:,2);z=vox(:,3);%in um
            cd(cpath)
            
            %      densities = voxels.density;
            densities = ones(length(vox),1);
            medVzmin = voxels.medVZmin; %in pixel
            medVzmax = voxels.medVZmax; %in pixel
            allZpos = (keepVox(:,3) - medVzmin)/(medVzmax - medVzmin); %0=ON-band, 1=OFF-band
            ids=find(allZpos>=-4); ids2 = find(allZpos<=4); ids = unique([ids;ids2]);
            allZpos = allZpos(ids);
            mmin = min(allZpos); mmax = max(allZpos); absmax=ceil(max(abs(mmin),mmax));
            zExt=8; %find the constant by which to devide allZpos to have values between -0.5 and 0.5
            allZpos = allZpos/zExt; %values need to be between -0.5 and 0.5
            gridPointCount = zExt*pixBetweenChats+1; % This is just the resolution of the grid
            
            zDist = gridder1d(allZpos,densities(ids),gridPointCount);%density is the same as weights
            zDist = sqrt(sum(densities))*zDist/sqrt(zDist(:)'*zDist(:)); %from original rgcAnalyzer
            
            bins =[-zExt/2:zExt/gridPointCount:zExt/2-zExt/gridPointCount];
            
            toconsider = find(bins>-1.7);
            [peak b]=max(zDist(toconsider));
            id = b+toconsider(1)-1;
            zpeak = bins(id);
            zpeak2nd = NaN;
            if zpeak<0.7
                tmp = find(bins>zpeak+0.7);
                [peak2 b]=max(zDist(tmp));
                id2 = b+tmp(1)-1;
                if peak2>peak/10
                    if zDist(id2-1)<peak2 && zDist(id2+1)<peak2
                        zpeak2nd = bins(id2);
                    end
                end
                if isnan(zpeak2nd)
                    tmp = find(bins<zpeak-0.7);
                    [peak2 b]=max(zDist(tmp));
                    id2 = b+tmp(1)-1;
                    if peak2>peak/20 && bins(id2)>-1.7
                        if zDist(id2-1)<peak2 && zDist(id2+1)<peak2
                            zpeak2nd = bins(id2);
                        end
                    end
                end
            elseif zpeak>0.3
                tmp = find(bins<zpeak-0.7);
                [peak2 b]=max(zDist(tmp));
                id2 = b+tmp(1)-1;
                if peak2>peak/10 && bins(id2)>-1.7
                    if zDist(id2-1)<peak2 && zDist(id2+1)<peak2
                        zpeak2nd = bins(id2);
                    end
                end
            else
                id2 = [];
            end
            
            somaZpos = (somaCoord(3) - medVzmin)/(medVzmax - medVzmin);
            
            figure('units','normalize','position',[0.25 0.2 0.6 0.65])
            subplot(2,2,1)
            plot(bins,zDist)
            hold on
            plot([0 0],[0 max(zDist)],'-m')
            plot([1 1],[0 max(zDist)],'-m')
            
            subplot(2,2,2)
            plot(x,z,'.','color',[0.7 0.7 0.7])
            
            if ~isnan(zpeak2nd)
                subplot(2,2,1)
                title([namein,': stratification: ',num2str(zpeak),', ',num2str(zpeak2nd)],'fontsize',12,'interpreter','none')
                keepThePeak = input('Is the 2nd peak a real peak?','s');
                if isempty(keepThePeak)
                    zpeak2nd = NaN;
                    ptype = 0;
                elseif keepThePeak == 'n' || keepThePeak == '0'
                    zpeak2nd = NaN;
                    ptype = 0;
                else
                    isBistratified = input('Is it a "real" bistratified cell?','s');
                    if  isBistratified == 'y' || isBistratified == '1'
                        ptype = 1;
                    else
                        ptype = 0;
                    end  
                    %ptype = input('Is it a "real" bistratified cell?');
                end
            else
                ptype = 0;
            end
            
            subplot(2,2,1)
            if isnan(zpeak2nd)
                title([namein,': stratification: ',num2str(zpeak)],'fontsize',12,'interpreter','none')
                
            else
                title([namein,': stratification: ',num2str(zpeak),', ',num2str(zpeak2nd)],'fontsize',12,'interpreter','none')
            end
            
            %===========================================
            
            
            % the variable are in um/10
            xnew2 = round(x*10); ynew2 = round(y*10); znew2 = round(z*10);
            
            %  make again a 2d image out of it
            volBinary = zeros(max(max(xnew2),max(ynew2)),max(max(xnew2),max(ynew2)));
            linearInd = sub2ind([max(max(xnew2),max(ynew2)) max(max(xnew2),max(ynew2))], xnew2,ynew2);
            volBinary(linearInd) = 1;
            
            %=========fit convex hull and calculate area of it============
            stats = regionprops(flipud(rot90(volBinary)),'ConvexHull','ConvexArea','Centroid','MajorAxisLength','MinorAxisLength','Orientation');
            xconvex = stats.ConvexHull(:,1); yconvex = stats.ConvexHull(:,2);
            area = stats.ConvexArea/100; %number of pixels with each pixel being 1x1 um
            
            
            
            tmp = regexp(namein,'_');
            experimentNumber = namein(1:tmp(1)-1);
            retinaN = namein(tmp(1)+2:tmp(2)-1);
            mouseN = namein(tmp(1)+1:tmp(2)-2);
            cellN = str2num(namein(tmp(2)+2:tmp(2)+3));
            subN = str2num(namein(tmp(3)+1:tmp(4)-1));
            
            
            found = 0; w = 1;
            while found == 0 && w<size(raw,1)
                w = w+1;
                c_name = raw{w,1};
                tmp = regexp(c_name,'_');
                c_exp = c_name(2:tmp(1)-1);
                c_mouse = c_name(tmp(1)+1);
                c_retina = c_name(tmp(1)+2);
                
                if ~isempty(regexp(experimentNumber,c_exp))
                    if c_retina == retinaN
                        if c_mouse == mouseN
                            found = 1;
                        end
                    end
                end
            end
            
            found = 0; w2 = 1;
            while found == 0 && w<size(raw2,1)
                w2 = w2+1;
                c_exp = raw2{w2,1};
                c_mouse = raw2{w2,2};
                c_retina = raw2{w2,3};
                c_cell = raw2{w2,4};
                
                if str2num(experimentNumber)==c_exp
                    if c_retina == retinaN
                        if c_mouse == mouseN
                            if c_cell == cellN;
                                found = 1;
                            end
                        end
                    end
                end
            end
            
            Params{1} = area;
            Params{2} = subN;
            Params{3} = str2num(experimentNumber);
            Params{4} = raw{w,3};
            Params{5} = raw{w,4};
            Params{6} = mouseN;
            Params{7} = raw{w,6};
            Params{8} = raw{w,5};
            if found == 1
                Params{9} = raw2{w2,7};
                Params{14} = raw2{w2,5};
                Params{15} = raw2{w2,6};
                Params{23} = raw2{w2,8};
                Params{24} = raw2{w2,9};
                Params{25} = raw2{w2,10};
                Params{26} = raw2{w2,11};
                Params{27} = raw2{w2,12};
                Params{28} = raw2{w2,13};
            else
                Params{9} = nan;
                Params{14} = nan;
                Params{15} = nan;
                Params{23} = nan;
                Params{24} = nan;
                Params{25} = nan;
                Params{26} = nan;
                Params{27} = nan;
                Params{28} = nan;
            end
            if exist('datatype','var')
                Params{10} = datatype;
            else
                Params{10} = 1;
            end
            if ~isnan(zpeak2nd)
                Params{11} = 1;
            else
                Params{11} = 0;
            end
            Params{12} = retinaN;
            Params{13} = cellN;
            Params{16} = zpeak;
            Params{17} = zpeak2nd;
            Params{18} = raw{w,2};
            Params{19} = nan;
            if size(raw,2)<7 || isempty(raw{w,9})
                if Params{18} == 1 || Params{18} == 5
                    Params{20} = 'Pbg';
                elseif Params{18} == 2 || Params{18} == 3
                    Params{20} = 'LP';
                elseif Params{18} == 4
                    Params{20} = 'LGN';
                else
                    Params{20} = 'nan';
                end
            else
                Params{20} = raw{w,9};
            end
            if size(raw,2)<7 || isempty(raw{w,7})
                if Params{18} == 1 || Params{18} == 2
                    Params{21} = 0;
                else
                    Params{21} = 1;
                end
            else
                Params{21} = raw{w,7};
            end
            if size(raw,2)<7 || isempty(raw{w,8})
                if Params{18} == 1
                    Params{22} = 'PV';
                elseif Params{18} == 2 || Params{18} == 3
                    Params{22} = 'Ntsr';
                elseif Params{18} == 4 || Params{18} == 5
                    Params{22} = 'Gad2';
                else
                    Params{22} = 'nan';
                end
            else
                Params{22} = raw{w,8};
            end
            
            thiscell = currNumberOfCells+1;
            for v = 1:length(mylist)
                name = mylist{v};
                current = Params{v};
                eval(['database(thiscell).' name '= current'])
            end
            
            
            clc
            disp(['current cell: ',namein ])
            
            % ---------------- write to excel and .mat variables---------------
            
            cd(datapath)
            tmp=regexp(namein,'_');
            namenow = namein(1:tmp(end)-1);
            oldName2 = [namenow,'_zDist.mat'];
            
            thiscell2 = size(listArborThere,1)+1;
            
            found = 0; m = 0;
            while found == 0 && m <size(listArborThere,1)
                m = m+1;
                curr = listArborThere(m).name;
                if regexp(curr,namein)
                    found = 1;
                end
            end
            
            if found == 0
                %numberOfThisCell = ['000',int2str(thiscell2)];
                numberOfThisCell = ['000',int2str(thiscell2)];
                numberOfThisCell = numberOfThisCell(end-3:end);
                newName2 = [numberOfThisCell,'_',oldName2];
            else
                newName2 = listArborThere(m).name;
            end
            
            copyfile(oldName2,fullfile(homepath,'dendriticArbors',newName2))
            close
        end
        
    end
    save(fullfile(homepath,'database','database.mat'),'database')
end

end
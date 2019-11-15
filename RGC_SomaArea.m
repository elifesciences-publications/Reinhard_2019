function RGC_SomaArea(cpath,nfiles,filename,namein,savepath,pixBetweenChats,handles)

clc
rawpath = handles.rawpath;
datapath = handles.datapath;
homepath = regexp(datapath,filesep);
homepath = datapath(1:homepath(end)-1);
cd(cpath)
for ff = 1:nfiles
    if nfiles>1
        fname = filename{ff};
        tmp = regexp(fname,'_');
        if length(tmp)==5
            namein = [fname(1:tmp(4)-1)];
        else
            namein = [fname(1:tmp(3)-1)];
        end
    else
        fname = filename{1};
        tmp = regexp(fname,'_');
        if length(tmp)==5
            namein = [fname(1:tmp(4)-1)];
        else
            namein = [fname(1:tmp(3)-1)];
        end
    end
    disp(['finding soma(s) for ', namein])
    anaylyze = input('do you want to anaylyze this cell?');
    if anaylyze == 1
        overlay = input('do you need an overlay picture (for Ariadne data: max projection tiff + trees)? (0 = no)','s');
        if overlay == 1
            %         addpath(genpath('/media/LabCode/Matlab/Plots/cmocean_v1.4/cmocean'))
            figure(100)
            scanpath = uigetfile(rawpath,'path to scan');
            swcpath = uigetfile(fullfile(datapath,'Ariadne'),'path to swc');
            MIP = tiffread(scanpath);
            trees = load(swcpath);
            cmap = cmocean('-gray');
            imagesc(MIP)
            colormap(cmap)
            hold on
            scatter(trees(:,3),trees(:,4),2,'.')
        end
        load(fullfile(savepath,[namein,'_warped']))
        % load(fullfile(savePath,[namein,'_GFP']))
        vox=voxels.nodes;
        xx = round(vox(:,1)); yy = round(vox(:,2)); zz = round(vox(:,3));
        tmp = find(xx>0); xx = xx(tmp); yy = yy(tmp); zz = zz(tmp);
        tmp = find(yy>0); xx = xx(tmp); yy = yy(tmp); zz = zz(tmp);
        tmp = find(zz>0); xx = xx(tmp); yy = yy(tmp); zz = zz(tmp);
        GFPflat = zeros(max(yy),max(xx),max(zz));
        linearInd = sub2ind(size(GFPflat),yy,xx,zz);
        GFPflat(linearInd)=1;
        f10 = figure(10);imagesc(mean(GFPflat,3))
        dilationRadius = 12;
        dilationBase = 12;
        dilationHeight = 5;
        sizeThreshold = 50;
        dilationRadius = 3;
        dilationBase = 3;
        dilationHeight = 3;
        dilationKernel = zeros(2*dilationBase+1,2*dilationBase+1,2*dilationHeight+1);
        overallRadius = sqrt(dilationBase^2+dilationBase^2+dilationHeight^2);
        [xs, ys, zs] = meshgrid(-dilationBase:dilationBase,-dilationBase:dilationBase,-dilationHeight:dilationHeight);
        dilationKernel = sqrt(xs.^2+ys.^2+zs.^2)<=dilationRadius;
        soma = imdilate(imopen(GFPflat,dilationKernel),dilationKernel);
        
        noSoma = max(0,GFPflat-soma);
        
        listx=[]; listy=[]; listz=[];
        for l= 1:size(noSoma,3)
            [xx yy] = find(noSoma(:,:,l)==1);
            if ~isempty(xx)
                listx=[listx;xx];
                listy=[listy;yy];
                listz=[listz;repmat(l,length(xx),1)];
            end
        end
        new = [listy listx listz];
        voxels.nodes = new;
        vox=voxels.nodes;
        x = vox(:,1); y = vox(:,2); z = vox(:,3);
        f20 = figure(20);
        subplot(1,2,1)
        plot(x,max(y)-y,'.')
        hold on
        
        subplot(1,2,2)
        imagesc(mean(soma,3))
        NoC = input('how many cells do you want to analyse? (-1 = 1 cell with known soma position)');
        if NoC == -1
            clear newSoma
            load(fullfile(savepath,[namein,'_thr']))
            somaCoord = newSoma;
            
            figure(20)
            subplot(1,2,1)
            plot(somaCoord(1),max(y)-somaCoord(2),'go','markerfacecolor','g')
            %version2:median
            %     somaCoord = [median(yind) size(soma,1)-median(xind) median(zind)];
            tmp = regexp(fname,'_');
            if length(tmp)==3
                currNumber = int2str(n);
                if n<10
                    currNumber = ['0',currNumber];
                end
                nameout = [namein,'_',currNumber];
            else
                nameout = namein;
            end
            save(fullfile(savepath,[nameout,'_warped_nosoma']),'voxels','sMap','resolution','somaCoord','datatype')
            NoC = 1;
        elseif NoC ==0
            close(gcf)
        else
            for n = 1:NoC
                giveLocation = input('is the soma well extracted? (0 = no / 1 = 1 / -1 = give me z projections)');
                if giveLocation ==1
                    figure(20)
                    subplot(1,2,2)
                    title('draw square around soma of 1 cell and hit Enter')
                elseif giveLocation == 0
                    figure(10)
                    title('draw square around soma of 1 cell and hit Enter')
                end
                
                if giveLocation > -1
                    [xsoma ysoma] = ginput;
                    xkeep = round(min(xsoma)):round(max(xsoma));
                    ykeep = round(min(ysoma)):round(max(ysoma));
                    
                    if giveLocation == 1
                        realSoma2 = zeros(size(soma));
                        realSoma2(ykeep,xkeep,:)=soma(ykeep,xkeep,:);
                        indices = find(realSoma2==1);
                        [yind xind zind] = ind2sub(size(realSoma2),indices);
                        %version1:COM
                        %
                        xCOM = sum(xind)/length(xind); %in um
                        yCOM = sum(yind)/length(yind); % in um
                        zCOM = sum(zind)/length(zind); % in um
                    else
                        xCOM = sum(xkeep)/length(xkeep);
                        yCOM = sum(ykeep)/length(ykeep);
                        zCOM = -1.5;
                    end
                else
                    close
                    figure(10)
                    subplot(1,2,1)
                    title('click on soma position and hit Enter')
                    imagesc(squeeze(mean(GFPflat,1)))
                    [xsoma ysoma] = ginput;
                    xkeep = ysoma;
                    subplot(1,2,2)
                    imagesc(squeeze(mean(GFPflat,2)))
                    [xsoma ysoma] = ginput;
                    ykeep = ysoma;
                    xCOM = round(xkeep);
                    yCOM = round(ykeep);
                    zCOM = round(xsoma);
                end
                somaCoord = [xCOM yCOM zCOM];
                
                
                figure(20)
                set(gcf,'position',[1 35 1600 783])
                subplot(1,2,1)
                plot(x,max(y)-y,'.')
                hold on
                plot(somaCoord(1),max(y)-somaCoord(2),'go','markerfacecolor','g')
                %version2:median
                %     somaCoord = [median(yind) size(soma,1)-median(xind) median(zind)];
                tmp = regexp(fname,'_');
                if length(tmp)==4
                    currNumber = int2str(n);
                    if n<10
                        currNumber = ['0',currNumber];
                    end
                    nameout = [namein,'_',currNumber];
                else
                    nameout = namein;
                end
                
                load(fullfile(savepath,[namein,'_GFP']))
                figure(30)
                set(gcf,'units','normalize','position',[0.21 0.14 0.51 0.74])
                imagesc(squeeze(max(GFP,[],3)))
                hold on
                title('zoom into soma, hit enter, label outline of soma, hit enter')
                input('done zooming?')
                [xsoma, ysoma] = ginput;
                Asoma = polyarea(xsoma,ysoma);
                if ~exist('datatype','var')
                    datatype = 1;
                end
                save(fullfile(savepath,[nameout,'_warped_nosoma']),'voxels','sMap','resolution','somaCoord','datatype','Asoma')
                
                clear GFP
            end
        end
        
        
        
        for nn=1:NoC
            clear voxels vox
            tmp = regexp(fname,'_');
            if length(tmp)==4
                cellNow = ['0',int2str(nn)]; cellNow = cellNow(end-1:end);
                load(fullfile(savepath,[namein,'_',cellNow,'_warped_nosoma']))
            else
                load(fullfile(savepath,[namein,'_warped_nosoma']))
                
            end
            cd(cpath)
            vox=voxels.nodes; %in pixels
            
            %----select data points that belong to 1 cell of interest------
            x=vox(:,1);y=vox(:,2);z=vox(:,3);
            xx = round(vox(:,1)); yy = round(vox(:,2)); zz = round(vox(:,3));
            figure(40)
            subplot(1,2,1)
            tmp = find(xx>0); xx = xx(tmp); yy = yy(tmp); zz = zz(tmp);
            tmp = find(yy>0); xx = xx(tmp); yy = yy(tmp); zz = zz(tmp);
            tmp = find(zz>0); xx = xx(tmp); yy = yy(tmp); zz = zz(tmp);
            GFPflat = zeros(max(yy),max(xx),max(zz));
            linearInd = sub2ind(size(GFPflat),yy,xx,zz);
            GFPflat(linearInd)=1;
            imagesc(flipud(mean(GFPflat,3)))
            subplot(1,2,2)
            plot(x,y,'.')
            hold on
            plot(somaCoord(1),somaCoord(2),'go','markerfacecolor','g')
            title('mark the area to be considered','fontsize',22)
            [limx, limy] = ginput;
            hold on
            plot(limx,limy,'-k')
            in = inpolygon(x,y,limx,limy);
            
            %----these variables contain only the dendritic tree of the cell of interest---
            xnew = x(in); ynew = y(in); znew = z(in);
            
            
            %check again
            prevx = x;
            prevy = y;
            prevz = z;
            tmp = find(znew>somaCoord(3));
            partx = xnew(tmp); party = ynew(tmp); partz= znew(tmp);
            
            figure(50)
            subplot(1,2,1)
            plot(x,y,'.')
            hold on
            plot(x(in),y(in),'r.')
            subplot(1,2,2)
            plot(x(in),y(in),'.')
            title('all selected data above soma','fontsize',22)
            OK = input('Is the selection OK (1 = yes / 0 = no, show me x,y / -1 = no, show me x,z / 2 = cell cannot be isolated)?');
            while OK < 1
                close
                figure(50)
                subplot(2,2,1)
                plot(prevx,prevy,'.')
                hold on
                plot(prevx(in),prevy(in),'r.')
                xlabel('x')
                ylabel('y')
                subplot(2,2,2)
                plot(prevx(in),prevy(in),'.')
                if OK == 0
                    title('all selected data above soma; SELECT HERE','fontsize',22)
                else
                    title('all selected data above soma','fontsize',22)
                end
                subplot(2,2,3)
                plot(prevx,prevz,'.')
                hold on
                plot(prevx(in),prevz(in),'r.')
                xlabel('x')
                ylabel('z')
                subplot(2,2,4)
                plot(prevx(in),prevz(in),'.')
                xlabel('x')
                ylabel('z')
                if OK == -1
                    title('all selected data above soma; SELECT HERE','fontsize',22)
                else
                    title('all selected data above soma','fontsize',22)
                end
                [limx, limy] = ginput;
                if OK == 0
                    subplot(2,2,2)
                else
                    subplot(2,2,4)
                end
                hold on
                plot(limx,limy,'-k')
                if OK == 0
                    in = inpolygon(xnew,ynew,limx,limy);
                else
                    in = inpolygon(xnew,znew,limx,limy);
                end
                prevx = xnew; prevy = ynew; prevz = znew;
                xnew = xnew(in); ynew = ynew(in); znew = znew(in);
                partx = xnew; party = ynew; partz = znew;
                OK = input('Is the selection OK (1 = yes / 0 = no, show me x,y / -1 = no, show me x,z / 2 = cell cannot be isolated)?');
                
            end
            %----
            vox = [xnew ynew znew];
            voxels.nodes = vox;
            %-------------------------------------------
            
            densities = voxels.density(in);
            
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
            clc
            if OK == 1
                tmp = regexp(fname,'_');
                if length(tmp)==4
                    save(fullfile(savepath,[namein,'_',cellNow,'_zDist']),'bins','zDist','voxels','zExt','resolution','somaCoord','datatype','Asoma')
                    disp(['saved as ', namein,'_',cellNow,'_zDist'])
                else
                    save(fullfile(savepath,[namein,'_zDist']),'bins','zDist','voxels','zExt','resolution','somaCoord','datatype','Asoma')
                    disp(['saved as ', namein,'_zDist'])
                end
                
            else
                tmp = regexp(fname,'_');
                if length(tmp)==4
                    save(fullfile(savepath,[namein,'_',cellNow,'_NOzDist']),'bins','zDist','voxels','zExt','resolution','somaCoord','datatype')
                    disp(['saved as ', namein,'_',cellNow,'_NOzDist'])
                else
                    save(fullfile(savepath,[namein,'_NOzDist']),'bins','zDist','voxels','zExt','resolution','somaCoord')
                    disp(['saved as ', namein,'_NOzDist'])
                end
            end
            
            fighand = findobj('Type','figure');
            if length(fighand>1)
                for ff = 2:length(fighand)
                    close(fighand(ff))
                end
            end 
            
        end
        close gcf
    else
    end
end
end
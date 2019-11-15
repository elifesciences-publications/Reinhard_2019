function RGC_CheckChatAnnotations(surfacepath,filename, namein, nfiles,datapath)


x2=1:256;
expF = log(x2);expF=round(expF/max(expF)*180); expF(end)=255;
manuals = [];
for ff = 1:nfiles
%     if nfiles>1
        fname = filename{ff};
        tmp = regexp(fname,'_');
        namein = [fname(1:tmp(end-1)-1)];
%     end
    file1 = [namein,'_chAT_STD_validation_ON_OFF.tif'];
    file2 = [namein,'_chAT_STD_validation_ON_OFF_2.tif'];
    
    doagain = 0; first = 1;
    
    while doagain == 1 || first == 1
        %version 1
        info = imfinfo(fullfile(surfacepath,file1));
        w = info(1).Width; h = info(1).Height;
        zsize = length(info);
        fullImage = zeros(h,w,zsize);
        
        for z=1:zsize
            a = imread(fullfile(surfacepath,file1),z);
            fullImage(:,:,z)=a(:,:,1);
        end
        %
        interval = ceil(h/10);
        figure('position',[-80 941 1920 963])
        cnt=0;
        for i=1:interval:h
            cnt=cnt+1;
            subplot(4,5,cnt)
            ma = fullImage(i,:,:);
            reslice = reshape(ma,w,zsize);
            %         reslice = expF(reslice(:)+1);
            %         reslice = reshape(reslice,w,zsize);
            if doagain == 0
                tst = find(reslice<20);
                tst2 = find(reslice>2);
                tst3 = intersect(tst,tst2);
                reslice(tst3) = 128;
            end
            imagesc(flipud(rot90(reslice)))
            colormap(gray)
            clear reslice ma
        end
        
        
        %version 2
        clear info fullImage
        info = imfinfo(fullfile(surfacepath,file2));
        w = info(1).Width; h = info(1).Height;
        zsize = length(info);
        fullImage = zeros(h,w,zsize);
        
        for z=1:zsize
            a = imread(fullfile(surfacepath,file2),z);
            fullImage(:,:,z)=a(:,:,1);
        end
        %
        interval = ceil(h/10);
        for i=1:interval:h
            cnt=cnt+1;
            subplot(4,5,cnt)
            ma = fullImage(i,:,:);
            reslice = reshape(ma,w,zsize);
            %         reslice = expF(reslice(:)+1);
            %         reslice = reshape(reslice,w,zsize);
            if doagain == 0
                tst = find(reslice<20);
                tst2 = find(reslice>2);
                tst3 = intersect(tst,tst2);
                reslice(tst3) = 128;
            end
            imagesc(flipud(rot90(reslice)))
            colormap(gray)
            clear reslice ma
        end
        subplot(4,5,1)
        title(file1,'interpreter','none')
        
        reply = input('which version is better? 0/1/2/3(3 = do again) [1]: ', 's');
        
        if reply=='1'
            clear vzmesh2 vzmesh
            load(fullfile(surfacepath,[namein,'_chAT_STD_OFF.mat']));
            destination1 = fullfile(datapath,[namein,'_OFF.mat']);
            vzmesh = vzmesh2;
            save(destination1,'vzmesh')
            clear vzmesh2 vzmesh
            load(fullfile(surfacepath,[namein,'_chAT_STD_ON.mat']));
            destination1 = fullfile(datapath,[namein,'_ON.mat']);
            save(destination1,'vzmesh')
            clear vzmesh2 vzmesh
            first = 0; doagain = 0;
        elseif reply=='2'
            clear vzmesh2 vzmesh
            load(fullfile(surfacepath,[namein,'_chAT_STD_OFF_2.mat']));
            destination1 = fullfile(datapath,[namein,'_OFF.mat']);
            vzmesh = vzmesh2;
            save(destination1,'vzmesh')
            clear vzmesh2 vzmesh
            load(fullfile(surfacepath,[namein,'_chAT_STD_ON_2.mat']));
            destination1 = fullfile(datapath,[namein,'_ON.mat']);
            save(destination1,'vzmesh')
            clear vzmesh2 vzmesh
            first = 0; doagain = 0;
        elseif reply == '0'
            manuals = [manuals;namein];
            first = 0; doagain = 0;
        else
            first = 0; doagain = 1;
        end
        close all
    end
end
if ~isempty(manuals)
    disp('do manual annotation for')
    disp(manuals)
    save(fullfile(datapath,'MANUAL'),'manuals')
end
end
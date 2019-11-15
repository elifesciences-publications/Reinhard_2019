function RGC_Thresholding(nfiles, namein, filename, savepath, cpath,datapath,sacFittingBoundaries)
% Thresholding: Binary dendritic tree (local) => stage 3
for ff = 1:nfiles
    if nfiles>1
        fname = filename{ff};
        tmp = regexp(fname,'_');
        namein = fname(1:tmp(3)-1);
    end
    disp(['thresholding cell ',namein])
    
    removeTheSoma = 0;
    % dataloaded = 0;
    % if dataloaded ==0
    addpath(fullfile(savepath));
    load(fullfile(savepath,[namein,'_GFP']))
    load(fullfile(savepath,[namein,'_res']))
    % end
    
    cd(cpath)
    OK = 0;
    options.threshold = .04;
    options.conservativeThreshold = .04;
    %     options.dilationRadius = 12;
    %     options.dilationBase = 12;
    %     options.dilationHeight = 5;
    options.sizeThreshold = 50;
    
    options.dilationRadius = 3;
    options.dilationBase = 3;
    options.dilationHeight = 3;
    
    while OK == 0
        %----- PostProcess -----%
        disp('PostProcessing Stack ...')
        GFP1 = postProcess(GFP, options);
        
        %----- Remove Somas -----%
        %         if removeTheSoma == 1
        %             disp('Removing Somas ...')
        %             [GFP2,somaCoord] = removeSoma(GFP1, GFP,options);
        %         else
        %             GFP2 = GFP1;
        %         end
        %
        %----- Check Processing -----%
        figure('Color', 'w','units','normalized','position',[0.2 0.2 0.65 0.7]);
        subplot(1,2,1)
        imagesc(max(GFP,[],3));
        subplot(1,2,2)
        imagesc(max(GFP1,[],3));
        colormap('gray')
        
        
        OK = input('Is the filtering OK?');
        if OK == 1
            
        else
            close
            disp(['Adjust threshold and conservativeThreshold (currently: ',num2str(options.threshold),', ',num2str(options.conservativeThreshold),')'])
            options.threshold = input('threshold = ');
            options.conservativeThreshold = input('conservativeThreshold = ');
        end
    end
    title([namein ' // threshold: ', num2str(options.threshold),', cons. threshold: ',num2str(options.conservativeThreshold)],'interpreter','none')
    saveas(gcf,fullfile(datapath,[namein,'_binary.png']))
    close
    
    listx=[]; listy=[]; listz=[];
    for l= 1:size(GFP1,3)
        [xx yy] = find(GFP1(:,:,l)==1);
        if ~isempty(xx)
            listx=[listx;xx];
            listy=[listy;yy];
            listz=[listz;repmat(l,length(xx),1)];
        end
    end
    volNew = [listy listx listz];
    conformalJump = 2;
    datatype = 1;
    save(fullfile(savepath,[namein,'_thr']),'volNew','sacFittingBoundaries','resolution','conformalJump','datatype')
end

end
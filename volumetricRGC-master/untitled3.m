clear
close all
clc

%% 1) Initiate
% add loading of several cells
cp = computer;
% cp = 'local';
% cp = 'cluster';
% cp = 'Karl';

%--- List of experiment info ---
expID = {'643_3L';'629_1L';'643_1L';'629_2R';'629_1R';'638_3R';...
    '645_2L';'629_2L';'567_4L';'628_1L';'637_1L';'587_3R';'567_4R';'587_4R';'589_1R';...
    '589_1L';'587_4L';'587_2L';'587_3L';'587_2R';'561_3R';'549_3L';...
    '549_5R';'561_3R';'549_3R';'567_3R';'567_1R';'555_3R';'556_4L';...
    '535_2L';'555_3L';'549_4R';'556_3R';'556_3L';'553_4R';'553_2R';'553_1R';...
    '555_4L';'555_4R';'550_3R';'550_3L';'550_2L';'549_2R';'549_1R';'544_2L';...
    '543_3L';'543_2L';'543_1R';'543_1L';'535_4R';'535_4L';'535_2R';'535_1R';...
    '535_1L'; '533_3R';'533_1R'; '522_2R';'522_2L'; '505_2R'};
typeOfExp = [3;1;3;1;1;3;1;1;3;1;3;3;3;3;3;3;3;3;3;3;1;1;1;1;1;1;3;2;1;3;2;1;1;1;2;2;2;2;2;2;2;2;1;1;3;2;2;2;2;3;3;3;3;3;1;1;1;1;1];%1=PBg,2=LP,3=LPflox
nasalPosition = [1;1;1;1;1;1;1;1;2;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;-1];
nasalCorrection = [0;0;0;0;0;0;0;0;270;90;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;45;90;NaN];
injectBrain = [1;2;1;2;2;1;2;2;2;2;1;1;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;3;1;1;2;2;2;2;2;1;1;2;2;2;1;1;1;1;1;1;1;1;1;3;3;3;3;3;3;3;3];%1=left,2=right,3=both
injectSC = [2;2;1;2;2;2;2;2;1;2;2;1;1;1;1;1;2;2;1;2;1;1;1;1;1;1;1;2;2;3;2;1;2;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;3;3;3;3;3;3;3;3;3;3];%1=left,2=right,3=both

%----- Add Paths to Code -----%
switch cp
    case 'PCWIN64' %local computer
        cpath = '\\10.86.1.80\areca\LabCode\Anatomy\matlab_v1\volumetricRGC-master';
        cpath2 = '\\10.86.1.80\areca\LabCode\Anatomy\matlab_v1';
        datapath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        savepath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        dbPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\database';
        arborPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\dendriticArbors';
        coordPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data';
        excelFile = fullfile(dbPath,'morphology_RGCs.xlsx');
        %         cpath = 'R:\Lab Related\Scripts\Sumbul_modified\volumetricRGC-master';
        %         cpath2 = 'R:\Lab Related\Scripts\Sumbul_modified\code';
        %         datapath = 'R:\Data\overviewSC\singleRGCs';
        %         savepath = 'R:\Data\overviewSC\singleRGCs';
        %         excelFile = 'R:\Data\overviewSC\morphology_RGCs.xlsx';
    case 'GLNXA64' %downstairs
        cpath = '/media/areca_raid/LabCode/Anatomy/matlab_v1/volumetricRGC-master';
        cpath2 = '/media/areca_raid/LabCode/Anatomy/matlab_v1';
        datapath = '/media/areca_raid/LabPapers/SCRouter/Data/singleRGCs'; %check that
        savepath = '/media/areca_raid/LabPapers/SCRouter/Data/singleRGCs'; %check that
        dbPath = '/media/areca_raid/LabPapers/SCRouter/Data/database';
        excelFile = fullfile(dbPath,'morphology_RGCs.xlsx');
    case 'local'
        cpath = 'C:\Users\KatjaR\Desktop\SumbulK\volumetricRGC-master';
        cpath2 = 'C:\Users\KatjaR\Desktop\Sumbul_modified\code\';
        datapath = 'C:\Users\KatjaR\Desktop\Sumbul_modified\data';
        savepath = 'C:\Users\KatjaR\Desktop\Sumbul_modified\data';
    case 'cluster'
        cpath = '/mnt/nerffs01/retinalab/Lab Related/Scripts/Sumbul_modified/volumetricRGC-master';
        cpath2 = '/mnt/nerffs01/retinalab/Lab Related/Scripts/Sumbul_modified/code';
        datapath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        savepath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        dbPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\database';
        excelFile = fullfile(dbPath,'morphology_RGCs.xlsx');
    case 'Karl'
        cpath = '\\NERFFS01\retinalab\Lab Related\Scripts\Sumbul_modified\volumetricRGC-master';
        cpath2 = '\\NERFFS01\retinalab\Lab Related\Scripts\Sumbul_modified\code';
        datapath = '\\NERFFS01\retinalab\Data\overviewSC\singleRGCs';
        savepath = '\\NERFFS01\retinalab\Data\overviewSC\singleRGCs';
        excelFile = '\\NERFFS01\retinalab\Data\overviewSC\morphology_RGCs.xlsx';
    case 'MACI64' %Chen's computer
        cpath = '/Volumes/retinalab/Lab Related/Scripts/Sumbul_modified/volumetricRGC-master';
        cpath2 = '/Volumes/retinalab/Lab Related/Scripts/Sumbul_modified/code';
        datapath = '/Volumes/areca/LabPapers/SCRouter/Data/singleRGCs';
        savepath = '/Volumes/areca/LabPapers/SCRouter/Data/singleRGCs';
        dbPath = '/Volumes/areca/LabPapers/SCRouter/Data/database';
        
end

pixBetweenChats = 24;
mylist = {'experiment','mouse','retina','scan','cellNumber','zpeak1','zpeak2','STDum',...
    'STDperc','somaZ','areaHull','areaCircle','asymmetry','angle','density','pixNN',...
    'pixNE','pixEE','pixSE','pixSS','pixSW','pixWW','pixNW','DSI','DSIangle',...
    'OSI','xCoordinates','yCoordinates','nasalAngle','quadrant','type','nasalPositionCheck',...
    'usable','injectionBrain','injectionSC','bistratType'};
%% 2) list of cells
listPreProc = dir(fullfile(datapath,'*GFP.tif'));
listPreProc = struct2cell(listPreProc); listPreProc = listPreProc(1,:)';
listAnnotated = dir(fullfile(datapath,'*OFF*'));
listAnnotated = struct2cell(listAnnotated); listAnnotated = listAnnotated(1,:)';
listParsed = dir(fullfile(datapath,'*GFP.mat'));
listParsed = struct2cell(listParsed); listParsed = listParsed(1,:)';
listThreshold= dir(fullfile(datapath,'*_thr.mat'));
listThreshold = struct2cell(listThreshold); listThreshold = listThreshold(1,:)';
listWarped= dir(fullfile(datapath,'*_warped.mat'));
listWarped = struct2cell(listWarped); listWarped = listWarped(1,:)';
listDone= dir(fullfile(datapath,'*zDist.mat'));
listDone = struct2cell(listDone); listDone = listDone(1,:)';

listOfCells = num2cell(repmat(0,length(listPreProc)+1,7));
listOfCells{1,1} = 'cell name';
listOfCells{1,2} = 'parsed (_GFP)';
listOfCells{1,3} = 'annotated (_OFF)';
listOfCells{1,4} = 'threshold (_thr)';
listOfCells{1,5} = 'warped (_warped)';
listOfCells{1,6} = 'analyzed (_zDist)';
listOfCells{1,7} = 'stage';
listOfCells(2:end,1) = listPreProc;

fullList = 2:length(listOfCells);
for l = 1:length(listAnnotated)
    curr = listAnnotated{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    found = 1;
                    fullList = setdiff(fullList,id);
                end
            end
        end
    end
    if found == 1
        listOfCells{id,3} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listParsed)
    curr = listParsed{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    found = 1;
                    fullList = setdiff(fullList,id);
                end
            end
        end
    end
    if found == 1
        listOfCells{id,2} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listWarped)
    curr = listWarped{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    found = 1;
                    fullList = setdiff(fullList,id);
                end
            end
        end
    end
    if found == 1
        listOfCells{id,5} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listDone)
    curr = listDone{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    found = 1;
                    fullList = setdiff(fullList,id);
                end
            end
        end
    end
    if found == 1
        listOfCells{id,6} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listThreshold)
    curr = listThreshold{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    found = 1;
                    fullList = setdiff(fullList,id);
                end
            end
        end
    end
    if found == 1
        listOfCells{id,4} = 111;
    end
end

for l = 2:length(listOfCells)
    curr = cell2mat(listOfCells(l,2:6));
    su = floor(sum(curr)/100);
    listOfCells{l,7} = su;
end
%% 3) select cells
giveIDs = 1;
IDlist = [58 147 148 258 223 294 309 308];

close all
cd(datapath)
if giveIDs == 1
    filename = listOfCells(IDlist,1);
else
    [filename, pathname, ext] = uigetfile(  '*GFP.tif','filtered GFP images', 'MultiSelect', 'on');
end
if giveIDs == 1 && size(filename,1)>1
    nfiles = length(filename);
elseif giveIDs == 0 && iscell(filename)
    nfiles = length(filename);
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

%----- Add paths to Data -----%
% namein = '00535_4L_C01'; %'TestAiry3'; %'exp522-M3L-C2';
suffix = '_GFP.tif';
%     VoxelSize = [.6 .6 .3];
% VoxelSize = [.5 .5 .2];
sacFittingBoundaries = [10 500 10 500];
%%
close all
for ff = 1:nfiles
if nfiles>1
    fname = filename{ff};
    tmp = regexp(fname,'_');
    namein = fname(1:tmp(3)-1);
end

load(fullfile(savepath,[namein,'_GFP']))
load(fullfile(savepath,[namein,'_res']))

cd(cpath)
OK = 0;
options.threshold = .04;
options.conservativeThreshold = .04;
options.sizeThreshold = 50;

options.dilationRadius = 3;
options.dilationBase = 3;
options.dilationHeight = 3;

% while OK == 0
    %----- PostProcess -----%
    disp('PostProcessing Stack ...')
    
    figure('Color', 'w');
    subplot(2,6,1)
    imagesc(max(GFP,[],3));
    set(gca,'plotboxaspectratio',[1 1 1])
    subplot(2,6,7)
    imagesc(squeeze(max(GFP,[],2)));
    set(gca,'plotboxaspectratio',[1 1 1])
    
    for rad = 1:5
        options.dilationRadius=rad;
         options.dilationHeight=rad;
        GFP1 = postProcess(GFP, options);
        
        
        subplot(2,6,rad+1)
        imagesc(max(GFP1,[],3));
        colormap('gray')
        set(gca,'plotboxaspectratio',[1 1 1])
        subplot(2,6,rad+7)
        imagesc(rot90(squeeze(max(GFP1,[],2))));
        set(gca,'plotboxaspectratio',[1 1 1])
    end
    
%     OK = input('Is the filtering OK?');
%     if OK == 1
%         
%     else
%         close
%         disp(['Adjust threshold and conservativeThreshold (currently: ',num2str(options.threshold),', ',num2str(options.conservativeThreshold),')'])
%         options.threshold = input('threshold = ');
%         options.conservativeThreshold = input('conservativeThreshold = ');
% %         options.dilationRadius = input('radius = ');
%     end
% end
end



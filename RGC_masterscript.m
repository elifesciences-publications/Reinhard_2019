function listOfCells = RGC_masterscript(checkAll,force, varargin)

%%

% clear
close all
clc



%% 1) Initiate

% checkAll = 2; % if 0: only check things to do manually, if 2 only automatic

% add loading of several cells
cp = computer;
% cp = 'local';
% cp = 'cluster';
% cp = 'Karl';

%--- List of experiment info ---
expID = {'891_7L';'925_2L';'914_3R';...
    '4_XX';'3_XX';'2_XX';'1_XX';'925_3L';'914_3R';'925_4L';'855_2L';'925_6L';...
    '925_7L';'914_2R';'966_3R';'966_8R';'966_7R';'966_9R';'925_7L';'966_6R';'966_5R';'899_3R';'915_5L';...
    '897_5R';'727_5R';'727_4R';'707_4R';'868_3R';'891_3L';'891_2L';'915_4L';'915_2L';'914_1R';...
    '854_3R';'854_4R';'741_3R';'821_3R';'758_3R';'758_2R';'686_3R';'686_3L';'686_1L';'686_1R';'638_1R';'643_2R';...
    '707_1R';'658_1L';'656_1R';'655_1R';'683_4R';'683_1R';'681_3R';'681_3L';'681_1L';'681_2R';'681_2L';'654_2R';...
    '638_2R';'658_1R';'654_1L';'654_1R';'645_2R';'643_3R';'638_3L';'628_2L';'591_1R';...
    '567_2R';'561_2R';'654_3R';'656_8R';'643_3L';'629_1L';'643_1L';'629_2R';'629_1R';'638_3R';...
    '645_2L';'629_2L';'567_4L';'628_1L';'637_1L';'587_3R';'567_4R';'587_4R';'589_1R';...
    '589_1L';'587_4L';'587_2L';'587_3L';'587_2R';'561_3R';'549_3L';...
    '549_5R';'561_3R';'549_3R';'567_3R';'567_1R';'555_3R';'556_4L';...
    '535_2L';'555_3L';'549_4R';'556_3R';'556_3L';'553_4R';'553_2R';'553_1R';...
    '555_4L';'555_4R';'550_3R';'550_3L';'550_2L';'549_2R';'549_1R';'544_2L';...
    '543_3L';'543_2L';'543_1R';'543_1L';'535_4R';'535_4L';'535_2R';'535_1R';...
    '535_1L'; '533_3R';'533_1R'; '522_2R';'522_2L'; '505_2R'};
typeOfExp = [1;1;3;10;10;10;10;1;3;1;5;1;1;3;3;3;3;3;1;3;3;5;1;3;3;3;3;5;1;1;1;1;3;3;3;4;4;4;4;4;4;4;4;3;3;3;3;3;3;1;1;3;3;3;3;3;1;3;3;1;1;1;3;3;1;1;3;1;1;3;3;1;3;1;1;3;1;1;3;1;3;3;3;3;3;3;3;3;3;3;1;1;1;1;1;1;3;2;1;3;2;1;1;1;2;2;2;2;2;2;2;2;1;1;3;2;2;2;2;3;3;3;3;3;1;1;1;1;1];%1=PBg,2=LP,3=LPflox,4=LGNG,5=PBgG
nasalPosition = [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;1;1;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;-1];
nasalCorrection = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;270;0;0;0;180;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;90;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;270;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;270;90;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;45;90;NaN];
injectBrain = [3;2;1;3;3;3;3;2;1;2;3;2;2;1;1;1;1;1;2;1;1;3;2;1;1;1;1;1;3;3;2;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;1;1;2;1;1;1;1;1;1;2;1;2;2;1;2;2;2;2;1;1;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;3;1;1;2;2;2;2;2;1;1;2;2;2;1;1;1;1;1;1;1;1;1;3;3;3;3;3;3;3;3];%1=left,2=right,3=both
injectSC = [3;2;1;3;3;3;3;2;1;2;3;2;2;1;1;1;1;1;2;1;1;3;2;1;1;1;1;1;3;3;2;2;1;1;1;1;1;1;1;1;1;1;1;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;2;2;1;1;1;1;1;2;2;1;2;2;2;2;2;1;2;2;1;1;1;1;1;2;2;1;2;1;1;1;1;1;1;1;2;2;3;2;1;2;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;3;3;3;3;3;3;3;3;3;3];%1=left,2=right,3=both

%----- Add Paths to Code -----%
switch cp
    case 'PCWIN64' %local computer
        cpath = '\\10.86.1.80\areca\LabCode\Anatomy\matlab_v1\volumetricRGC-master';
        cpath2 = '\\10.86.1.80\areca\LabCode\Anatomy\matlab_v1';
        addpath(cpath2)
        datapath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        savepath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        dbPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\database';
        arborPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\dendriticArbors';
        coordPath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data';
        surfacepath = '\\10.86.1.80\areca\VNet\SurfacesDetected';
        annotationScript = '\\10.86.1.80\areca\VNet';
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
        arborPath = '/media/areca_raid/LabPapers/SCRouter/Data/dendriticArbors';
        excelFile = fullfile(dbPath,'morphology_RGCs.xlsx');
        surfacepath = '/media/areca_raid/VNet/SurfacesDetected';
        annotationScript = '/media/areca_raid/VNet';
        addpath(cpath2)
    case 'local'
        cpath = 'C:\Users\KatjaR\Desktop\SumbulK\volumetricRGC-master';
        cpath2 = 'C:\Users\KatjaR\Desktop\Sumbul_modified\code\';
        datapath = 'C:\Users\KatjaR\Desktop\Sumbul_modified\data';
        savepath = 'C:\Users\KatjaR\Desktop\Sumbul_modified\data';
        surfacepath = 'A:\VNet\SurfacesDetected';
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

suffix = '_GFP.tif';
sacFittingBoundaries = [10 500 10 500];
%% 2) list of cells

listPreProc = dir(fullfile(datapath,'*chAT_STD.tif'));
listPreProc = struct2cell(listPreProc); listPreProc = listPreProc(1,:)';
listAnnotated = dir(fullfile(datapath,'*OFF*'));
listAnnotated = struct2cell(listAnnotated); listAnnotated = listAnnotated(1,:)';
listChat = dir(fullfile(surfacepath,'*OFF.mat*'));
listChat = struct2cell(listChat); listChat = listChat(1,:)';
listParsed = dir(fullfile(datapath,'*GFP.mat'));
listParsed = struct2cell(listParsed); listParsed = listParsed(1,:)';
listThreshold= dir(fullfile(datapath,'*_thr.mat'));
listThreshold = struct2cell(listThreshold); listThreshold = listThreshold(1,:)';
listWarped= dir(fullfile(datapath,'*_warped.mat'));
listWarped = struct2cell(listWarped); listWarped = listWarped(1,:)';
listSoma= dir(fullfile(datapath,'*_warped_nosoma.mat'));
listSoma = struct2cell(listSoma); listSoma = listSoma(1,:)';
listDone= dir(fullfile(datapath,'*zDist.mat'));
listDone = struct2cell(listDone); listDone = listDone(1,:)';
listBad= dir(fullfile(datapath,'*NOzDist.mat'));
listBad = struct2cell(listBad); listBad = listBad(1,:)';
listFinal= dir(fullfile(datapath,'parameters_*'));
listFinal = struct2cell(listFinal); listFinal = listFinal(1,:)';
listKvox= dir(fullfile(arborPath,'*zDist.mat'));
listKvox = struct2cell(listKvox); listKvox = listKvox(1,:)';

listOfCells = num2cell(repmat(0,length(listPreProc)+1,11));
listOfCells{1,1} = 'cell name';
listOfCells{1,2} = 'parsed (_GFP)';
listOfCells{1,3} = 'annotated (_OFF)';
listOfCells{1,4} = 'threshold (_thr)';
listOfCells{1,5} = 'warped (_warped)';
listOfCells{1,6} = 'analyzed (_zDist)';
listOfCells{1,7} = 'stage';
listOfCells{1,8} = 'chat';
listOfCells{1,9} = 'soma';
listOfCells{1,10} = 'area';
listOfCells{1,11} = 'kvox';
listOfCells(2:end,1) = listPreProc;



if nargin>2
    selectedCells =  varargin{1};
    if ~iscell(selectedCells)
        selectedCells = cell(1,1);
        selectedCells{1,1} = varargin{1};
    end
    if length(regexp(selectedCells{1,1},'_'))>1
        selectedCells2 = [];
        for l = 1:length(selectedCells)
            found = 0; m = 1;
            while found == 0
                m = m+1;
                if ~isempty(regexp(listOfCells{m,1},selectedCells{l}))
                    found = 1;
                    selectedCells2 = [selectedCells2;m];
                end
            end
        end
    else
        selectedCells2 = [];
        for l = 1:length(listOfCells)
            
            if ~isempty(regexp(listOfCells{l,1},selectedCells{1,1}))
                found = 1;
                selectedCells2 = [selectedCells2;l];
            end
            
        end
    end
else
    selectedCells2 = 2:length(listOfCells);
end




fullList = 2:length(listOfCells);
for l = 1:length(listAnnotated)
    curr = listAnnotated{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    if length(tmp)>3
        cellID = curr(tmp(3)+1:tmp(4)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>3
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    if length(tmp)==3 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif length(tmp)>3 && ~isempty(regexp(cellID,cellID2))
                        found = 1;
                        fullList = setdiff(fullList,id);
                    end
                end
            end
        end
        
    end
    if found == 1
        listOfCells{id,3} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listChat)
    curr = listChat{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    if length(tmp)>3
        cellID = curr(tmp(3)+1:tmp(4)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>3
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    if length(tmp)==3 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif length(tmp)>3 && ~isempty(regexp(cellID,cellID2))
                        found = 1;
                        fullList = setdiff(fullList,id);
                    end
                end
            end
        end
    end
    if found == 1
        listOfCells{id,8} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listParsed)
    curr = listParsed{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    if length(tmp)>3
        cellID = curr(tmp(3)+1:tmp(4)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>3
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if length(tmp)==3 && length( regexp(curr2,'_'))==4
                    found = 1;
                    fullList = setdiff(fullList,id);
                elseif length(tmp)>3 && ~isempty(regexp(cellID,cellID2))
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
    if length(tmp)>3
        cellID = curr(tmp(3)+1:tmp(4)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>3
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    if length(tmp)==3 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif length(tmp)>3 && ~isempty(regexp(cellID,cellID2))
                        found = 1;
                        fullList = setdiff(fullList,id);
                    end
                end
            end
        end
    end
    if found == 1
        listOfCells{id,5} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listSoma)
    curr = listSoma{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    if length(tmp)>4
        cellID = curr(tmp(3)+1:tmp(4)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>4
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    if length(tmp)==4 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif length(tmp)==5 && ~isempty(regexp(cellID,cellID2))
                        found = 1;
                        fullList = setdiff(fullList,id);
                    end
                end
            end
        end
    end
    
    if found == 1
        listOfCells{id,9} = 111;
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listDone)
    curr = listDone{l};
    tmp = regexp(curr,'_');
    expe = curr(1:tmp(1)-1);
    retina = curr(tmp(1)+1:tmp(2)-1);
    cellN = curr(tmp(2)+1:tmp(3)-1);
    if length(tmp)>3
        cellID = curr(tmp(3)+1:tmp(4)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>3
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    if length(tmp)==3 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif length(tmp)==4 && ~isempty(regexp(cellID,cellID2))
                        found = 1;
                        fullList = setdiff(fullList,id);
                    end
                end
            end
        end
    end
    
    if found == 1
        listOfCells{id,10} = 111;
        if ~isempty(regexp(curr,'NOzDist'))
            listOfCells{id,6} = 111;
        end
    end
end

if force == 0
    fullList = 2:length(listOfCells);
    for l = 1:length(listFinal)
        curr = listFinal{l};
        
        
        found = 0; cnt = 0;
        while found == 0 && cnt<length(fullList)
            cnt = cnt + 1;
            id = fullList(cnt);
            curr2 = listOfCells{id};
            tmp = regexp(curr2,'_');
            curr2 = curr2(1:tmp(end-1)-1);
            if ~isempty(regexp(curr,curr2))
                found=1;
                fullList = setdiff(fullList,id);
            end
        end
        if found == 1
            listOfCells{id,6} = 111;
        end
    end
end

fullList = 2:length(listOfCells);
for l = 1:length(listBad)
    curr = listBad{l};
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


% fullList = 2:size(listOfCells,1);
% for l = 1:length(listKvox)
%     curr = listKvox{l};
%     tmp = regexp(curr,'_');
%     expe = curr(tmp(1)+1:tmp(2)-1);
%     retina = curr(tmp(2)+1:tmp(3)-1);
%     cellN = curr(tmp(3)+1:tmp(4)-1);
%
%     found = 0; cnt = 0;
%     while found == 0 && cnt<length(fullList)
%
%         cnt = cnt + 1;
%         id = fullList(cnt);
%         curr2 = listOfCells{id};
%         tmp = regexp(curr2,'_');
%         exp2 = curr2(1:tmp(1)-1);
%         retina2 = curr2(tmp(1)+1:tmp(2)-1);
%         cellN2 = curr2(tmp(2)+1:tmp(3)-1);
%         if ~isempty(regexp(expe,exp2))
%             if ~isempty(regexp(retina,retina2))
%                 if ~isempty(regexp(cellN,cellN2))
%                     found = 1;
%                     fullList = setdiff(fullList,id);
%                 end
%             end
%         end
%     end
%     if found == 1
%         listOfCells{id,11} = 111;
%     end
% end

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
        listOfCells{id,2} = 111;
    end
end

for l = 2:length(listOfCells)
    curr = cell2mat(listOfCells(l,2:6));
    su = floor(sum(curr)/100);
    listOfCells{l,7} = su;
end

if checkAll==3
    return
end



try
    load(fullfile(datapath,'weirdCells'))
    listWeird=[];
    if ~ isempty(weirdCells)
        for w=1:length(weirdCells)
            found = 0; m=0;
            while found ==0 && m<length(listPreProc)
                m=m+1;
                if ~isempty(regexp(listPreProc{m},weirdCells{w}))
                    found = 1;
                    listWeird = [listWeird;m+1];
                end
            end
        end
    end
catch
    listWeird = [];
end


onlyIndices = cell2mat(listOfCells(2:end,2:end));

%% FIND THINGS TO DO
IDlistParse = find(onlyIndices(:,1)==0)+1;
IDlistParse = setdiff(IDlistParse,listWeird);
IDlistAnnotate = find(onlyIndices(:,2)==0)+1;
IDlistAnnotate = setdiff(IDlistAnnotate,listWeird);
IDlistAnnotate = intersect(IDlistAnnotate,selectedCells2);
IDlistWarp = find(onlyIndices(:,4)==0);
tmp=find(sum(onlyIndices(IDlistWarp,[1 2 3]),2)==333);
IDlistWarp=IDlistWarp(tmp)+1;
IDlistWarp = setdiff(IDlistWarp,listWeird);
IDlistWarp = intersect(IDlistWarp,selectedCells2);
IDlistSoma = find(onlyIndices(:,8)==0);
tmp=find(onlyIndices(IDlistSoma,4)==111);
IDlistSoma=IDlistSoma(tmp)+1;
IDlistSoma = setdiff(IDlistSoma,listWeird);
IDlistSoma = intersect(IDlistSoma,selectedCells2);
IDlistFinish = find(onlyIndices(:,5)==0);
tmp=find(sum(onlyIndices(IDlistFinish,[1 2 3 4 5 8 9]),2)==666);
IDlistFinish=IDlistFinish(tmp)+1;
IDlistFinish = setdiff(IDlistFinish,listWeird);
IDlistFinish = intersect(IDlistFinish,selectedCells2);
IDlistThreshold= find(onlyIndices(:,3)==0);
tmp=find(onlyIndices(IDlistThreshold,1)==111);
IDlistThreshold=IDlistThreshold(tmp)+1;
IDlistThreshold = setdiff(IDlistThreshold,listWeird);
IDlistThreshold = intersect(IDlistThreshold,selectedCells2);
IDlistChat = find(onlyIndices(:,7)==111);
tmp=find(onlyIndices(IDlistChat,2)==0);
IDlistChat=IDlistChat(tmp)+1;
IDlistChat = setdiff(IDlistChat,listWeird);
IDlistChat = intersect(IDlistChat,selectedCells2);
IDlistKvox = find(onlyIndices(:,10)==0);
tmp=find(sum(onlyIndices(IDlistKvox,[1 2 3 4 5 8 9]),2)==777);
IDlistKvox=IDlistKvox(tmp)+1;

%% inform about manual steps that are necessary
clc
if ~isempty(IDlistChat)
    disp(['CHAT: ',int2str(length(IDlistChat)),' cells '])
end
if ~isempty(IDlistThreshold)
    disp(['THRESHOLD: ',int2str(length(IDlistThreshold)),' cells'])
end
if ~isempty(IDlistSoma)
    disp(['SOMA: ', int2str(length(IDlistSoma))])
end
if ~isempty(IDlistFinish)
    disp(['FINALIZE: ',int2str(length(IDlistFinish)),' cells'])
end

if checkAll<2
    %% ---exclude axons----
    cd(cpath2)
    reply = input('Do you want to exclude axons? y/n [y]: ', 's');
    if reply == 'y'
        excludeAxons(arborPath,dbPath)
    end
    
    %% check chat bands
    if ~isempty(IDlistChat)
        reply = input('Do you want to check Chat bands? y/n [y]: ', 's');
        if reply == 'y'
            %             switch cp
            %                 case 'GLNXA64'
            %                     disp('please check bands on your local computer')
            %                 otherwise
            %                     % check chat bands
            IDlistChat = RGC_CurrentlyWorkingOn(datapath,IDlistChat,listOfCells,1);
            clc
            if ~isempty(IDlistChat)
                disp(['checking chat bands for ',int2str(length(IDlistChat)),' cells'])
                [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistChat,listOfCells,datapath);
                RGC_CheckChatAnnotations(surfacepath,filename, namein, nfiles,datapath)
                IDlistChat = RGC_CurrentlyWorkingOn(datapath,IDlistChat,listOfCells,2);
                disp('check done')
            end
        end
    end
    
    %% thresholding
    if ~isempty(IDlistThreshold)
        reply = input('Do you want to threshold cells? y/n [y]: ', 's');
        if reply == 'y'
            switch cp
                case 'GLNXA64'
                    % thresholding
                    IDlistThreshold = RGC_CurrentlyWorkingOn(datapath,IDlistThreshold,listOfCells,1);
                    clc
                    if ~isempty(IDlistThreshold)
                        disp(['doing thresholding for ',int2str(length(IDlistThreshold)),' cells'])
                        [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistThreshold,listOfCells,datapath);
                        RGC_Thresholding(nfiles, namein, filename, savepath, cpath,datapath,sacFittingBoundaries)
                        IDlistThreshold = RGC_CurrentlyWorkingOn(datapath,IDlistThreshold,listOfCells,2);
                        disp('thresholding done')
                    end
                otherwise
                    disp('please do thresholding on the computer downstairs')
            end
        end
    end
    
    %% find soma and extract cell
    if ~isempty(IDlistSoma)
        reply = input('Do you want to find somas for cells? y/n [y]: ', 's');
        if reply == 'y'
            switch cp
                case 'GLNXA64'
                    % soma
                    IDlistSoma = RGC_CurrentlyWorkingOn(datapath,IDlistSoma,listOfCells,1);
                    clc
                    if ~isempty(IDlistSoma)
                        disp(['doing soma/area for ',int2str(length(IDlistSoma)),' cells'])
                        [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistSoma,listOfCells,datapath);
                        RGC_SomaArea(cpath,nfiles,filename,namein,savepath,pixBetweenChats)
                        IDlistSoma = RGC_CurrentlyWorkingOn(datapath,IDlistSoma,listOfCells,2);
                        disp('soma/area done')
                    end
                otherwise
                    disp('please do this on the computer downstairs')
            end
        end
    end
    
    %% ---check chat bands---
    reply = input('Do you want to run CheckChatBands? y/n [y]: ', 's');
    if reply == 'y'
    cd(cpath2)
    CheckChatBands(arborPath);
    end
    
    
    %% finalize
    if ~isempty(IDlistFinish)
        reply = input('Do you want to finalize cells? y/n [y]: ', 's');
        if reply == 'y'
            switch cp
                case 'GLNXA64'
                    disp('please do this on your local computer')
                otherwise
                    % finalize
                    %                     IDlistFinish = RGC_CurrentlyWorkingOn(datapath,IDlistFinish,listOfCells,1);
                    clc
                    if ~isempty(IDlistFinish)
                        disp(['doing finalization for ',int2str(length(IDlistFinish)),' cells'])
                        [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistFinish,listOfCells,datapath);
                        RGC_Parameters(cpath,datapath,filename,savepath,namein,nfiles,pixBetweenChats,coordPath,mylist,expID,typeOfExp,nasalPosition,nasalCorrection,injectBrain,injectSC,excelFile,dbPath,arborPath)
                        close all
                        IDlistFinish = RGC_CurrentlyWorkingOn(datapath,IDlistFinish,listOfCells,2);
                        disp('finalizing done')
                    end
            end
        end
    end
end

if checkAll>0
    
    listToDo=[];
    if ~isempty(IDlistParse)
        listToDo=[listToDo 'Parse(p)'];
    end
    if ~isempty(IDlistAnnotate)
        listToDo=[listToDo 'Annotate(a)'];
    end
    if ~isempty(IDlistWarp)
        listToDo=[listToDo 'Warp(w)'];
    end
    reply = input(['Which of the following tasks do you want to do? ',listToDo,' []'], 's');
    
    %% Load Parse
    if ~isempty(regexp(reply,'p'))
        IDlistParse = RGC_CurrentlyWorkingOn(datapath,IDlistParse,listOfCells,1);
        clc
        if  ~isempty(IDlistParse)
            disp(['doing parsing for ',int2str(length(IDlistParse)),' cells'])
            [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistParse,listOfCells,datapath);
            RGC_LoadParse(cpath2,nfiles,filename,suffix,savepath,namein,datapath)
            IDlistParse = RGC_CurrentlyWorkingOn(datapath,IDlistParse,listOfCells,2);
            disp('parsing done')
        end
    end
    %% Run Annotation
    if ~isempty(regexp(reply,'a'))
        v = version;
        if str2num(v(end-3:end-2))==17
            disp('annotations only work with older Matlab versions')
        else
            IDlistAnnotate = RGC_CurrentlyWorkingOn(datapath,IDlistAnnotate,listOfCells,1);
            clc
            if  ~isempty(IDlistAnnotate)
                disp(['doing annotation for ',int2str(length(IDlistAnnotate)),' cells'])
                [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistAnnotate,listOfCells,datapath);
                RGC_Annotate(filename,namein,nfiles,datapath)
                IDlistAnnotate = RGC_CurrentlyWorkingOn(datapath,IDlistAnnotate,listOfCells,2);
                disp('annotation done')
            end
        end
    end
    
    
    %% Warping
    if ~isempty(regexp(reply,'w'))
        IDlistWarp = RGC_CurrentlyWorkingOn(datapath,IDlistWarp,listOfCells,1);
        clc
        if ~isempty(IDlistWarp)
            switch cp
                case 'GLNXA64'
                    disp(['doing warping for ',int2str(length(IDlistWarp)),' cells'])
                    [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistWarp,listOfCells,datapath);
                    RGC_Warping(nfiles, namein, filename, listAnnotated, savepath, cpath2,datapath)
                    IDlistWarp = RGC_CurrentlyWorkingOn(datapath,IDlistWarp,listOfCells,2);
                    disp('warping done')
                otherwise
                    disp('please do this on the other computer')
            end
        end
    end
    
    
end

%% ---raw2arbordensity---
reply = input('Do you want to run raw2arbordensity? y/n [y]: ', 's');
if reply == 'y'
    raw2arbordensity('kvoxels','',0)
end

%% kvoxels25
reply = input('Do you want to downsample kvoxels? y/n [y]: ', 's');
if reply == 'y'
    RGC_downSampleVoxels(arborPath,0)
end

%% tree
reply = input('Do you want to make trees? y/n [y]: ', 's');
if reply == 'y'
    RGC_skeletonRGC(arborPath, [], 0, 1,0)
end

%% arborDensity_tree
reply = input('Do you want to run raw2arbordensity for trees? y/n [y]: ', 's');
if reply == 'y'
    raw2arbordensity('tree','_tree',0)
end


end

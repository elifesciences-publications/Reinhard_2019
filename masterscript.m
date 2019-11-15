function listOfCells = masterscript(handles)
clc




%% 1) Initiate
onlylist = handles.onlylist;
datapath = handles.datapath;
path2script = handles.path2script;
annotationScript = handles.path2annotation;
surfacepath = fullfile(annotationScript,'SurfacesDetected');
addpath(genpath(path2script))

homepath = regexp(datapath,filesep);
homepath = datapath(1:homepath(end)-1);
if ~exist(fullfile(homepath,'database'),'dir')
    mkdir(fullfile(homepath,'database'))
    str = get(handles.logbox,'String');
    if ~iscell(str)
        str = {str};
    end
    strnew = [str;'made dir "database"'];
    set(handles.logbox,'String',strnew)
end
if ~exist(fullfile(homepath,'dendriticArbors'),'dir')
    mkdir(fullfile(homepath,'dendriticArbors'))
    str = get(handles.logbox,'String');
    if ~iscell(str)
        str = {str};
    end
    strnew = [str;'made dir "dendriticArbors"'];
    set(handles.logbox,'String',strnew)
end
dbPath = fullfile(homepath,'database');
arborPath = fullfile(homepath,'dendriticArbors');

cpath = fullfile(path2script,'volumetricRGC-master');
cpath2 = path2script;
savepath = datapath;

pixBetweenChats = handles.pixBetweenChats;
sacFittingBoundaries = handles.sacFittingBoundaries;
suffix = '_GFP.tif';
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



if ~isempty(handles.selectedCells)
    curr =  handles.selectedCells;
    tmp = regexp(curr,',');
    tmp = [0 tmp length(curr)+1];
    selectedCells = [];
    for s = 1:length(tmp)-1
        selectedCells{s} = curr(tmp(s)+1:tmp(s+1)-1);
    end
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


typeOfProcessing = zeros(length(listOfCells)-1,1); %1=inhouse, 2=Ariadne
for l =1:length(listPreProc)
    curr = listPreProc{l};
    sep = regexp(curr,'_');
    if length(sep)==4
        typeOfProcessing(l) = 1;
    else
        typeOfProcessing(l) = 2;
    end
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
aria = find(typeOfProcessing==2);
for a =1:length(aria)
    listOfCells{aria(a)+1,2} = 111;
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
                    if typeOfProcessing(id-1)==1 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif typeOfProcessing(id-1)==2 && length( regexp(curr2,'_'))==5
                        if ~isempty(regexp(cellID,cellID2))
                            found = 1;
                            fullList = setdiff(fullList,id);
                        end
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
                    if typeOfProcessing(id-1)==1 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif typeOfProcessing(id-1)==2 && length( regexp(curr2,'_'))==5
                        if ~isempty(regexp(cellID,cellID2))
                            found = 1;
                            fullList = setdiff(fullList,id);
                        end
                    end
                end
            end
        end
    end
    
    if found == 1
        if ~isempty(regexp(curr,'NOzDist'))
            listOfCells{id,6} = 111;
        end
    end
end

%     fullList = 2:length(listOfCells);
%     for l = 1:length(listFinal)
%         curr = listFinal{l};
%
%
%         found = 0; cnt = 0;
%         while found == 0 && cnt<length(fullList)
%             cnt = cnt + 1;
%             id = fullList(cnt);
%             curr2 = listOfCells{id};
%             tmp = regexp(curr2,'_');
%             curr2 = curr2(1:tmp(end-1)-1);
%             if ~isempty(regexp(curr,curr2))
%                 found=1;
%                 fullList = setdiff(fullList,id);
%             end
%         end
%         if found == 1
%             listOfCells{id,6} = 111;
%         end
%     end


% fullList = 2:length(listOfCells);
% for l = 1:length(listBad)
%     curr = listBad{l};
%     tmp = regexp(curr,'_');
%     expe = curr(1:tmp(1)-1);
%     retina = curr(tmp(1)+1:tmp(2)-1);
%     cellN = curr(tmp(2)+1:tmp(3)-1);
%
%     found = 0; cnt = 0;
%     while found == 0 && cnt<length(fullList)
%         cnt = cnt + 1;
%         id = fullList(cnt);
%         curr2 = listOfCells{id};
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
%         listOfCells{id,6} = 111;
%     end
% end


fullList = 2:size(listOfCells,1);
for l = 1:length(listKvox)
    curr = listKvox{l};
    tmp = regexp(curr,'_');
    expe = curr(tmp(1)+1:tmp(2)-1);
    retina = curr(tmp(2)+1:tmp(3)-1);
    cellN = curr(tmp(3)+1:tmp(4)-1);
    if length(tmp)>4
        cellID = curr(tmp(4)+1:tmp(5)-1);
    end
    found = 0; cnt = 0;
    while found == 0 && cnt<length(fullList)
        cnt = cnt + 1;
        id = fullList(cnt);
        curr2 = listOfCells{id};
        tmp = regexp(curr2,'_');
        exp2 = curr2(1:tmp(1)-1);
        retina2 = curr2(tmp(1)+1:tmp(2)-1);
        cellN2 = curr2(tmp(2)+1:tmp(3)-1);
        if length(tmp)>3
            cellID2 = curr2(tmp(3)+1:tmp(4)-1);
        end
        if ~isempty(regexp(expe,exp2))
            if ~isempty(regexp(retina,retina2))
                if ~isempty(regexp(cellN,cellN2))
                    if typeOfProcessing(id-1)==1 && length( regexp(curr2,'_'))==4
                        found = 1;
                        fullList = setdiff(fullList,id);
                    elseif typeOfProcessing(id-1)==2 && length( regexp(curr2,'_'))==5
                        if ~isempty(regexp(cellID,cellID2))
                            found = 1;
                            fullList = setdiff(fullList,id);
                        end
                    end
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
        listOfCells{id,2} = 111;
    end
end

for l = 2:length(listOfCells)
    curr = cell2mat(listOfCells(l,2:6));
    su = floor(sum(curr)/100);
    listOfCells{l,7} = su;
end

% if checkAll==3
%     return
% end


if onlylist == 0
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
tmp=find(sum(onlyIndices(IDlistFinish,[1 2 3 4 8]),2)==555);
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

if handles.force == 1
    IDlistThreshold = selectedCells2;
elseif handles.force == 2
     IDlistAnnotate = selectedCells2;
elseif handles.force == 3
     IDlistWarp = selectedCells2;
elseif handles.force == 4
     IDlistSoma = selectedCells2;
elseif handles.force == 5
     IDlistFinish = selectedCells2;
end

%% inform about manual steps that are necessary

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

chosenOne = 0;
%% ---exclude axons----
cd(path2script)
reply = input('Do you want to exclude axons? y/n [y]: ', 's');
if reply == 'y'
    chosenOne = 1;
    excludeAxons(arborPath,dbPath)
end

%% check chat bands
if ~isempty(IDlistChat) && chosenOne == 0
    reply = input('Do you want to check Chat bands? y/n [y]: ', 's');
    if reply == 'y'
        chosenOne = 1;
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
            str = get(handles.logbox,'String');
            if ~iscell(str)
                str = {str};
            end
            strnew = [str;'Chat bands checked'];
            set(handles.logbox,'String',strnew)
            disp('check done')
        end
    end
end

%% thresholding
if ~isempty(IDlistThreshold) && chosenOne == 0
    reply = input('Do you want to threshold cells? y/n [y]: ', 's');
    if reply == 'y'
        chosenOne = 1;
        %             switch cp
        %                 case 'GLNXA64'
        % thresholding
        IDlistThreshold = RGC_CurrentlyWorkingOn(datapath,IDlistThreshold,listOfCells,1);
        clc
        if ~isempty(IDlistThreshold)
            disp(['doing thresholding for ',int2str(length(IDlistThreshold)),' cells'])
            [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistThreshold,listOfCells,datapath);
            RGC_Thresholding(nfiles, namein, filename, savepath, cpath,datapath,sacFittingBoundaries)
            IDlistThreshold = RGC_CurrentlyWorkingOn(datapath,IDlistThreshold,listOfCells,2);
            str = get(handles.logbox,'String');
            if ~iscell(str)
                str = {str};
            end
            strnew = [str;'thresholded'];
            set(handles.logbox,'String',strnew)
            disp('thresholding done')
        end
        %                 otherwise
        %                     disp('please do thresholding on the computer downstairs')
        %             end
    end
end

%% find soma and extract cell
if ~isempty(IDlistSoma) && chosenOne == 0
    reply = input('Do you want to find somas for cells? y/n [y]: ', 's');
    if reply == 'y'
        chosenOne = 1;
        %             switch cp
        %                 case 'GLNXA64'
        % soma
        IDlistSoma = RGC_CurrentlyWorkingOn(datapath,IDlistSoma,listOfCells,1);
        clc
        if ~isempty(IDlistSoma)
            disp(['doing soma/area for ',int2str(length(IDlistSoma)),' cells'])
            [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistSoma,listOfCells,datapath);
            RGC_SomaArea(cpath,nfiles,filename,namein,savepath,pixBetweenChats,handles)
            IDlistSoma = RGC_CurrentlyWorkingOn(datapath,IDlistSoma,listOfCells,2);
            str = get(handles.logbox,'String');
            if ~iscell(str)
                str = {str};
            end
            strnew = [str;'soma/area done'];
            set(handles.logbox,'String',strnew)
            disp('soma/area done')
        end
        %                 otherwise
        %                     disp('please do this on the computer downstairs')
        %             end
    end
end

%% ---check chat bands---
if chosenOne == 0
    reply = input('Do you want to run CheckChatBands? y/n [y]: ', 's');
    if reply == 'y'
        chosenOne = 1;
        cd(path2script)
        CheckChatBands(arborPath);
        
    end
end

%% finalize
if ~isempty(IDlistFinish) && chosenOne == 0
    reply = input('Do you want to finalize cells? y/n [y]: ', 's');
    if reply == 'y'
        chosenOne = 1;
        %             switch cp
        %                 case 'GLNXA64'
        %                     disp('please do this on your local computer')
        %                 otherwise
        % finalize
        %                     IDlistFinish = RGC_CurrentlyWorkingOn(datapath,IDlistFinish,listOfCells,1);
        clc
        if ~isempty(IDlistFinish)
            disp(['doing finalization for ',int2str(length(IDlistFinish)),' cells'])
            [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistFinish,listOfCells,datapath);
            
            load(fullfile(handles.xlsFile,'RGC_expInfo'));
            missing = [];
            for mm = 1:length(filename)
                experimentNumber = filename{mm}(1:5);
                retinaN = filename{mm}(8);
                mouseN = filename{mm}(7);
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
                if found == 0
                    missing = [missing;mm];
                end
            end
            if ~isempty(missing)
                datanow = get(handles.expInfo,'Data');
                for mm = 1:length(missing)
                    fnow = filename{missing(mm)};
                    fnow = str2num(fnow(1:5));
                    fnow = num2str(fnow);
                    datanow{mm,1} = [fnow '_' filename{missing(mm)}(7:8)];
                end
                set(handles.expInfo,'Data',datanow)
                clc
                disp('please fill in the missing info in the GUI and hit Enter')
                input('done?');
                datanow = datanow(1:length(missing),:);
                raw = [raw;datanow];
                save(fullfile(handles.xlsFile,'RGC_expInfo'),'raw');
            end
            
            RGC_Parameters(cpath,datapath,filename,savepath,namein,nfiles,pixBetweenChats,handles)
            IDlistFinish = RGC_CurrentlyWorkingOn(datapath,IDlistFinish,listOfCells,2);
            str = get(handles.logbox,'String');
            if ~iscell(str)
                str = {str};
            end
            strnew = [str;'finalized'];
            set(handles.logbox,'String',strnew)
            disp('finalizing done')
        end
        %             end
    end
end
% end

% if checkAll>0

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
        RGC_LoadParse(path2script,nfiles,filename,suffix,savepath,namein,datapath)
        IDlistParse = RGC_CurrentlyWorkingOn(datapath,IDlistParse,listOfCells,2);
        str = get(handles.logbox,'String');
        if ~iscell(str)
            str = {str};
        end
        strnew = [str;'parsed'];
        set(handles.logbox,'String',strnew)
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
            str = get(handles.logbox,'String');
            if ~iscell(str)
                str = {str};
            end
            strnew = [str;'annotated'];
            set(handles.logbox,'String',strnew)
            disp('annotation done')
        end
    end
end


%% Warping
if ~isempty(regexp(reply,'w'))
    IDlistWarp = RGC_CurrentlyWorkingOn(datapath,IDlistWarp,listOfCells,1);
    clc
    if ~isempty(IDlistWarp)
        %             switch cp
        %                 case 'GLNXA64'
        disp(['doing warping for ',int2str(length(IDlistWarp)),' cells'])
        [filename,namein,nfiles] = RGC_InfoSelectedCells(IDlistWarp,listOfCells,datapath);
        RGC_Warping(nfiles, namein, filename, listAnnotated, savepath, cpath2,datapath)
        IDlistWarp = RGC_CurrentlyWorkingOn(datapath,IDlistWarp,listOfCells,2);
        str = get(handles.logbox,'String');
        if ~iscell(str)
            str = {str};
        end
        strnew = [str;'warped'];
        set(handles.logbox,'String',strnew)
        disp('warping done')
        %                 otherwise
        %                     disp('please do this on the other computer')
        %             end
    end
end


% end

%% ---raw2arbordensity---
if chosenOne == 0
    reply = input('Do you want to run raw2arbordensity, downsample kvoxels and make trees? y/n [y]: ', 's');
    if reply == 'y'
        raw2arbordensity('kvoxels','',0)
        
        
        %% kvoxels25
        % reply = input('Do you want to downsample kvoxels? y/n [y]: ', 's');
        % if reply == 'y'
        RGC_downSampleVoxels(arborPath,0)
        % end
        
        %% tree
        % reply = input('Do you want to make trees? y/n [y]: ', 's');
        % if reply == 'y'
        RGC_skeletonRGC(arborPath, [], 0, 1,0)
        % end
        
        %% arborDensity_tree
        % reply = input('Do you want to run raw2arbordensity for trees? y/n [y]: ', 's');
        % if reply == 'y'
        raw2arbordensity('tree','_tree',0)
        str = get(handles.logbox,'String');
        if ~iscell(str)
            str = {str};
        end
        strnew = [str;'postprocessing done'];
        set(handles.logbox,'String',strnew)
    end
end
else
    str = get(handles.logbox,'String');
    if ~iscell(str)
        str = {str};
    end
    strnew = [str;'list created'];
    set(handles.logbox,'String',strnew)
end

end

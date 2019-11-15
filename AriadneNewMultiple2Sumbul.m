function AriadneNewMultiple2Sumbul(handles)

%%
singlepath = handles.datapath;
homepath = regexp(singlepath,filesep);
homepath = datapath(1:homepath(end)-1);
codepath = handles.path2script;
savepath = fullfile(homepath,'Ariadne','temporary');



addpath(codepath);
cd (fullfile(homepath,'Ariadne'))
[filename, path1, ext] = uigetfile({  '*nodes*','Node files'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');
path2 = uigetdir(homepath,'directory to raw data (Chat bands)');

if iscell(filename)
    nfiles = length(filename);
else
    nfiles = 1;
end
%%    %---------- Set Options ----------%
options = handles.FilterOptions;
% options.doCandle = 'No'; % Denoising.;
% options.Flip = 'No';
% options.Deconvolve = 'No';
% options.Filter = 'Yes';
% options.Downsample = 'Yes';

%%   %---------- Get Info From MetaData ----------%
fileList = 1:nfiles;
II.VoxelSizeX = .3765;
II.VoxelSizeY = .3765;
II.VoxelSizeZ = .3;
options.ds = .5/II.VoxelSizeX;
ncnt = 0;
for n = fileList
    if ~iscell(filename)
        tmp = cell(1,1);
        tmp{1,1} = filename;
        filename = tmp;
    end
    ncnt = ncnt+1;
    idx = strfind(filename{n},'_');
    
    corrected_file = filename{n};
    corrected_file(10) = 'C';
    
    %     alreadyThere = [];
    alreadyThere = dir(fullfile(singlepath,[corrected_file(1:idx(3)-1),'*warped_nosoma*']));
    
    if length(idx) == 4
        num = str2num(filename{n}(idx(3)+1:idx(4)-1))+length(alreadyThere);
    else
        num = 1+length(alreadyThere);
    end
    if num < 10
        cellnum = ['0' num2str(num)];
    else
        cellnum = num2str(num);
    end
    
    if length(idx) == 4
        fname = [filename{n}(1:idx(3)-1) '_' cellnum];
    else
        fname = [filename{n}(1:idx(end)-1) '_' cellnum];
    end
    
    VoxelSize{ncnt} = [II.VoxelSizeX, II.VoxelSizeY, II.VoxelSizeZ] * 1000000;
    sizeX = (II.VoxelSizeX*1000000);
    sizeY= (II.VoxelSizeY*1000000);
    sizeZ = (II.VoxelSizeZ*1000000);
    resolution = [0.5 0.5 sizeZ];
    save(fullfile(savepath,[fname,'_res']),'resolution')
end
%% flip nodes
% --- need chat only once ---
n = 1;
idx = strfind(filename{n},'_');
chatname = filename{n}(1:idx(3)-1);
chatname2 = chatname;
if chatname(10) == 'c'
    chatname2(10) = 'C';
else
    chatname2(10) = 'c';
end

% ---- get chat ---
chat_list = dir(fullfile(path2,chatname,'chat','*.tif'));
dofirst = 1;
if isempty(chat_list)
    chat_list = dir(fullfile(path2,chatname2,'chat','*.tif'));
    dofirst = 0;
    if isempty(chat_list)
        chat_list = dir(fullfile(path2,[chatname2,'.lsm']));
    end
end

if isempty(regexp(chat_list(1).name,'lsm'))
    CHAT = [];
    for l = 1:length(chat_list)
        if dofirst == 1
            stack = tiffread(fullfile(path2,chatname,'chat', chat_list(l).name));
        else
            stack = tiffread(fullfile(path2,chatname2,'chat', chat_list(l).name));
        end
        if l == 1
            CHAT = stack.data;
        else
            CHAT = cat(3,CHAT,stack.data);
        end
    end
else
    stack = tiffread(fullfile(path2, chat_list(1).name));
    [nx, nz] = size(stack(1).data{1});
    ny = length(stack);
    CHAT = zeros(nx,nz,ny);
    for z = 1:length(stack)
        CHAT(:,:,z) = stack(z).data{2};
    end
end
[cx, cy, cz] = size(CHAT);

CHAT2 = CHAT;
CHAT2 = flip(CHAT,3); %needed orientation for chat
clear CHAT stack



for n = fileList
    
    idx = strfind(filename{n},'_');
    
    corrected_file = filename{n};
    corrected_file(10) = 'C';
    
    alreadyThere = dir(fullfile(singlepath,[corrected_file(1:idx(3)-1),'*warped_nosoma*']));
    
    if length(idx) == 4
        num = str2num(filename{n}(idx(3)+1:idx(4)-1))+length(alreadyThere);
    else
        num = 1+length(alreadyThere);
    end
    if num < 10
        cellnum = ['0' num2str(num)];
    else
        cellnum = num2str(num);
    end
    
    if length(idx) == 4
        fname = [filename{n}(1:idx(3)-1) '_' cellnum];
    else
        fname = [filename{n}(1:idx(end)-1) '_' cellnum];
    end
    
    
    
    %----- Load Ariadne Neuron Nodes -----%
    
    NN = load(fullfile(path1,filename{n}));
    if isfield(NN,'coords')
        TEMP = NN.coords;
    else
        TEMP = NN.volNew;
    end
    
    temp = TEMP;
    TEMP(:,1) = temp(:,2);
    TEMP(:,2) = temp(:,1);
    %     TEMP(:,2) = cy - TEMP(:,2);
    TEMP(:,3) = cz - TEMP(:,3);
    
    tmp = find(TEMP(:,1)<0);
    TEMP(tmp,1) = 0;
    tmp = find(TEMP(:,2)<0);
    TEMP(tmp,2) = 0;
    minxyz = min(TEMP);
    minxyz(3) = 0;
    
    
    
    
    
    
    % ---- normalize them to 0/0/0 being left bottom bottom ----
    try
        TEMP = TEMP- minxyz + 1;
    catch
        TEMP = TEMP - repmat(minxyz,size(TEMP,1),1) + 1;
    end
    try
        NN.soma = NN.soma - int32(minxyz) + 1;
    catch
        NN.soma = NN.soma;
    end
    maxxyz = max(TEMP);
    tx = maxxyz(1); ty = maxxyz(2); tz = maxxyz(3);
    
    
    
    
    % --- adjust chat accordingly (CHAT2, chAT2_STD)
    CHAT3 = CHAT2(minxyz(1):end,minxyz(2):end,:);
    CHAT3 = CHAT3(1:tx,1:ty,:);
    [nx,ny,nz] = size(CHAT3);
    chAT2_STD = zeros(nx,ny,nz);
    for z = 1:cz
        plane = squeeze(CHAT3(:,:,z));
        chAT2_STD(:,:,z) = movingstd2(plane,10);
    end
    
    
    
    %--- Resample to 0.5, 0.5, .3 ---%
    gfp2 = zeros(nx,ny,nz);
    for ii = 1:size(TEMP,1)
        if TEMP(ii,1) < nx && TEMP(ii,2) < ny && TEMP(ii,1) > 1 && TEMP(ii,2) > 1
            gfp2(TEMP(ii,1)-1:TEMP(ii,1)+1, TEMP(ii,2)-1:TEMP(ii,2)+1, TEMP(ii,3)-1:TEMP(ii,3)+1) = 1;
        else
            gfp2(TEMP(ii,1), TEMP(ii,2), TEMP(ii,3)) = 1;
        end
    end
    gfp2 = gfp2(1:nx,1:ny,1:nz);
    
    for z = 1:nz
        if z == 1
            [xx,yy] = size(imresize(gfp2(:,:,z), 1/options.ds,  'bicubic'));
            gfp = uint16(zeros(xx, yy, nz));
            chAT = uint16(zeros(xx,yy, nz));
            chAT_STD = uint16(zeros(xx, yy, nz));
        end
        gfp(:,:,z) = imresize(gfp2(:,:,z), 1/options.ds,  'bicubic');
        chAT(:,:,z) = imresize(CHAT3(:,:,z), 1/options.ds, 'bicubic');
        chAT_STD(:,:,z) = imresize(chAT2_STD(:,:,z), 1/options.ds, 'bicubic');
    end
    
    
    
    %----- Get New Cell Coordinates -----%
    listx=[]; listy=[]; listz=[];
    for l= 1:size(gfp,3)
        [xx, yy] = find(gfp(:,:,l)==1);
        if ~isempty(xx)
            listx=[listx;xx];
            listy=[listy;yy];
            listz=[listz;repmat(l,length(xx),1)];
        end
    end
    volNew = [listy listx listz];
    conformalJump = 2;
    
    %----- Define Variables to save -----%
    sacFittingBoundaries = [1 nx 1 ny];
    conformalJump = 2; % What is this?
    resolution = [.5 .5  II.VoxelSizeZ];
    
    oldSoma = [TEMP(1,1),TEMP(1,2),TEMP(1,3)];
    newSoma  = round(oldSoma([2,1,3])/options.ds); newSoma(3) = oldSoma(3);
    
    %----- Save Data -----%
    
    %--- Cell ---%
    datatype = 2;
    save(fullfile(savepath,[fname,'_thr']),'volNew','sacFittingBoundaries','resolution','conformalJump','newSoma','datatype'); % Cell
    
    %--- chAT Stacks ---%
    fullfile(savepath,[fname,'_chAT.tif'])
    savename1 = fullfile(savepath,[fname,'_chAT.tif']);
    savename2 = fullfile(savepath,[fname,'_chAT_STD.tif']);
    soptions.compression = 'none';
    soptions.overwrite = 'true';
    saveastiff(uint16(chAT), savename1, soptions);
    saveastiff(uint16(chAT_STD), savename2, soptions);
    
end
str = get(handles.logbox,'String');
if ~iscell(str)
    str = {str};
end
strnew = [str;'Ariadne2Sumbul done'];
set(handles.logbox,'String',strnew)
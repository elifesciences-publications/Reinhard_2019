function Ariadne2Nodes(handles)
%%
keyword = handles.keyword;
% keyword2 = '.*swc';
additionalFolder = handles.additionalFolder;
% additionalFolder = 1;
keyword2 = handles.keyword2;
% keyword = '*Results*'
makefolder = 1;

datapath = handles.datapath;
homepath = regexp(datapath,filesep);
homepath = datapath(1:homepath(end)-1);
path2script = handles.path2script;
homescript = regexp(path2script,filesep);
homescript = path2script(1:homescript(end)-1);
addpath(genpath(fullfile(homescript,'treestoolbox')))


scwpath = uigetdir(fullfile(homescript,'Ariadne'),'path to swc files');
savepath = uigetdir(fullfile(homescript,'Ariadne'),'path to save node files');
% scwpath = '/media/areca_raid/LabPapers/SCRouter/Data/Ariadne/PatchedCells/Results';
% savepath = '/media/areca_raid/LabPapers/SCRouter/Data/Ariadne/PatchedCells';

filelist = dir(fullfile(scwpath,keyword));

clear trees
for f = 1:length(filelist)
    if additionalFolder == 1
        SWCFolder = fullfile(scwpath,filelist(f).name);
        SWCFile = dir(fullfile(SWCFolder,keyword2));
    else
        SWCFolder = scwpath;
        SWCFile = filelist(f);
    end
    
    
    [tree,namet,path] = load_tree(fullfile(SWCFolder,SWCFile(1).name),'none');
    if iscell(tree)
        tree = tree{1,1};
    end
    
    coords = [tree.X tree.Y tree.Z];
    radius = 1.5;
    soma = [tree.X(1) tree.Y(1) tree.Z(1)];
    units = [0.3765 0.3765 0.3000];
    
    savepathnow = savepath;
    if additionalFolder == 1
        tmp = regexp(SWCFolder,'-');
        savename = SWCFolder(1:tmp-1);
        tmp = regexp(savename,'/');
        savename = savename(tmp(end)+1:end);
        savename(end-2) = 'C';
    else
        savename = SWCFolder;
        tmp = regexp(savename,'/');
        savename = savename(tmp(end)+1:end);
        savename = savename(1:12);
        savename(end-2) = 'C';
        num = ['0',int2str(f)]; num = num(end-1:end);
        savename = [savename '_' num];
        if makefolder == 1
            if ~exist(fullfile(savepath,savename(1:12)),'dir')
                mkdir(savepath,savename(1:12))
            end
            savepathnow = fullfile(savepath,savename(1:12));
        end
    end
    
    save(fullfile(savepathnow,[savename,'_nodes']),'coords','radius','soma','units')
end
str = get(handles.logbox,'String');
if ~iscell(str)
    str = {str};
end
strnew = [str;'Ariadne2Nodes done'];
set(handles.logbox,'String',strnew)
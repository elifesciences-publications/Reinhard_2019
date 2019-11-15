% Display Image MIP and results of Ariadne
%% Initiate
clear; clc; close all
currexp = '00914_3R_C01';
type = 2; %1=tree, 2=nodes

addpath A:\LabCode\Matlab\IO;
addpath A:\LabCode\Matlab\Plots\cmocean_v1.4\cmocean
% path = 'Z:\Data\_Projects\MachineLearningProject\00654_1R_c01\';
MIPName = fullfile('A:\LabPapers\SCRouter\Data\Ariadne',currexp,[currexp,'_max.tif']);
% SWCName = fullfile('A:\LabPapers\SCRouter\Data\Ariadne',currexp,'px');
SWCName = fullfile('A:\LabPapers\SCRouter\Data\Ariadne',currexp);

%% Load Data
%---------- Load MIP ----------%
MIP = tiffread(MIPName);
xp = MIP(1).width;
yp = MIP(1).height;
MIP = MIP(1).data;

if type == 1
    %---------- Load SWC ----------%
    flist = subdir(SWCName);
    ncells = length(flist);
    for f = 1:ncells
        clear tree
        tree = load(flist(f).name);
        trees{f} = tree(:,3:5);
    end
else
    flist = dir(fullfile(SWCName,'*nodes*'));
    ncells = length(flist);
    for f = 1:ncells
        clear coords volNew
        load(fullfile(SWCName,flist(f).name))
        if exist('coords','var')
            trees{f} = double(coords);
        else
            trees{f} = double(volNew);
        end
    end
end

%% Visualize
f1 = figure('Position',[100 100 xp/3 yp/3]);
cmap = cmocean('-gray');
col = colormap('jet'); col = [col;col];
idx = randperm(length(col),length(trees));

%---------- MIP ----------%
imagesc(MIP);
colormap(cmap);
hold on



%----------SWC ----------%
for c = 1:ncells
    %         figure
    xx = trees{c}(:,1);
    yy = trees{c}(:,2);
    scatter(xx,yy,2,col(idx(c),:),'filled')
    text(median(xx),median(yy),flist(c).name(14:15),'fontsize',20)
end

saveas(f1, fullfile('A:\LabPapers\SCRouter\Data\Ariadne\overviews',['Ariadne_',currexp,'.png']))


%----------SWC ----------%
for c = 1:ncells
    figure
    xx = trees{c}(:,1);
    yy = trees{c}(:,2);
    scatter(xx,yy,5,col(idx(c),:),'filled')
    text(median(xx),median(yy),flist(c).name(14:15),'fontsize',20)
    saveas(gcf, fullfile('A:\LabPapers\SCRouter\Data\Ariadne\overviews',['Ariadne_',currexp,'_',int2str(flist(c).name(14:15)),'.png']))
end


clear
close all;
clc

checkAll = 1; % if 0: only check things to do manually, if 2 only automatic, 3: only list
force = 0;

cp = computer;
switch cp
    case 'PCWIN64' %local computer
        path2script = '\\10.86.1.80\areca\LabCode\Anatomy\matlab_v1';
    case  'GLNXA64' %downstairs
        path2script = '/media/areca_raid/LabCode/Anatomy/matlab_v1';
    case 'MACI64' %Chen's computer
        path2script = '/Volumes/areca/LabCode/Anatomy/matlab_v1';
end

cd(path2script)
listOfCells = RGC_masterscript(checkAll,force,{'914_3R_C01','915_2L_C04','914_1R_C03','925_2L_C02','891_7L_C01','914_1R_C07','915_5L_C17','914_1R_C02','925_2L_C04'});
% listOfCells = RGC_masterscript(checkAll,force,{'914_3R_C01','915_2L_C04','914_1R_C03','925_2L_C02','891_7L_C01','914_1R_C07','915_5L_C17','914_1R_C02','925_2L_C04'});

% listOfCells = RGC_masterscript(checkAll,force,{'0001_XX_C01','0002_XX_C01','0002_XX_C02','0003_XX_C01','0004_XX_C01','0004_XX_C02'});

%listOfCells = RGC_masterscript(checkAll,{'681_2L_C01_28','681_2L_C01_29','681_2L_C01_30','681_2L_C01_31','681_2L_C01_32','681_2L_C01_33'});
% {'915_4L_C05','915_4L_C02','915_2L_C03','914_1R_C05','914_1R_C01','891_3L_C06','891_2L_C05','868_3R_C07','854_4R_C03','854_3R_C03','854_3R_C02'}
% listOfCells = RGC_masterscript(checkAll,'683_1R_C05');%,'656_8R_C02'
% listOfCells = RGC_masterscript(checkAll,{'707_1R_C01_02','707_1R_C02_02','707_1R_C03_01','707_1R_C04_01','707_1R_C05_01','707_1R_C06_01','707_1R_C06_02','707_1R_C07_01','707_1R_C08_01','707_1R_C09_01','707_1R_C10_01','707_1R_C11_01','707_1R_C11_02','707_1R_C11_03','707_1R_C11_04','707_1R_C11_05'});


%% clean up CurrentlyWorkingOn if interrupted
cp = computer;

switch cp
    case 'PCWIN64' %local computer
        datapath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
        path2script = '\\10.86.1.80\areca\LabCode\Anatomy\matlab_v1';
    case 'GLNXA64' %downstairs
        datapath = '/media/areca_raid/LabPapers/SCRouter/Data/singleRGCs'; %check that
          path2script = '/media/areca_raid/LabCode/Anatomy/matlab_v1';
    case 'MACI64' %Chen's computer
        datapath = '/Volumes/areca/LabPapers/SCRouter/Data/singleRGCs';
        path2script = '/Volumes/areca/LabCode/Anatomy/matlab_v1';
end
cd(path2script)
RGC_CurrentlyWorkingOn(datapath,[],[],0);
%% clean up automatic chat detection
path2areca = '/media/areca_raid/VNet';
paths2clean = {'SurfacesDetected','ResultsONOFF','ResultsON','ResultsOFF'};
for p = 1:length(paths2clean)
   files = dir(fullfile(path2areca,paths2clean{p}));
   for f = 1:length(files)
   delete(fullfile(path2areca,paths2clean{p},files(f).name))
   end
end

%% add weird cells
name = '00643_3L_C03_63';
action = 1; %1=add, 0=remove, -1=remove all
cp = computer;
switch cp
    case 'PCWIN64' %local computer
        datapath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\singleRGCs';
    case 'GLNXA64' %downstairs
        datapath = '/media/areca_raid/LabPapers/SCRouter/Data/singleRGCs'; %check that
    case 'MACI64' %Chen's computer
        datapath = '/Volumes/areca/LabPapers/SCRouter/Data/singleRGCs';
end
RGC_WeirdCells(datapath,name,action)

%% change if usable
number = 361;
use = 0; %1=add, 0=remove, -1=remove all
cp = computer;
switch cp
    case 'PCWIN64' %local computer
        datapath = '\\10.86.1.80\areca\LabPapers\SCRouter\Data\database';
    case 'GLNXA64' %downstairs
        datapath = '/media/areca_raid/LabPapers/SCRouter/Data/database'; %check that
    case 'MACI64' %Chen's computer
        datapath = '/Volumes/areca/LabPapers/SCRouter/Data/database';
end
RGC_changeUsable(datapath,number,use)

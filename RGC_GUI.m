function listOfCells = RGC_GUI(varargin)
% This is a GUI to extract the morphology of high-resolution retinal
% ganglion cell scans.

% Last Modified by GUIDE v2.5 22-Oct-2019 17:05:37


% ===== SETTING UP THE GUI =====
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RGC_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @RGC_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- define some variables and settings ---
function RGC_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RGC_GUI (see VARARGIN)

% switch off warnings
warning('off','all')

% global variables
global done stop
done = 0;
stop = 0;

% get default variables
cp = cd;
defaultGUIsettings = fullfile(cp,'defaultGUIsettings.mat');
handles.defaultGUIsettings = defaultGUIsettings;
if exist(defaultGUIsettings,'file')
    data = load(defaultGUIsettings);
    set(handles.listdatapath,'String',data.listdatapath)
    set(handles.listcodepath,'String',data.listcodepath)
    set(handles.listvnetpath,'String',data.listvnetpath)
    set(handles.listxlspath,'String',data.listxlspath)
    set(handles.listRawPath,'String',data.listRawPath)
end
guidata(hObject, handles);

strings = get(handles.listdatapath,'String');
handles.datapath = strings{1};
strings = get(handles.listcodepath,'String');
handles.path2script = strings{1};
strings = get(handles.listxlspath,'String');
handles.xlsFile = strings{1};
strings = get(handles.listvnetpath,'String');
handles.path2annotation = strings{1};
strings = get(handles.listRawPath,'String');
handles.rawpath = strings{1};

% set some more default variables
handles.selectedCells = [];

handles.pixBetweenChats = 24;
handles.sacFittingBoundaries = [10 500 10 500];
set(handles.procSettings,'Min',0,'Max',2)
set(handles.procSettings,'string',{['pixels between ChAT: ',...
    num2str(handles.pixBetweenChats)],['sac fitting boundaries: ',...
    num2str(handles.sacFittingBoundaries)]})

handles.keyword = [];
handles.keyword2 = [];
handles.additionalFolder = [];

handles.IknowChannelNumber = 1;
handles.bigFiles = 0;

options.doCandle = 'Yes'; % Denoising.;
options.Flip = 'Yes';
options.Deconvolve = 'No';
options.Filter = 'Yes';
options.Downsample = 'Yes';
handles.FilterOptions = options;

handles.force = 0;
handles.onlylist = 0;

% Choose default command line output for RGC_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%--- Outputs from this function are returned to the command line ---
function varargout = RGC_GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% ===== PANEL DIRECTORIES =====
% --- path to data ---
function listdatapath_Callback(hObject, eventdata, handles)
chosen = get(hObject,'Value');
strings = get(hObject,'String');
handles.datapath = strings{chosen};
guidata(hObject, handles);

% --- select a path that is not in the list ---
function selectpathtodata_Callback(hObject, eventdata, handles)
handles.datapath = uigetdir;
guidata(hObject, handles);

% --- path to code ---
function listcodepath_Callback(hObject, eventdata, handles)
chosen = get(handles.listcodepath,'Value');
strings = get(handles.listcodepath,'String');
handles.path2script = strings{chosen};
addpath(genpath(handles.path2script))
guidata(hObject, handles);

% --- select a path that is not in the list ---
function selectpathtocode_Callback(hObject, eventdata, handles)
handles.path2script = uigetdir;
addpath(genpath(handles.path2script))
guidata(hObject, handles);

% --- path to mat file with experiment info ---
function listxlspath_Callback(hObject, eventdata, handles)
chosen = get(handles.listxlspath,'Value');
strings = get(handles.listxlspath,'String');
handles.xlsFile = strings{chosen};
guidata(hObject, handles);

% --- select a path that is not in the list ---
function selectpathtoexcel_Callback(hObject, eventdata, handles)
handles.xlsFile = uigetdir;
guidata(hObject, handles);

% --- path to raw data ---
function listRawPath_Callback(hObject, eventdata, handles)
chosen = get(handles.listRawPath,'Value');
strings = get(handles.listRawPath,'String');
handles.rawpath = strings{chosen};
guidata(hObject, handles);

% --- select a path that is not in the list ---
function selectraw_Callback(hObject, eventdata, handles)
handles.rawpath = uigetdir;
guidata(hObject, handles);

% --- path to VNet ---
function listvnetpath_Callback(hObject, eventdata, handles)
chosen = get(handles.listvnetpath,'Value');
strings = get(handles.listvnetpath,'String');
handles.path2annotation = strings{chosen};
guidata(hObject, handles);

% --- select a path that is not in the list ---
function selectpathtovnet_Callback(hObject, eventdata, handles)
handles.path2annotation = uigetdir;
guidata(hObject, handles);

% --- add new data path to list ---
function addtolist1_Callback(hObject, eventdata, handles)
strings = get(handles.listdatapath,'String');
new = handles.datapath;
set(handles.listdatapath,'String', cat(1,strings,new));
guidata(hObject, handles);

% --- add new code path to list ---
function addtolist2_Callback(hObject, eventdata, handles)
strings = get(handles.listcodepath,'String');
new = handles.path2script;
set(handles.listcodepath,'String', cat(1,strings,new));
guidata(hObject, handles);

% --- add new exp info path to list ---
function addtolist3_Callback(hObject, eventdata, handles)
strings = get(handles.listxlspath,'String');
new = handles.xlsFile;
set(handles.listxlspath,'String', cat(1,strings,new));
guidata(hObject, handles);

% --- add new VNet path to list ---
function addtolist4_Callback(hObject, eventdata, handles)
strings = get(handles.listvnetpath,'String');
new = handles.path2annotation;
set(handles.listvnetpath,'String', cat(1,strings,new));
guidata(hObject, handles);


% --- add new raw data path to list ---
function addtolist5_Callback(hObject, eventdata, handles)
strings = get(handles.listRawPath,'String');
new = handles.rawpath;
set(handles.listRawPath,'String', cat(1,strings,new));
guidata(hObject, handles);

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ===== PANEL PRE-PROCESSING =====
% --- make tif out of LSM ---
function LSMtoSumbul_Callback(hObject, eventdata, handles)
LSM2Sumbul(handles)

% --- make node files out of Ariadne swc ---
function AriadnetoMatlab_Callback(hObject, eventdata, handles)
Ariadne2Nodes(handles)

% --- extract ChAT for Ariadne and change matlab format ---
function AriadneToSumbul_Callback(hObject, eventdata, handles)
AriadneNewMultiple2Sumbul(handles)

% --- put tree tool box result into processable format ---
function TreeToSumbul_Callback(hObject, eventdata, handles)
str = get(handles.logbox,'String');
if ~iscell(str)
    str = {str};
end
strnew = [str;'this tool is not available yet'];
set(handles.logbox,'String',strnew)
guidata(hObject, handles);

% --- keyword to look for in Ariadne files ---
function AriadneKeyword_Callback(hObject, eventdata, handles)
handles.keyword = get(handles.hObject,'String');
guidata(hObject, handles);

% --- keyword to look for in Ariadne subfolders (old format) ---
function AriadneKeyword2_Callback(hObject, eventdata, handles)
handles.keyword2 = get(handles.hObject,'String');
guidata(hObject, handles);

% --- select if there is a subfolder ---
function AriadneAdditionalFolder_Callback(hObject, eventdata, handles)
handles.keyword = get(handles.hObject,'Value');
guidata(hObject, handles);

% --- select if bif files (requires tif)
function filesize_Callback(hObject, eventdata, handles)
handles.bigFiles = get(hObject,'Value');
guidata(hObject, handles);

% --- adjust if not standard format (in development) ---
function IknowChannels_Callback(hObject, eventdata, handles)
handles.IknowChannelNumber = get(hObject,'Value');
guidata(hObject, handles);

% --- adjust if not standard format (in development) ---
function IknowChannelsDiff_Callback(hObject, eventdata, handles)
handles.IknowChannelNumber = get(IknowChannels,'Value');
guidata(hObject, handles);

% --- FILTER OPTIONS ---
% Candle
function checkbox1_Callback(hObject, eventdata, handles)
sel = get(hObject,'Value');
handles.FilterOptions.options.doCandle = sel;
guidata(hObject, handles);

% Filter
function checkbox2_Callback(hObject, eventdata, handles)
sel = get(hObject,'Value');
handles.FilterOptions.options.Filter = sel;
guidata(hObject, handles);

% Deconvolve
function checkbox3_Callback(hObject, eventdata, handles)
sel = get(hObject,'Value');
handles.FilterOptions.options.Deconvolve = sel;
guidata(hObject, handles);

% Downsample
function checkbox4_Callback(hObject, eventdata, handles)
sel = get(hObject,'Value');
handles.FilterOptions.options.Downsample = sel;
guidata(hObject, handles);

% Flip
function checkbox5_Callback(hObject, eventdata, handles)
sel = get(hObject,'Value');
handles.FilterOptions.options.Flip = sel;
guidata(hObject, handles);

% --- default Filter settings Ariadne data ---
function defaultAriadne_Callback(hObject, eventdata, handles)
set(handles.checkbox1,'Value',0); % Denoising.;
checkbox1_Callback(handles.checkbox1, eventdata, handles)
set(handles.checkbox2,'Value',1); %
checkbox2_Callback(handles.checkbox2, eventdata, handles)
set(handles.checkbox3,'Value',0); %
checkbox3_Callback(handles.checkbox3, eventdata, handles)
set(handles.checkbox4,'Value',1); %
checkbox4_Callback(handles.checkbox4, eventdata, handles)
set(handles.checkbox5,'Value',0); %
checkbox5_Callback(handles.checkbox5, eventdata, handles)
guidata(hObject, handles);

% --- default Filter settings semi-manual ---
function defaultSemi_Callback(hObject, eventdata, handles)
set(handles.checkbox1,'Value',1); % Denoising.;
checkbox1_Callback(handles.checkbox1, eventdata, handles)
set(handles.checkbox2,'Value',1); %
checkbox2_Callback(handles.checkbox2, eventdata, handles)
set(handles.checkbox3,'Value',0); %
checkbox3_Callback(handles.checkbox3, eventdata, handles)
set(handles.checkbox4,'Value',1); %
checkbox4_Callback(handles.checkbox4, eventdata, handles)
set(handles.checkbox5,'Value',1); %
checkbox5_Callback(handles.checkbox5, eventdata, handles)
guidata(hObject, handles);

% --- default Filter settings trees ---
function defaultTrees_Callback(hObject, eventdata, handles)

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ===== PANEL PROCESSING =====
% --- processing settings (currently not changable) ---
function procSettings_Callback(hObject, eventdata, handles)
str = get(handles.logbox,'String');
if ~iscell(str)
    str = {str};
end
strnew = [str;'you cannot change this (yet)'];
set(handles.logbox,'String',strnew)
guidata(hObject, handles);

% --- choose cells for processing ---
function chooseCells_Callback(hObject, eventdata, handles)
handles.selectedCells = get(hObject,'String');
guidata(hObject, handles);

% --- action forced onto chosen cells ---
function uipanel9_SelectionChangeFcn(hObject, eventdata, handles)
sel = get(hObject,'Tag');
sel = str2num(sel(end));
handles.force = sel;
guidata(hObject, handles);

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ===== PANEL MISSING INFORMATION =====
% --- table with missing info ---
function expInfo_CellEditCallback(hObject, eventdata, handles)

% --- clear table ---
function cleartable_Callback(hObject, eventdata, handles)
set(handles.expInfo,'Data',{'',[],[] ,[] ,[] ,[] ,[] ,'',''})

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ===== PANEL LOG =====
% --- log pannel ---
function logbox_Callback(hObject, eventdata, handles)

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ===== ACTION BUTTONS =====
% --- RUN processing ---
function run_Callback(hObject, eventdata, handles)
global done stop
disp(handles.datapath)
disp(handles.path2script)
jframe = get(gcf,'javaframe');
jframe.setMinimized(true)
handles.onlylist = 0;
while done == 0 && stop == 0
    listOfCells = masterscript(handles);
    handles.output = listOfCells;
    set(handles.table_list,'Data',listOfCells)
end
if done == 1
    figure1_CloseRequestFcn(gcf, eventdata, handles)
else
    jframe = get(gcf,'javaframe');
    jframe.setMaximized(true)
end

% --- Get list of cells in the folder and their status, save as .mat ---
function getlist_Callback(hObject, eventdata, handles)
handles.onlylist = 1;
listOfCells = masterscript(handles);
set(handles.table_list,'Data',listOfCells)
datapath = handles.datapath;
save(fullfile(datapath,'listOfCells'),'listOfCells')


% --- clean-up after crash ---
function cleanup_Callback(hObject, eventdata, handles)
RGC_CurrentlyWorkingOn(handles.datapath,[],[],0);
fighand = findobj('Type','figure');
if length(fighand>1)
    for ff = 2:length(fighand)
        close(fighand(ff))
    end
end

% --- stop looking for jobs, close everything ---
function doneForToday_Callback(hObject, eventdata, handles)
global done
jframe = get(gcf,'javaframe');
jframe.setMinimized(true)
done = 1;

% --- stop the current loop ---
function stoploop_Callback(hObject, eventdata, handles)
global stop
jframe = get(gcf,'javaframe');
jframe.setMinimized(true)
stop = 1;

% --- check zDist ---
function checkZ_Callback(hObject, eventdata, handles)
RGC_checkZDist(handles)

% --- add missing coordinate info ---
function missingCoord_Callback(hObject, eventdata, handles)
RGC_missingCoord(handles)

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% ===== CLOSE GUI =====
% --- what happens when GUI is closed ---
function figure1_CloseRequestFcn(hObject, eventdata, handles)
warning('on','all')
listdatapath = get(handles.listdatapath,'String');
listcodepath = get(handles.listcodepath,'String');
listvnetpath = get(handles.listvnetpath,'String');
listxlspath = get(handles.listxlspath,'String');
listRawPath = get(handles.listRawPath,'String');
cd(handles.path2script)
save(handles.defaultGUIsettings,'listRawPath','listdatapath','listcodepath','listvnetpath','listxlspath')
delete(hObject);




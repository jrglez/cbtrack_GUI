function varargout = cbtrackGUI_files(varargin)
% CBTRACKGUI_FILES MATLAB code for cbtrackGUI_files.fig
%      CBTRACKGUI_FILES, by itself, creates a new CBTRACKGUI_FILES or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_FILES returns the handle to a new CBTRACKGUI_FILES or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_FILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_FILES.M with the given input arguments.
%
%      CBTRACKGUI_FILES('Property','Value',...) creates a new CBTRACKGUI_FILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_files_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_files_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_files

% Last Modified by GUIDE v2.5 15-Nov-2013 08:41:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_files_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_files_OutputFcn, ...
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


% --- Executes just before cbtrackGUI_files is made visible.
function cbtrackGUI_files_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_files (see VARARGIN)

% Choose default command line output for cbtrackGUI_files
handles.output = hObject;
addpath(genpath(fileparts(which('cbtrackGUI_files'))))
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cbtrackGUI_files wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_files_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_infile_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to edit_infile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fullfilein=get(hObject,'String');
[in.folder.test{1},in.file{1},ext]=fileparts(fullfilein);
in.file{1}=[in.file{1} ext];
in.analysis_protocol = splitdir(in.folder.test{1},'last');
set(handles.pushbutton_infile,'UserData',in)
if isempty(get(handles.pushbutton_outfile,'UserData'))
    out.folder=fullfile(in.folder.test{1},'ouput');
    set(handles.edit_outfile,'String',out.folder)
    set(handles.pushbutton_outfile,'UserData',out)
end

% Hints: get(hObject,'String') returns contents of edit_infile as text
%        str2double(get(hObject,'String')) returns contents of edit_infile as a double


% --- Executes during object creation, after setting all properties.
function edit_infile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_infile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_infile.
function pushbutton_infile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_infile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filetypes={  '*.ufmf','MicroFlyMovieFormat (*.ufmf)'; ...
  '*.fmf','FlyMovieFormat (*.fmf)'; ...
  '*.sbfmf','StaticBackgroundFMF (*.sbfmf)'; ...
  '*.avi','AVI (*.avi)'
  '*.mp4','MP4 (*.mp4)'
  '*.mov','MOV (*.mov)'
  '*.mmf','MMF (*.mmf)'
  '*.*','*.*'};
[in.file,in.folder.test{1}]=open_files2(filetypes); %in.folder is a structure as is required by the main code. 
if in.file{1}~=0
    set(handles.edit_infile,'String',[in.folder.test{1},in.file{1}])
    in.analysis_protocol = splitdir(in.folder.test{1},'last');
    set(handles.pushbutton_infile,'UserData',in)
    if isempty(get(handles.pushbutton_outfile,'UserData'))
        out.folder=fullfile(in.folder.test{1},'ouput');
        set(handles.edit_outfile,'String',out.folder)
        set(handles.pushbutton_outfile,'UserData',out)
    end
end



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_infile.
function text_infile_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_infile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_outfile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out.folder=get(hObject,'String');
set(handles.pushbutton_outfile,'UserData',out)

% Hints: get(hObject,'String') returns contents of edit_outfile as text
%        str2double(get(hObject,'String')) returns contents of edit_outfile as a double


% --- Executes during object creation, after setting all properties.
function edit_outfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_outfile.
function pushbutton_outfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out.folder=uigetdir;
if out.folder{1}~=0
    set(handles.edit_outfile,'String',folder)
    set(handles.pushbutton_outfile,'UserData',out)
end


function edit_restart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_restart as text
%        str2double(get(hObject,'String')) returns contents of edit_restart as a double


% --- Executes during object creation, after setting all properties.
function edit_restart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_restart.
function pushbutton_restart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_restart.
function checkbox_restart_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.text_restart,'enable','on')
    set(handles.edit_restart,'enable','on')
    set(handles.pushbutton_restart,'enable','on')
elseif ~get(hObject,'Value')
    set(handles.text_restart,'enable','off')
    set(handles.edit_restart,'enable','off')
    set(handles.pushbutton_restart,'enable','off')
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_restart


% --- Executes on button press in checkbox_log.
function checkbox_log_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_log


% --- Executes on button press in checkbox_debug.
function checkbox_debug_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_debug


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

restart.ison=get(handles.checkbox_restart,'Value');
if restart.ison
    restart.dir=get(handles.edit_restart,'String');
else
    restart.dir=[];
end

in=get(handles.pushbutton_infile,'UserData');
expdirs=in.folder;
out=get(handles.pushbutton_outfile,'UserData');

% auto checks

paramsfilestr='params.xml';
cbparams = ReadXMLParams(fullfile(expdirs.test{1},paramsfilestr)); % (expdirs)
cbparams.track.DEBUG=get(handles.checkbox_debug, 'Value');


fns = fieldnames(expdirs);
issuccess = struct;
k=0;
nexp=0;
for i=1:numel(fns)
    nexp=nexp+numel(expdirs.(fns{i}));
end
prog=k/nexp;
hwait=waitbar(prog,['Checking files. experiment ', num2str(k),' of ',num2str(nexp),'.']);
for i = 1:numel(fns),    
    fn = fns{i};
    issuccess.(fn) = false(1,numel(expdirs.(fn)));
    for j = 1:numel(expdirs.(fn)),
        k=k+1; prog=k/nexp;
        waitbar(prog,hwait,['Checking files. experiment ', num2str(k),' of ',num2str(nexp),'.'])
        expdir = expdirs.(fn){j};
        [success,msgs,iserror] = CourtshipBowlAutomaticChecks_Incoming(expdir,'analysis_protocol',in.analysis_protocol); %#ok<*NASGU>
        issuccess.(fn)(j) = success;
        if ~success,
            fprintf('\nAuto checks incoming failed for %s\n',expdir);
            fprintf('%s\n',msgs{:});
        end
    end
end
close all
if ~exist(out.folder,'dir')
    mkdir(out.folder)
end
setappdata(0,'expdirs',expdirs)
setappdata(0,'moviefile',fullfile(expdirs.test{1},in.file{1}))%(expdirs)
setappdata(0,'outdir',out.folder);
setappdata(0,'analysis_protocol',in.analysis_protocol)
setappdata(0,'cbparams',cbparams)
setappdata(0,'restart',restart)
cbtrackGUI_BG



% --- Executes on button press in pushbutton_accept.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cancelar

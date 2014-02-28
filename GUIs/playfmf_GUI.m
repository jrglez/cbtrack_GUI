function varargout = playfmf_GUI(varargin)
% PLAYFMF_GUI M-file for playfmf_GUI.fig
%      PLAYFMF_GUI, by itself, creates a new PLAYFMF_GUI or raises the existing
%      singleton*.
%
%      H = PLAYFMF_GUI returns the handle to a new PLAYFMF_GUI or the handle to
%      the existing singleton*.
%
%      PLAYFMF_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAYFMF_GUI.M with the given input arguments.
%
%      PLAYFMF_GUI('Property','Value',...) creates a new PLAYFMF_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before playfmf_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to playfmf_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help playfmf_GUI

% Last Modified by GUIDE v2.5 24-Oct-2013 15:04:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @playfmf_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @playfmf_GUI_OutputFcn, ...
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


% --- Executes just before playfmf_GUI is made visible.
function playfmf_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to playfmf_GUI (see VARARGIN)

% Choose default command line output for playfmf_GUI
handles.output = hObject;

%GUI original sieze
vid.old_pos=get(hObject,'position');
set(handles.figure1,'UserData',vid)

% set up path
if isempty(which('myparse')),
  if exist('../misc','file'),
    addpath('../misc');
  end
  while isempty(which('myparse')),
    miscdir = uigetdir('.','Choose "misc" folder to add to path');
    try
      addpath(miscdir);
    catch %#ok<CTCH>
    end
  end
end
    

% load previous values
handles.rcfilename = ''; %.playfmfrc.mat
handles.previous_values = struct;
if exist(handles.rcfilename,'file')
  handles.previous_values = load(handles.rcfilename);
end

if isfield(handles.previous_values,'filename'),
  handles.filename = handles.previous_values.filename;
  [handles.filedir,handles.filenamebase,handles.fileext] = ...
    fileparts(handles.previous_values.filename);
  if ~exist(handles.filename,'file'),
    handles.filename = '';
  end
else
    moviefile=getappdata(0,'moviefile');
  handles.filename = moviefile;
end

if isfield(handles.previous_values,'CompressionSettings'),
  handles.CompressionSettings = handles.previous_values.CompressionSettings;
else
  handles.CompressionSettings = struct;
end
if ~isfield(handles.CompressionSettings,'OutputFPS'),
  handles.CompressionSettings.OutputFPS = 30;
end
if ~isfield(handles.CompressionSettings,'Compression'),
  handles.CompressionSettings.Compression = 'None';
end
if ~isfield(handles.CompressionSettings,'Quality'),
  handles.CompressionSettings.Quality = 100;
end
handles.CompressionSettings.StartFrame = 1;
handles.CompressionSettings.EndFrame = inf;

if isfield(handles.previous_values,'MaxFPS'),
  handles.MaxFPS = handles.previous_values.MaxFPS;
else
  handles.MaxFPS = 0;
  handles.MinSPF = 0;
end

% set callback for slider motion
fcn = get(handles.slider_Frame,'Callback');
handles.hslider_listener = handle.listener(handles.slider_Frame,...
  'ActionEvent',fcn);

% open video
handles = open_fmf(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes playfmf_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function play(hObject)

global ISPLAYING;

handles = guidata(hObject);
set(hObject,'String','Stop','BackgroundColor',[.5,0,0]);
ISPLAYING = true;
tic;
for f = handles.f:handles.nframes,
  handles = guidata(hObject);
  if ~ISPLAYING,
    break;
  end
  handles.f = f;
  handles = update_frame(handles);
  guidata(hObject,handles);
  if handles.MaxFPS > 0,
    tmp = toc;
    if tmp < handles.MinSPF
      pause(handles.MinSPF - tmp);
    end
  else
    drawnow;
  end
  tic;
end

stop(hObject);

function stop(hObject)

global ISPLAYING;

handles = guidata(hObject);
ISPLAYING = false;
guidata(hObject,handles);
set(handles.pushbutton_PlayStop,'String','Play','BackgroundColor',[0,.5,0]);

% --- Outputs from this function are returned to the command line.
function varargout = playfmf_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = update_frame(handles)

try
  [handles.im,handles.timestamp] = handles.readframe(handles.f);
catch ME
  warning([sprintf('Error reading frame %d\n',handles.f),getReport(ME)]);
  return;
end
set(handles.himage,'CData',handles.im);
set(handles.edit_Frame,'String',num2str(handles.f));
set(handles.slider_Frame,'Value',(handles.f-1)/(handles.nframes-1));

% --- Executes on slider movement.
function slider_Frame_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to slider_Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
v = get(hObject,'Value');
handles.f = round(1 + v * (handles.nframes - 1));
handles = update_frame(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider_Frame_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to slider_Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_PlayStop.
function pushbutton_PlayStop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_PlayStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ISPLAYING;

if ~ISPLAYING,
  play(hObject);
else
  stop(hObject);
end

function edit_Frame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Frame as text
%        str2double(get(hObject,'String')) returns contents of edit_Frame as a double
f = str2double(get(hObject,'String'));
if isnan(f),
  set(hObject,'String',num2str(handles.f));
  return;
end
handles.f = max(1,min(f,handles.nframes));
handles = update_frame(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_Frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_File_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_File_Open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = open_fmf(handles);
guidata(hObject,handles);

function handles = open_fmf(handles)

global ISPLAYING;

if ~isempty(ISPLAYING) && ISPLAYING,
  stop(handles.figure1);
  handles = guidata(handles.figure1);
end

handles.filterspec = {  '*.ufmf','MicroFlyMovieFormat (*.ufmf)'; ...
  '*.fmf','FlyMovieFormat (*.fmf)'; ...
  '*.sbfmf','StaticBackgroundFMF (*.sbfmf)'; ...
  '*.avi','AVI (*.avi)'
  '*.mp4','MP4 (*.mp4)'
  '*.mov','MOV (*.mov)'
  '*.mmf','MMF (*.mmf)'
  '*.*','*.*'};

if isfield(handles,'fileext'),
  % default ext is last chosen
  i = find(strcmpi(['*',handles.fileext],handles.filterspec(:,1)),1);
  n = size(handles.filterspec,1);
  if ~isempty(i),
    handles.filterspec = handles.filterspec([i,1:i-1,i+1:n],:);
  end
end

[pathname, filename] = fileparts(handles.filename); %#ok<ASGLU>
if ~ischar(filename),
  return;
end
% handles.filename = fullfile(pathname,filename);
[handles.filedir,handles.filenamebase,handles.fileext] = fileparts(handles.filename);

if isfield(handles,'fid') && ~isempty(fopen(handles.fid)) && handles.fid > 1,
  fclose(handles.fid);
end
if isfield(handles,'himage') && ishandle(handles.himage),
  delete(handles.himage);
end

try
  [handles.readframe,handles.nframes,handles.fid,handlies.headerinfo] = ...
    get_readframe_fcn(handles.filename);
catch ME
  s = sprintf('Could not read video %s.',filename);
  uiwait(errordlg(s,'Error opening video'));
  rethrow(ME);
end

% set slider steps
sliderstep = [1/(handles.nframes-1),min(1,100/(handles.nframes-1))];
set(handles.slider_Frame,'Value',0,'SliderStep',sliderstep);

% show first image
handles.f = 1;
[handles.im,handles.timestamp] = handles.readframe(handles.f);
if size(handles.im,3) == 1,
  handles.himage = imagesc(handles.im,'Parent',handles.axes_Video,[0,255]);
else
  handles.himage = image(uint8(handles.im),'Parent',handles.axes_Video);
end
colormap(handles.axes_Video,'gray');
axis(handles.axes_Video,'image','off');
handles = update_frame(handles);

ISPLAYING = false;

% --------------------------------------------------------------------
function menu_File_Quit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File_Quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(handles.figure1, eventdata, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isfield(handles,'fid') && ~isempty(fopen(handles.fid)) && handles.fid > 1,
  fclose(handles.fid);
end

% savefns = {'filename','CompressionSettings'};
% save(handles.rcfilename,'-struct','handles',savefns{:});
if ishandle(hObject)
    delete(hObject);
end

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vid=get(handles.figure1,'UserData');
if ~isfield(vid,'old_pos')
    vid.old_pos=get(hObject,'position');
end
vid.new_pos=get(hObject,'position');
rescalex=vid.new_pos(3)/vid.old_pos(3);
rescaley=vid.new_pos(4)/vid.old_pos(4) ;
h=fieldnames(handles);
    
for i=2:length(h)
    obj_handle=handles.(h{i});
    if ~strcmp(h{i},'output')
        if isprop(obj_handle,'position') && isempty(strfind(h{i},'menu'))        
            old_pos=get(obj_handle,'position');
            if ~isprop(obj_handle,'xTick') %not a figure
                new_pos([1,3])=old_pos([1,3])*rescalex;
                new_pos([2,4])=old_pos([2,4])*rescaley;
                set(obj_handle,'position',new_pos)
            elseif isprop(obj_handle,'xTick') %figure
                rescale=min(rescalex,rescaley);
                new_pos(1)=old_pos(1)*rescalex+(old_pos(3)*(rescalex-rescale)/2);
                new_pos(2)=old_pos(2)*rescaley+(old_pos(4)*(rescaley-rescale)/2);
                new_pos([3,4])=old_pos([3,4])*rescale;
                set(obj_handle,'position',new_pos)        
            end
        end
        if isprop(obj_handle,'FontSize')
            old_fontsize=get(obj_handle,'FontSize');
            new_fontsize=max(12,old_fontsize*min(rescalex,rescaley));
            set(obj_handle,'FontSize',new_fontsize)
        end
    end
end
vid.old_pos=vid.new_pos;
set(hObject,'UserData',vid)


% --------------------------------------------------------------------
function menu_Edit_Preferences_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Edit_Preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompts = {};
defAns = {};
prompts{end+1} = 'Max FPS: ';
defAns{end+1} = num2str(handles.MaxFPS);
while true,
  answer = inputdlg(prompts,'playfmf Preferences',1,defAns,'on');
  if isempty(answer),
    return;
  end
  v = str2double(answer{1});
  iserror = false;
  if isnan(v),
    iserror = true;
  else
    defAns{1} = num2str(v);
    handles.MaxFPS = v;
    handles.MinSPF = 1 / handles.MaxFPS;
  end
  if iserror,
    uiwait(warndlg('Illegal values entered. Max FPS must be a number','Bad Preferences'));
  else
    break;
  end
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_Help_About_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Help_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s = {};
s{end+1} = 'PlayFMF';
s{end+1} = '';
s{end+1} = 'Kristin Branson';
s{end+1} = 'bransonk@janelia.hhmi.org';
s{end+1} = '';
s{end+1} = 'This is a GUI for playing FMF, SBFMF, UFMF, and AVI videos. The maximum frame rate can be set through the "Preferences..." menu. Set to <= 0 for no maximum frame rate. Control the frame shown with the slider or editable text box. The Play/Stop button does what you think it does.';
msgbox(s,'About PlayFMF','help','Replace');

% --------------------------------------------------------------------
function menu_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Edit_CompressionSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Edit_CompressionSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CompressionSettings = SaveFMFSettings(handles.CompressionSettings);
fns = fieldnames(CompressionSettings);
for i = 1:length(fns),
  fn = fns{i};
  handles.CompressionSettings.(fn) = CompressionSettings.(fn);
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function menu_File_Compress_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File_Compress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.CompressionSettings.StartFrame > handles.nframes,
  uiwait(errordlg(sprintf('StartFrame set to %d > NFrames = %d. Please fix Compression Settings',...
    handles.CompressionSettings.StartFrame,handles.nframes)));
  return;
end

[pathstr,filestr,ext] = fileparts(handles.filename); %#ok<*NASGU>
handles.aviname = fullfile(pathstr,[filestr,'.avi']);

[filename,pathname] = uiputfile('*.avi','Save to AVI file',handles.aviname);
if ~ischar(filename),
  return;
end
handles.aviname = fullfile(pathname,filename);

ncolors = size(handles.im,3);
isindexed = ismember(handles.CompressionSettings.Compression,{'MSVC','RLE'}) || ...
  (strcmp(handles.CompressionSettings.Compression,'None') && ...
  ncolors == 1);
if isindexed,
  if ncolors == 1,
    cmap = repmat(linspace(0,1,256)',[1,3]);
  else
    [tmp,cmap] = rgb2ind(handles.im,256,'nodither'); %#ok<ASGLU>
  end
end

params = {'compression',handles.CompressionSettings.Compression,...
  'fps',handles.CompressionSettings.OutputFPS};

if isindexed,
  params(end+1:end+2) = {'colormap',cmap};
end
if ~strcmp(handles.CompressionSettings.Compression,'None'),
  params(end+1:end+2) = {'quality',handles.CompressionSettings.Quality};
end
handles.aviobj = avifile(handles.aviname,params{:});

endframe = min(handles.nframes,handles.CompressionSettings.EndFrame);
nframescompress = endframe - handles.CompressionSettings.StartFrame + 1;

i = 0;
s = sprintf('Compressing frame %d / %d',i,nframescompress);
hwaitbar = waitbar(0,s,'CreateCancelBtn',...
  'setappdata(gcbf,''canceling'',1)');
setappdata(hwaitbar,'canceling',0);
for t = handles.CompressionSettings.StartFrame:endframe,
  if getappdata(hwaitbar,'canceling')
    break
  end
  im = uint8(handles.readframe(t));
  if isindexed,
    if ncolors == 1,
      handles.aviobj = addframe(handles.aviobj,im);
    else
      handles.aviobj = addframe(handles.aviobj,rgb2ind(im,cmap,'nodither'));
    end
  else
    if ncolors == 1,
      handles.aviobj = addframe(handles.aviobj,repmat(im,[1,1,3]));
    else
      handles.aviobj = addframe(handles.aviobj,im);
    end
  end
  i = i + 1;
  if mod(i,50) == 0,
    s = sprintf('Compressing frame %d / %d',i,nframescompress);
    waitbar(i/nframescompress,hwaitbar,s);
  end
end
handles.aviobj = close(handles.aviobj);
if ishandle(hwaitbar),
  delete(hwaitbar);
end
msgbox(sprintf('Successfully compressed %d / %d of frames in the interval [%d,%d].',i,nframescompress,handles.CompressionSettings.StartFrame,endframe),'Compression Complete','modal');

% --------------------------------------------------------------------
function menu_Help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_initial_Callback(hObject, eventdata, handles)
% hObject    handle to edit_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_final as text
%        str2double(get(hObject,'String')) returns contents of edit_final as a double

% --- Executes during object creation, after setting all properties.
function edit_initial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_final_Callback(hObject, eventdata, handles)
% hObject    handle to edit_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_final as text
%        str2double(get(hObject,'String')) returns contents of edit_final as a double

% --- Executes during object creation, after setting all properties.
function edit_final_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ISPLAYING;
init=str2double(get(handles.edit_initial,'String'));
if isempty(init) || isnan(init)
    init=0;
end
fin=str2double(get(handles.edit_final,'String'));
if isempty(fin) || isnan(fin)
    fin=0;
end

if init>0 && round(init)==init && fin>0 && round(fin)==fin && fin<=handles.nframes && fin>init
    if ISPLAYING,
        stop(hObject);
    end
    set(handles.edit_initial,'String', '0')
    set(handles.edit_final,'String','0')
    setappdata(0,'startframe',init)
    setappdata(0,'endframe',fin)
    set(handles.figure1,'Visible','off')

elseif init<=0 || round(init)~=init || fin<0 || round(fin)~=fin || fin>handles.nframes
    mymsgbox(50,190,14,'Helvetica',{'Please, input a valid value for the initial and final frames.'},'Error','error')
elseif fin<=init
    mymsgbox(50,190,14,'Helvetica',{'The inital value must be lower than the final value'},'Error','error')
end

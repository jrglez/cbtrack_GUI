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

% Last Modified by GUIDE v2.5 28-Feb-2014 11:07:11

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
[in.folder,in.file{1},ext]=fileparts(fullfilein);
in.file{1}=[in.file{1} ext];
try
    in.analysis_protocol = splitdir(in.folder,'last');
catch ME
    in.analysis_protocol='';
    mymsgbox(50,190,14,'Helvetica','The file path is not valid','Error','error')        
end
set(handles.pushbutton_infile,'UserData',in)
if isempty(get(handles.pushbutton_outfile,'UserData'))
    out.folder=fullfile(in.folder,'ouput');
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
[in.file,in.folder]=open_files2(filetypes); %in.folder is a structure as is required by the main code. 
if in.file{1}~=0
    try
        in.analysis_protocol = splitdir(in.folder,'last');
    catch ME
        mymsgbox(50,190,14,'Helvetica','The file path is not valid','Error','error')
        
    end
    set(handles.edit_infile,'String',[in.folder,in.file{1}])
    set(handles.pushbutton_infile,'UserData',in)
    if isempty(get(handles.pushbutton_outfile,'UserData'))
        out.folder=fullfile(in.folder,'ouput');
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
[restart_file,restart_folder]=open_files2('mat');  
if restart_file{1}~=0
    restart=fullfile(restart_folder,restart_file{1});
    set(handles.edit_restart,'String',restart)
end


% --- Executes on button press in checkbox_restart.
function checkbox_restart_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.text_restart,'enable','on')
    set(handles.edit_restart,'enable','on')
    set(handles.pushbutton_restart,'enable','on')
    set(handles.pushbutton_infile,'enable','off')
    set(handles.text_infile,'enable','off')
    set(handles.edit_infile,'enable','off')
    set(handles.pushbutton_outfile,'enable','off')
    set(handles.text_outfile,'enable','off')
    set(handles.edit_outfile,'enable','off')
    set(handles.pushbutton_outfile,'enable','off')
    set(handles.checkbox_savetemp,'Enable','off')
elseif ~get(hObject,'Value')
    set(handles.text_restart,'enable','off')
    set(handles.edit_restart,'enable','off')
    set(handles.pushbutton_restart,'enable','off')
    set(handles.pushbutton_infile,'enable','on')
    set(handles.text_infile,'enable','on')
    set(handles.edit_infile,'enable','on')
    set(handles.pushbutton_outfile,'enable','on')
    set(handles.text_outfile,'enable','on')
    set(handles.edit_outfile,'enable','on')
    set(handles.pushbutton_outfile,'enable','on')
    set(handles.checkbox_savetemp,'Enable','on')
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_restart


% --- Executes on button press in checkbox_savetemp.
function checkbox_savetemp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_savetemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_savetemp


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

if get(handles.checkbox_restart,'Value');
    restart=get(handles.edit_restart,'String');
    if exist(restart,'file')
        load(restart);
        logfid=open_log('track_log',cbparams,out.folder); %#ok<NODEF>
        fprintf(logfid,'\n\n***\nRestarting experiment %s from %s at %s\n',experiment,restart,datestr(now,'yyyymmddTHHMMSS')); %#ok<NODEF>
        appdatalist={'cancel_hwait','expdir','experiment','moviefile','out','analysis_protocol','P_stage','cbparams','restart','GUIscale','startframe','endframe','BG','fidBG','roidata','visdata','pff_all','t','trackdata','debugdata_WT'};
        for i=1:length(appdatalist)
            if exist(appdatalist{i},'var')
                setappdata(0,appdatalist{i},eval(appdatalist{i}))
            end
        end
        if ishandle(handles.figure1)
            delete(handles.figure1)
        end
        if strcmp(P_stage,'track2') 
                CourtshipBowlTrack_GUI2
                iscancel=getappdata(0,'iscancel');
                if iscancel
                    if iscancel==1
                        cancelar
                    end
                    return
                end
                CourtshipBowlMakeResultsMovie_GUI
                pffdata = CourtshipBowlComputePerFrameFeatures_GUI(1);
                setappdata(0,'pffdata',pffdata)
                cancelar
        elseif strcmp(P_stage,'track1')
            if isfield(roidata,'nflies_per_roi')
                if cbparams.track.DEBUG 
                    cbtrackGUI_tracker_video
                elseif ~cbparams.track.DEBUG
                    cbtrackGUI_tracker_NOvideo
                end
            else
                cbtrackGUI_tracker
            end
        elseif strcmp(P_stage,'wing_params')
            cbtrackGUI_WingTracker
        elseif strcmp(P_stage,'params')
            cbtrackGUI_tracker
        elseif strcmp(P_stage,'ROIs')
            cbtrackGUI_ROI
        elseif strcmp(P_stage,'BG')
            cbtrackGUI_BG
        end    
    else
        msg_error=mymsgbox(50,190,14,'Helvetica',{'File does not exist'},'Error','error','modal');
    end
else
    restart=[];
    in=get(handles.pushbutton_infile,'UserData');
    expdir=in.folder;
    out=get(handles.pushbutton_outfile,'UserData');
    out.temp=['Temp_',datestr(now,TimestampFormat),'_',in.analysis_protocol,'.mat'];
    out.temp_full=fullfile(out.folder,out.temp);
    moviefile=fullfile(expdir,in.file{1});
    analysis_protocol=in.analysis_protocol;
    experiment=in.analysis_protocol;
    experiment(experiment=='_')=' ';

    if exist(moviefile, 'file')
        % auto checks
        paramsfilestr='params.xml';
        cbparams = ReadXMLParams(fullfile(expdir,paramsfilestr)); 
        if ~isfield(cbparams.track,'DEBUG')
            cbparams.track.DEBUG=false;
        end

        if ~get(handles.checkbox_savetemp,'Value')
            cbparams.dataloc.ufmf_log.filestr=[];
            cbparams.dataloc.fbdc_log.filestr=[];
            cbparams.dataloc.automaticchecks_incoming_log.filestr=[];
            cbparams.dataloc.bg_log.filestr=[];
            cbparams.dataloc.roi_log.filestr=[];
            cbparams.dataloc.track_log.filestr=[];
            cbparams.dataloc.perframefeature_log.filestr=[];
            cbparams.dataloc.resultsmovie_log.filestr=[];
            cbparams.dataloc.automaticchecks_complete_log.filestr=[];
        end
        setappdata(0,'cbparams',cbparams)

        hwait=waitbar(1,'Checking files.');
        setappdata(0,'out',out);
        [issuccess,msgs,iserror] = CourtshipBowlAutomaticChecks_Incoming(expdir,'analysis_protocol',in.analysis_protocol); %#ok<*NASGU>
        if ~issuccess,
            logfid=open_log('automaticchecks_incoming_log',cbparams,out.folder);
            fprintf(logfid, '\nAuto checks incoming failed for experiment %s\n',experiment);
            fprintf(logfid, '%s\n',msgs{:});
        end

        if ishandle(hwait)
            delete(hwait)
        end
        if ~exist(out.folder,'dir')
            mkdir(out.folder)
        end
        setappdata(0,'expdir',expdir)
        setappdata(0,'experiment',experiment);
        setappdata(0,'moviefile',moviefile)
        setappdata(0,'analysis_protocol',analysis_protocol)
        setappdata(0,'restart',restart)
        setappdata(0,'P_stage','BG')
        savetemp
        if ishandle(handles.figure1)
            delete(handles.figure1)
        end
        cbtrackGUI_BG
    else
        msg_error=mymsgbox(50,190,14,'Helvetica',{'File does not exist'},'Error','error','modal');
    end
end



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

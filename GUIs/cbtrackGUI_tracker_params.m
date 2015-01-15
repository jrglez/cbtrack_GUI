function varargout = cbtrackGUI_tracker_params(varargin)
% CBTRACKGUI_TRACKER_PARAMS MATLAB code for cbtrackGUI_tracker_params.fig
%      CBTRACKGUI_TRACKER_PARAMS, by itself, creates a new CBTRACKGUI_TRACKER_PARAMS or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_TRACKER_PARAMS returns the handle to a new CBTRACKGUI_TRACKER_PARAMS or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_TRACKER_PARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_TRACKER_PARAMS.M with the given input arguments.
%
%      CBTRACKGUI_TRACKER_PARAMS('Property','Value',...) creates a new CBTRACKGUI_TRACKER_PARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_tracker_params_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_tracker_params_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_tracker_params

% Last Modified by GUIDE v2.5 28-May-2014 13:39:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_tracker_params_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_tracker_params_OutputFcn, ...
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


function cbtrackGUI_tracker_params_OpeningFcn(hObject, eventdata, handles, varargin)
% Set parameters in the gui
temp_Tparams=varargin{1};
handles_tracker=varargin{2};
vign=get(handles_tracker.pushbutton_trset,'UserData');
H0=get(handles_tracker.edit_set_first,'UserData');

set(handles.checkbox_debug,'Value',temp_Tparams.DEBUG)
set(handles.edit_duration_initial,'String',num2str(temp_Tparams.firstframetrack))
set(handles.edit_duration_final,'String',num2str(temp_Tparams.lastframetrack))
set(handles.checkbox_wings,'Value',temp_Tparams.dotrackwings)
if temp_Tparams.dotrackwings
   set(handles.radiobutton_ID_wings,'Enable','on')
end
if strcmp(temp_Tparams.assignidsby,'size')
    set(handles.uipanel_ID,'selectedobject',handles.radiobutton_ID_body)
elseif strcmp(temp_Tparams.assignidsby,'wingsize')
    set(handles.uipanel_ID,'selectedobject',handles.radiobutton_ID_wings)
end

set(handles.figure1,'UserData',temp_Tparams)
set(handles.pushbutton_accept,'UserData',handles_tracker)
set(handles.pushbutton_cancel,'UserData',temp_Tparams)
set(handles.pushbutton_advanced,'UserData',vign)
set(handles.checkbox_wings,'UserData',H0)

% Choose default command line output for cbtrackGUI_tracker_params
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);


function varargout = cbtrackGUI_tracker_params_OutputFcn(hObject, eventdata, handles) 
varargout{1} = get(handles.figure1,'UserData');
varargout{2} = get(handles.pushbutton_advanced,'UserData');
varargout{3} = get(handles.checkbox_wings,'UserData');

if isfield(handles,'figure1') && ishandle(handles.figure1)
    delete(handles.figure1)
end


function edit_duration_initial_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


function edit_duration_initial_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_duration_final_Callback(hObject, eventdata, handles)


function edit_duration_final_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_advanced_Callback(hObject, eventdata, handles)
temp_Tparams=get(handles.figure1,'UserData');
handles_tracker=get(handles.pushbutton_accept,'UserData');
[temp_Tparams,vign,H0]=advanced_track(temp_Tparams,handles_tracker);
set(handles.figure1,'UserData',temp_Tparams)
set(handles.pushbutton_advanced,'UserData',vign)
set(handles.checkbox_wings,'UserData',H0)



function checkbox_wings_Callback(hObject, eventdata, handles)
dotrackwings=get(hObject,'Value');
if dotrackwings
    set(handles.radiobutton_ID_wings,'Enable','on')
else
    set(handles.radiobutton_ID_wings,'Enable','off')
    set(handles.uipanel_ID,'selectedobject',handles.radiobutton_ID_body)
    uipanel_ID_SelectionChangeFcn(handles.uipanel_ID, handles)
end


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)


function pushbutton_accept_Callback(hObject, eventdata, handles)
temp_Tparams=get(handles.figure1,'UserData');
temp_Tparams.DEBUG=get(handles.checkbox_debug, 'Value');
ID=get(handles.uipanel_ID,'SelectedObject');
if ID==handles.radiobutton_ID_body
    temp_Tparams.assignidsby='size';
    temp_Tparams.typefield='sex';
    temp_Tparams.typesmallval='M';
    temp_Tparams.typebigval='F';
elseif ID==handles.radiobutton_ID_wings
    temp_Tparams.assignidsby='wingsize';
    temp_Tparams.typefield='wingtype';
    temp_Tparams.typesmallval='clipped';
    temp_Tparams.typebigval='full';
end
ini=get(handles.edit_duration_initial,'String');
fin=get(handles.edit_duration_final,'String');
if strcmp(ini,'Initial')
    ini=num2str(temp_Tparams.firstframetrack);
end
if strcmp(fin,'Final')
    fin=num2str(temp_Tparams.lastframetrack);
end
    ini=str2double(ini);
    fin=str2double(fin);
if isnan(ini) || isnan(fin) 
    mymsgbox(50,190,14,'Helvetica','Video duration parameters must be numeric or Inf','Error','error')
elseif ini>fin
    mymsgbox(50,190,14,'Helvetica','The final frame  must be smaller than the last one','Error','error')
else
    temp_Tparams.firstframetrack=ini;
    temp_Tparams.lastframetrack=fin;
end
temp_Tparams.dotrackwings=logical(get(handles.checkbox_wings,'Value'));
set(handles.figure1,'UserData',temp_Tparams);
uiresume(handles.figure1)


function uipanel_ID_SelectionChangeFcn(hObject, eventdata, handles)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
old_Tparams=get(handles.pushbutton_cancel,'UserData');
handles_tracker=get(handles.pushbutton_accept,'UserData');
update_fh=handles_tracker.update_fh;
visdata=handles_tracker.visdata;
vign=get(handles_tracker.pushbutton_trset,'UserData');
H0=get(handles_tracker.edit_set_first,'UserData');

update_fh(handles_tracker,old_Tparams,visdata,vign,H0);

set(handles.figure1,'UserData',old_Tparams)
set(handles.pushbutton_advanced,'UserData',vign)
set(handles.checkbox_wings,'UserData',H0)
uiresume(handles.figure1);


function checkbox_debug_Callback(hObject, eventdata, handles)

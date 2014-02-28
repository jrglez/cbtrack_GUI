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

% Last Modified by GUIDE v2.5 08-Dec-2013 11:21:01

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


% --- Executes just before cbtrackGUI_tracker_params is made visible.
function cbtrackGUI_tracker_params_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_tracker_params (see VARARGIN)

% Set parameters in the gui
temp_Tparams=varargin{1};
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

% Choose default command line output for cbtrackGUI_tracker_params
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

% UIWAIT makes cbtrackGUI_tracker_params wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_tracker_params_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.figure1,'UserData');
if isfield(handles,'figure1') && ishandle(handles.figure1)
    delete(handles.figure1)
end





function edit_duration_initial_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to edit_duration_initial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_duration_initial as text
%        str2double(get(hObject,'String')) returns contents of edit_duration_initial as a double


% --- Executes during object creation, after setting all properties.
function edit_duration_initial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_duration_initial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_duration_final_Callback(hObject, eventdata, handles)
% hObject    handle to edit_duration_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_duration_final as text
%        str2double(get(hObject,'String')) returns contents of edit_duration_final as a double


% --- Executes during object creation, after setting all properties.
function edit_duration_final_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_duration_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ID_advanced.
function pushbutton_ID_advanced_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ID_advanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_orient_advanced.
function pushbutton_orient_advanced_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_orient_advanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_wings.
function checkbox_wings_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_wings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dotrackwings=get(hObject,'Value');
if dotrackwings
    set(handles.radiobutton_ID_wings,'Enable','on')
else
    set(handles.radiobutton_ID_wings,'Enable','off')
    set(handles.uipanel_ID,'selectedobject',handles.radiobutton_ID_body)
    uipanel_ID_SelectionChangeFcn(handles.uipanel_ID, handles)
end

% Hint: get(hObject,'Value') returns toggle state of checkbox_wings


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1)


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes when selected object is changed in uipanel_ID.
function uipanel_ID_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_ID 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1);

% --- Executes on button press in checkbox_debug.
function checkbox_debug_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_debug

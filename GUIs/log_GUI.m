function varargout = log_GUI(varargin)
% LOG_GUI MATLAB code for log_GUI.fig
%      LOG_GUI, by itself, creates a new LOG_GUI or raises the existing
%      singleton*.
%
%      H = LOG_GUI returns the handle to a new LOG_GUI or the handle to
%      the existing singleton*.
%
%      LOG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOG_GUI.M with the given input arguments.
%
%      LOG_GUI('Property','Value',...) creates a new LOG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before log_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to log_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help log_GUI

% Last Modified by GUIDE v2.5 18-Jun-2014 09:35:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @log_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @log_GUI_OutputFcn, ...
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


function log_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
set(handles.listbox_log,'UserData',false);

% Choose default command line output for log_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function varargout = log_GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = [handles.text_exp,handles.listbox_log];



function edit1_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function listbox_log_Callback(hObject, eventdata, handles)


function listbox_log_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);




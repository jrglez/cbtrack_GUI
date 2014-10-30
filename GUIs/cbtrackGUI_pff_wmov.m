function varargout = cbtrackGUI_pff_wmov(varargin)
% CBTRACKGUI_PFF_WMOV MATLAB code for cbtrackGUI_pff_wmov.fig
%      CBTRACKGUI_PFF_WMOV, by itself, creates a new CBTRACKGUI_PFF_WMOV or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_PFF_WMOV returns the handle to a new CBTRACKGUI_PFF_WMOV or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_PFF_WMOV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_PFF_WMOV.M with the given input arguments.
%
%      CBTRACKGUI_PFF_WMOV('Property','Value',...) creates a new CBTRACKGUI_PFF_WMOV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_pff_wmov_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_pff_wmov_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_pff_wmov

% Last Modified by GUIDE v2.5 03-Dec-2013 17:42:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_pff_wmov_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_pff_wmov_OutputFcn, ...
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


% --- Executes just before cbtrackGUI_pff_wmov is made visible.
function cbtrackGUI_pff_wmov_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_pff_wmov (see VARARGIN)
pff_all=getappdata(0,'pff_all');
iswmov=cellfun(@(x) any(x==8), {pff_all(:).type});
pff_wmov=pff_all(iswmov);
nr=9;
nc=2; 
uipos_x=linspace(50,250,nc);
uipos_y=linspace(325,75,nr);
[uipos_X,uipos_Y]=meshgrid(uipos_x,uipos_y);
handles.checkbox_all=NaN(size(pff_wmov));
for i=1:length(pff_wmov)
    handles.checkbox_all(i)=uicontrol('Style','checkbox','units','pixels',...
        'Position',[uipos_X(i),uipos_Y(i),200,25],'String',pff_app(i).name,...
        'FontName','Arial','FontSize',12,'TooltipString',pff_app(i).description,...
        'Value',pff_app(i).on);
end

% Choose default command line output for cbtrackGUI_pff_wmov
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cbtrackGUI_pff_wmov wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_pff_wmov_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_select_all.
function checkbox_select_all_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to checkbox_select_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_on=get(hObject,'Value');
if all_on
    set(handles.checkbox_all,'Value',true)
elseif ~all_on
    set(handles.checkbox_all,'Value',false)
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_select_all


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1)


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pff_all=getappdata(0,'pff_all');
iswmov=cellfun(@(x) any(x==8), {pff_all(:).type});
pff_on=num2cell(cellfun(@(x) logical(x),get(handles.checkbox_all,'Value')));
[pff_all(iswmov).on]=deal(pff_on{:});
setappdata(0,'pff_all',pff_all)
delete(handles.figure1)

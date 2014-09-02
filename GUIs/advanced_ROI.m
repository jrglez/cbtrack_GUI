function varargout = advanced_ROI(varargin)
% ADVANCED_ROI MATLAB code for advanced_ROI.fig
%      ADVANCED_ROI, by itself, creates a new ADVANCED_ROI or raises the existing
%      singleton*.
%
%      H = ADVANCED_ROI returns the handle to a new ADVANCED_ROI or the handle to
%      the existing singleton*.
%
%      ADVANCED_ROI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCED_ROI.M with the given input arguments.
%
%      ADVANCED_ROI('Property','Value',...) creates a new ADVANCED_ROI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before advanced_ROI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to advanced_ROI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help advanced_ROI

% Last Modified by GUIDE v2.5 29-Aug-2014 15:53:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advanced_ROI_OpeningFcn, ...
                   'gui_OutputFcn',  @advanced_ROI_OutputFcn, ...
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


function advanced_ROI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

temp_ROIparams=varargin{1};

params_fields=fieldnames(temp_ROIparams);
handles_edits=findobj(struct2array(handles),'Style','edit');
handles_edits=unique(handles_edits);
tags_edits=get(handles_edits,'Tag');
tags_edits=cellfun(@(x) x(6:end),tags_edits,'UniformOutput',false);
common=intersect(tags_edits,params_fields);
edits_fields=cellfun(@(x) ['edit_',x],common,'UniformOutput',false);
for i=1:numel(common)
    set(handles.(edits_fields{i}),'String',num2str(temp_ROIparams.(common{i})));
end

set(handles.figure1,'UserData',temp_ROIparams)
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1)



function varargout = advanced_ROI_OutputFcn(hObject, eventdata, handles) 
if isfield(handles,'figure1') && ishandle(handles.figure1)
    varargout{1} = get(handles.figure1,'UserData');
    delete(handles.figure1)
end


function edit_maxdcenter_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>


function edit_maxdcenter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_maxdradius_Callback(hObject, eventdata, handles)


function edit_maxdradius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_nbinscenter_Callback(hObject, eventdata, handles)


function edit_nbinscenter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_nbinsradius_Callback(hObject, eventdata, handles)


function edit_nbinsradius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)


function pushbutton_accept_Callback(hObject, eventdata, handles)
temp_ROIparams=get(handles.figure1,'UserData');

params_fields=fieldnames(temp_ROIparams);
handles_edits=findobj(struct2array(handles),'Style','edit');
handles_edits=unique(handles_edits);
tags_edits=get(handles_edits,'Tag');
tags_edits=cellfun(@(x) x(6:end),tags_edits,'UniformOutput',false);
[common,iedits]=intersect(tags_edits,params_fields);
value_edits=str2double(get(handles_edits(iedits),'String'));
if any(isnan(value_edits))
    mymsgbox(50,190,14,'Helvetica','Invalid parameters','Error','error')
    return
end
for i=1:numel(common);
    temp_ROIparams.(common{i})=value_edits(i);
end

set(handles.figure1,'UserData',temp_ROIparams)

uiresume(handles.figure1)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
uiresume(handles.figure1);


function edit_meanroiradius_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_meanroiradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meanroiradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

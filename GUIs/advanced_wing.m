function varargout = advanced_wing(varargin)
% ADVANCED_WING MATLAB code for advanced_wing.fig
%      ADVANCED_WING, by itself, creates a new ADVANCED_WING or raises the existing
%      singleton*.
%
%      H = ADVANCED_WING returns the handle to a new ADVANCED_WING or the handle to
%      the existing singleton*.
%
%      ADVANCED_WING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCED_WING.M with the given input arguments.
%
%      ADVANCED_WING('Property','Value',...) creates a new ADVANCED_WING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before advanced_wing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to advanced_wing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help advanced_wing

% Last Modified by GUIDE v2.5 15-Oct-2014 19:33:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advanced_wing_OpeningFcn, ...
                   'gui_OutputFcn',  @advanced_wing_OutputFcn, ...
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


function advanced_wing_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

temp_Wparams=varargin{1};
f=varargin{2};
debugdata=varargin{3};
debugdata.f=f;

params_fields=fieldnames(temp_Wparams);
handles_edits=findobj(struct2array(handles),'Style','edit');
handles_edits=unique(handles_edits);
tags_edits=get(handles_edits,'Tag');
tags_edits=cellfun(@(x) x(6:end),tags_edits,'UniformOutput',false);
common=intersect(tags_edits,params_fields);
edits_fields=cellfun(@(x) ['edit_',x],common,'UniformOutput',false);
for i=1:numel(common)
    set(handles.(edits_fields{i}),'String',num2str(temp_Wparams.(common{i})));
end

set(handles.edit_wing_frac_filter1,'String',num2str(temp_Wparams.wing_frac_filter(1)))
set(handles.edit_wing_frac_filter2,'String',num2str(temp_Wparams.wing_frac_filter(2)))
set(handles.edit_wing_frac_filter3,'String',num2str(temp_Wparams.wing_frac_filter(3)))

set(handles.figure1,'UserData',temp_Wparams)
set(handles.pushbutton_apply,'UserData',debugdata)
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1)



function varargout = advanced_wing_OutputFcn(hObject, eventdata, handles) 
if isfield(handles,'figure1') && ishandle(handles.figure1)
    varargout{1} = get(handles.figure1,'UserData');
    varargout{2} = get(handles.pushbutton_apply,'UserData');    
    delete(handles.figure1)
end


function edit_max_wingcc_dist_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>


function edit_max_wingcc_dist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_max_wingpx_angle_Callback(hObject, eventdata, handles)


function edit_max_wingpx_angle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wing_frac_filter2_Callback(hObject, eventdata, handles)


function edit_wing_frac_filter2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_radius_open_wing_Callback(hObject, eventdata, handles)


function edit_radius_open_wing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_min_nonzero_wing_angle_Callback(hObject, eventdata, handles)


function edit_min_nonzero_wing_angle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_nbins_dthetawing_Callback(hObject, eventdata, handles)


function edit_nbins_dthetawing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_radius_dilate_body_Callback(hObject, eventdata, handles)


function edit_radius_dilate_body_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wing_min_peak_dist_bins_Callback(hObject, eventdata, handles)


function edit_wing_min_peak_dist_bins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wing_min_peak_threshold_frac_Callback(hObject, eventdata, handles)


function edit_wing_min_peak_threshold_frac_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wing_radius_quadfit_bins_Callback(hObject, eventdata, handles)


function edit_wing_radius_quadfit_bins_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wing_frac_filter3_Callback(hObject, eventdata, handles)


function edit_wing_frac_filter3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_wing_frac_filter1_Callback(hObject, eventdata, handles)


function edit_wing_frac_filter1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)


function pushbutton_accept_Callback(hObject, eventdata, handles)
temp_Wparams=get(handles.figure1,'UserData');
debugdata=get(handles.pushbutton_apply,'UserData');

params_fields=fieldnames(temp_Wparams);
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
    temp_Wparams.(common{i})=value_edits(i);
end
temp_Wparams.wing_frac_filter=[str2double(get(handles.edit_wing_frac_filter1,'String')),...
    str2double(get(handles.edit_wing_frac_filter2,'String')),...
    str2double(get(handles.edit_wing_frac_filter3,'String'))];

if debugdata.vis>3
    f=debugdata.f;
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    visdata=getappdata(0,'visdata');
    debugdata=TrackWingsSingle_GUI(visdata.trxW(:,f),bgmed,temp_Wparams,visdata.framesW{f},visdata.dbkgdW{f},debugdata);
end
debugdata=rmfield(debugdata,'f');

set(handles.figure1,'UserData',temp_Wparams)
set(handles.pushbutton_apply,'UserData',debugdata)

uiresume(handles.figure1)


function pushbutton_apply_Callback(hObject, eventdata, handles)
temp_Wparams=get(handles.figure1,'UserData');
debugdata=get(handles.pushbutton_apply,'UserData');

params_fields=fieldnames(temp_Wparams);
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
    temp_Wparams.(common{i})=value_edits(i);
end
temp_Wparams.wing_frac_filter=[str2double(get(handles.edit_wing_frac_filter1,'String')),...
    str2double(get(handles.edit_wing_frac_filter2,'String')),...
    str2double(get(handles.edit_wing_frac_filter3,'String'))];

if debugdata.vis>3
    f=debugdata.f;
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    visdata=getappdata(0,'visdata');
    debugdata=TrackWingsSingle_GUI(visdata.trxW(:,f),bgmed,temp_Wparams,visdata.framesW{f},visdata.dbkgdW{f},debugdata);
end

set(handles.pushbutton_apply,'UserData',debugdata)
    

function figure1_CloseRequestFcn(hObject, eventdata, handles)
temp_Wparams=get(handles.figure1,'UserData');
debugdata=get(handles.pushbutton_apply,'UserData');
if debugdata.vis>3
    f=debugdata.f;
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    visdata=getappdata(0,'visdata');
    debugdata=TrackWingsSingle_GUI(visdata.trxW(:,f),bgmed,isarena,temp_Wparams,visdata.framesW{f},visdata.dbkgfW{f},debugdata);
end

set(handles.pushbutton_apply,'UserData',debugdata)

uiresume(handles.figure1);

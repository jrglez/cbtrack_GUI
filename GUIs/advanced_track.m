function varargout = advanced_track(varargin)
%ADVANCED_TRACK M-file for advanced_track.fig
%      ADVANCED_TRACK, by itself, creates a new ADVANCED_TRACK or raises the existing
%      singleton*.
%
%      H = ADVANCED_TRACK returns the handle to a new ADVANCED_TRACK or the handle to
%      the existing singleton*.
%
%      ADVANCED_TRACK('Property','Value',...) creates a new ADVANCED_TRACK using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to advanced_track_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ADVANCED_TRACK('CALLBACK') and ADVANCED_TRACK('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ADVANCED_TRACK.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help advanced_track

% Last Modified by GUIDE v2.5 14-Oct-2014 18:00:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advanced_track_OpeningFcn, ...
                   'gui_OutputFcn',  @advanced_track_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


function advanced_track_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

temp_Tparams=varargin{1};
params_fields=fieldnames(temp_Tparams);
handles_edits=findobj(struct2array(handles),'Style','edit');
handles_edits=unique(handles_edits);
tags_edits=get(handles_edits,'Tag');
tags_edits=cellfun(@(x) x(6:end),tags_edits,'UniformOutput',false);
common=intersect(tags_edits,params_fields);
edits_fields=cellfun(@(x) ['edit_',x],common,'UniformOutput',false);
for i=1:numel(common)
    set(handles.(edits_fields{i}),'String',num2str(temp_Tparams.(common{i})));
end

set(handles.checkbox_usemediandt,'Value',temp_Tparams.usemediandt)

set(handles.figure1,'UserData',temp_Tparams)
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1)


function varargout = advanced_track_OutputFcn(hObject, eventdata, handles)
if isfield(handles,'figure1') && ishandle(handles.figure1)
    varargout{1} = get(handles.figure1,'UserData');
    delete(handles.figure1)
end




function checkbox_usemediandt_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


function edit_choose_orientations_velocity_angle_weight_Callback(hObject, eventdata, handles)


function edit_choose_orientations_velocity_angle_weight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_choose_orientations_max_velocity_angle_weight_Callback(hObject, eventdata, handles)


function edit_choose_orientations_max_velocity_angle_weight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_choose_orientations_weight_theta_Callback(hObject, eventdata, handles)


function edit_choose_orientations_weight_theta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_choose_orientations_max_ecc_confident_Callback(hObject, eventdata, handles)


function edit_choose_orientations_max_ecc_confident_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_choose_orientations_min_ecc_factor_Callback(hObject, eventdata, handles)


function edit_choose_orientations_min_ecc_factor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_choose_orientations_min_jump_speed_Callback(hObject, eventdata, handles)


function edit_choose_orientations_min_jump_speed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_err_weightpos_Callback(hObject, eventdata, handles)


function edit_err_weightpos_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_err_weighttheta_Callback(hObject, eventdata, handles)


function edit_err_weighttheta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_err_weightarea_Callback(hObject, eventdata, handles)


function edit_err_weightarea_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gmmem_precision_Callback(hObject, eventdata, handles)


function edit_gmmem_precision_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gmmem_maxiters_Callback(hObject, eventdata, handles)


function edit_gmmem_maxiters_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gmmem_min_obsprior_Callback(hObject, eventdata, handles)


function edit_gmmem_min_obsprior_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gmmem_nrestarts_firstframe_Callback(hObject, eventdata, handles)


function edit_gmmem_nrestarts_firstframe_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_err_dampen_priors_Callback(hObject, eventdata, handles)


function edit_err_dampen_priors_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_err_dampen_pos_Callback(hObject, eventdata, handles)


function edit_err_dampen_pos_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_err_dampen_theta_Callback(hObject, eventdata, handles)


function edit_err_dampen_theta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)


function pushbutton_accept_Callback(hObject, eventdata, handles)
temp_Tparams=get(handles.figure1,'UserData');
temp_Tparams.usemediandt=get(handles.checkbox_usemediandt,'Value');

params_fields=fieldnames(temp_Tparams);
handles_edits=findobj(struct2array(handles),'Style','edit');
handles_edits=unique(handles_edits);
value_edits=str2double(get(handles_edits,'String'));
if any(isnan(value_edits))
    mymsgbox(50,190,14,'Helvetica','Invalid parameters','Error','error')
    return
end
tags_edits=get(handles_edits,'Tag');
tags_edits=cellfun(@(x) x(6:end),tags_edits,'UniformOutput',false);
[common,iedits]=intersect(tags_edits,params_fields);
for i=1:numel(tags_edits);
    temp_Tparams.(common{i})=value_edits(iedits(i));
end
set(handles.figure1,'UserData',temp_Tparams)

uiresume(handles.figure1)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
uiresume(handles.figure1);


function edit_bgthresh_low_Callback(hObject, eventdata, handles)


function edit_bgthresh_low_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

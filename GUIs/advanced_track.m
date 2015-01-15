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

% Last Modified by GUIDE v2.5 13-Jan-2015 10:22:50

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
handles_tracker=varargin{2};
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
set(handles.checkbox_devignet,'Value',~isempty(temp_Tparams.vign_coef))
set(handles.checkbox_normalize,'Value',temp_Tparams.normalize)

set(handles.popupmenu_eq,'Value',temp_Tparams.eq_method+1)

if temp_Tparams.computeBG
    set(handles.checkbox_devignet,'Enable','off')
    set(handles.pushbutton_vign,'Enable','off')
    set(handles.text_eq,'Enable','off')
    set(handles.popupmenu_eq,'Enable','off')
end
    
set(handles.figure1,'UserData',temp_Tparams)
set(handles.pushbutton_apply,'UserData',handles_tracker)
set(handles.pushbutton_vign,'UserData',temp_Tparams.vign_coef)
% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1)


function varargout = advanced_track_OutputFcn(hObject, eventdata, handles)
if isfield(handles,'figure1') && ishandle(handles.figure1)
    varargout{1} = get(handles.figure1,'UserData');
    varargout{2} = get(handles.pushbutton_vign,'UserData');
    varargout{3} = get(handles.popupmenu_eq,'UserData');
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
handles_tracker=get(handles.pushbutton_apply,'UserData');
update_fh=handles_tracker.update_fh;
visdata=handles_tracker.visdata;
cbparams=getappdata(0,'cbparams');

temp_Tparams.usemediandt=get(handles.checkbox_usemediandt,'Value');
temp_Tparams.normalize=get(handles.checkbox_normalize,'Value');
if get(handles.checkbox_devignet,'Value');
    temp_Tparams.vign_coef=get(handles.pushbutton_vign,'Userdata');
    if isempty(temp_Tparams.vign_coef) || all(temp_Tparams.vign_coef==[1 0 0 0 0 0 0 0 0 0])
        msg_vign=myquestdlg(14,'Helvetica','You need to estimate the vignetting function to devignet the video. Estimate function?','Devignetting','Yes','No','No'); 
        if strcmp(msg_vign,'Yes')
            temp_Tparams.vign_coef=compute_vignetting_GUI(temp_Tparams,cbparams.detect_rois);
        else
            temp_Tparams.vign_coef=[1 0 0 0 0 0 0 0 0 0];
        end
    end
else
    temp_Tparams.vign_coef=[1 0 0 0 0 0 0 0 0 0];
end
frame=visdata.frames{1};
[X,Y]=meshgrid(1:size(frame,2),1:size(frame,1));
A=temp_Tparams.vign_coef;
vign=ones(size(X)).*A(1)+X.*A(2)+Y.*A(3)+X.^2.*A(4)+X.*Y.*A(5)+Y.^2.*A(6)+X.^3.*A(7)+X.^2.*Y.*A(8)+X.*Y.^2.*A(9)+Y.^3.*A(10);

temp_Tparams.eq_method=get(handles.popupmenu_eq,'Value')-1;
if any(temp_Tparams.eq_method==[1,2])
    H0=base_hist(temp_Tparams,cbparams.detect_rois);
else
    H0=[];
end
    
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

update_fh(handles_tracker,temp_Tparams,visdata,vign,H0);

set(handles.figure1,'UserData',temp_Tparams)
set(handles.pushbutton_vign,'UserData',vign)
set(handles.popupmenu_eq,'UserData',H0)

uiresume(handles.figure1)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
temp_Tparams=get(handles.figure1,'UserData');
handles_tracker=get(handles.pushbutton_apply,'UserData');
update_fh=handles_tracker.update_fh;
visdata=handles_tracker.visdata;
vign=get(handles_tracker.pushbutton_trset,'UserData');
H0=get(handles_tracker.edit_set_first,'UserData');

update_fh(handles_tracker,temp_Tparams,visdata,vign,H0);

set(handles.pushbutton_vign,'UserData',vign)
set(handles.popupmenu_eq,'UserData',H0)

uiresume(handles.figure1);


function edit_bgthresh_low_Callback(hObject, eventdata, handles)


function edit_bgthresh_low_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_apply_Callback(hObject, eventdata, handles)
temp_Tparams=get(handles.figure1,'UserData');
handles_tracker=get(handles.pushbutton_apply,'UserData');
update_fh=handles_tracker.update_fh;
visdata=handles_tracker.visdata;
cbparams=getappdata(0,'cbparams');

temp_Tparams.usemediandt=get(handles.checkbox_usemediandt,'Value');
temp_Tparams.normalize=get(handles.checkbox_normalize,'Value');
if get(handles.checkbox_devignet,'Value');
    temp_Tparams.vign_coef=get(handles.pushbutton_vign,'Userdata');
    if isempty(temp_Tparams.vign_coef) || all(temp_Tparams.vign_coef==[1 0 0 0 0 0 0 0 0 0])
        msg_vign=myquestdlg(14,'Helvetica','You need to estimate the vignetting function to devignet the video. Estimate function?','Devignetting','Yes','No','No'); 
        if strcmp(msg_vign,'Yes')
            temp_Tparams.vign_coef=compute_vignetting_GUI(temp_Tparams,cbparams.detect_rois);
        else
            temp_Tparams.vign_coef=[1 0 0 0 0 0 0 0 0 0];
        end
    end
else
    temp_Tparams.vign_coef=[1 0 0 0 0 0 0 0 0 0];
end
frame=visdata.frames{1};
[X,Y]=meshgrid(1:size(frame,2),1:size(frame,1));
A=temp_Tparams.vign_coef;
vign=ones(size(X)).*A(1)+X.*A(2)+Y.*A(3)+X.^2.*A(4)+X.*Y.*A(5)+Y.^2.*A(6)+X.^3.*A(7)+X.^2.*Y.*A(8)+X.*Y.^2.*A(9)+Y.^3.*A(10);

temp_Tparams.eq_method=get(handles.popupmenu_eq,'Value')-1;
if any(temp_Tparams.eq_method==[1,2])
    H0=base_hist(temp_Tparams,cbparams.detect_rois);
else
    H0=[];
end
    
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

update_fh(handles_tracker,temp_Tparams,visdata,vign,H0);

set(handles.pushbutton_vign,'Userdata',temp_Tparams.vign_coef)


function edit_radius_open_body_Callback(hObject, eventdata, handles)


function edit_radius_open_body_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_eq_Callback(hObject, eventdata, handles)


function popupmenu_eq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_normalize_Callback(hObject, eventdata, handles)


function checkbox_devignet_Callback(hObject, eventdata, handles)


function pushbutton_vign_Callback(hObject, eventdata, handles)
temp_Tparams=get(handles.figure1,'UserData');
cbparams=getappdata(0,'cbparams');
V_coeff=compute_vignetting_GUI(temp_Tparams,cbparams.detect_rois);
set(handles.pushbutton_vign,'UserData',V_coeff)


% function pushbutton_default_Callback(hObject, eventdata, handles)
% expdir=getappdata(0,'expdir');
% paramsfile=fullfile(expdir,'params.xml');
% defaultparams=ReadXMLParams(paramsfile);
% 
% temp_Tparams=get(handles.figure1,'UserData');
% params_fields=fieldnames(temp_Tparams);
% handles_edits=findobj(struct2array(handles),'Style','edit');
% handles_edits=unique(handles_edits);
% tags_edits=get(handles_edits,'Tag');
% tags_edits=cellfun(@(x) x(6:end),tags_edits,'UniformOutput',false);
% common=intersect(tags_edits,params_fields);
% edits_fields=cellfun(@(x) ['edit_',x],common,'UniformOutput',false);
% for i=1:numel(common)
%     temp_Tparams.(common{i})=defaultparams.track.(common{i});
%     set(handles.(edits_fields{i}),'String',num2str(temp_Tparams.(common{i})));
% end
% 
% set(handles.checkbox_usemediandt,'Value',temp_Tparams.usemediandt)
% 
% set(handles.figure1,'UserData',temp_Tparams)



function edit_choose_orientations_weight_Warea_Callback(hObject, eventdata, handles)
% hObject    handle to edit_choose_orientations_weight_Warea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_choose_orientations_weight_Warea as text
%        str2double(get(hObject,'String')) returns contents of edit_choose_orientations_weight_Warea as a double


% --- Executes during object creation, after setting all properties.
function edit_choose_orientations_weight_Warea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_choose_orientations_weight_Warea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

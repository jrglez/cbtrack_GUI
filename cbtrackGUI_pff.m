function varargout = cbtrackGUI_pff(varargin)
% CBTRACKGUI_PFF MATLAB code for cbtrackGUI_pff.fig
%      CBTRACKGUI_PFF, by itself, creates a new CBTRACKGUI_PFF or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_PFF returns the handle to a new CBTRACKGUI_PFF or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_PFF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_PFF.M with the given input arguments.
%
%      CBTRACKGUI_PFF('Property','Value',...) creates a new CBTRACKGUI_PFF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_pff_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_pff_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_pff

% Last Modified by GUIDE v2.5 05-Dec-2013 14:45:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_pff_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_pff_OutputFcn, ...
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


% --- Executes just before cbtrackGUI_pff is made visible.
function cbtrackGUI_pff_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_pff (see VARARGIN)
pff_names={'a_mm';'absanglefrom1to2_nose2ell';'absdtheta';'absdv_cor';...
    'absphidiff_anglesub';'absphidiff_nose2ell';'absthetadiff_anglesub';...
    'absthetadiff_nose2ell';'angle_biggest_wing';'angle_smallest_wing';...
    'angle2wall';'anglefrom1to2_anglesub';'anglefrom1to2_nose2ell';...
    'angleonclosestfly';'anglesub';'area';'area_inmost_wing';...
    'area_outmost_wing';'arena_angle';'arena_r';'b_mm';...
    'closestfly_anglesub';'closestfly_center';'closestfly_ell2nose';...
    'closestfly_nose2ell';'corfrac_maj';'corfrac_min';'da';...
    'dangle_biggest_wing';'dangle_smallest_wing';'dangle2wall';...
    'danglesub';'darea';'darea_inmost_wing';'darea_outmost_wing';...
    'db';'dcenter';'ddcenter';'ddist2wall';'decc';'dell2nose';...
    'dist2wall';'dmax_wing_angle';'dmax_wing_area';'dmin_wing_angle';...
    'dmin_wing_area';'dnose2ell';'dnose2ell_angle_30tomin30';...
    'dnose2ell_angle_min20to20';'dnose2ell_angle_min30to30';...
    'dnose2tail';'dnwingsdetected';'dphi';'dtheta';'du_cor';'du_ctr';...
    'du_tail';'dv_cor';'dv_ctr';'dv_tail';'dwing_angle_diff';...
    'dwing_angle_imbalance';'ecc';'flipdv_cor';'magveldiff_anglesub';...
    'magveldiff_nose2ell';'max_absdwing_angle';'max_absdwing_area';...
    'max_dwing_angle_in';'max_dwing_angle_out';'max_wing_angle';...
    'max_wing_area';'mean_wing_angle';'mean_wing_area';...
    'min_absdwing_angle';'min_absdwing_area';'min_dwing_angle_in';...
    'min_dwing_angle_out';'min_wing_angle';'min_wing_area';...
    'nflies_close';'nwingsdetected';'phi';'phisideways';'velmag';...
    'velmag_ctr';'velmag_nose';'velmag_tail';'veltoward_anglesub';...
    'veltoward_nose2ell';'wing_angle_diff';'wing_angle_imbalance';'yaw'};

pff_type={1;3;2;2;3;3;3;3;7;7;5;3;3;3;3;1;7;7;6;[5,6];1;4;4;4;4;2;2;1;8;...
    8;5;3;1;8;8;1;3;3;5;1;3;5;8;8;8;8;3;3;3;3;3;7;[2,6];2;2;2;2;2;2;2;8;...
    8;1;2;3;3;8;8;8;8;7;7;7;7;8;8;8;8;7;7;3;7;6;2;2;2;2;2;3;3;7;7;2};

pff_description={'Quarter major axis length (mm). This feature was not used for mice. Transformation: none, abs.';...
'Absolute difference between direction to closest animal based on dnose2ell and current animal''s orientation (rad). Transformations: none.';...
'Angular speed (rad/s) |dtheta|. Transformations: relative.';...
'Sideways speed of the animal''s center of rotation (defined by corfrac_maj and corfrac_min) (mm/s). Transformations: relative.';...
'Absolute difference in velocity direction between current animal and closest animal based on anglesub (rad). Transformations: none.';...
'Absolute difference in velocity direction between current animal and closest animal based on dnose2ell (rad) . Transformations: none.';...
'Absolute difference in orientation between current animal and closest animal based on anglesub (rad). Transformations: none.';...
'Absolute difference in orientation between this animal and closest animal based on dnose2ell (rad). Transformations: none.';...
'Angle of the bigger wing. The bigger wing is decided based on the detected area of the wings. Transformations: none.';...
'Angle of the smaller wing. The smaller wing is decided based on the detected area of the wings. Transformations: none.';...
'Angle to closest point on the arena wall from animal''s center, relative to the animal''s orientation (rad). Transformations: flip,abs.';...
'Angle to closest (based on angle subtended) animal''s centroid in current animal''s coordinate system. Metric that encodes the position of the closest animal relative to the current animal. Transformations: flip, abs.';...
'Angle to closest (based on distance from nose to ellipse) animal''s centroid in current animal''s coordinate system. Metric that encodes the position of the closest animal relative to the current animal. Transformations: flip, abs.';...
'Angle of the current animal''s centroid in the closest (based on distance from nose to ellipse) animal''s coordinate system. Metric that encodes the position of the closest animal relative to the current animal. Transformations: flip, abs.';...
'<html>Maximum total angle of animal''s field of view (fov) occluded by another animal (rad). The parameter fov that can be set, and for our classifier''s we set it to &pi radians. Transformations: none.</html>';...
'<html>Area of the ellipse (mm<sup>2</sup>). Transformations: none, relative.</html>';...
'Area of the wing that is closer to the body. Transformations: none, relative.';...
'Area of the wing that is further away from the body. Transformations: none, relative.';...
'Animal''s angular position in the arena measured as angle from x-axis. Transformations: none.';...
'Distance of animal''s center from arena''s center. Transformations: none.';...
'Quarter minor axis length (mm). Transformations: none, abs.';...
'Identity of closest animal, based on anglesub, which is the total angle of animal''s eld of view (fov) occluded by the other animal (rad). The parameter fov that can be set, and for our classifier''s we set it to  radians. Transformations: none.';...
'Identity of closest animal, based on dcenter. Transformations: none.';...
'Identity of closest animal, based on dell2nose. Transformations: none.';...
'Identity of closest animal, based on dnose2ell. Transformations: none.';...
'Projection of the center of rotation on the animal''s major axis (no units). This is a measure of the point on the animal that translates least from one frame to the next. It is 0 at the center of the animal, 1 at the forward tip of the major axis, and -1 and the backward tip of the major axis. Transformations: none, abs.';...
'Projection of the center of rotation on the animal''s minor axis (no units). This is a measure of the point on the animal that translates least from one frame to the next. It is 0 at the center of the animal, 1 at the right tip of the minor axis, and -1 and the backward tip of the minor axis. Transformations: flip, abs.';...
'Change in quarter major axis length from frame t to t+1 (mm/s). Transformations: none, abs.';...
'Change in the angle of the bigger wing. The bigger wing is decided based on the detected area of the wings. Transformations: none, abs, flip.';...
'Change in the angle of the smaller wing. The smaller wing is decided based on the detected area of the wings. Transformations: none, abs, flip.';...
'Change in the angle to closest point on the arena wall to animal''s center, relative to the animal''s orientation (rad). Transformations: flip, abs.';...
'Change in maximum total angle of animal''s view occluded by another animal (rad/s). Transformations: none, abs.';...
'Change in area from frame t to t+1 (mm/s). Transformations: none, abs.';...
'Change in the area of the wing that is closer to the body. Transformations: none, abs, relative.';...
'Change in the area of the wing that is more away from the body. Transformations: none, abs, relative.';...
'Change in quarter minor axis length from frame t to t+1 (mm/s). Transformations: none, abs.';...
'Minimum distance from this animal''s center to other animal''s center. Transformations: none, relative.';...
'Change in minimum distance between this animal''s center and other flies'' centers (mm/s). Transformations: none, abs.';...
'Change in the distance to arena wall (mm/s). Transformations: none.';...
'Change in the eccentricity of the ellipse from frame t to t+1 (1/s). Transformations: none, abs.';...
'Minimum distance from any point of this animal''s ellipse to the nose of other flies. Transformations: none, relative.';...
'Distance to the arena wall from the animal''s center (mm). Transformations: none, relative.';...
'Change in the angle of the larger wing angle. Transformations: none, abs.';...
'Change in the area of the larger wing. Transformations: none, abs, relative.';...
'Change in the angle of the smaller the wing angle. Transformations: none, abs.';...
'Change in the are of the smaller wing. Transformations: none, abs, relative.';...
'Minimum distance from any point of this animal''s nose to the ellipse of other flies. Transformations: none, relative.';...
'Minimum distance from this animal''s nose to the ellipse of other flies. The distance to flies that lie within the cone of -30º to 30º are multiplied by a factor greater than 1 dependent on the angle. This feature is used to find distance to flies that are close but not in front of the animal. Transformations: none.';...
'Minimum distance from this animal''s nose to the ellipse of other flies. The distance to flies that lie outside the -20º to 20º cone in front of the animal are multiplied by a factor greater than 1 depending on the angle. This feature is used to find distance to flies that are close and in front of the animal. Transformations: none.';...
'Minimum distance from this animal''s nose to the ellipse of other flies. The distance to flies that lie outside the -30º to 30º cone in front of the animal are multiplied by a factor greater than 1 depending on the angle. This feature is used to find distance to flies that are close and in front of the animal. Transformations: none.';...
'Minimum distance from any point of this animal''s nose to the tail of other flies. Transformations: none, relative.';...
'Change in nwingsdetected. Transformations: none, abs.';...
'Change in the velocity direction (rad/s). Transformations: none, abs.';...
'Angular velocity (rad/s). Transformations: flip, abs.';...
'Sideways velocity of the animal''s center of rotation (mm/s). This is the projection of the change in the position of the center of rotation on the animal onto the direction orthogonal to the animal''s orientation. Transformations: none, abs and relative.';...
'Forward velocity of the animal''s center (mm/s). This is the projection of the animal''s velocity on its orientation direction. Transformations: none, abs and relative.';...
'Forward velocity of the backmost point on the animal (mm/s). Transformations: none, abs and relative.';...
'Sideways velocity of the animal''s center of rotation (mm/s). This is the projection of the change in the position of the center of rotation on the animal onto the direction orthogonal to the animal''s orientation. Transformations: flip and abs.';...
'Sideways velocity of the animal''s center (mm/s). This is the projection of the animal''s velocity on the direction orthogonal to the orientation. Transformations: flip and abs.';...
'Sideways velocity of the backmost point on the animal (mm/s). Transformations: flip and abs.';...
'Change in wing_angle_diff. Transformations: none, abs.';...
'Change in wing_angle_imbalance. Transformations: none, abs.';...
'Eccentricity of the ellipse (no units). Transformations: none, abs.';...
'Sideways velocity of the animal''s center of rotation, sign-normalized so that if the animal''s orientation is turning right, then flipdv_cor is positive if the animal''s center of rotation is also translating to the right (dv_cor x signdtheta) (mm/s). Transformations: relative.';...
'Magnitude of difference in velocity of this animal and velocity of closest animal based on anglesub (mm/s). Transformations: none, relative.';...
'Magnitude of difference in velocity of this animal and velocity of closest animal based on dnose2ell (mm/s). Transformations: none, relative.';...
'Maximum of the largest absolute change in the wing angles. Transformations: none.';...
'Maximum of the largest absolute change in the wing areas. Transformations: none, relative.';...
'Change in the angle of the wing that moves in the most. Transformations: none.';...
'Change in the angle of the wing that moves out the most. Transformations: none.';...
'Maximum of the wing angles. Transformations: none.';...
'Maximum of the wing areas. Transformations: none, relative.';...
'Mean of the angles of the wings. Transformations: none.';...
'Mean of the areas of the wings. Transformations: none, relative.';...
'Minimum of the largest absolute change in the wing angles. Transformations: none.';...
'Minimum of the largest absolute change in the wing areas. Transformations: none, relative.';...
'Change in the angle of the wing that moves in the least. Transformations: none.';...
'Change in the angle of the wing that moves out the least. Transformations: none.';...
'Minimum of the wing angles. Transformations: none.';...
'Minimum of the wing areas. Transformations: none, relative.';...
'Number of flies within 2 body lengths (4a). Transformations: none.';...
'Number of wings detected by the wing tracker. It can be either 0, 1 or 2. Transformations: none.';...
'Velocity direction (rad). Transformations: none.';...
'Difference between velocity direction and the animal''s orientation. Transformations: none.';...
'Speed of the center of rotation (mm/s). Transformations: none and relative';...
'Speed of the fitted ellipse''s center(mm/s). Transformations: none and relative.';...
'Speed of the animal''s nose (mm/s). Transformations: none and relative.';...
'Speed of the animal''s tail (mm/s). Transformations: none and relative.';...
'Velocity of this animal in the direction towards the closest animal (closest animal being defined based on anglesub) (mm/s). Transformations: none, relative.';...
'Velocity of this animal in the direction towards the closest animal (closest animal being defined based on dnose2ell) (mm/s). Transformations: none, relative.';...
'Angle between the right wing and the left wing. Transformations: none.';...
'Difference of the right wing angle and the left wing angle. Transformations: none.';...
'Difference between velocity direction and orientation (rad). Transformations: flip and abs.'};

cbparams=getappdata(0,'cbparams');
on_default=num2cell(ismember((pff_names(:)),cbparams.compute_perframe_features.perframefns));

pff_all=struct('name',pff_names,'type',pff_type,'description',pff_description,'on',on_default);

if all(cell2mat(on_default))
    set(handles.checkbox_all,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==1),pff_type))))
    set(handles.checkbox_app,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==2),pff_type))))
    set(handles.checkbox_loc,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==3),pff_type))))
    set(handles.checkbox_soc,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==4),pff_type))))
    set(handles.checkbox_id,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==5),pff_type))))
    set(handles.checkbox_are,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==6),pff_type))))
    set(handles.checkbox_pos,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==7),pff_type))))
    set(handles.checkbox_Wapp,'Value',true)
end

if all(cell2mat(on_default(cellfun(@(x) any(x==8),pff_type))))
    set(handles.checkbox_Wmov,'Value',true)
end


setappdata(0,'pff_all',pff_all)
% Choose default command line output for cbtrackGUI_pff
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cbtrackGUI_pff wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_pff_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_app.
function checkbox_app_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to checkbox_app (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
isapp=cellfun(@(x) any(x==1), {pff_all(:).type});
[pff_all(isapp).on]=deal(app_on);
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end
setappdata(0,'pff_all',pff_all)
    


% --- Executes on button press in pushbutton_app.
function pushbutton_app_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_app (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_app;
waitfor(w)
pff_all=getappdata(0,'pff_all');
isapp=cellfun(@(x) any(x==1), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_app,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_app,'Value',false)
elseif all(~[pff_all(isapp).on]) 
    set(handles.checkbox_app,'Value',false)
elseif all([pff_all(isapp).on]) 
    set(handles.checkbox_app,'Value',true)
end

% --- Executes on button press in checkbox_loc.
function checkbox_loc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loc_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
isloc=cellfun(@(x) any(x==2), {pff_all(:).type});
[pff_all(isloc).on]=deal(loc_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end


% --- Executes on button press in pushbutton_loc.
function pushbutton_loc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_loc;
waitfor(w)
pff_all=getappdata(0,'pff_all');
isloc=cellfun(@(x) any(x==2), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_loc,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_loc,'Value',false)
elseif all(~[pff_all(isloc).on]) 
    set(handles.checkbox_loc,'Value',false)
elseif all([pff_all(isloc).on]) 
    set(handles.checkbox_loc,'Value',true)
end

% --- Executes on button press in checkbox_soc.
function checkbox_soc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_soc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
soc_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
issoc=cellfun(@(x) any(x==3), {pff_all(:).type});
[pff_all(issoc).on]=deal(soc_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end

% --- Executes on button press in pushbutton_soc.
function pushbutton_soc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_soc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_soc;
waitfor(w)
pff_all=getappdata(0,'pff_all');
issoc=cellfun(@(x) any(x==3), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_soc,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_soc,'Value',false)
elseif all(~[pff_all(issoc).on]) 
    set(handles.checkbox_soc,'Value',false)
elseif all([pff_all(issoc).on]) 
    set(handles.checkbox_soc,'Value',true)
end

% --- Executes on button press in checkbox_id.
function checkbox_id_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
id_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
isid=cellfun(@(x) any(x==4), {pff_all(:).type});
[pff_all(isid).on]=deal(id_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end

% --- Executes on button press in pushbutton_id.
function pushbutton_id_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_id;
waitfor(w)
pff_all=getappdata(0,'pff_all');
isid=cellfun(@(x) any(x==4), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_id,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_id,'Value',false)
elseif all(~[pff_all(isid).on]) 
    set(handles.checkbox_id,'Value',false)
elseif all([pff_all(isid).on]) 
    set(handles.checkbox_id,'Value',true)
end

% --- Executes on button press in checkbox_are.
function checkbox_are_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_are (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
are_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
isare=cellfun(@(x) any(x==5), {pff_all(:).type});
[pff_all(isare).on]=deal(are_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end

% --- Executes on button press in pushbutton_are.
function pushbutton_are_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_are (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_are;
waitfor(w)
pff_all=getappdata(0,'pff_all');
isare=cellfun(@(x) any(x==5), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_are,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_are,'Value',false)
elseif all(~[pff_all(isare).on]) 
    set(handles.checkbox_are,'Value',false)
elseif all([pff_all(isare).on]) 
    set(handles.checkbox_are,'Value',true)
end

% --- Executes on button press in checkbox_pos.
function checkbox_pos_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
ispos=cellfun(@(x) any(x==6), {pff_all(:).type});
[pff_all(ispos).on]=deal(pos_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end

% --- Executes on button press in pushbutton_pos.
function pushbutton_pos_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_pos;
waitfor(w)
pff_all=getappdata(0,'pff_all');
ispos=cellfun(@(x) any(x==6), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_pos,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_pos,'Value',false)
elseif all(~[pff_all(ispos).on]) 
    set(handles.checkbox_pos,'Value',false)
elseif all([pff_all(ispos).on]) 
    set(handles.checkbox_pos,'Value',true)
end


% --- Executes on button press in checkbox_Wapp.
function checkbox_Wapp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Wapp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Wapp_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
isWapp=cellfun(@(x) any(x==7), {pff_all(:).type});
[pff_all(isWapp).on]=deal(Wapp_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end

% --- Executes on button press in pushbutton_Wapp.
function pushbutton_Wapp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Wapp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_wapp;
waitfor(w)
pff_all=getappdata(0,'pff_all');
isWapp=cellfun(@(x) any(x==7), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_Wapp,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_Wapp,'Value',false)
elseif all(~[pff_all(isWapp).on]) 
    set(handles.checkbox_Wapp,'Value',false)
elseif all([pff_all(isWapp).on]) 
    set(handles.checkbox_Wapp,'Value',true)
end


% --- Executes on button press in checkbox_Wmov.
function checkbox_Wmov_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Wmov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Wmov_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
isWmov=cellfun(@(x) any(x==8), {pff_all(:).type});
[pff_all(isWmov).on]=deal(Wmov_on);
setappdata(0,'pff_all',pff_all)
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
end

% --- Executes on button press in pushbutton_Wmov.
function pushbutton_Wmov_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Wmov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_wmov;
waitfor(w)
pff_all=getappdata(0,'pff_all');
isWmov=cellfun(@(x) any(x==8), {pff_all(:).type});
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_Wmov,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_Wmov,'Value',false)
elseif all(~[pff_all(isWmov).on]) 
    set(handles.checkbox_Wmov,'Value',false)
elseif all([pff_all(isWmov).on]) 
    set(handles.checkbox_Wmov,'Value',true)
end

% --- Executes on button press in checkbox_all.
function checkbox_all_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_on=logical(get(hObject,'Value'));
pff_all=getappdata(0,'pff_all');
[pff_all(:).on]=deal(all_on);
setappdata(0,'pff_all',pff_all)
if all_on
    set(handles.checkbox_app,'Value',true)
    set(handles.checkbox_loc,'Value',true)
    set(handles.checkbox_soc,'Value',true)
    set(handles.checkbox_id,'Value',true)
    set(handles.checkbox_are,'Value',true)
    set(handles.checkbox_pos,'Value',true)
    set(handles.checkbox_Wapp,'Value',true)
    set(handles.checkbox_Wmov,'Value',true)
elseif ~all_on
    set(handles.checkbox_app,'Value',false)
    set(handles.checkbox_loc,'Value',false)
    set(handles.checkbox_soc,'Value',false)
    set(handles.checkbox_id,'Value',false)
    set(handles.checkbox_are,'Value',false)
    set(handles.checkbox_pos,'Value',false)
    set(handles.checkbox_Wapp,'Value',false)
    set(handles.checkbox_Wmov,'Value',false)
end

% --- Executes on button press in pushbutton_all.
function pushbutton_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=cbtrackGUI_pff_all;
waitfor(w)
pff_all=getappdata(0,'pff_all');
if all([pff_all(:).on])
    set(handles.checkbox_all,'Value',true)
    set(handles.checkbox_app,'Value',true)
    set(handles.checkbox_loc,'Value',true)
    set(handles.checkbox_soc,'Value',true)
    set(handles.checkbox_id,'Value',true)
    set(handles.checkbox_are,'Value',true)
    set(handles.checkbox_pos,'Value',true)
    set(handles.checkbox_Wapp,'Value',true)
    set(handles.checkbox_Wmov,'Value',true)
elseif all(~[pff_all(:).on])
    set(handles.checkbox_all,'Value',false)
    set(handles.checkbox_app,'Value',false)
    set(handles.checkbox_loc,'Value',false)
    set(handles.checkbox_soc,'Value',false)
    set(handles.checkbox_id,'Value',false)
    set(handles.checkbox_are,'Value',false)
    set(handles.checkbox_pos,'Value',false)
    set(handles.checkbox_Wapp,'Value',false)
    set(handles.checkbox_Wmov,'Value',false)
end


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)  %#ok<*INUSD>
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
cbparams=getappdata(0,'cbparams');
pff_on=pff_all([pff_all(:).on]);
cbparams.compute_perframe_features.perframefns={pff_on(:).name};
setappdata(0,'cbparams',cbparams)
delete(handles.figure1)

function varargout = cbtrackGUI_WingTracker(varargin)
% CBTRACKGUI_ROI_TEMP MATLAB code for cbtrackGUI_ROI_temp.fig
%      CBTRACKGUI_ROI_TEMP, by itself, creates a new CBTRACKGUI_ROI_TEMP or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_ROI_TEMP returns the handle to a new CBTRACKGUI_ROI_TEMP or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_ROI_TEMP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_ROI_TEMP.M with the given input arguments.
%
%      CBTRACKGUI_ROI_TEMP('Property','Value',...) creates a new CBTRACKGUI_ROI_TEMP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_WingTracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_WingTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_ROI_temp

% Last Modified by GUIDE v2.5 21-Feb-2014 12:46:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_WingTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_WingTracker_OutputFcn, ...
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


function cbtrackGUI_WingTracker_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
GUIsize(handles,hObject)

experiment=getappdata(0,'experiment');
moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
roi_params=cbparams.detect_rois;
wing_params=cbparams.wingtrack;
roidata=getappdata(0,'roidata');
visdata=getappdata(0,'visdata');
wings=struct;
[wings.readframe,wings.nframes,wings.fid,wings.headerinfo] = get_readframe_fcn(moviefile);
frame=wings.readframe(1);
aspect_ratio=size(frame,2)/size(frame,1);
pos1=get(handles.axes_wingtracker,'position'); %axes 1 position

% Plot figure
visdata.plot=1;
if aspect_ratio<=1 
    old_width=pos1(3); new_width=pos1(4)*aspect_ratio; pos1(3)=new_width; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(1)=pos1(1)-(new_width-old_width)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_wingtracker,'position',pos1) %reset axes position and size
else
    old_height=pos1(4); new_height=pos1(3)/aspect_ratio; pos1(4)=new_height; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(2)=pos1(2)-(new_height-old_height)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_wingtracker,'position',pos1) %reset axes position and size
end

axes(handles.axes_wingtracker);
colormap('gray')
handles.img=imagesc(frame);
set(handles.axes_wingtracker,'XTick',[],'YTick',[])
axis equal


% Set parameters on the gui
if ~cbparams.track.dosetBG
    set(handles.pushbutton_BG,'Enable','off')
end
if ~cbparams.detect_rois.dosetROI
    set(handles.pushbutton_ROIs,'Enable','off')
end
if ~cbparams.track.dosettrack
    set(handles.pushbutton_tracker_setup,'Enable','off')
end

set(handles.text_exp,'FontSize',24,'HorizontalAlignment','center','units','pixels','FontUnits','pixels','String',experiment);

set(handles.edit_set_Hbgthresh,'String',num2str(wing_params.mindwing_high));
set(handles.slider_set_Hbgthresh,'Value',wing_params.mindwing_high,'Min',0,'Max',255);
fcn_slider_Hbgthresh = get(handles.slider_set_Hbgthresh,'Callback');
hlisten_Hbgthresh=addlistener(handles.slider_set_Hbgthresh,'ContinuousValueChange',fcn_slider_Hbgthresh); %#ok<NASGU>

set(handles.edit_set_Lbgthresh,'String',num2str(wing_params.mindwing_low));
set(handles.slider_set_Lbgthresh,'Value',wing_params.mindwing_low,'Min',0,'Max',wing_params.mindwing_high-1);
fcn_slider_Lbgthresh = get(handles.slider_set_Lbgthresh,'Callback');
hlisten_Lbgthresh=addlistener(handles.slider_set_Lbgthresh,'ContinuousValueChange',fcn_slider_Lbgthresh); %#ok<NASGU>

set(handles.edit_set_minbody,'String',num2str(wing_params.mindbody));
set(handles.slider_set_minbody,'Value',wing_params.mindbody,'Min',0,'Max',255);
fcn_slider_minbody = get(handles.slider_set_minbody,'Callback');
hlisten_minbody=addlistener(handles.slider_set_minbody,'ContinuousValueChange',fcn_slider_minbody); %#ok<NASGU>

set(handles.edit_set_minwing,'String',num2str(wing_params.min_single_wing_area));
set(handles.slider_set_minwing,'Value',wing_params.min_single_wing_area,'Min',0,'Max',200);
fcn_slider_minwing = get(handles.slider_set_minwing,'Callback');
hlisten_minwing=addlistener(handles.slider_set_minwing,'ContinuousValueChange',fcn_slider_minwing); %#ok<NASGU>

set(handles.edit_set_wingin,'String',num2str(wing_params.wing_peak_min_frac_factor));
set(handles.slider_set_wingin,'Value',wing_params.wing_peak_min_frac_factor,'Min',0,'Max',200);
fcn_slider_wingin = get(handles.slider_set_wingin,'Callback');
hlisten_wingin=addlistener(handles.slider_set_wingin,'ContinuousValueChange',fcn_slider_wingin); %#ok<NASGU>

 % Set frame slider
nframessample=roi_params.nframessample;
set(handles.slider_frame,'Value',1,'Min',1,'Max',nframessample,'SliderStep',[1/(nframessample-1),10/(nframessample-1)])
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); %#ok<NASGU>

% Plot ROIs
nROI=roidata.nrois;
if ~roidata.isall
    colors_roi = jet(nROI)*.7;
    hold on
    for i = 1:nROI,
      drawellipse(roidata.centerx(i),roidata.centery(i),0,roidata.radii(i),roidata.radii(i),'Color',colors_roi(i,:));
        text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
          'Color',colors_roi(i,:),'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
    end
end

P_stages={'BG','ROIs','params','wing_params','track1','track2'};
P_curr_stage='wing_params';
P_stage=getappdata(0,'P_stage');
if find(strcmp(P_stage,P_stages))>find(strcmp(P_curr_stage,P_stages))
    debugdata.isnew=false;
    if cbparams.track.DEBUG==1 && getappdata(0,'singleexp')
        set(handles.pushbutton_debuger,'Enable','on')
    end
else
    debugdata.isnew=true;
end

GUI.old_pos=get(hObject,'position');

% Initialize debugdata
debugdata.haxes=handles.axes_wingtracker;
debugdata.him=handles.img;
debugdata.vis=1;
debugdata.track=0;
debugdata.play=0;

% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',GUI);
set(handles.uipanel_set,'UserData',wing_params);
set(handles.slider_frame,'UserData',1);
set(handles.axes_wingtracker,'UserData',debugdata);

fclose(wings.fid);

uiwait(handles.cbtrackGUI_ROI)


function varargout = cbtrackGUI_WingTracker_OutputFcn(hObject, eventdata, handles)  %#ok<STOUT>


function axes_wingtracker_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.cbtrackGUI_ROI)


function pushbutton_accept_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

restart='';
setappdata(0,'restart',restart)
cbparams=getappdata(0,'cbparams');
wing_params=get(handles.uipanel_set,'UserData');
cbparams.wingtrack=wing_params;
setappdata(0,'cbparams',cbparams)

debugdata=get(handles.axes_wingtracker,'UserData');

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

if debugdata.isnew
    if cbparams.track.dosave
        savetemp({'debugdata'})
    end
end
if getappdata(0,'singleexp')
    P_stage=getappdata(0,'P_stage');       
    if strcmp(P_stage,'track2')
        if debugdata.isnew
            if isappdata(0,'debugdata_WT')
                rmappdata(0,'debugdata_WT')
            end
            if isappdata(0,'twing')
                rmappdata(0,'twing')
            end
            trackdata=getappdata(0,'trackdata');
            trackdata=rmfield(trackdata,{'trackwings_timestamp','trackwings_version','twing','perframedata','wingplotdata','perframeunits'});
            trackdata.trx=rmfield(trackdata.trx,{'wing_anglel','wing_angler','xwingl','ywingl','xwingr','ywingr'});
            setappdata(0,'trackdata',trackdata);
            WriteParams
        end
        CourtshipBowlTrack_GUI2
        iscancel=getappdata(0,'iscancel');
        if iscancel
            if iscancel==1
                cancelar
            end
            return
        end
    else
        setappdata(0,'P_stage','track1')
        if cbparams.track.dosave
           savetemp({'P_stage'})
        end
        if debugdata.isnew
            WriteParams
        end
        if cbparams.track.DEBUG==1
            cbtrackGUI_tracker_video
        else
            cbtrackGUI_tracker_NOvideo
        end
    end
else
    setappdata(0,'P_stage','track1')
    WriteParams    
end


function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
GUIresize(handles,hObject);


function slider_frame_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
f=round(get(hObject,'Value'));
set(hObject,'Value',f);
visdata=getappdata(0,'visdata');
if debugdata.vis==1
    set(debugdata.him,'CData',visdata.frames{f});
    if isfield(debugdata,'htext')
      delete(debugdata.htext(ishandle(debugdata.htext)));
    end
    if isfield(debugdata,'hwing'),
      delete(debugdata.hwing(ishandle(debugdata.hwing)));
    end
    if isfield(debugdata,'htrough'),
      delete(debugdata.htrough(ishandle(debugdata.htrough)));
    end
    debugdata.htext = [];
    debugdata.hwing = [];
    debugdata.htrough = [];
elseif debugdata.vis>1
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
end
set(handles.axes_wingtracker,'UserData',debugdata);


function slider_frame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit_set_Hbgthresh_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.mindwing_high=str2double(get(hObject,'String'));
if wing_params.mindwing_high>get(handles.slider_set_Hbgthresh,'Max')
    wing_params.mindwing_high=get(handles.slider_set_Hbgthresh,'Max');
    set(hObject,'String',num2str(get(handles.slider_set_Hbgthresh,'Max')))
elseif wing_params.mindwing_high<get(handles.slider_set_Hbgthresh,'Min')
    wing_params.mindwing_high=get(handles.slider_set_Hbgthresh,'Min');
    set(hObject,'String',num2str(get(handles.slider_set_Hbgthresh,'Min')))
end
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.slider_set_Hbgthresh,'Value',wing_params.mindwing_high);
set(handles.slider_set_Lbgthresh,'Value',min(get(handles.slider_set_Lbgthresh,'Value'),wing_params.mindwing_high),'Max',wing_params.mindwing_high);
set(handles.edit_set_Lbgthresh,'String',num2str(min(str2double(get(handles.edit_set_Lbgthresh,'String')),wing_params.mindwing_high)));
set(handles.uipanel_set,'UserData',wing_params);


function edit_set_Hbgthresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_Lbgthresh_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.mindwing_low=str2double(get(hObject,'String'));
if wing_params.mindwing_low>get(handles.slider_set_Lbgthresh,'Max')
    wing_params.mindwing_low=get(handles.slider_set_Lbgthresh,'Max');
    set(hObject,'String',num2str(get(handles.slider_set_Lbgthresh,'Max')))
elseif wing_params.mindwing_low<get(handles.slider_set_Lbgthresh,'Min')
    wing_params.mindwing_low=get(handles.slider_set_Lbgthresh,'Min');
    set(hObject,'String',num2str(get(handles.slider_set_Lbgthresh,'Min')))
end
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.slider_set_Lbgthresh,'Value',wing_params.mindwing_low);
set(handles.uipanel_set,'UserData',wing_params);


function edit_set_Lbgthresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
if strcmp('Yes',msg_cancel)
    setappdata(0,'iscancel',true)
    uiresume(handles.cbtrackGUI_ROI)
    if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
        delete(handles.cbtrackGUI_ROI)
    end
end


function slider_set_Hbgthresh_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.mindwing_high=get(hObject,'Value');
set(handles.edit_set_Hbgthresh,'String',num2str(wing_params.mindwing_high,'%.2f'));
set(handles.uipanel_set,'UserData',wing_params);
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.slider_set_Lbgthresh,'Value',min(get(handles.slider_set_Lbgthresh,'Value'),wing_params.mindwing_high),'Max',wing_params.mindwing_high);
set(handles.edit_set_Lbgthresh,'String',num2str(min(str2double(get(handles.edit_set_Lbgthresh,'String')),wing_params.mindwing_high),'%.2f'));


function slider_set_Hbgthresh_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider_set_Lbgthresh_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.mindwing_low=get(hObject,'Value');
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.edit_set_Lbgthresh,'String',num2str(wing_params.mindwing_low,'%.2f'));
set(handles.uipanel_set,'UserData',wing_params);


function slider_set_Lbgthresh_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu_vis_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData');
wing_params=get(handles.uipanel_set,'UserData');
debugdata.vis=get(hObject,'Value');
f=get(handles.slider_frame,'Value');
visdata=getappdata(0,'visdata');
if debugdata.vis==1
    set(debugdata.him,'CData',visdata.frames{f});
    if isfield(debugdata,'htext')
      delete(debugdata.htext(ishandle(debugdata.htext)));
    end
    if isfield(debugdata,'hwing'),
      delete(debugdata.hwing(ishandle(debugdata.hwing)));
    end
    if isfield(debugdata,'htrough'),
      delete(debugdata.htrough(ishandle(debugdata.htrough)));
    end
    debugdata.htext = [];
    debugdata.hwing = [];
    debugdata.htrough = [];
elseif debugdata.vis>1
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
set(handles.axes_wingtracker,'UserData',debugdata)


function popupmenu_vis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_advanced_Callback(hObject, eventdata, handles)


function pushbutton_BG_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

cbtrackGUI_BG


function pushbutton_ROIs_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

cbtrackGUI_ROI


function pushbutton_WT_Callback(hObject, eventdata, handles)


function pushbutton_debuger_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

P_stage=getappdata(0,'P_stage');
if strcmp(P_stage,'track2')
    CourtshipBowlTrack_GUI2
    iscancel=getappdata(0,'iscancel');
    if iscancel
        if iscancel==1
            cancelar
        end
        return
    end
elseif strcmp(P_stage,'track1')
    cbtrackGUI_tracker_video
end



function edit_set_minbody_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.mindbody=str2double(get(hObject,'String'));
if wing_params.mindbody>get(handles.slider_set_minbody,'Max')
    wing_params.mindbody=get(handles.slider_set_minbody,'Max');
    set(hObject,'String',num2str(get(handles.slider_set_minbody,'Max')))
elseif wing_params.mindbody<get(handles.slider_set_minbody,'Min')
    wing_params.mindbody=get(handles.slider_set_minbody,'Min');
    set(hObject,'String',num2str(get(handles.slider_set_minbody,'Min')))
end
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.slider_set_minbody,'Value',wing_params.mindbody);
set(handles.uipanel_set,'UserData',wing_params);


function edit_set_minbody_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider_set_minbody_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.mindbody=get(hObject,'Value');
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.edit_set_minbody,'String',num2str(wing_params.mindbody,'%.2f'));
set(handles.uipanel_set,'UserData',wing_params);


function slider_set_minbody_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit_set_minwing_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.min_single_wing_area=str2double(get(hObject,'String'));
if wing_params.min_single_wing_area>get(handles.slider_set_minwing,'Max')
    wing_params.min_single_wing_area=get(handles.slider_set_minwing,'Max');
    set(hObject,'String',num2str(get(handles.slider_set_minwing,'Max')))
elseif wing_params.min_single_wing_area<get(handles.slider_set_minwing,'Min')
    wing_params.min_single_wing_area=get(handles.slider_set_minwing,'Min');
    set(hObject,'String',num2str(get(handles.slider_set_minwing,'Min')))
end
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.slider_set_minwing,'Value',wing_params.min_single_wing_area);
set(handles.uipanel_set,'UserData',wing_params);


function edit_set_minwing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider_set_minwing_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.min_single_wing_area=get(hObject,'Value');
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.edit_set_minwing,'String',num2str(wing_params.min_single_wing_area,'%.2f'));
set(handles.uipanel_set,'UserData',wing_params);


function slider_set_minwing_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit_set_wingin_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.wing_peak_min_frac_factor=str2double(get(hObject,'String'));
if wing_params.wing_peak_min_frac_factor>get(handles.slider_set_wingin,'Max')
    wing_params.wing_peak_min_frac_factor=get(handles.slider_set_wingin,'Max');
    set(hObject,'String',num2str(get(handles.slider_set_wingin,'Max')))
elseif wing_params.min_single_wing_area<get(handles.slider_set_wingin,'Min')
    wing_params.wing_peak_min_frac_factor=get(handles.slider_set_wingin,'Min');
    set(hObject,'String',num2str(get(handles.slider_set_wingin,'Min')))
end
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.slider_set_wingin,'Value',wing_params.wing_peak_min_frac_factor);
set(handles.uipanel_set,'UserData',wing_params);


function edit_set_wingin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider_set_wingin_Callback(hObject, eventdata, handles)
debugdata=get(handles.axes_wingtracker,'UserData'); 
wing_params=get(handles.uipanel_set,'UserData');
wing_params.wing_peak_min_frac_factor=get(hObject,'Value');
if debugdata.vis>1
    f=get(handles.slider_frame,'Value');
    visdata=getappdata(0,'visdata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=getappdata(0,'roidata');
    isarena=roidata.inrois_all;
    debugdata=TrackWingsSingle_GUI(visdata.trx(:,f),bgmed,isarena,wing_params,visdata.frames{f},debugdata);
    debugdata.isnew=1;
    setappdata(0,'roidata',roidata)
end
debugdata.isnwe=true;
set(handles.axes_wingtracker,'UserData',debugdata);
set(handles.edit_set_wingin,'String',num2str(wing_params.wing_peak_min_frac_factor,'%.2f'));
set(handles.uipanel_set,'UserData',wing_params);


function slider_set_wingin_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function pushbutton_tracker_setup_Callback(hObject, eventdata, handles)
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

cbtrackGUI_tracker

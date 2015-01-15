function varargout = cbtrackGUI_WingTracker_video(varargin)
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
%      applied to the GUI before cbtrackGUI_WingTracker_video_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_WingTracker_video_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_ROI_temp

% Last Modified by GUIDE v2.5 14-Oct-2014 17:46:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_WingTracker_video_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_WingTracker_video_OutputFcn, ...
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


function cbtrackGUI_WingTracker_video_OpeningFcn(hObject, eventdata, handles, varargin)
global ISPLAYING
ISPLAYING=false;

handles.output = hObject;
GUIsize(handles,hObject)
experiment=getappdata(0,'experiment');
moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
roidata=getappdata(0,'roidata');
[wingtrack.readframe,wingtrack.nframes,wingtrack.fid,wingtrack.headerinfo] = get_readframe_fcn(moviefile);
frame=firstimage(wingtrack.readframe(cbparams.track.firstframetrack),cbparams.track);
aspect_ratio=size(frame,2)/size(frame,1);
pos1=get(handles.axes_wingtracker_video,'position'); %axes 1 position

% Plot figure
if aspect_ratio<=1 
    old_width=pos1(3); new_width=pos1(4)*aspect_ratio; pos1(3)=new_width; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(1)=pos1(1)-(new_width-old_width)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_wingtracker_video,'position',pos1) %reset axes position and size
else
    old_height=pos1(4); new_height=pos1(3)/aspect_ratio; pos1(4)=new_height; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(2)=pos1(2)-(new_height-old_height)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_wingtracker_video,'position',pos1) %reset axes position and size
end

axes(handles.axes_wingtracker_video);
colormap('gray')
handles.video_img=imagesc(frame);
set(handles.axes_wingtracker_video,'XTick',[],'YTick',[])
axis equal

if ~cbparams.track.dosetBG || ~getappdata(0,'singleexp')
    set(handles.pushbutton_BG,'Enable','off')
end
if ~cbparams.detect_rois.dosetROI || ~getappdata(0,'singleexp')
    set(handles.pushbutton_ROIs,'Enable','off')
end
if ~cbparams.track.dosettrack || ~getappdata(0,'singleexp')
    set(handles.pushbutton_tracker_setup,'Enable','off')
end
if ~ cbparams.wingtrack.dosetwingtrack || ~getappdata(0,'singleexp')
    set(handles.pushbutton_WT,'Enable','off')
end

% Plot ROIs
if ~roidata.isall
    nROI=roidata.nrois;
    colors_roi = jet(nROI)*.7;
    hold on
    for i = 1:nROI,
      drawellipse(roidata.centerx(i),roidata.centery(i),0,roidata.radii(i),roidata.radii(i),'Color',colors_roi(i,:));
    %     text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
    %       'Color',colors_roi(i,:),'HorizontalAlignment','center','VerticalAlignment','middle');
    end
end

trackdata=getappdata(0,'trackdata');

if isfield(trackdata,'twing')
    debugdata=getappdata(0,'debugdata_WT');
    %set slider
    t=trackdata.twing;
    set(handles.slider_frame,'Value',t,'SliderStep',[.01,.1])
    set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(t),' (',num2str(debugdata.nframestrack),' frames tracked)']})  

    % Plot
    debugdata.haxes=handles.axes_wingtracker_video;
    debugdata.him=handles.video_img;
    debugdata.DEBUG=cbparams.track.DEBUG;
    debugdata.play=false;
    iframe = trackdata.twing;
    frame=firstimage(wingtrack.readframe(iframe),cbparams.track);
else
    debugdata.haxes=handles.axes_wingtracker_video;
    debugdata.him=handles.video_img;
    debugdata.DEBUG=cbparams.track.DEBUG;
    debugdata.play=false;
    iframe = 1;
end
debugdata.nframestracked = trackdata.nframetrack;
debugdata.nframestrack = trackdata.nframetrack;
debugdata.framestracked = trackdata.firstframetrack:trackdata.lastframetrack;
debugdata=plot_wings(iframe,debugdata,frame);
set(handles.text_info,'String',{['Experiment ',experiment];['Visualizing wings: frame ',num2str(iframe),' of ',num2str(trackdata.nframetrack)]})

% Set slider
set(handles.slider_frame,'Value',iframe,'Min',1,'Max',trackdata.nframetrack,'SliderStep',[1/trackdata.nframetrack,10/trackdata.nframetrack],'Enable','on')
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); 
 
GUI.old_pos=get(hObject,'position');

% Update handles structure
set(hObject,'UserData',GUI);
set(handles.slider_frame,'UserData',1);
set(handles.axes_wingtracker_video,'UserData',wingtrack);
setappdata(0,'debugdata_WT',debugdata)
setappdata(0,'cbparams',cbparams);

guidata(hObject, handles);

uiwait(handles.cbtrackGUI_ROI);


function varargout = cbtrackGUI_WingTracker_video_OutputFcn(hObject, eventdata, handles)


function axes_wingtracker_video_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.cbtrackGUI_ROI)


function pushbutton_accept_Callback(hObject, eventdata, handles) %#ok<*INUSL>
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

setappdata(0,'iscancel',false)
setappdata(0,'isskip',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end


function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
GUIscale=getappdata(0,'GUIscale');
GUIscale=GUIresize(handles,hObject,GUIscale);
setappdata(0,'GUIscale',GUIscale)


function slider_frame_Callback(hObject, eventdata, handles)
iframe=round(get(hObject,'Value'));
set(hObject,'Value',iframe);
set(handles.slider_frame,'UserData',iframe);
% Plot
experiment=getappdata(0,'experiment');
cbparams=getappdata(0,'cbparams');
debugdata=getappdata(0,'debugdata_WT');
trackdata=getappdata(0,'trackdata');
wingtrack=get(handles.axes_wingtracker_video,'UserData');
frame=firstimage(wingtrack.readframe(debugdata.framestracked(iframe)),cbparams.track);
debugdata=plot_wings(iframe,debugdata,frame);
set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(debugdata.framestracked(iframe)),' (',num2str(debugdata.nframestrack),' frames tracked)']})  
trackdata.twing = iframe;
setappdata(0,'trackdata',trackdata)
setappdata(0,'debugdata_WT',debugdata)


function slider_frame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function axes_wingtracker_video_ButtonDownFcn(hObject, eventdata, handles)


function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
if strcmp('Yes',msg_cancel)
    setappdata(0,'iscancel',true)
    setappdata(0,'isskip',true)
    uiresume(handles.cbtrackGUI_ROI)
    if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
        delete(handles.cbtrackGUI_ROI)
    end
end


function pushbutton_play_Callback(hObject, eventdata, handles)
global ISPLAYING
if ISPLAYING
    ISPLAYING=false;
elseif ~ISPLAYING
    ISPLAYING=true;
    set(handles.pushbutton_play,'String','Stop','Backgroundcolor',[.5,0,0])
    set(handles.pushbutton_clear,'Enable','off');
    set(handles.pushbutton_accept,'Enable','off');
    set(handles.pushbutton_skip,'Enable','off');
    iframe=get(handles.slider_frame,'Value');
    experiment=getappdata(0,'experiment');
    cbparams=getappdata(0,'cbparams');
    debugdata=getappdata(0,'debugdata_WT');
    wingtrack=get(handles.axes_wingtracker_video,'UserData');
    debugdata.play=true;
    ilastf=debugdata.nframestracked;
    for j=iframe:ilastf
        tframe=debugdata.framestracked(j);
        set(handles.slider_frame,'Value',j);    
        if ~ISPLAYING
            break
        end
        set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(tframe),' (',num2str(debugdata.nframestrack),' frames tracked)']})  
        frame=firstimage(wingtrack.readframe(j),cbparams.track);
        debugdata=plot_wings(j,debugdata,frame);        
    end
    ISPLAYING=false;
    debugdata.play=false;
    set(handles.pushbutton_play,'String','Play','Backgroundcolor',[0,.5,0])
    set(handles.pushbutton_clear,'Enable','on');
    set(handles.pushbutton_accept,'Enable','on');
    set(handles.pushbutton_skip,'Enable','on');
    setappdata(0,'debugdata_WT',debugdata)
end


function pushbutton_clear_Callback(hObject, eventdata, handles)
logfid=open_log('track_log');
experiment=getappdata(0,'experiment');
iframe=get(handles.slider_frame,'Value');

clear_partial_wing(iframe);

debugdata=getappdata(0,'debugdata_WT');
set(handles.slider_frame,'Max',iframe,'SliderStep',[1/iframe,10/iframe]);
set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(debugdata.framestracked(iframe)),' (',num2str(debugdata.nframestrack),' frames tracked)']})  
s=sprintf('Tracking data cleared from frame %i at %s.\n',iframe,datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,getappdata(0,'experiment'),s)

if logfid > 1,
    fclose(logfid);
end


function pushbutton_BG_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','BG')
setappdata(0,'isnew',false)


function pushbutton_ROIs_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','ROI')
setappdata(0,'isnew',false)


function pushbutton_tracker_setup_Callback(hObject, eventdata, handles)
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','body')
setappdata(0,'isnew',false)


function pushbutton_debuger_Callback(hObject, eventdata, handles)


function pushbutton_debug_Callback(hObject, eventdata, handles)


function pushbutton_WT_Callback(hObject, eventdata, handles)
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','wing')
setappdata(0,'isnew',false)


function pushbutton_skip_Callback(hObject, eventdata, handles)
setappdata(0,'iscancel',false)
setappdata(0,'isskip',true)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end


function frame=firstimage(frame,tracking_params)
vign=getappdata(0,'vign');
% Equalize histogram using different methods (1 and 2 requires a
% reference histogram H0)
if any(tracking_params.eq_method==[1,2])
  H0=getappdata(0,'H0');
  frame=histeq(uint8(frame),H0);
elseif tracking_params.eq_method==3
  frame=eq_image(frame);
end

% Devignet and normalize
frame = double(frame)./vign;
frame = imresize(frame,1/tracking_params.down_factor);

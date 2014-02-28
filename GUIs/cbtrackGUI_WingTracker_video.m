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

% Last Modified by GUIDE v2.5 21-Feb-2014 16:33:05

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


% --- Executes just before cbtrackGUI_ROI_temp is made visible.
function cbtrackGUI_WingTracker_video_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_ROI_temp (see VARARGIN)

% Choose default command line output for cbtrackGUI_ROI_temp
global ISPAUSE
global ISPLAYING
ISPLAYING=false;

handles.output = hObject;
GUIsize(handles,hObject)
moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
roidata=getappdata(0,'roidata');
[wingtrack.readframe,wingtrack.nframes,wingtrack.fid,wingtrack.headerinfo] = get_readframe_fcn(moviefile);
cbparams.track.lastframetrack=(min(cbparams.track.lastframetrack,wingtrack.nframes));
cbparams.track.nframetrack=cbparams.track.lastframetrack-cbparams.track.firstframetrack+1;
frame=wingtrack.readframe(cbparams.track.firstframetrack);
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
    
 % Set slider
set(handles.slider_frame,'Value',1,'Min',1,'Max',2,'SliderStep',[.01,.1],'Enable','off')
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); 

trackdata=getappdata(0,'trackdata');
if isfield(trackdata,'twing')
    debugdata=getappdata(0,'debugdata_WT');
    set(handles.pushbutton_start,'String','CONTINUE')
    %set slider
    t=trackdata.twing;
    set(handles.slider_frame,'Value',debugdata.nframestracked,'Max',debugdata.nframestracked,'SliderStep',[.01,.1],'Enable','on')
    set(handles.text_info,'String',['Displaying frame ',num2str(t-1),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.'])  
    set(handles.pushbutton_clear,'Enable','on');
    set(handles.pushbutton_save,'Enable','on');

    % Plot
    debugdata.haxes=handles.axes_wingtracker_video;
    debugdata.him=handles.video_img;
    debugdata.vis=8;
    debugdata.DEBUG=cbparams.track.DEBUG;
    debugdata.track=false;
    debugdata.play=false;
    iframe = debugdata.nframestracked;
    frame=double(wingtrack.readframe(iframe));
    debugdata=plot_wings(iframe,debugdata,frame);
else
    debugdata.haxes=handles.axes_wingtracker_video;
    debugdata.him=handles.video_img;
    debugdata.vis=8;
    debugdata.DEBUG=cbparams.track.DEBUG;
    debugdata.track=false;
    debugdata.play=false;
end
    
% Initialize debugdata
 
 GUI.old_pos=get(hObject,'position');


% Update handles structure
set(hObject,'UserData',GUI);
set(handles.slider_frame,'UserData',1);
set(handles.pushbutton_start,'UserData',wingtrack);
setappdata(0,'debugdata_WT',debugdata)
setappdata(0,'cbparams',cbparams);


if ~ISPAUSE
    ISPAUSE=true;
    pushbutton_start_Callback(handles.pushbutton_start,eventdata,handles)
    if ISPAUSE
        uiwait(handles.cbtrackGUI_ROI);
    end
else
    ISPAUSE=true;
    uiwait(handles.cbtrackGUI_ROI);
end
guidata(hObject, handles);




% UIWAIT makes cbtrackGUI_ROI_temp wait for user response (see UIRESUME)
% uiwait(handles.cbtrackGUI_ROI_temp);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_WingTracker_video_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end



% --- Executes during object creation, after setting all properties.
function axes_wingtracker_video_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to axes_wingtracker_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: place code in OpeningFcn to populate axes_wingtracker_video



% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ISPAUSE
ISPAUSE=true;
close(handles.cbtrackGUI_ROI)


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
trackdata=getappdata(0,'trackdata');
debugdata=getappdata(0,'debugdata_WT');
out=getappdata(0,'out');
logfid=open_log('track_log',cbparams,out.folder);
iframe=debugdata.nframestracked;
fprintf(logfid,'Saving tracking results up to frame %i at %s...\n',debugdata.framestracked(iframe),datestr(now,'yyyymmddTHHMMSS'));
[trackdata,debugdata]=delete_partial_wing(iframe,trackdata,debugdata);
setappdata(0,'trackdata',trackdata)
setappdata(0,'debugdata_WT',debugdata);
setappdata(0,'iscancel',false)
if logfid > 1,
  fclose(logfid);
end
uiresume(handles.cbtrackGUI_ROI);



% --- Executes when cbtrackGUI_WingTracker_video is resized.
function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_WingTracker_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIresize(handles,hObject);

% --- Executes on slider movement.
function slider_frame_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iframe=round(get(hObject,'Value'));
set(hObject,'Value',iframe);
set(handles.slider_frame,'UserData',iframe);
% Plot
debugdata=getappdata(0,'debugdata_WT');
wingtrack=get(handles.pushbutton_start,'UserData');
frame=double(wingtrack.readframe(debugdata.framestracked(iframe)));
debugdata=plot_wings(iframe,debugdata,frame);
set(handles.text_info,'String',['Displaying frame ',num2str(debugdata.framestracked(iframe)),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.'])  
setappdata(0,'debugdata_WT',debugdata)



% --- Executes during object creation, after setting all properties.
function slider_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on mouse press over axes background.
function axes_wingtracker_video_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_wingtracker_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when user attempts to close cbtrackGUI_ROI.
function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
if strcmp('Yes',msg_cancel)
    setappdata(0,'iscancel',true)
    if ishandle(hObject)
        delete(hObject)
    end
end


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ISPAUSE
if ~ISPAUSE
    set(hObject,'String','CONTINUE')
    ISPAUSE=true;
elseif ISPAUSE
    set(hObject,'String','PAUSE')
    set(handles.pushbutton_save,'Enable','off')
    set(handles.pushbutton_clear,'Enable','off')
    set(handles.pushbutton_accept,'Enable','off')
    set(handles.pushbutton_play,'Enable','off')
    set(handles.slider_frame,'Enable','off')
    
    trackdata=getappdata(0,'trackdata');
    moviefile=getappdata(0,'moviefile');
    BG=getappdata(0,'BG');
    roidata=getappdata(0,'roidata');
    cbparams=getappdata(0,'cbparams');
    debugdata=getappdata(0,'debugdata_WT');
    debugdata.track=1;
    [wingtrx,wingperframedata,wingplotdata,wingtrackinfo,wingperframeunits,debugdata] = TrackWingsHelper_GUI(handles,trackdata.trx,moviefile,double(BG.bgmed),roidata.inrois_all,cbparams.wingtrack,debugdata,...
              'debug',cbparams.track.DEBUG,'firstframe',cbparams.track.firstframetrack);
    trackdata.trackwings_timestamp = wingtrackinfo.trackwings_timestamp;
    trackdata.trackwings_version = wingtrackinfo.trackwings_version;
    trackdata.trx = wingtrx;
    trackdata.twing=getappdata(0,'twing');
    trackdata.perframedata = wingperframedata;
    trackdata.wingplotdata=wingplotdata;
    trackdata.perframeunits = wingperframeunits;
    setappdata(0,'trackdata',trackdata);
    
    setappdata(0,'debugdata_WT',debugdata)
    set(handles.pushbutton_save,'Enable','on')
    set(handles.pushbutton_clear,'Enable','on')
    set(handles.pushbutton_accept,'Enable','on')
    set(handles.pushbutton_play,'Enable','on')
    %set slider
    t=getappdata(0,'twing');
    set(handles.slider_frame,'Value',debugdata.nframestracked,'Max',debugdata.nframestracked,'SliderStep',[.01,.1],'Enable','on')
    set(handles.text_info,'String',['Displaying frame ',num2str(t-1),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.'])  
    
    if ~ISPAUSE
        out=getappdata(0,'out');
        logfid=open_log('track_log',cbparams,out.folder);
        fprintf(logfid,'Wing tracking finished at %s...\n',datestr(now,'yyyymmddTHHMMSS'));
        
        if logfid > 1,
            fclose(logfid);
        end
        restart='';
        setappdata(0,'restart',restart)
        setappdata(0,'iscancel',false)
        uiresume(handles.cbtrackGUI_ROI);
    end
end




% --- Executes on button press in pushbutton_play.
function pushbutton_play_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ISPLAYING
if ISPLAYING
    ISPLAYING=false;
elseif ~ISPLAYING
    ISPLAYING=true;
    set(handles.pushbutton_play,'String','Stop','Backgroundcolor',[.5,0,0])
    set(handles.pushbutton_clear,'Enable','off');
    set(handles.pushbutton_save,'Enable','off');
    set(handles.pushbutton_start,'Enable','off');
    set(handles.pushbutton_accept,'Enable','off');
    iframe=get(handles.slider_frame,'Value');
    debugdata=getappdata(0,'debugdata_WT');
    wingtrack=get(handles.pushbutton_start,'UserData');
    frame=double(wingtrack.readframe(debugdata.framestracked(iframe)));
    debugdata.play=true;
    ilastf=debugdata.nframestracked;
    for j=iframe:ilastf
        tframe=debugdata.framestracked(j);
        set(handles.slider_frame,'Value',j);    
        if ~ISPLAYING
            break
        end
        set(handles.text_info,'String',['Displaying frame ',num2str(tframe),'. ',num2str(ilastf),' of ',num2str(debugdata.nframestracked),' (',num2str(ilastf*100/debugdata.nframestracked,'%.1f'),'%) tracked.'])  
        frame=double(wingtrack.readframe(j));
        debugdata=plot_wings(j,debugdata,frame);        
    end
    ISPLAYING=false;
    debugdata.play=false;
    set(handles.pushbutton_play,'String','Play','Backgroundcolor',[0,.5,0])
    set(handles.pushbutton_clear,'Enable','on');
    set(handles.pushbutton_save,'Enable','on');
    set(handles.pushbutton_start,'Enable','on');
    set(handles.pushbutton_accept,'Enable','on');
    setappdata(0,'debugdata_WT',debugdata)
end


% --- Executes on button press in pushbutton_clear.
function pushbutton_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg_clear=myquestdlg(14,'Helvetica',{'Which data would you like to delete?';'- All: Delete all the tracked frames';'- Current: Delete from the displayed frame'},'Cancel','All','Current','Cancel','Cancel'); 
out=getappdata(0,'out');
logfid=open_log('track_log',getappdata(0,'cbparams'),out.folder);
debugdata=getappdata(0,'debugdata_WT');
trackdata=getappdata(0,'trackdata');
if strcmp(msg_clear,'All')
    wingtrack=get(handles.pushbutton_start,'UserData');
    frame=double(wingtrack.readframe(1));
    set(handles.video_img,'CData',frame);
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
    trackdata=rmfield(trackdata,{'trackwings_timestamp','trackwings_version','twing','perframedata','wingplotdata','perframeunits'});
    trackdata.trx=rmfield(trackdata.trx,{'wing_anglel','wing_angler','xwingl','ywingl','xwingr','ywingr'});
    debugdata=rmfield(debugdata,{'framestracked','nframestracked'});
    set(handles.pushbutton_start,'String','Start Tracking');
    set(handles.pushbutton_save,'Enable','off')
    set(handles.pushbutton_clear,'Enable','off')
    set(handles.pushbutton_accept,'Enable','off')
    set(handles.pushbutton_play,'Enable','off')
    set(handles.slider_frame,'Value',1,'Min',1,'Max',2,'SliderStep',[.01,.1],'Enable','off')
    set(handles.text_info,'String','Tracking wings: No frames trackedNo frames tracked')
    fprintf(logfid,'All wing tracking data cleared at %s.\n',datestr(now,'yyyymmddTHHMMSS')');
elseif strcmp(msg_clear,'Current')
    iframe=get(handles.slider_frame,'Value');
    [trackdata,debugdata]=clear_partial_wing(iframe,trackdata,debugdata);
    set(handles.slider_frame,'Max',iframe);
    set(handles.text_info,'String',['Displaying frame ',num2str(debugdata.framestracked(iframe)),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.'])  
    fprintf(logfid,'Tracking data cleared from frame %i at %s.\n',iframe,datestr(now,'yyyymmddTHHMMSS'));
end
if logfid > 1,
    fclose(logfid);
end
setappdata(0,'trackdata',trackdata);
setappdata(0,'debugdata_WT',debugdata)


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[tempfile,tempdir]=uiputfile('.mat');
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
logfid=open_log('track_log',cbparams,out.folder);
t=getappdata(0,'t');
trackdata=getappdata(0,'trackdata'); %#ok<*NASGU>
tempfile = fullfile(tempdir,tempfile);
fprintf(logfid,'Saving temporary file after %i frames at %s...\n',t,datestr(now,'yyyymmddTHHMMSS'));
copyfile(out.temp_full,tempfile);
save(tempfile,'trackdata','-append')
if logfid > 1,
  fclose(logfid);
end

% --- Executes on button press in pushbutton_BG.
function pushbutton_BG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_BG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

delete(handles.cbtrackGUI_ROI)
setappdata(0,'iscancel',2)
cbtrackGUI_BG



% --- Executes on button press in pushbutton_ROIs.
function pushbutton_ROIs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

delete(handles.cbtrackGUI_ROI)
setappdata(0,'iscancel',2)
cbtrackGUI_ROI


% --- Executes on button press in pushbutton_tracker_setup.
function pushbutton_tracker_setup_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tracker_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

delete(handles.cbtrackGUI_ROI)
setappdata(0,'iscancel',2)
cbtrackGUI_tracker

% --- Executes on button press in pushbutton_debuger.
function pushbutton_debuger_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_debuger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_debug.
function pushbutton_debug_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_WT.
function pushbutton_WT_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_WT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

delete(handles.cbtrackGUI_ROI)
setappdata(0,'iscancel',2)
cbtrackGUI_WingTracker

%%%%% Aquí. Ya está terminado. Mirar las listas


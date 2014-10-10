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

% Last Modified by GUIDE v2.5 16-Jun-2014 08:35:15

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
global ISPAUSE
global ISPLAYING
ISPLAYING=false;

handles.output = hObject;
GUIsize(handles,hObject)
experiment=getappdata(0,'experiment');
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

set(handles.text_info,'String',{['Experiment ',experiment];'Tracking wings: No frames tracked'})
 % Set slider
set(handles.slider_frame,'Value',1,'Min',1,'Max',2,'SliderStep',[.01,.1],'Enable','off')
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); 

trackdata=getappdata(0,'trackdata');
if isfield(trackdata,'twing')
    debugdata=getappdata(0,'debugdata_WT');
    set(handles.pushbutton_start,'String','CONTINUE')
    set(handles.pushbutton_accept,'Enable','on')
    %set slider
    t=trackdata.twing;
    set(handles.slider_frame,'Value',debugdata.nframestracked,'Max',debugdata.nframestracked,'SliderStep',[.01,.1],'Enable','on')
    set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(t-1),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.']})  
    set(handles.pushbutton_clear,'Enable','on');
    set(handles.pushbutton_save,'Enable','on');

    % Plot
    debugdata.haxes=handles.axes_wingtracker_video;
    debugdata.him=handles.video_img;
    debugdata.vis=9;
    debugdata.DEBUG=cbparams.track.DEBUG;
    debugdata.track=false;
    debugdata.play=false;
    iframe = debugdata.nframestracked;
    frame=double(wingtrack.readframe(iframe));
    debugdata=plot_wings(iframe,debugdata,frame);
else
    debugdata.haxes=handles.axes_wingtracker_video;
    debugdata.him=handles.video_img;
    debugdata.vis=9;
    debugdata.DEBUG=cbparams.track.DEBUG;
    debugdata.track=false;
    debugdata.play=false;
end
    
hslider=unique(findobj('Style','slider'));
mins=get(hslider,'Min');
maxs=get(hslider,'Max');
if ~isa(mins,'cell')
    mins=num2cell(mins);
    maxs=num2cell(maxs);
end
for i=1:numel(hslider)
    set(hslider(i),'SliderStep',[1/(maxs{i}-mins{i}),10/(maxs{i}-mins{i})])
end

% Initialize debugdata
 
 GUI.old_pos=get(hObject,'position');


% Update handles structure
set(hObject,'UserData',GUI);
set(handles.slider_frame,'UserData',1);
set(handles.pushbutton_start,'UserData',wingtrack);
setappdata(0,'debugdata_WT',debugdata)
setappdata(0,'cbparams',cbparams);

guidata(hObject, handles);

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

cbparams=getappdata(0,'cbparams');
trackdata=getappdata(0,'trackdata');
debugdata=getappdata(0,'debugdata_WT');
out=getappdata(0,'out');
if debugdata.nframestrack~=debugdata.nframestracked
    msg_nframes=myquestdlg(14,'Helvetica',{'The number of tracked frames for bodies and wings must be simmilar.'; 'Continue tracking? (''No'' will delete missmatching frames)'},'Number of frames mismatch','Yes','No','Yes'); 
    if ~strcmp(msg_nframes,'No')
        return
    end
end
logfid=open_log('track_log');
iframe=debugdata.nframestracked;
s=sprintf('Saving tracking results up to frame %i at %s...\n',debugdata.framestracked(iframe),datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,getappdata(0,'experiment'),s)
[trackdata,debugdata]=delete_partial_wing(iframe,trackdata,debugdata);
setappdata(0,'trackdata',trackdata)
setappdata(0,'debugdata_WT',debugdata);
if logfid > 1,
  fclose(logfid);
end

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
debugdata=getappdata(0,'debugdata_WT');
wingtrack=get(handles.pushbutton_start,'UserData');
frame=double(wingtrack.readframe(debugdata.framestracked(iframe)));
debugdata=plot_wings(iframe,debugdata,frame);
set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(debugdata.framestracked(iframe)),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.']})  
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


function pushbutton_start_Callback(hObject, eventdata, handles)
global ISPAUSE
if ~ISPAUSE
    set(hObject,'String','CONTINUE')
    ISPAUSE=true;
elseif ISPAUSE
    set(hObject,'String','PAUSE')
    set(handles.pushbutton_save,'Enable','off')
    set(handles.pushbutton_clear,'Enable','off')
    set(handles.pushbutton_accept,'Enable','off')
    set(handles.pushbutton_cancel,'Enable','off')
    set(handles.pushbutton_play,'Enable','off')
    set(handles.pushbutton_skip,'Enable','off');
    set(handles.slider_frame,'Enable','off')
    
    trackdata=getappdata(0,'trackdata');
    experiment=getappdata(0,'experiment');
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
    set(handles.pushbutton_cancel,'Enable','on')
    set(handles.pushbutton_play,'Enable','on')
    set(handles.pushbutton_skip,'Enable','on');
    %set slider
    t=getappdata(0,'twing');
    set(handles.slider_frame,'Value',debugdata.nframestracked,'Max',debugdata.nframestracked,'SliderStep',[1/debugdata.nframestracked,10/debugdata.nframestracked],'Enable','on')
    set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(t-1),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.']})  
    
    if ~ISPAUSE
        out=getappdata(0,'out');
        logfid=open_log('track_log');
        s=sprintf('Wing tracking finished at %s for experiment %s...\n',datestr(now,'yyyymmddTHHMMSS'),experiment);
        write_log(logfid,getappdata(0,'experiment'),s)
        
        if logfid > 1,
            fclose(logfid);
        end
        restart='';
        setappdata(0,'restart',restart)
        setappdata(0,'iscancel',false)
        uiresume(handles.cbtrackGUI_ROI);
        if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
            delete(handles.cbtrackGUI_ROI)
        end
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
    set(handles.pushbutton_save,'Enable','off');
    set(handles.pushbutton_start,'Enable','off');
    set(handles.pushbutton_accept,'Enable','off');
    set(handles.pushbutton_skip,'Enable','off');
    iframe=get(handles.slider_frame,'Value');
    experiment=getappdata(0,'experiment');
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
        set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(tframe),'. ',num2str(ilastf),' of ',num2str(debugdata.nframestracked),' (',num2str(ilastf*100/debugdata.nframestracked,'%.1f'),'%) tracked.']})  
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
    set(handles.pushbutton_skip,'Enable','on');
    setappdata(0,'debugdata_WT',debugdata)
end


function pushbutton_clear_Callback(hObject, eventdata, handles)
msg_clear=myquestdlg(14,'Helvetica',{'Which data would you like to delete?';'- All: Delete all the tracked frames';'- Current: Delete from the displayed frame'},'Cancel','All','Current','Cancel','Cancel'); 
out=getappdata(0,'out');
logfid=open_log('track_log');
experiment=getappdata(0,'experiment');
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
    set(handles.slider_frame,'Value',1,'Min',1,'Max',2,'SliderStep',[1/2,10/2],'Enable','off')
    set(handles.text_info,'String',{['Experiment ',experiment];'Tracking wings: No frames trackedNo frames tracked'})
    s=sprintf('All wing tracking data cleared at %s.\n',datestr(now,'yyyymmddTHHMMSS')');
    write_log(logfid,getappdata(0,'experiment'),s)
elseif strcmp(msg_clear,'Current')
    iframe=get(handles.slider_frame,'Value');
    [trackdata,debugdata]=clear_partial_wing(iframe,trackdata,debugdata);
    set(handles.slider_frame,'Max',iframe,'SliderStep',[1/iframe,10/iframe]);
    set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(debugdata.framestracked(iframe)),'. ',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),' (',num2str(debugdata.nframestracked*100/debugdata.nframestrack,'%.1f'),'%) tracked.']})  
    s=sprintf('Tracking data cleared from frame %i at %s.\n',iframe,datestr(now,'yyyymmddTHHMMSS'));
    write_log(logfid,getappdata(0,'experiment'),s)
end
if logfid > 1,
    fclose(logfid);
end
setappdata(0,'trackdata',trackdata);
setappdata(0,'debugdata_WT',debugdata)


function pushbutton_save_Callback(hObject, eventdata, handles)
[tempfile,tempdir]=uiputfile('.mat');
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
logfid=open_log('track_log');
t=getappdata(0,'t');
trackdata=getappdata(0,'trackdata'); %#ok<*NASGU>
tempfile = fullfile(tempdir,tempfile);
s=sprintf('Saving temporary file after %i frames at %s...\n',t,datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,getappdata(0,'experiment'),s)
copyfile(out.temp_full,tempfile);
save(tempfile,'trackdata','-append')
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

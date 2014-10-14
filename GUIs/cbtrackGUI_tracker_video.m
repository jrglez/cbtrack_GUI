function varargout = cbtrackGUI_tracker_video(varargin)
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
%      applied to the GUI before cbtrackGUI_tracker_video_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_tracker_video_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_ROI_temp

% Last Modified by GUIDE v2.5 11-Jun-2014 18:51:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_tracker_video_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_tracker_video_OutputFcn, ...
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
function cbtrackGUI_tracker_video_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for cbtrackGUI_ROI_temp
global ISPAUSE
ISPAUSE=true;
global ISPLAYING
ISPLAYING=false;

handles.output = hObject;
GUIsize(handles,hObject)

experiment=getappdata(0,'experiment');
moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
roidata=getappdata(0,'roidata');
[track.readframe,track.nframes,track.fid,track.headerinfo] = get_readframe_fcn(moviefile);
cbparams.track.lastframetrack=(min(cbparams.track.lastframetrack,track.nframes));
cbparams.track.nframetrack=cbparams.track.lastframetrack-cbparams.track.firstframetrack+1;
frame=track.readframe(cbparams.track.firstframetrack);
aspect_ratio=size(frame,2)/size(frame,1);
pos1=get(handles.axes_tracker_video,'position'); %axes 1 position

% Plot figure
if aspect_ratio<=1 
    old_width=pos1(3); new_width=pos1(4)*aspect_ratio; pos1(3)=new_width; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(1)=pos1(1)-(new_width-old_width)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_tracker_video,'position',pos1) %reset axes position and size
else
    old_height=pos1(4); new_height=pos1(3)/aspect_ratio; pos1(4)=new_height; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(2)=pos1(2)-(new_height-old_height)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_tracker_video,'position',pos1) %reset axes position and size
end

axes(handles.axes_tracker_video);
colormap('gray')
handles.video_img=imagesc(frame);
set(handles.axes_tracker_video,'XTick',[],'YTick',[])
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

if ~cbparams.track.dosetBG || ~getappdata(0,'singleexp')
    set(handles.pushbutton_BG,'Enable','off')
end
if ~cbparams.detect_rois.dosetROI || ~getappdata(0,'singleexp')
    set(handles.pushbutton_ROIs,'Enable','off')
end
if ~cbparams.track.dosettrack || ~getappdata(0,'singleexp')
    set(handles.pushbutton_tracker_setup,'Enable','off')
end
if ~cbparams.wingtrack.dosetwingtrack || ~getappdata(0,'singleexp')
    set(handles.pushbutton_WT,'Enable','off')
end

set(handles.text_info,'String',{['Experiment ', experiment];'No frames tracked'})

% Set slider
set(handles.slider_frame,'Value',1,'Min',1,'Max',2,'Enable','off')
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); %#ok<NASGU>

if isappdata(0,'trackdata')
    trackdata=getappdata(0,'trackdata');
    set(handles.pushbutton_start,'String','CONTINUE')
    iframe = trackdata.t - cbparams.track.firstframetrack + 1;
    set(handles.slider_frame,'Value',iframe,'Min',1,'Max',iframe,'Enable','on')
    % Plot
    
    frame=track.readframe(trackdata.t);
    set(handles.video_img,'CData',frame);
    handles.hell=NaN(2,roidata.nrois);
    handles.htrx=NaN(2,roidata.nrois);
    flycolors = {'r','b'};
    for roii = 1:roidata.nrois,
        roibb = roidata.roibbs(roii,:);
        offx = roibb(1)-1;
        offy = roibb(3)-1;
        for i = 1:2,
            handles.hell(i,roii) = drawellipse(trackdata.trxx(i,roii,iframe)+offx,trackdata.trxy(i,roii,iframe)+offy,trackdata.trxtheta(i,roii,iframe),trackdata.trxa(i,roii,iframe),trackdata.trxb(i,roii,iframe),[flycolors{i},'-']);
            handles.htrx(i,roii) = plot(squeeze(trackdata.trxx(i,roii,max(iframe-30,1):iframe)+offx),squeeze(trackdata.trxy(i,roii,max(iframe-30,1):iframe)+offy),[flycolors{i},'.-']);
        end
    end
    currf=trackdata.t;    
    ilastf=get(handles.slider_frame,'Max');
    set(handles.text_info,'String',{['Experiment ', experiment];['Displaying frame ',num2str(currf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.']})  
    set(handles.pushbutton_accept,'Enable','on');
    setappdata(0,'t',trackdata.t)
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
 
 GUI.old_pos=get(hObject,'position');


% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',GUI);
set(handles.slider_frame,'UserData',1);
set(handles.pushbutton_start,'UserData',track)
setappdata(0,'cbparams',cbparams);

uiwait(handles.cbtrackGUI_ROI)


function varargout = cbtrackGUI_tracker_video_OutputFcn(hObject, eventdata, handles) 


function axes_tracker_video_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


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
out=getappdata(0,'out');
logfid=open_log('track_log');
t=getappdata(0,'t');
finalfile = fullfile(out.folder,cbparams.dataloc.trx.filestr);
s=sprintf('Saving tracking results up to frame %i at %s...\n',t,datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,getappdata(0,'experiment'),s)
CourtshipBowlTrack_GUI_save(finalfile,t)
if logfid > 1,
  fclose(logfid);
end

setappdata(0,'iscancel',false)
setappdata(0,'isskip',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'P_stage','track2')
if cbparams.track.dosave
    savetemp({'trackdata'})
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
roidata=getappdata(0,'roidata');
trackdata=getappdata(0,'trackdata');
cbparams=getappdata(0,'cbparams');
track=get(handles.pushbutton_start,'UserData');
f = iframe + cbparams.track.firstframetrack - 1;
frame=track.readframe(f);
set(handles.video_img,'CData',frame);
for roii = 1:roidata.nrois,
  roibb = roidata.roibbs(roii,:);
  offx = roibb(1)-1;
  offy = roibb(3)-1;
  for i = 1:2,
    updateellipse(handles.hell(i,roii),trackdata.trxx(i,roii,iframe)+offx,trackdata.trxy(i,roii,iframe)+offy,trackdata.trxtheta(i,roii,iframe),trackdata.trxa(i,roii,iframe),trackdata.trxb(i,roii,iframe));
    set(handles.htrx(i,roii),'XData',squeeze(trackdata.trxx(i,roii,max(iframe-30,1):iframe)+offx),...
      'YData',squeeze(trackdata.trxy(i,roii,max(iframe-30,1):iframe)+offy));
  end
end
ilastf=get(handles.slider_frame,'Max');
set(handles.text_info,'String',{['Experiment ', experiment];['Displaying frame ',num2str(f),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.']})  


function slider_frame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function axes_tracker_video_ButtonDownFcn(hObject, eventdata, handles)


function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
track=get(handles.pushbutton_start,'UserData');
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
fid_video=track.fid; %#ok<NASGU>
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
    CourtshipBowlTrack_GUI_debug(handles);
    set(handles.pushbutton_save,'Enable','on')
    set(handles.pushbutton_clear,'Enable','on')
    set(handles.pushbutton_accept,'Enable','on')
    set(handles.pushbutton_cancel,'Enable','on')
    set(handles.pushbutton_play,'Enable','on')
    set(handles.pushbutton_skip,'Enable','on');
    %set slider
    experiment=getappdata(0,'experiment');
    cbparams=getappdata(0,'cbparams');
    t=getappdata(0,'t');
    icurrf=t-cbparams.track.firstframetrack+1;
    ilastf=icurrf;
    set(handles.slider_frame,'Value',icurrf,'Min',1,'Max',ilastf,'SliderStep',[1/(ilastf),10/ilastf],'Enable','on')
    set(handles.text_info,'String',{['Experiment ', experiment];['Displaying frame ',num2str(t),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.']})  
    if ~ISPAUSE
        GUIscale=getappdata(0,'GUIscale');
        new_pos=get(handles.cbtrackGUI_ROI,'position'); 
        old_pos=GUIscale.original_position;
        GUIscale.rescalex=new_pos(3)/old_pos(3);
        GUIscale.rescaley=new_pos(4)/old_pos(4);
        GUIscale.position=new_pos;
        setappdata(0,'GUIscale',GUIscale)

        experiment=getappdata(0,'experiment');
        out=getappdata(0,'out');
        logfid=open_log('track_log');
        s={sprintf('Main tracking finished at %s for experiment %s...\n',datestr(now,'yyyymmddTHHMMSS'),experiment);...
            sprintf('Saving tracking results up to frame %i...\n',t)};
        write_log(logfid,getappdata(0,'experiment'),s)
        finalfile = fullfile(out.folder,cbparams.dataloc.trx.filestr);
        CourtshipBowlTrack_GUI_save(finalfile,t)
        
        setappdata(0,'P_stage','track2')
        if cbparams.track.dosave
            savetemp({'trackdata'})
        end
        
        uiresume(handles.cbtrackGUI_ROI)
        if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
            delete(handles.cbtrackGUI_ROI)
        end
        if logfid > 1,
            fclose(logfid);
        end
        restart='';
        setappdata(0,'restart',restart)
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
    experiment=getappdata(0,'experiment');
    cbparams=getappdata(0,'cbparams');
    iframe=get(handles.slider_frame,'Value');
    track=get(handles.pushbutton_start,'UserData');
    t=getappdata(0,'t');
    ilastf=t-cbparams.track.firstframetrack+1;
    cbparams=getappdata(0,'cbparams');
    roidata=getappdata(0,'roidata');
    trackdata=getappdata(0,'trackdata');
    tic;
    for j=iframe:ilastf
        set(handles.slider_frame,'Value',j);    
        if ~ISPLAYING
            break
        end
        f=j+cbparams.track.firstframetrack-1;
        set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(f),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.']})  
        frame=track.readframe(f);
        set(handles.video_img,'CData',frame);
        for roii = 1:roidata.nrois,
            roibb = roidata.roibbs(roii,:);
            offx = roibb(1)-1;
            offy = roibb(3)-1;
            for i = 1:2,
              updateellipse(handles.hell(i,roii),trackdata.trxx(i,roii,j)+offx,trackdata.trxy(i,roii,j)+offy,trackdata.trxtheta(i,roii,j),trackdata.trxa(i,roii,j),trackdata.trxb(i,roii,j));
              set(handles.htrx(i,roii),'XData',squeeze(trackdata.trxx(i,roii,max(j-30,1):j)+offx),...
                'YData',squeeze(trackdata.trxy(i,roii,max(j-30,1):j)+offy));
            end
        end
        drawnow;
    end
    ISPLAYING=false;
    set(handles.pushbutton_play,'String','Play','Backgroundcolor',[0,.5,0])
    set(handles.pushbutton_clear,'Enable','on');
    set(handles.pushbutton_save,'Enable','on');
    set(handles.pushbutton_start,'Enable','on');
    set(handles.pushbutton_accept,'Enable','on');
    set(handles.pushbutton_skip,'Enable','on');
end


function pushbutton_clear_Callback(hObject, eventdata, handles)
msg_clear=myquestdlg(14,'Helvetica',{'Which data would you like to delete?';'- All: Delete all the tracked frames';'- Current: Delete from the displayed frame'},'Cancel','All','Current','Cancel','Cancel'); 
logfid=open_log('track_log');
experiment=getappdata(0,'experiment');
if strcmp(msg_clear,'All')
    cbparams=getappdata(0,'cbparams');

    track=get(handles.pushbutton_start,'UserData');
    frame=track.readframe(cbparams.track.firstframetrack);
    set(handles.video_img,'CData',frame);
    if isfield(handles,'hell') 
        delete(handles.hell(ishandle(handles.hell)))
    end
    handles.hell=[];
    if isfield(handles,'htrx') 
        delete(handles.htrx(ishandle(handles.htrx)))
    end
    handles.htrx=[];

    rmappdata(0,'trackdata')

    set(handles.pushbutton_start,'String','Start Tracking');
    set(handles.pushbutton_save,'Enable','off')
    set(handles.pushbutton_clear,'Enable','off')
    set(handles.pushbutton_accept,'Enable','off')
    set(handles.pushbutton_play,'Enable','off')

     % Set slider
    set(handles.slider_frame,'Value',1,'Min',1,'Max',2,'SliderStep',[1/2,10/2])
    set(handles.text_info,'String',{['Experiment ', experiment];'Tracking flies: No frames tracked'})
    s=sprintf('All tracking data cleared at %s.\n',datestr(now,'yyyymmddTHHMMSS')');
    write_log(logfid,getappdata(0,'experiment'),s)
elseif strcmp(msg_clear,'Current')
    ilastf=get(handles.slider_frame,'Value');
    clear_partial(ilastf);  
    set(handles.slider_frame,'Max',ilastf,'SliderStep',[1/ilastf,10/ilastf]);
    cbparams=getappdata(0,'cbparams');
    currf=ilastf + cbparams.track.firstframetrack -1;
    set(handles.text_info,'String',{['Experiment ',experiment];['Displaying frame ',num2str(currf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.']})  
    s=sprintf('Tracking data cleared from frame %i at %s.\n',ilastf,datestr(now,'yyyymmddTHHMMSS'));
    write_log(logfid,getappdata(0,'experiment'),s)
end
if logfid > 1,
    fclose(logfid);
end


function pushbutton_save_Callback(hObject, eventdata, handles)
[tempfile,tempdir]=uiputfile('.mat');
out=getappdata(0,'out');
logfid=open_log('track_log');
t=getappdata(0,'twing');
trackdata=getappdata(0,'trackdata'); %#ok<*NASGU>
debugdata_WT=getappdata(0,'debugdata_WT');
tempfile = fullfile(tempdir,tempfile);
old_out=out.temp_full;
out.temp_full=tempfile;
setappdata(0,'out',out)
s=sprintf('Saving temporary file %s after frames %i at %s...\n',tempfile,t,datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,getappdata(0,'experiment'),s)
savetemp('all')
out.temp_full=old_out;
setappdata(0,'out',out)
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

setappdata(0,'iscancel',false)
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

setappdata(0,'iscancel',false)
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

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','body')
setappdata(0,'isnew',false)

function pushbutton_debuger_Callback(hObject, eventdata, handles)


function pushbutton_debug_Callback(hObject, eventdata, handles)


function pushbutton_WT_Callback(hObject, eventdata, handles)
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

setappdata(0,'button','wing')
setappdata(0,'isnew',false)


function pushbutton_skip_Callback(hObject, eventdata, handles)
setappdata(0,'iscancel',false)
setappdata(0,'isskip',true)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

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

% Last Modified by GUIDE v2.5 21-Feb-2014 16:28:12

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_ROI_temp (see VARARGIN)

% Choose default command line output for cbtrackGUI_ROI_temp
global ISPAUSE
ISPAUSE=true;
global ISPLAYING
ISPLAYING=false;

handles.output = hObject;
GUIsize(handles,hObject)
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
    
 % Set slider
first=cbparams.track.firstframetrack;
current=first;
last=current;
set(handles.slider_frame,'Value',current+1,'Min',first,'Max',last+1,'SliderStep',[.01,.1],'Enable','off')
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); %#ok<NASGU>


if isappdata(0,'trackdata')
    trackdata=getappdata(0,'trackdata');
    set(handles.pushbutton_start,'String','CONTINUE')
    first=cbparams.track.firstframetrack;
    current=trackdata.t;
    last=current;
    set(handles.slider_frame,'Value',current,'Min',first,'Max',last,'SliderStep',[.01,.1],'Enable','on')
    % Plot
    iframe = trackdata.t - cbparams.track.firstframetrack + 1;
    frame=track.readframe(iframe);
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
    icurrf=iframe;
    lastf=get(handles.slider_frame,'Max');
    ilastf=lastf-cbparams.track.firstframetrack+1;
    set(handles.text_info,'String',['Displaying frame ',num2str(icurrf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.'])  
    set(handles.pushbutton_accept,'Enable','on');
end
    

 
 GUI.old_pos=get(hObject,'position');


% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',GUI);
set(handles.slider_frame,'UserData',1);
set(handles.pushbutton_start,'UserData',track)
setappdata(0,'cbparams',cbparams);



% UIWAIT makes cbtrackGUI_ROI_temp wait for user response (see UIRESUME)
% uiwait(handles.cbtrackGUI_ROI_temp);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_tracker_video_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes during object creation, after setting all properties.
function axes_tracker_video_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to axes_tracker_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: place code in OpeningFcn to populate axes_tracker_video



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
out=getappdata(0,'out');
logfid=open_log('track_log',cbparams,out.folder);
t=getappdata(0,'t');
finalfile = fullfile(out.folder,cbparams.dataloc.trx.filestr);
fprintf(logfid,'Saving tracking results up to frame %i at %s...\n',t,datestr(now,'yyyymmddTHHMMSS'));
CourtshipBowlTrack_GUI_save(finalfile,t)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end
if logfid > 1,
  fclose(logfid);
end

setappdata(0,'P_stage','track2')
savetemp
CourtshipBowlTrack_GUI2
iscancel=getappdata(0,'iscancel');
if iscancel
    if iscancel==1
        cancelar
    end
    return
end
CourtshipBowlMakeResultsMovie_GUI
pffdata = CourtshipBowlComputePerFrameFeatures_GUI(1);
setappdata(0,'pffdata',pffdata)
cancelar


% --- Executes when cbtrackGUI_tracker_video is resized.
function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_tracker_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIresize(handles,hObject);

% --- Executes on slider movement.
function slider_frame_Callback(hObject, eventdata, handles)
% hObject    handle to slider_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=round(get(hObject,'Value'));
set(hObject,'Value',f);
set(handles.slider_frame,'UserData',f);
% Plot
roidata=getappdata(0,'roidata');
trackdata=getappdata(0,'trackdata');
cbparams=getappdata(0,'cbparams');
iframe = f - cbparams.track.firstframetrack + 1;
track=get(handles.pushbutton_start,'UserData');
frame=track.readframe(iframe);
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
icurrf=iframe;
lastf=get(handles.slider_frame,'Max');
ilastf=lastf-cbparams.track.firstframetrack+1;
set(handles.text_info,'String',['Displaying frame ',num2str(icurrf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.'])  





% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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
function axes_tracker_video_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_tracker_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes when user attempts to close cbtrackGUI_ROI.
function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
track=get(handles.pushbutton_start,'UserData');
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
fid_video=track.fid; %#ok<NASGU>
if strcmp('Yes',msg_cancel)
    cancelar
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
    CourtshipBowlTrack_GUI_debug(handles);
    set(handles.pushbutton_save,'Enable','on')
    set(handles.pushbutton_clear,'Enable','on')
    set(handles.pushbutton_accept,'Enable','on')
    set(handles.pushbutton_play,'Enable','on')
    %set slider
    cbparams=getappdata(0,'cbparams');
    firstf=cbparams.track.firstframetrack;
    t=getappdata(0,'t');
    currentf=t;
    %last=min(cbparams.track.lastframetrack,tracknframes);
    lastf=currentf;
    set(handles.slider_frame,'Value',currentf,'Min',firstf,'Max',lastf,'SliderStep',[.01,.1],'Enable','on')
    icurrf=currentf-cbparams.track.firstframetrack+1;
    ilastf=lastf-cbparams.track.firstframetrack+1;
    set(handles.text_info,'String',['Displaying frame ',num2str(icurrf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.'])  
    if ~ISPAUSE
        GUIscale=getappdata(0,'GUIscale');
        new_pos=get(handles.cbtrackGUI_ROI,'position'); 
        old_pos=GUIscale.original_position;
        GUIscale.rescalex=new_pos(3)/old_pos(3);
        GUIscale.rescaley=new_pos(4)/old_pos(4);
        GUIscale.position=new_pos;
        setappdata(0,'GUIscale',GUIscale)

        out=getappdata(0,'out');
        logfid=open_log('track_log',cbparams,out.folder);
        fprintf(logfid,'Main tracking finished at %s...\n',datestr(now,'yyyymmddTHHMMSS'));
        finalfile = fullfile(out.folder,cbparams.dataloc.trx.filestr);
        fprintf(logfid,'Saving tracking results up to frame %i...\n',t);
        CourtshipBowlTrack_GUI_save(finalfile,t)
        
        setappdata(0,'P_stage','track2')
        savetemp

        if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
            delete(handles.cbtrackGUI_ROI)
        end
        if logfid > 1,
            fclose(logfid);
        end
        restart='';
        setappdata(0,'restart',restart)
        CourtshipBowlTrack_GUI2
        iscancel=getappdata(0,'iscancel');
        if iscancel
            cancelar
            return
        end
        CourtshipBowlMakeResultsMovie_GUI
        pffdata = CourtshipBowlComputePerFrameFeatures_GUI(1);
        setappdata(0,'pffdata',pffdata)
        cancelar
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
    cbparams=getappdata(0,'cbparams');
    f=get(handles.slider_frame,'Value');
    track=get(handles.pushbutton_start,'UserData');
    t=getappdata(0,'t');
    lastf=t;
    ilastf=lastf-cbparams.track.firstframetrack+1;
    cbparams=getappdata(0,'cbparams');
    roidata=getappdata(0,'roidata');
    trackdata=getappdata(0,'trackdata');
    tic;
    for j=f:lastf
        set(handles.slider_frame,'Value',j);    
        if ~ISPLAYING
            break
        end
        iframe=j-cbparams.track.firstframetrack+1;
        icurrf=iframe;
        set(handles.text_info,'String',['Displaying frame ',num2str(icurrf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.'])  
        frame=track.readframe(j);
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
        drawnow;
    end
    set(handles.pushbutton_play,'String','Play','Backgroundcolor',[0,.5,0])
    set(handles.pushbutton_clear,'Enable','on');
    set(handles.pushbutton_save,'Enable','on');
    set(handles.pushbutton_start,'Enable','on');
    set(handles.pushbutton_accept,'Enable','on');
end


% --- Executes on button press in pushbutton_clear.
function pushbutton_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg_clear=myquestdlg(14,'Helvetica',{'Which data would you like to delete?';'- All: Delete all the tracked frames';'- Current: Delete from the displayed frame'},'Cancel','All','Current','Cancel','Cancel'); 
out=getappdata(0,'out');
logfid=open_log('track_log',getappdata(0,'cbparams'),out.folder);
if strcmp(msg_clear,'All')
    cbparams=getappdata(0,'cbparams');

    track=get(handles.pushbutton_start,'UserData');
    frame=track.readframe(1);
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
    first=cbparams.track.firstframetrack;
    if isfield(cbparams.track,'currframe')
        current=cbparams.track.currframe;
    else
        current=first;
    end
    %last=min(cbparams.track.lastframetrack,tracknframes);
    last=current;
    set(handles.slider_frame,'Value',current+1,'Min',first,'Max',last+1,'SliderStep',[.01,.1])
    set(handles.text_info,'String','Tracking flies: No frames tracked')
    fprintf(logfid,'All tracking data cleared at %s.\n',datestr(now,'yyyymmddTHHMMSS')');
elseif strcmp(msg_clear,'Current')
    lastf=get(handles.slider_frame,'Value');
    clear_partial(lastf);  
    set(handles.slider_frame,'Max',lastf);
    cbparams=getappdata(0,'cbparams');
    ilastf=lastf-cbparams.track.firstframetrack+1;
    icurrf=ilastf;
    set(handles.text_info,'String',['Displaying frame ',num2str(icurrf),'. ',num2str(ilastf),' of ',num2str(cbparams.track.nframetrack),' (',num2str(ilastf*100/cbparams.track.nframetrack,'%.1f'),'%) tracked.'])  
    fprintf(logfid,'Tracking data cleared from frame %i at %s.\n',lastf,datestr(now,'yyyymmddTHHMMSS'));
end
if logfid > 1,
    fclose(logfid);
end


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

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_ROI,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

delete(handles.cbtrackGUI_ROI)
cbtrackGUI_WingTracker

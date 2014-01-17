function varargout = cbtrackGUI_tracker(varargin)
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
%      applied to the GUI before cbtrackGUI_tracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_tracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_ROI_temp

% Last Modified by GUIDE v2.5 08-Dec-2013 10:25:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_tracker_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_tracker_OutputFcn, ...
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
function cbtrackGUI_tracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_ROI_temp (see VARARGIN)

% Choose default command line output for cbtrackGUI_ROI_temp
handles.output = hObject;
GUIsize(handles,hObject)
moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
roi_params=cbparams.detect_rois;
tracking_params=cbparams.track;
roidata=getappdata(0,'roidata');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
count=struct;
[count.readframe,count.nframes,count.fid,conunt.headerinfo] = get_readframe_fcn(moviefile);
frame=count.readframe(1);
aspect_ratio=size(frame,2)/size(frame,1);
pos1=get(handles.axes_tracker,'position'); %axes 1 position

% Plot figure
visdata.plot=1;
if aspect_ratio<=1 
    old_width=pos1(3); new_width=pos1(4)*aspect_ratio; pos1(3)=new_width; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(1)=pos1(1)-(new_width-old_width)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_tracker,'position',pos1) %reset axes position and size
else
    old_height=pos1(4); new_height=pos1(3)/aspect_ratio; pos1(4)=new_height; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(2)=pos1(2)-(new_height-old_height)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_tracker,'position',pos1) %reset axes position and size
end

axes(handles.axes_tracker);
colormap('gray')
handles.BG_img=imagesc(frame);
set(handles.axes_tracker,'XTick',[],'YTick',[])
axis equal


% Set parameters on the gui
set(handles.edit_set_nframessample,'String',num2str(roi_params.nframessample));
set(handles.edit_set_bgthresh,'String',num2str(tracking_params.bgthresh));
set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh);
fcn_slider_bgthresh = get(handles.slider_set_bgthresh,'Callback');
hlisten_bgthresh=addlistener(handles.slider_set_bgthresh,'ContinuousValueChange',fcn_slider_bgthresh); %#ok<NASGU>
set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea));
set(handles.slider_set_minccarea,'Value',tracking_params.minccarea);
fcn_slider_minccarea = get(handles.slider_set_minccarea,'Callback');
hlisten_minccarea=addlistener(handles.slider_set_minccarea,'ContinuousValueChange',fcn_slider_minccarea); %#ok<NASGU>


% Count flies on each ROI if they have not been count before
if ~isfield(roidata,'nflies_per_roi')
    [count.nflies_per_roi,visdata.frames,visdata.dbkgd,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] = CountFliesPerROI_GUI(count.readframe,bgmed,count.nframes,roidata,roi_params,tracking_params);
    roidata.isnew=3;
else
    visdata=getappdata(0,'visdata');
    count.nflies_per_roi=roidata.nflies_per_roi;
    set(handles.pushbutton_debuger,'Enable','on')
end

visdata.rois=~roidata.inrois_all;
visdata.hcc=[];
visdata.hflies=[];
visdata.hell=[];

% Plot ROIs
nROI=roidata.nrois;
if ~roidata.isall
    colors_roi = jet(nROI)*.7;
    hold on
    for i = 1:nROI,
      drawellipse(roidata.centerx(i),roidata.centery(i),0,roidata.radii(i),roidata.radii(i),'Color',colors_roi(i,:));
        text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
          'Color',colors_roi(i,:),'HorizontalAlignment','center','VerticalAlignment','middle');
    end
end
GUIscale=getappdata(0,'GUIscale');
pospanel=get(handles.uipanel_fxROI,'Position');
fontsize=14*min(GUIscale.rescalex,GUIscale.rescaley);
minposy=6*GUIscale.rescaley;
topposy=78*GUIscale.rescaley; topposy=pospanel(4)-minposy-topposy;
height=topposy-minposy;

text1=nan(nROI,1);
text2=nan(nROI,1);
edit1=nan(nROI,1);

fxROI=[(1:nROI)',count.nflies_per_roi',nan(nROI,1)];
posx=[14, 81, 146]*GUIscale.rescalex;
lowposy=topposy-26*(nROI-1)*GUIscale.rescaley;
posy=(topposy:-26*GUIscale.rescaley:lowposy);
w=[52,52,70]*GUIscale.rescalex;
h=[20,20,30]*GUIscale.rescaley;
if posy(1)-posy(end)>height
    rescale=height/(posy(1)-posy(end));
    fontsize=fontsize*rescale;
    posy=posy*rescale; repos=minposy-posy(end); posy=posy+repos;
    h=h*rescale;
end

for i=1:nROI
    text1(i)=uicontrol('Style','text', 'string',num2str(fxROI(i,1)),'fontsize',fontsize,'units','pixels','position',[posx(1), posy(i),w(1),h(1)],'parent',handles.uipanel_fxROI);
    text2(i)=uicontrol('Style','text', 'string',num2str(fxROI(i,2)),'fontsize',fontsize,'units','pixels','position',[posx(2), posy(i),w(2),h(2)],'parent',handles.uipanel_fxROI);
    edit1(i)=uicontrol('Style','edit', 'string',num2str(fxROI(i,3)),'BackgroundColor',[1 1 1],'fontsize',fontsize,'units','pixels','position',[posx(3), posy(i)-3,w(3),h(3)],'parent',handles.uipanel_fxROI,'enable','off');
end

 handles.text1=text1;
 handles.text2=text2;
 handles.edit1=edit1;
  
 % Set slider
nframessample=roi_params.nframessample;
set(handles.slider_frame,'Value',1,'Min',1,'Max',nframessample,'SliderStep',[1/(nframessample-1),10/(nframessample-1)])
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); %#ok<NASGU>
 
 GUI.old_pos=get(hObject,'position');


% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',GUI);
set(handles.edit_set_nframessample,'UserData',roi_params)
set(handles.edit_set_bgthresh,'UserData',tracking_params)
set(handles.pushbutton_set_count,'UserData',count);
set(handles.popupmenu_vis,'UserData',visdata);
set(handles.slider_frame,'UserData',1);
setappdata(0,'roidata',roidata)



% UIWAIT makes cbtrackGUI_ROI_temp wait for user response (see UIRESUME)
% uiwait(handles.cbtrackGUI_ROI_temp);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_tracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes during object creation, after setting all properties.
function axes_tracker_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to axes_tracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: place code in OpeningFcn to populate axes_tracker



% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.cbtrackGUI_ROI)


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles)
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

cbparams=getappdata(0,'cbparams');
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
roidata=getappdata(0,'roidata'); 

restart='';
setappdata(0,'restart',restart)

if roidata.isnew
    count=get(handles.pushbutton_set_count,'UserData');
    visdata=get(handles.popupmenu_vis,'UserData');
    if roidata.isnew==2
        msg_change=myquestdlg(14,'Helvetica','You changed some of the parameters but did not count the flyes. Would like to count the flies and save the parameters?','Warning','Yes','No','Cancel','No'); 
        if isempty(msg_change) || strcmp(msg_change,'Cancel')
            return
        elseif strcmp(msg_change,'Yes')
            BG=getappdata(0,'BG');
            bgmed=BG.bgmed;            
            roi_params.nframessample=str2double(get(handles.edit_set_nframessample,'String'));
            [count.nflies_per_roi,visdata.frames,visdata.dbkgd,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] = CountFliesPerROI_GUI(count.readframe,bgmed,count.nframes,roidata,roi_params,tracking_params);
            roidata.nflies_per_roi=count.nflies_per_roi;
            fxROI(:,2)=count.nflies_per_roi';
            for i=1:roidata.nrois
                set(handles.text2(i),'String',num2str(fxROI(i,2)))
            end

            if visdata.plot==6 && isempty(visdata.trx{1,1})
                visdata.trx(:,1)=fit_to_ellipse(roidata,count.nflies_per_roi, visdata.dbkgd{1}, visdata.isfore{1},tracking_params);
            end

            plot_vis(handles,visdata,1)

             % Set slider
            nframessample=roi_params.nframessample;
            set(handles.slider_frame,'Value',1,'Min',1,'Max',nframessample,'SliderStep',[1/(nframessample-1),10/(nframessample-1)])

            set(handles.pushbutton_set_count,'UserData',count);
            set(handles.popupmenu_vis,'UserData',visdata);
            set(handles.slider_frame,'UserData',1);
            set(handles.edit_set_nframessample,'UserData',roi_params);
            
            roidata.isnew=3;
            setappdata(0,'roidata',roidata)
            return
        end
    end
    cbparams.detect_rois=roi_params;
    cbparams.track.bgthresh=tracking_params.bgthresh;
    cbparams.track.minccarea=tracking_params.minccarea;
    roidata.nflies_per_roi=count.nflies_per_roi;
    roidata.isnew=false;
    setappdata(0,'cbparams',cbparams)
    setappdata(0,'visdata',visdata);
    setappdata(0,'roidata',roidata);
    if isappdata(0,'t')
        rmappdata(0,'t')
    end
    if isappdata(0,'trackdata')
        rmappdata(0,'trackdata')
    end
    
    out=getappdata(0,'out');
    savefile = fullfile(out.folder,cbparams.dataloc.roidatamat.filestr); 
    logfid=open_log('roi_log',cbparams,out.folder);
    fprintf(logfid,'Saving ROI data to file %s...\n\n***\n',savefile);
    if exist(savefile,'file'),
      delete(savefile);
    end
    save(savefile,'-struct','roidata');
    savetemp
end
if cbparams.track.DEBUG==1
    cbtrackGUI_tracker_video
else
    cbtrackGUI_tracker_NOvideo
end

delete(handles.cbtrackGUI_ROI)



% --- Executes when cbtrackGUI_tracker is resized.
function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_tracker (see GCBO)
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
visdata=get(handles.popupmenu_vis,'UserData');
if isempty(visdata.isfore{1,f})
    roi_params=get(handles.edit_set_nframessample,'UserData');
    tracking_params=get(handles.edit_set_bgthresh,'UserData');
    roidata=getappdata(0,'roidata');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    count=get(handles.pushbutton_set_count,'UserData');
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,count.nflies_per_roi,roi_params,tracking_params);
elseif visdata.plot==6 && isempty(visdata.trx{1,f})
    tracking_params=get(handles.edit_set_bgthresh,'UserData');
    roidata=getappdata(0,'roidata');
    count=get(handles.pushbutton_set_count,'UserData');
    visdata.trx(:,f)=fit_to_ellipse(roidata,count.nflies_per_roi, visdata.dbkgd{f}, visdata.isfore{f},tracking_params);
end

plot_vis(handles,visdata,f)
set(handles.slider_frame,'UserData',f);




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
function axes_tracker_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_tracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uipanel_fxROI.
function uipanel_fxROI_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_fxROI 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if eventdata.NewValue==handles.radiobutton_automatic %???
    for i=1:length(handles.edit1)
        set(handles.edit1(i),'Enable','off')
    end
elseif eventdata.NewValue==handles.radiobutton_manual 
    for i=1:length(handles.edit1)
        set(handles.edit1(i),'Enable','on')
    end   
end
%Update user and gui data
guidata(hObject, handles);


function edit_set_bgthresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_set_bgthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
tracking_params.bgthresh=str2double(get(hObject,'String'));
set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh)
f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
roidata=getappdata(0,'roidata');
nROI=roidata.nrois;
count=get(handles.pushbutton_set_count,'UserData');
nframes=count.nframes;
visdata.isfore=cell(1,nframes);
visdata.cc_ind=cell(nROI,nframes);
visdata.flies_ind=cell(nROI,nframes);
visdata.trx=cell(nROI,nframes);
[visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,count.nflies_per_roi,roi_params,tracking_params);
plot_vis(handles,visdata,f)
roidata.isnew=2;
setappdata(0,'roidata',roidata)
set(handles.edit_set_bgthresh,'UserData',tracking_params);
        

% Hints: get(hObject,'String') returns contents of edit_set_bgthresh as text
%        str2double(get(hObject,'String')) returns contents of edit_set_bgthresh as a double


% --- Executes during object creation, after setting all properties.
function edit_set_bgthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_set_bgthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_set_minccarea_Callback(hObject, eventdata, handles)
% hObject    handle to edit_set_minccarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
tracking_params.minccarea=str2double(get(hObject,'String'));
set(handles.slider_set_minccarea,'Value',tracking_params.minccarea)
f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
roidata=getappdata(0,'roidata');
nROI=roidata.nrois;
count=get(handles.pushbutton_set_count,'UserData');
nframes=count.nframes;
visdata.isfore=cell(1,nframes);
visdata.cc_ind=cell(nROI,nframes);
visdata.flies_ind=cell(nROI,nframes);
visdata.trx=cell(nROI,nframes);
[visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,count.nflies_per_roi,roi_params,tracking_params);
plot_vis(handles,visdata,f)
set(handles.edit_set_nframessample,'UserData',roi_params);
roidata.isnew=2;
setappdata(0,'roidata',roidata)


% --- Executes during object creation, after setting all properties.
function edit_set_minccarea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_set_minccarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_set_nframessample_Callback(hObject, eventdata, handles)
% hObject    handle to edit_set_nframessample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_set_nframessample as text
%        str2double(get(hObject,'String')) returns contents of edit_set_nframessample as a double


% --- Executes during object creation, after setting all properties.
function edit_set_nframessample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_set_nframessample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_set_count.
function pushbutton_set_count_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_set_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
roidata=getappdata(0,'roidata');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
count=get(hObject,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');

roi_params.nframessample=str2double(get(handles.edit_set_nframessample,'String'));

[count.nflies_per_roi,visdata.frames,visdata.dbkgd,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] = CountFliesPerROI_GUI(count.readframe,bgmed,count.nframes,roidata,roi_params,tracking_params);
fxROI(:,2)=count.nflies_per_roi';
for i=1:roidata.nrois
    set(handles.text2(i),'String',num2str(fxROI(i,2)))
end

if visdata.plot==6 && isempty(visdata.trx{1,1})
    visdata.trx(:,1)=fit_to_ellipse(roidata,count.nflies_per_roi, visdata.dbkgd{1}, visdata.isfore{1},tracking_params);
end

plot_vis(handles,visdata,1)

 % Set slider
nframessample=roi_params.nframessample;
set(handles.slider_frame,'Value',1,'Min',1,'Max',nframessample,'SliderStep',[1/(nframessample-1),10/(nframessample-1)])

roidata.isnew=3;

set(handles.pushbutton_set_count,'UserData',count);
set(handles.popupmenu_vis,'UserData',visdata);
set(handles.slider_frame,'UserData',1);
set(handles.edit_set_nframessample,'UserData',roi_params);
setappdata(0,'roidata',roidata)



% --- Executes when user attempts to close cbtrackGUI_ROI.
function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
count=get(handles.pushbutton_set_count,'UserData');
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
if isfield(count,'fid')
    fidBG=count.fid; %#ok<NASGU>
end
if strcmp('Yes',msg_cancel)
    cancelar
end


% --- Executes on slider movement.
function slider_set_bgthresh_Callback(hObject, eventdata, handles)
% hObject    handle to slider_set_bgthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
tracking_params.bgthresh=get(hObject,'Value');
set(handles.edit_set_bgthresh,'string',num2str(tracking_params.bgthresh))
f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
roidata=getappdata(0,'roidata');
nROI=roidata.nrois;
count=get(handles.pushbutton_set_count,'UserData');
nframes=count.nframes;
visdata.isfore=cell(1,nframes);
visdata.cc_ind=cell(nROI,nframes);
visdata.flies_ind=cell(nROI,nframes);
visdata.trx=cell(nROI,nframes);
[visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,count.nflies_per_roi,roi_params,tracking_params);
plot_vis(handles,visdata,f)
set(handles.edit_set_bgthresh,'UserData',tracking_params);
roidata.isnew=2;
setappdata(0,'roidata',roidata)




% --- Executes during object creation, after setting all properties.
function slider_set_bgthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_set_bgthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_set_minccarea_Callback(hObject, eventdata, handles)
% hObject    handle to slider_set_minccarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
tracking_params.minccarea=get(hObject,'Value');
set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea))
f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
roidata=getappdata(0,'roidata');
nROI=roidata.nrois;
count=get(handles.pushbutton_set_count,'UserData');
nframes=count.nframes;
visdata.isfore=cell(1,nframes);
visdata.cc_ind=cell(nROI,nframes);
visdata.flies_ind=cell(nROI,nframes);
visdata.trx=cell(nROI,nframes);
[visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,count.nflies_per_roi,roi_params,tracking_params);
plot_vis(handles,visdata,f)
set(handles.edit_set_bgthresh,'UserData',tracking_params);
roidata.isnew=2;
setappdata(0,'roidata',roidata)



% --- Executes during object creation, after setting all properties.
function slider_set_minccarea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_set_minccarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu_vis.
function popupmenu_vis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_vis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
visdata.plot=get(hObject,'Value');
roidata=getappdata(0,'roidata');
tracking_params=get(handles.edit_set_bgthresh,'UserData');

if visdata.plot==6 && isempty(visdata.trx{1,f})
    count=get(handles.pushbutton_set_count,'UserData');
    visdata.trx(:,f)=fit_to_ellipse(roidata,count.nflies_per_roi, visdata.dbkgd{f}, visdata.isfore{f},tracking_params);
end

plot_vis(handles,visdata,f)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_vis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_vis


% --- Executes during object creation, after setting all properties.
function popupmenu_vis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_vis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_trset.
function pushbutton_trset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cbtrackGUI_tracker_params


% --- Executes on button press in pushbutton_pff.
function pushbutton_pff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cbtrackGUI_pff

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


% --- Executes on button press in pushbutton_debuger.
function pushbutton_debuger_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_debuger (see GCBO)
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
cbtrackGUI_tracker_video

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

% Last Modified by GUIDE v2.5 04-Dec-2014 09:42:14

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


function cbtrackGUI_tracker_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

GUIsize(handles,hObject)

experiment=getappdata(0,'experiment');
moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
roi_params=cbparams.detect_rois;
tracking_params=cbparams.track;
movie_params=cbparams.results_movie;
pff_params=cbparams.compute_perframe_features;
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
roidata=getappdata(0,'roidata');
count=struct;
[count.readframe,count.nframes,count.fid,conunt.headerinfo] = get_readframe_fcn(moviefile);
[frame,tracking_params]=firstimage(handles,count.readframe(1),tracking_params);
visdata.frame_rs=frame;
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


% Open video frames
P_stages={'BG','ROIs','params','wing_params','track1','track2'};
P_curr_stage='params';
P_stage=getappdata(0,'P_stage');
if find(strcmp(P_stage,P_stages))>find(strcmp(P_curr_stage,P_stages))
    visdata=getappdata(0,'visdata');
    visdata.frame_rs=frame;
    visdata.plot=1;
    count.nflies_per_roi=roidata.nflies_per_roi;
    if cbparams.wingtrack.dosetwingtrack
        set(handles.pushbutton_WT,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('track1',P_stages)) && cbparams.track.DEBUG==1 && getappdata(0,'singleexp')
        set(handles.pushbutton_debuger,'Enable','on')
    end
else
    roidata.nflies_per_roi=roi_params.nflies_per_roi;        
    count.nflies_per_roi = nan(1,roidata.nrois);
    visdata.frames=...
        read_samples(count.readframe,count.nframes,roi_params.nframessample,tracking_params);
    if getappdata(0,'iscancel') || getappdata(0,'isskip')
        uiresume(handles.cbtrackGUI_ROI)
        if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
            delete(handles.cbtrackGUI_ROI)
        end
        return
    end
    visdata.framesW=[];
    visdata.dbkgd=[];
    visdata.dbkgdW=[];
    visdata.isfore=[];
    visdata.trx=[];
    visdata.trxW=[];
    roidata.isnew=1;
end

% Set parameters on the gui
if ~cbparams.track.dosetBG
    set(handles.pushbutton_BG,'Enable','off')
end
if ~cbparams.detect_rois.dosetROI
    set(handles.pushbutton_ROIs,'Enable','off')
end

% Estimate maximum minccarea as the area of the biggest cc
Mmccarea=max_minccarea(handles,visdata.frames{1},tracking_params,bgmed);

set(handles.edit_set_nframessample,'String',num2str(roi_params.nframessample));
set(handles.edit_set_first,'String',num2str(tracking_params.count_firstframe));
set(handles.edit_set_last,'String',num2str(tracking_params.count_lastframe));
set(handles.edit_set_first,'String',num2str(tracking_params.count_firstframe));
set(handles.edit_set_last,'String',num2str(tracking_params.count_lastframe));
set(handles.edit_set_dfactor,'String',num2str(tracking_params.down_factor));
set(handles.slider_set_dfactor,'Value',max(1,min(tracking_params.down_factor,100)));
fcn_slider_dfactor = get(handles.slider_set_dfactor,'Callback');
hlisten_dfactor=addlistener(handles.slider_set_dfactor,'ContinuousValueChange',fcn_slider_dfactor); %#ok<NASGU>
set(handles.edit_set_bgthresh,'String',num2str(tracking_params.bgthresh));
if tracking_params.normalize
    set(handles.slider_set_bgthresh,'Min',0,'Max',1);
end
set(handles.slider_set_bgthresh,'Value',min(tracking_params.bgthresh,get(handles.slider_set_bgthresh,'Max')));
fcn_slider_bgthresh = get(handles.slider_set_bgthresh,'Callback');
hlisten_bgthresh=addlistener(handles.slider_set_bgthresh,'ContinuousValueChange',fcn_slider_bgthresh); %#ok<NASGU>
set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea));
set(handles.slider_set_minccarea,'Value',tracking_params.minccarea,'Max',Mmccarea);
fcn_slider_minccarea = get(handles.slider_set_minccarea,'Callback');
hlisten_minccarea=addlistener(handles.slider_set_minccarea,'ContinuousValueChange',fcn_slider_minccarea); %#ok<NASGU>

visdata.hcc=[];
visdata.hflies=[];
visdata.hell=[];

% Plot ROIs
hold on
nROI=roidata.nrois;
if ~roidata.isall
    colors_roi = jet(nROI)*.7;
    
    for i = 1:nROI,
      drawellipse(roidata.centerx(i),roidata.centery(i),0,roidata.radii(i),roidata.radii(i),'Color',colors_roi(i,:));
        text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
          'Color',colors_roi(i,:),'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
    end
end
GUIscale=getappdata(0,'GUIscale');
pospanel=get(handles.uipanel_fxROI,'Position');
fontsize=14*min(GUIscale.rescalex,GUIscale.rescaley);
minposy=6*GUIscale.rescaley;
topposy=78*GUIscale.rescaley; topposy=pospanel(4)-minposy-topposy;
height=topposy-minposy;

check=nan(nROI,1);
text1=nan(nROI,1);
text2=nan(nROI,1);
edit1=nan(nROI,1);

fxROI=[(1:nROI)',nan(nROI,1),roidata.nflies_per_roi'];
posx=[10, 30, 81, 146]*GUIscale.rescalex;
lowposy=topposy-26*(nROI-1)*GUIscale.rescaley;
posy=(topposy:-26*GUIscale.rescaley:lowposy);
w=[15,20,52,70]*GUIscale.rescalex;
h=[20,20,20,30]*GUIscale.rescaley;
if posy(1)-posy(end)>height
    rescale=height/(posy(1)-posy(end));
    fontsize=fontsize*rescale;
    posy=posy*rescale; repos=minposy-posy(end); posy=posy+repos;
    h=h*rescale;
end

isignored=zeros(nROI,1);
isignored(roidata.ignore)=1;
for i=1:nROI
    check(i)=uicontrol('Style','checkbox','string','','fontunits','pixels',...
        'units','pixels','position',[posx(1), posy(i),w(1),h(1)],...
        'parent', handles.uipanel_fxROI,'value',~isignored(i),...
        'callback',@checkbox_Callback,'FontName','Arial');
    text1(i)=uicontrol('Style','text', 'string',num2str(fxROI(i,1)),...
        'fontunits','pixels','fontsize',fontsize,'units','pixels',...
        'position',[posx(2), posy(i),w(2),h(2)],'parent',handles.uipanel_fxROI,...
        'FontName','Arial');
    text2(i)=uicontrol('Style','text', 'string',num2str(fxROI(i,2)),...
        'fontunits','pixels','fontsize',fontsize,'units','pixels',...
        'position',[posx(3), posy(i),w(3),h(3)],'parent',handles.uipanel_fxROI,...
        'FontName','Arial');
    edit1(i)=uicontrol('Style','edit', 'string',num2str(fxROI(i,3)),...
        'fontunits','pixels','BackgroundColor',[1 1 1],'fontsize',fontsize,...
        'units','pixels','position',[posx(4), posy(i)-3,w(4),h(4)],...
        'parent',handles.uipanel_fxROI,'enable','off','FontName','Arial');
end
handles.check=check;
handles.text1=text1;
handles.text2=text2;
handles.edit1=edit1;

set(handles.text_exp,'FontSize',24,'HorizontalAlignment','center','units','pixels','FontUnits','pixels','String',experiment);
goodfs(handles.text_exp,experiment);

% Set slider
nframessample=roi_params.nframessample;
set(handles.slider_frame,'Value',1,'Min',1,'Max',nframessample,'SliderStep',[1/(nframessample-1),10/(nframessample-1)])
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); %#ok<NASGU>
 
% hslider=unique(findobj('Style','slider'));
% mins=get(hslider,'Min');
% maxs=get(hslider,'Max');
% if ~isa(mins,'cell')
%     mins=num2cell(mins);
%     maxs=num2cell(maxs);
% end
% if ~isa(mins,'cell')
%     mins=num2cell(mins);
%     maxs=num2cell(maxs);
% end
% for i=1:numel(hslider)
%     set(hslider(i),'SliderStep',[1/(maxs{i}-mins{i}),10/(maxs{i}-mins{i})])
% end

 GUI.old_pos=get(hObject,'position');


% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',GUI);
set(handles.edit_set_nframessample,'UserData',roi_params)
set(handles.edit_set_bgthresh,'UserData',tracking_params)
set(handles.pushbutton_set_count,'UserData',count);
set(handles.popupmenu_vis,'UserData',visdata);
set(handles.slider_frame,'UserData',1);
set(handles.uipanel_fxROI,'UserData',roidata)
set(handles.pushbutton_vid,'UserData',movie_params)
set(handles.pushbutton_pff,'UserData',pff_params);

uiwait(handles.cbtrackGUI_ROI)


function varargout = cbtrackGUI_tracker_OutputFcn(hObject, eventdata, handles)  %#ok<STOUT>


function axes_tracker_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


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

cbparams=getappdata(0,'cbparams');
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData'); 
count=get(handles.pushbutton_set_count,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');
movie_params=get(handles.pushbutton_vid,'UserData');
pff_params=get(handles.pushbutton_pff,'UserData');

restart='';
setappdata(0,'restart',restart)

setappdata(0,'isnew',roidata.isnew~=0)
if roidata.isnew
    if roidata.isnew==2 || all(isnan(count.nflies_per_roi)) || (cbparams.wingtrack.dosetwingtrack && isempty(visdata.trxW))
        nframessample=str2double(get(handles.edit_set_nframessample,'String'));
        count_first=str2double(get(handles.edit_set_first,'String'));
        count_last=str2double(get(handles.edit_set_last,'String'));
        if nframessample~=roi_params.nframessample || count_first~=tracking_params.count_firstframe || count_last~=tracking_params.count_lastframe
            visdata.frames=[];
            roi_params.nframessample=nframessample;
            tracking_params.count_firstframe=count_first;
            tracking_params.count_lastframe=count_last;
        end

        setappdata(0,'allow_stop',true)
        if cbparams.wingtrack.dosetwingtrack
            [count.nflies_per_roi,visdata.frames,visdata.framesW,visdata.dbkgdW,visdata.trxW] = ...
                CountFliesPerROI_GUI(visdata.frames,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack,vign,H0);
        else
            [count.nflies_per_roi,visdata.frames] = ...
                CountFliesPerROI_GUI(visdata.frames,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack,vign,H0);
        end
        if getappdata(0,'iscancel') || getappdata(0,'isskip')
            uiresume(handles.cbtrackGUI_ROI)
            if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
                delete(handles.cbtrackGUI_ROI)
            end
            return
        elseif getappdata(0,'isstop')
            setappdata(0,'isstop',false)
            return
        end
        roidata.nflies_per_roi=count.nflies_per_roi;
    end
    
    use_man=get(handles.uipanel_fxROI,'SelectedObject')==handles.radiobutton_manual;
    if use_man 
        nflies_per_roi_man=str2double(get(handles.edit1,'String'))';
        nflies_per_roi_man_ok=nflies_per_roi_man; nflies_per_roi_man_ok(roidata.ignore)=[];
        nflies_per_roi_ok=count.nflies_per_roi; nflies_per_roi_ok(roidata.ignore)=[];
        if all(isnumeric(nflies_per_roi_man_ok)) && any(nflies_per_roi_man_ok~=nflies_per_roi_ok)
            msg_nflies=myquestdlg(14,'Helvetica','The detected number of flies does not match the number input manualy. Do you wish to preceed?','Warning','Yes','No','No'); 
            if isempty(msg_nflies) || strcmp(msg_nflies,'No')
                return
            end
        end
        count.nflies_per_roi=nflies_per_roi_man;
    end
    
    % clear data
    if isappdata(0,'t')
        rmappdata(0,'t')
    end
    if isappdata(0,'trackdata')
        rmappdata(0,'trackdata')
    end
    if isappdata(0,'debugdata_WT')
        rmappdata(0,'debugdata_WT')
    end
    
    % save new params
    cbparams.detect_rois=roi_params;
    cbparams.detect_rois.nflies_per_roi=count.nflies_per_roi;
    cbparams.track=tracking_params;
    roidata.nflies_per_roi=count.nflies_per_roi;
    roidata.isnew=false;
    setappdata(0,'visdata',visdata);
    setappdata(0,'roidata',roidata);
    setappdata(0,'vign',vign);
    setappdata(0,'H0',H0);
    
    out=getappdata(0,'out');
    savefile = fullfile(out.folder,cbparams.dataloc.roidatamat.filestr); 
    logfid=open_log('roi_log');
    s=sprintf('Saving ROI data to file %s...\n\n***\n',savefile);
    write_log(logfid,getappdata(0,'experiment'),s)
    if logfid>1
        fclose(logfid);
    end
    if exist(savefile,'file'),
      delete(savefile);
    end
    save(savefile,'-struct','roidata');
    setappdata(0,'P_stage','wing_params')
    if cbparams.track.dosave
        savetemp({'roidata','visdata','vign','H0'})
    end
end
cbparams.results_movie=movie_params;
cbparams.compute_perframe_features=pff_params;

setappdata(0,'cbparams',cbparams)
setappdata(0,'iscancel',false)
setappdata(0,'isskip',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','wing')


function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
GUIscale=getappdata(0,'GUIscale');
GUIscale=GUIresize(handles,hObject,GUIscale);
setappdata(0,'GUIscale',GUIscale)


function slider_frame_Callback(hObject, eventdata, handles)
f=round(get(hObject,'Value'));
set(hObject,'Value',f);

tracking_params=get(handles.edit_set_bgthresh,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

update_frame(handles,tracking_params,visdata,vign,H0)

set(handles.slider_frame,'UserData',f);


function slider_frame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function axes_tracker_ButtonDownFcn(hObject, eventdata, handles)


function uipanel_fxROI_SelectionChangeFcn(hObject, eventdata, handles)
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
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

tracking_params.bgthresh=str2double(get(hObject,'String'));
set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh)

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 
set(handles.edit_set_bgthresh,'UserData',tracking_params);


function edit_set_bgthresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_minccarea_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

tracking_params.minccarea=str2double(get(hObject,'String'));
set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh)

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 
set(handles.edit_set_bgthresh,'UserData',tracking_params);


function edit_set_minccarea_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_nframessample_Callback(hObject, eventdata, handles)
roidata=get(handles.uipanel_fxROI,'UserData') ;
roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 


function edit_set_nframessample_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_set_count_Callback(hObject, eventdata, handles)
cbparams=getappdata(0,'cbparams');
roi_params=get(handles.edit_set_nframessample,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
count=get(hObject,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

nframessample=str2double(get(handles.edit_set_nframessample,'String'));
count_first=str2double(get(handles.edit_set_first,'String'));
count_last=str2double(get(handles.edit_set_last,'String'));
if nframessample~=roi_params.nframessample || count_first~=tracking_params.count_firstframe || count_last~=tracking_params.count_lastframe
    visdata.frames=[];
    roi_params.nframessample=nframessample;
    tracking_params.count_firstframe=count_first;
    tracking_params.count_lastframe=count_last;
end

setappdata(0,'allow_stop',true)
[count.nflies_per_roi,visdata.frames,visdata.framesW,visdata.dbkgdW,visdata.trxW] = ...
    CountFliesPerROI_GUI(visdata.frames,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack,vign,H0);
if getappdata(0,'iscancel') || getappdata(0,'isskip')
    uiresume(handles.cbtrackGUI_ROI)
    if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
        delete(handles.cbtrackGUI_ROI)
    end
    return
elseif getappdata(0,'isstop')
    setappdata(0,'isstop',false)
    return
end
fxROI(:,2)=count.nflies_per_roi';
for i=1:roidata.nrois
    set(handles.text2(i),'String',num2str(fxROI(i,2)))
end

plot_vis(handles,visdata)

roidata.nflies_per_roi=count.nflies_per_roi;
roidata.isnew=3;

set(handles.pushbutton_set_count,'UserData',count);
set(handles.slider_frame,'UserData',1);
set(handles.edit_set_nframessample,'UserData',roi_params);
set(handles.uipanel_fxROI,'UserData',roidata)
set(handles.edit_set_bgthresh,'UserData',tracking_params);
set(handles.popupmenu_vis,'UserData',visdata);


function cbtrackGUI_ROI_CloseRequestFcn(hObject, eventdata, handles)
count=get(handles.pushbutton_set_count,'UserData');
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
if isfield(count,'fid') && count.fid>1
    fclose(count.fid); 
end
if strcmp('Yes',msg_cancel)
    setappdata(0,'iscancel',true)
    setappdata(0,'isskip',true)
    uiresume(handles.cbtrackGUI_ROI)
    if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
        delete(handles.cbtrackGUI_ROI)
    end
end


function slider_set_bgthresh_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

tracking_params.bgthresh=get(hObject,'Value');
set(handles.edit_set_bgthresh,'string',num2str(tracking_params.bgthresh))

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 
set(handles.edit_set_bgthresh,'UserData',tracking_params);


function slider_set_bgthresh_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider_set_minccarea_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

tracking_params.minccarea=get(hObject,'Value');
set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea))

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 
set(handles.edit_set_bgthresh,'UserData',tracking_params);


function slider_set_minccarea_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu_vis_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

visdata.plot=get(hObject,'Value');

update_frame(handles,tracking_params,visdata,vign,H0);


function popupmenu_vis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_trset_Callback(hObject, eventdata, handles)
tracking_params=get(handles.edit_set_bgthresh,'UserData');
handles.update_fh=@update_frame;
handles.visdata=get(handles.popupmenu_vis,'UserData');
[temp_Tparams,vign,H0]=cbtrackGUI_tracker_params(tracking_params,handles);
cbparams=getappdata(0,'cbparams');
if ~isequaln(temp_Tparams,cbparams.track)
    roidata=get(handles.uipanel_fxROI,'UserData');
    if temp_Tparams.bgthresh_low~=tracking_params.bgthresh_low
        roidata.isnew=2;
    else
        roidata.isnew=1;
    end
    set(handles.uipanel_fxROI,'UserData',roidata) 
    set(handles.edit_set_bgthresh,'UserData',temp_Tparams)
    set(handles.pushbutton_trset,'UserData',vign)
    set(handles.edit_set_first,'UserData',H0)
end


function pushbutton_pff_Callback(hObject, eventdata, handles)
pff_params=get(handles.pushbutton_pff,'UserData');
pff_params = cbtrackGUI_pff(pff_params);
set(handles.pushbutton_pff,'UserData',pff_params)


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

setappdata(0,'button','track')
setappdata(0,'isnew',false)


function pushbutton_WT_Callback(hObject, eventdata, handles)
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


function pushbutton_vid_Callback(hObject, eventdata, handles)
movie_params=get(handles.pushbutton_vid,'UserData');
roi_params=get(handles.edit_set_nframessample,'UserData');
count=get(handles.pushbutton_set_count,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

if isfield(roidata,'nflies_per_roi')
    nflies_per_roi=roidata.nflies_per_roi;
else
    nflies_per_roi=[];
end
if all(~isnan(count.nflies_per_roi))
    roidata.nflies_per_roi=count.nflies_per_roi;
elseif ~isempty(roi_params.nflies_per_roi) && all(~isnan(roi_params.nflies_per_roi))
    roidata.nflies_per_roi=roi_params.nflies_per_roi;
else 
    roidata.nflies_per_roi=2*ones(1,roidata.nrois);
end
setappdata(0,'roidata',roidata);

movie_params = video_params(movie_params,vign,H0);

if isempty(nflies_per_roi)
    roidata=rmfield(roidata,'nflies_per_roi');
else
    roidata.nflies_per_roi=nflies_per_roi;
end
set(handles.pushbutton_vid,'UserData',movie_params)
setappdata(0,'roidata',roidata)


function pushbutton_skip_Callback(hObject, eventdata, handles)
setappdata(0,'iscancel',false)
setappdata(0,'isskip',true)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end


function checkbox_Callback(hObject, eventdata)
handles=guidata(hObject);
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

use=get(handles.check,'Value');
roidata.ignore=find(~cell2mat(use));
tracking_params.ignorebowls=roidata.ignore; % AL20150630 does not appear to be used for anything, see discussion in CountFliesPerROI_GUI

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 


function edit_set_last_Callback(hObject, eventdata, handles)
roidata=get(handles.uipanel_fxROI,'UserData') ;
roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 


function edit_set_last_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_first_Callback(hObject, eventdata, handles)
roidata=get(handles.uipanel_fxROI,'UserData') ;
roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 


function edit_set_first_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_dfactor_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

tracking_params.down_factor=str2double(get(hObject,'String'));
set(handles.slider_set_dfactor,'Value',tracking_params.down_factor)

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 
set(handles.edit_set_bgthresh,'UserData',tracking_params);


function edit_set_dfactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider_set_dfactor_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');

tracking_params.down_factor=get(hObject,'Value');
set(handles.edit_set_dfactor,'string',num2str(tracking_params.down_factor))

update_frame(handles,tracking_params,visdata,vign,H0);

roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 
set(handles.edit_set_bgthresh,'UserData',tracking_params);


function slider_set_dfactor_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function Mmccarea=max_minccarea(handles,frame,tracking_params,bgmed)
vign=get(handles.pushbutton_trset,'UserData');
H0=get(handles.edit_set_first,'UserData');
roidata=getappdata(0,'roidata');
if tracking_params.normalize
    im_class='double';
else
    im_class=class(frame);
end

if tracking_params.normalize
    normalize=bgmed;
else
    normalize=ones(size(bgmed));
end
tracking_params.down_factor=1;
[~,dbkgd]=compute_dbkgd1(frame,tracking_params,bgmed,roidata.inrois_all,H0,im_class,vign,normalize);
isfore = dbkgd >= tracking_params.bgthresh;
cc=bwconncomp(isfore);
cc.Area = cellfun(@numel,cc.PixelIdxList);
Mccarea=max(cc.Area);
Mmccarea=2*Mccarea;


function update_frame(handles,tracking_params,visdata,vign,H0)
roidata=get(handles.uipanel_fxROI,'UserData');
f=get(handles.slider_frame,'UserData');
[visdata.frame_rs,visdata.dbkgd,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] =...
    ChangeParams_GUI(visdata.frames{f},roidata,roidata.nflies_per_roi,tracking_params,vign,H0,visdata.plot);
plot_vis(handles,visdata)


function [frame,tracking_params]=firstimage(handles,frame,tracking_params)
if tracking_params.computeBG || isempty(tracking_params.vign_coef)
    vign=ones(size(frame));
    tracking_params.vign_coef=[1 0 0 0 0 0 0 0 0 0];
else
    [X,Y]=meshgrid(1:size(frame,2),1:size(frame,1));
    A=tracking_params.vign_coef;
    vign=ones(size(X)).*A(1)+X.*A(2)+Y.*A(3)+X.^2.*A(4)+X.*Y.*A(5)+Y.^2.*A(6)+X.^3.*A(7)+X.^2.*Y.*A(8)+X.*Y.^2.*A(9)+Y.^3.*A(10);
end

% Equalize histogram using different methods (1 and 2 requires a
% reference histogram H0)
if any(tracking_params.eq_method==[1,2])
  H0=base_hist(tracking_params,roi_params);
  frame=histeq(uint8(frame),H0);
else
  H0=[];
  frame=eq_image(frame);
end

% Devignet and normalize
frame = double(frame)./vign;
frame = imresize(frame,1/tracking_params.down_factor);
set(handles.pushbutton_trset,'UserData',vign)
set(handles.edit_set_nframessample,'UserData',H0)



% function pushbutton72_Callback(hObject, eventdata, handles)
% expdir=getappdata(0,'expdir');
% paramsfile=fullfile(expdir,'params.xml');
% defaultparams=ReadXMLParams(paramsfile);
% 
% roidata=get(handles.uipanel_fxROI,'UserData'); 
% roi_params=get(handles.edit_set_nframessample,'UserData');
% tracking_params=get(handles.edit_set_bgthresh,'UserData');
% temp_Tparams=get(handles.pushbutton_trset,'UserData');
% 
% roi_params.nframessample=defaultparams.detect_rois.nframessample;
% tracking_params.count_firstframe=defaultparams.track.count_firstframe;
% tracking_params.count_lastframe=defaultparams.track.count_lastframe;
% tracking_params.bgthresh=defaultparams.track.bgthresh;
% tracking_params.minccarea=defaultparams.track.minccarea;
% temp_Tparams.firstframetrack=defaultparams.track.firstframetrack;
% temp_Tparams.lastframetrack=defaultparams.track.lastframetrack;
% temp_Tparams.DEBUG=defaultparams.track.DEBUG;
% temp_Tparams.assignidsby=defaultparams.track.assignidsby;
% temp_Tparams.typefield=defaultparams.track.typefield;
% temp_Tparams.typesmallval=defaultparams.track.typesmallval;
% temp_Tparams.typebigval=defaultparams.track.typebigval;
% temp_Tparams.dotrackwings=defaultparams.track.dotrackwings;
% 
% set(handles.edit_set_nframessample,'String',num2str(roi_params.nframessample));
% set(handles.edit_set_first,'String',num2str(roi_params.count_firstframe));
% set(handles.edit_set_last,'String',num2str(roi_params.count_lastframe));
% set(handles.edit_set_bgthresh,'String',num2str(tracking_params.bgthresh));
% set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh);
% set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea));
% set(handles.slider_set_minccarea,'Value',tracking_params.minccarea);
% 
% roidata.isnew=2;
% 
% set(handles.uipanel_fxROI,'UserData',roidata); 
% set(handles.edit_set_nframessample,'UserData',roi_params);
% set(handles.edit_set_bgthresh,'UserData',tracking_params);
% set(handles.pushbutton_trset,'UserData',temp_Tparams);

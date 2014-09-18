% roidata.isnew=0; Nothing has changed. Nothing is saved.
% roidata.isnew=1; Only cbparams.track.DEBUG has changed. Only cbparams is saved
% roidata.isnew=2; Some parameters have changed but flies have not been recounte. The user is offered to either continue without saving or recounting.
% roidata.isnew=3; Flies have been recounted. roidata and cbparams are saved

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

% Last Modified by GUIDE v2.5 08-Sep-2014 11:36:21

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
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
roidata=getappdata(0,'roidata');
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


% Open video frames
P_stages={'BG','ROIs','params','wing_params','track1','track2'};
P_curr_stage='params';
P_stage=getappdata(0,'P_stage');
if find(strcmp(P_stage,P_stages))>find(strcmp(P_curr_stage,P_stages))
    visdata=getappdata(0,'visdata');
    if isstruct(visdata.trx) && size(visdata.trx,1)==nansum(roidata.nflies_per_roi) % The seccond part prevents format conversion if it has already been converted
        trx=struct('x',[],'y',[],'a',[],'b',[],'theta',[]);
        trx=repmat({trx},[roidata.nrois,roi_params.nframessample]);
        f=0;
        for i=1:roidata.nrois
            if isnan(roidata.nflies_per_roi(i))
                trx(i,:)=[];
                continue
            end
            f=f(end)+1:f(end)+roidata.nflies_per_roi(i);
            for t=1:roi_params.nframessample
                trx{i,t}.x=visdata.trx(f,t).x;
                trx{i,t}.y=visdata.trx(f,t).y;
                trx{i,t}.a=visdata.trx(f,t).a;
                trx{i,t}.b=visdata.trx(f,t).b;
                trx{i,t}.theta=visdata.trx(f,t).theta;
            end
        end    
        visdata.trx=trx;
    end
    count.trx=visdata.trx;
    count.nflies_per_roi=roidata.nflies_per_roi;
    if cbparams.wingtrack.dosetwingtrack
        set(handles.pushbutton_WT,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('track1',P_stages)) && cbparams.track.DEBUG==1 && getappdata(0,'singleexp')
        set(handles.pushbutton_debuger,'Enable','on')
    end
else
    if isfield(roidata,'nflies_per_roi') && getappdata(0,'usefiles')
        count.nflies_per_roi=roidata.nflies_per_roi;
    else
        roidata.nflies_per_roi=roi_params.nflies_per_roi;        
        count.nflies_per_roi = nan(1,roidata.nrois);
    end
    [visdata.frames,visdata.dbkgd]=compute_dbkgd(count.readframe,count.nframes,roi_params.nframessample,tracking_params.bgmode,bgmed,roidata.inrois_all);
    if getappdata(0,'iscancel') || getappdata(0,'isskip')
        uiresume(handles.cbtrackGUI_ROI)
        if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
            delete(handles.cbtrackGUI_ROI)
        end
        return
    end
    visdata.isfore=cell(1,roi_params.nframessample);
    visdata.cc_ind=cell(roidata.nrois,roi_params.nframessample);
    visdata.flies_ind=cell(roidata.nrois,roi_params.nframessample);
    visdata.trx=cell(roidata.nrois,roi_params.nframessample);
    count.trx=visdata.trx;
    roidata.isnew=3;
end

% Set parameters on the gui
if ~cbparams.track.dosetBG
    set(handles.pushbutton_BG,'Enable','off')
end
if ~cbparams.detect_rois.dosetROI
    set(handles.pushbutton_ROIs,'Enable','off')
end

% Estimate maximum minccarea as the area of the biggest cc
isfore = visdata.dbkgd{1} >= tracking_params.bgthresh;
cc=bwconncomp(isfore);
cc.Area = cellfun(@numel,cc.PixelIdxList);
maxccarea=2*max(cc.Area);
if isempty(maxccarea)
    maxccarea=10*tracking_params.minccarea;
end
clear cc

set(handles.edit_set_nframessample,'String',num2str(roi_params.nframessample));
set(handles.edit_set_bgthresh,'String',num2str(tracking_params.bgthresh));
set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh);
fcn_slider_bgthresh = get(handles.slider_set_bgthresh,'Callback');
hlisten_bgthresh=addlistener(handles.slider_set_bgthresh,'ContinuousValueChange',fcn_slider_bgthresh); %#ok<NASGU>
set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea));
set(handles.slider_set_minccarea,'Value',tracking_params.minccarea,'Max',maxccarea);
fcn_slider_minccarea = get(handles.slider_set_minccarea,'Callback');
hlisten_minccarea=addlistener(handles.slider_set_minccarea,'ContinuousValueChange',fcn_slider_minccarea); %#ok<NASGU>

visdata.rois=~roidata.inrois_all;
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
        'callback',@checkbox_Callback);
    text1(i)=uicontrol('Style','text', 'string',num2str(fxROI(i,1)),...
        'fontunits','pixels','fontsize',fontsize,'units','pixels',...
        'position',[posx(2), posy(i),w(2),h(2)],'parent',handles.uipanel_fxROI);
    text2(i)=uicontrol('Style','text', 'string',num2str(fxROI(i,2)),...
        'fontunits','pixels','fontsize',fontsize,'units','pixels',...
        'position',[posx(3), posy(i),w(3),h(3)],'parent',handles.uipanel_fxROI);
    edit1(i)=uicontrol('Style','edit', 'string',num2str(fxROI(i,3)),...
        'fontunits','pixels','BackgroundColor',[1 1 1],'fontsize',fontsize,...
        'units','pixels','position',[posx(4), posy(i)-3,w(4),h(4)],...
        'parent',handles.uipanel_fxROI,'enable','off');
end
handles.check=check;
handles.text1=text1;
handles.text2=text2;
handles.edit1=edit1;

set(handles.text_exp,'FontSize',24,'HorizontalAlignment','center','units','pixels','FontUnits','pixels','String',experiment);
 
% Set slider
nframessample=roi_params.nframessample;
set(handles.slider_frame,'Value',1,'Min',1,'Max',nframessample,'SliderStep',[1/(nframessample-1),10/(nframessample-1)])
fcn_slider_frame = get(handles.slider_frame,'Callback');
hlisten_frame=addlistener(handles.slider_frame,'ContinuousValueChange',fcn_slider_frame); %#ok<NASGU>
 
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
set(handles.edit_set_nframessample,'UserData',roi_params)
set(handles.edit_set_bgthresh,'UserData',tracking_params)
set(handles.pushbutton_set_count,'UserData',count);
set(handles.popupmenu_vis,'UserData',visdata);
set(handles.slider_frame,'UserData',1);
set(handles.pushbutton_trset,'UserData',cbparams.track)
set(handles.uipanel_fxROI,'UserData',roidata) 

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

restart='';
setappdata(0,'restart',restart)

if all(isnan(count.nflies_per_roi)) || all([cbparams.wingtrack.dosetwingtrack,all(all(cellfun(@isempty,visdata.trx)))]) 
    roi_params.nframessample=str2double(get(handles.edit_set_nframessample,'String'));
    setappdata(0,'allow_stop',true)
    [count.nflies_per_roi,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] = CountFliesPerROI_GUI(visdata.dbkgd,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack);
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
    count.trx=visdata.trx;
    roidata.nflies_per_roi=count.nflies_per_roi;
    roidata.isnew=3;
end
isnew=roidata.isnew;

if isnew
    if isnew==2
        msg_change=myquestdlg(14,'Helvetica','You changed some of the parameters but did not count the flyes. Would like to count the flies and save the parameters?','Warning','Yes','No','Cancel','No'); 
        if isempty(msg_change) || strcmp(msg_change,'Cancel')
            return
        elseif strcmp(msg_change,'Yes')
            roi_params.nframessample=str2double(get(handles.edit_set_nframessample,'String'));
            setappdata(0,'allow_stop',true)
            [count.nflies_per_roi,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] = CountFliesPerROI_GUI(visdata.dbkgd,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack);
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
            count.trx=visdata.trx;
            roidata.nflies_per_roi=count.nflies_per_roi;
            fxROI(:,2)=count.nflies_per_roi';
            for i=1:roidata.nrois
                set(handles.text2(i),'String',num2str(fxROI(i,2)))
            end
            f=get(handles.slider_frame,'Value');
            if visdata.plot==6 && isempty(visdata.trx{1,f})
                visdata.trx(:,f)=fit_to_ellipse_GUI(roidata,count.nflies_per_roi, visdata.dbkgd{1}, visdata.isfore{1},tracking_params);    
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
            set(handles.uipanel_fxROI,'UserData',roidata) 
            return        
        end
    elseif isnew==3 && cbparams.wingtrack.dosetwingtrack
        use_man=get(handles.uipanel_fxROI,'SelectedObject')==handles.radiobutton_manual;
        nflies_per_roi_man=str2double(get(handles.edit1,'String'))';
        nflies_per_roi_man_ok=nflies_per_roi_man; nflies_per_roi_man_ok(roidata.ignore)=[];
        nflies_per_roi_ok=count.nflies_per_roi; nflies_per_roi_ok(roidata.ignore)=[];
        if use_man 
            if all(isnumeric(nflies_per_roi_man_ok)) && any(nflies_per_roi_man_ok~=nflies_per_roi_ok)
                msg_nflies=myquestdlg(14,'Helvetica','The detected number of flies does not match the number input manualy. Do you wish to preceed?','Warning','Yes','No','No'); 
                if isempty(msg_nflies) || strcmp(msg_nflies,'No')
                    return
                end
            end
            count.nflies_per_roi=nflies_per_roi_man;
        end
        visdata.trx=struct('x',[],'y',[],'a',[],'b',[],'theta',[]);
        visdata.trx=repmat(visdata.trx,[nansum(count.nflies_per_roi),roi_params.nframessample]);
        k=1;
        for iroi = 1:size(count.trx,1),
            if any(roidata.ignore==iroi)
                continue
            end
            for fly=1:count.nflies_per_roi(iroi)
                for t=1:size(count.trx,2)
                    visdata.trx(k,t).x = count.trx{iroi,t}.x(fly);
                    visdata.trx(k,t).y = count.trx{iroi,t}.y(fly);
                    visdata.trx(k,t).a = count.trx{iroi,t}.a(fly)/2;
                    visdata.trx(k,t).b = count.trx{iroi,t}.b(fly)/2;
                    visdata.trx(k,t).theta = count.trx{iroi,t}.theta(fly);           
                end
                k=k+1;
            end
        end
    end
    if isappdata(0,'t')
        rmappdata(0,'t')
    end
    if isappdata(0,'trackdata')
        rmappdata(0,'trackdata')
    end
    if isappdata(0,'debugdata_WT')
        rmappdata(0,'debugdata_WT')
    end
    if isappdata(0,'twing')
        rmappdata(0,'twing')
    end
    
    temp_Tparams=get(handles.pushbutton_trset,'UserData');
    cbparams.detect_rois=roi_params;
    cbparams.detect_rois.nflies_per_roi=count.nflies_per_roi;
    cbparams.track=temp_Tparams;
    cbparams.track.bgthresh=tracking_params.bgthresh;
    cbparams.track.minccarea=tracking_params.minccarea;
    roidata.nflies_per_roi=count.nflies_per_roi;
    roidata.isnew=false;
    setappdata(0,'cbparams',cbparams)
    setappdata(0,'visdata',visdata);
    setappdata(0,'roidata',roidata);
    
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
        savetemp({'roidata','visdata'})
    end
end

setappdata(0,'iscancel',false)
setappdata(0,'isskip',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

if cbparams.wingtrack.dosetwingtrack
    cbtrackGUI_WingTracker
elseif getappdata(0,'singleexp') && cbparams.track.dotrack
    if ~cbparams.track.DEBUG
        WriteParams
        setappdata(0,'P_stage','track1')
        savetemp([])
        cbtrackGUI_tracker_NOvideo
    else
        if isnew
            WriteParams
            setappdata(0,'P_stage','track1')
            savetemp([])
            cbtrackGUI_tracker_video
        else
            P_stage=getappdata(0,'P_stage');       
            if strcmp(P_stage,'track2')
                CourtshipBowlTrack_GUI2
                if getappdata(0,'iscancel') || getappdata(0,'isskip')
                    return
                end
            elseif strcmp(P_stage,'track1')
                cbtrackGUI_tracker_video
            end
        end        
    end
end


function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
GUIscale=getappdata(0,'GUIscale');
GUIscale=GUIresize(handles,hObject,GUIscale);
setappdata(0,'GUIscale',GUIscale)



function slider_frame_Callback(hObject, eventdata, handles)
f=round(get(hObject,'Value'));
set(hObject,'Value',f);
visdata=get(handles.popupmenu_vis,'UserData');
roidata=get(handles.uipanel_fxROI,'UserData');
if isempty(visdata.isfore{1,f}) && visdata.plot~=1 && visdata.plot~=2
    roi_params=get(handles.edit_set_nframessample,'UserData');
    tracking_params=get(handles.edit_set_bgthresh,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,roidata.nflies_per_roi,roi_params,tracking_params);
elseif visdata.plot==6 && isempty(visdata.trx{1,f})
    tracking_params=get(handles.edit_set_bgthresh,'UserData');
    visdata.trx(:,f)=fit_to_ellipse_GUI(roidata,roidata.nflies_per_roi, visdata.dbkgd{f}, visdata.isfore{f},tracking_params);
end

plot_vis(handles,visdata,f)
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
if visdata.plot~=1 && visdata.plot~=2
    roi_params=get(handles.edit_set_nframessample,'UserData');
    tracking_params=get(handles.edit_set_bgthresh,'UserData');
    tracking_params.bgthresh=str2double(get(hObject,'String'));
    set(handles.slider_set_bgthresh,'Value',tracking_params.bgthresh)
    f=get(handles.slider_frame,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=get(handles.uipanel_fxROI,'UserData');
    nROI=roidata.nrois;
    count=get(handles.pushbutton_set_count,'UserData');
    nframes=count.nframes;
    visdata.isfore=cell(1,nframes);
    visdata.cc_ind=cell(nROI,nframes);
    visdata.flies_ind=cell(nROI,nframes);
    visdata.trx=cell(nROI,nframes);
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] =...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,roidata.nflies_per_roi,roi_params,tracking_params);
    plot_vis(handles,visdata,f)
    roidata.isnew=2;
    set(handles.uipanel_fxROI,'UserData',roidata) 
    set(handles.edit_set_bgthresh,'UserData',tracking_params);
end


function edit_set_bgthresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_minccarea_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
if visdata.plot~=1 && visdata.plot~=2
    roi_params=get(handles.edit_set_nframessample,'UserData');
    tracking_params=get(handles.edit_set_bgthresh,'UserData');
    tracking_params.minccarea=str2double(get(hObject,'String'));
    set(handles.slider_set_minccarea,'Value',tracking_params.minccarea)
    f=get(handles.slider_frame,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    roidata=get(handles.uipanel_fxROI,'UserData');
    nROI=roidata.nrois;
    count=get(handles.pushbutton_set_count,'UserData');
    nframes=count.nframes;
    visdata.isfore=cell(1,nframes);
    visdata.cc_ind=cell(nROI,nframes);
    visdata.flies_ind=cell(nROI,nframes);
    visdata.trx=cell(nROI,nframes);
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] =...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,roidata.nflies_per_roi,roi_params,tracking_params);
    plot_vis(handles,visdata,f)
    set(handles.edit_set_nframessample,'UserData',roi_params);
    roidata.isnew=2;
    set(handles.uipanel_fxROI,'UserData',roidata) 
end


function edit_set_minccarea_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_set_nframessample_Callback(hObject, eventdata, handles)
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

roi_params.nframessample=str2double(get(handles.edit_set_nframessample,'String'));

setappdata(0,'allow_stop',true)
[count.nflies_per_roi,visdata.isfore,visdata.cc_ind,visdata.flies_ind,visdata.trx] = CountFliesPerROI_GUI(visdata.dbkgd,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack);
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
count.trx=visdata.trx;
fxROI(:,2)=count.nflies_per_roi';
for i=1:roidata.nrois
    set(handles.text2(i),'String',num2str(fxROI(i,2)))
end

f=get(handles.slider_frame,'Value');
plot_vis(handles,visdata,f)

roidata.nflies_per_roi=count.nflies_per_roi;
roidata.isnew=3;

set(handles.pushbutton_set_count,'UserData',count);
set(handles.slider_frame,'UserData',1);
set(handles.edit_set_nframessample,'UserData',roi_params);
set(handles.uipanel_fxROI,'UserData',roidata) 


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
tracking_params=get(handles.edit_set_bgthresh,'UserData');
tracking_params.bgthresh=get(hObject,'Value');
set(handles.edit_set_bgthresh,'string',num2str(tracking_params.bgthresh))
roidata=get(handles.uipanel_fxROI,'UserData');
if visdata.plot~=1 && visdata.plot~=2
    roi_params=get(handles.edit_set_nframessample,'UserData');
    f=get(handles.slider_frame,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    nROI=roidata.nrois;
    count=get(handles.pushbutton_set_count,'UserData');
    nframes=count.nframes;
    visdata.isfore=cell(1,nframes);
    visdata.cc_ind=cell(nROI,nframes);
    visdata.flies_ind=cell(nROI,nframes);
    visdata.trx=cell(nROI,nframes);
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] =...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,roidata.nflies_per_roi,roi_params,tracking_params);
    plot_vis(handles,visdata,f)
end
set(handles.edit_set_bgthresh,'UserData',tracking_params);
roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 



function slider_set_bgthresh_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider_set_minccarea_Callback(hObject, eventdata, handles)
visdata=get(handles.popupmenu_vis,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
tracking_params.minccarea=get(hObject,'Value');
set(handles.edit_set_minccarea,'String',num2str(tracking_params.minccarea))
roidata=get(handles.uipanel_fxROI,'UserData');
if visdata.plot~=1 && visdata.plot~=2
    roi_params=get(handles.edit_set_nframessample,'UserData');
    f=get(handles.slider_frame,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    nROI=roidata.nrois;
    count=get(handles.pushbutton_set_count,'UserData');
    nframes=count.nframes;
    visdata.isfore=cell(1,nframes);
    visdata.cc_ind=cell(nROI,nframes);
    visdata.flies_ind=cell(nROI,nframes);
    visdata.trx=cell(nROI,nframes);
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] =...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,count.nflies_per_roi,roi_params,tracking_params);
    plot_vis(handles,visdata,f)
end
set(handles.edit_set_bgthresh,'UserData',tracking_params);
roidata.isnew=2;
set(handles.uipanel_fxROI,'UserData',roidata) 



function slider_set_minccarea_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function popupmenu_vis_Callback(hObject, eventdata, handles)
f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
visdata.plot=get(hObject,'Value');
roidata=get(handles.uipanel_fxROI,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
if isempty(visdata.isfore{1,f}) || roidata.isnew==2 && visdata.plot~=1 && visdata.plot~=2 
    roi_params=get(handles.edit_set_nframessample,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] =...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,roidata.nflies_per_roi,roi_params,tracking_params);
elseif isempty(visdata.trx{1,f}) || roidata.isnew==2 && visdata.plot==6 
    visdata.trx(:,f)=fit_to_ellipse_GUI(roidata,roidata.nflies_per_roi, visdata.dbkgd{f}, visdata.isfore{f},tracking_params);
end

plot_vis(handles,visdata,f)


function popupmenu_vis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_trset_Callback(hObject, eventdata, handles)
temp_Tparams=get(handles.pushbutton_trset,'UserData');
temp_Tparams=cbtrackGUI_tracker_params(temp_Tparams);
cbparams=getappdata(0,'cbparams');
if ~isequal(temp_Tparams,cbparams.track)
    roidata=get(handles.uipanel_fxROI,'UserData');
    if roidata.isnew~=2
        if temp_Tparams.DEBUG~=cbparams.track.DEBUG
            roidata.isnew=1;
        else
            roidata.isnew=3;
        end
    end
    set(handles.uipanel_fxROI,'UserData',roidata) 
    set(handles.pushbutton_trset,'UserData',temp_Tparams)
end


function pushbutton_pff_Callback(hObject, eventdata, handles)
cbtrackGUI_pff


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

P_stage=getappdata(0,'P_stage');
if strcmp(P_stage,'track2')
    CourtshipBowlTrack_GUI2
    if getappdata(0,'iscancel') || getappdata(0,'isskip')
        return
    end
elseif strcmp(P_stage,'track1')
    cbtrackGUI_tracker_video
end


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

cbtrackGUI_WingTracker


function pushbutton_vid_Callback(hObject, eventdata, handles)
video_params


function pushbutton_skip_Callback(hObject, eventdata, handles)
setappdata(0,'iscancel',false)
setappdata(0,'isskip',true)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end


function checkbox_Callback(hObject, eventdata)
handles=guidata(hObject);
roidata=get(handles.uipanel_fxROI,'UserData');
use=get(handles.check,'Value');
roidata.ignore=find(~cell2mat(use));
roidata.isnew=2;

f=get(handles.slider_frame,'UserData');
visdata=get(handles.popupmenu_vis,'UserData');
tracking_params=get(handles.edit_set_bgthresh,'UserData');
if visdata.plot~=1 && visdata.plot~=2 
    roi_params=get(handles.edit_set_nframessample,'UserData');
    BG=getappdata(0,'BG');
    bgmed=BG.bgmed;
    [visdata.isfore{f},visdata.cc_ind(:,f),visdata.flies_ind(:,f),visdata.trx(:,f)] = ...
        ChangeParams_GUI(visdata.frames{f},bgmed,visdata.dbkgd{f},roidata,roidata.nflies_per_roi,roi_params,tracking_params);
end
plot_vis(handles,visdata,f)

set(handles.uipanel_fxROI,'UserData',roidata) ;
function varargout = cbtrackGUI_ROI(varargin)
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
%      applied to the GUI before cbtrackGUI_ROI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_ROI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_ROI_temp

% Last Modified by GUIDE v2.5 16-Jun-2014 08:30:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_ROI_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_ROI_OutputFcn, ...
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


function cbtrackGUI_ROI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for cbtrackGUI_ROI_temp
handles.output = hObject;

GUIsize(handles,hObject)

experiment=getappdata(0,'experiment');
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
aspect_ratio=size(bgmed,2)/size(bgmed,1);
pos1=get(handles.axes_ROI,'position'); %axes 1 position

if aspect_ratio<=1 
    old_width=pos1(3); new_width=pos1(4)*aspect_ratio; pos1(3)=new_width; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(1)=pos1(1)-(new_width-old_width)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_ROI,'position',pos1) %reset axes position and size
else
    old_height=pos1(4); new_height=pos1(3)/aspect_ratio; pos1(4)=new_height; %Recalculate the width of the axes to fit the figure aspect ratio
    pos1(2)=pos1(2)-(new_height-old_height)/2; %Recalculate the new horizontal position of the axes
    set(handles.axes_ROI,'position',pos1) %reset axes position and size
end

% Plot BG figure
axes(handles.axes_ROI);
colormap('gray')
handles.BG_img=imagesc(bgmed);
set(handles.axes_ROI,'XTick',[],'YTick',[])
axis equal

%Initialize
manual.pos=cell(0);
manual.roi=1; %number of ROIS detected
manual.proi=0; %number of rois selected on esach ROI;
manual.pos_h=cell(0); %point plots handles
manual.add=0; % 1 whena dding point to a ROI after removing any of the exitent ones; 2 when adding points to a ROI after removing ALL the existent ones; 3 when adding points to a ROI after pressing Add
manual.pos_h=cell(0);
manual.on=0;
manual.delete=0;
set(handles.text_exp,'FontSize',24,'HorizontalAlignment','center','units','pixels','FontUnits','pixels','String',experiment);
goodfs(handles.text_exp,experiment);

list.text=cell(0); %list of selected points to display at listbox_manual
list.ind=cell(0);
list.ind_mat=[]; %(ROI,point) index matrix
GUI.bgmed=bgmed;
set(handles.cbtrackGUI_ROI,'WindowButtonDownFcn',{@axes_ROI_ButtonDownFcn,handles});
cbparams=getappdata(0,'cbparams');


% Load and plot roidata if exists
P_stages={'BG','ROIs','params','wing_params','track1','track2'};
P_curr_stage='ROIs';
P_stage=getappdata(0,'P_stage');
if find(strcmp(P_stage,P_stages))>find(strcmp(P_curr_stage,P_stages))
    roidata=getappdata(0,'roidata');
    if isfield(roidata,'manual')
        manual=roidata.manual;
    else
        manual.pos=[];
    end
    if isfield(roidata,'list')
        list=roidata.list;
    else
        list=[];
    end
    params=roidata.params;
    colors = jet(roidata.nrois)*.7;
    axes(handles.axes_ROI)
    hold on
    handles.hroisT=nan(roidata.nrois,1);
    for i = 1:roidata.nrois,
        ROIpos=[roidata.centerx(i)-roidata.radii(i),roidata.centery(i)-roidata.radii(i),2*roidata.radii(i),2*roidata.radii(i)];
        handles.hrois(i,1)=imellipse(handles.axes_ROI,ROIpos);
        handles.hrois(i,1).setFixedAspectRatioMode(1);
        handles.hrois(i,1).setColor(colors(i,:));
        handles.hroisT(i,1)=text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
          'Color',colors(i,:),'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
        if ~isempty(manual.pos)
            for j=1:length(manual.pos{i})
                manual.pos_h{i}(j)=plot(manual.pos{i}(j,1),manual.pos{i}(j,2),'rx');
            end
            set(handles.listbox_manual,'string',vertcat(list.text{:}),'Value',numel(vertcat(list.text{:})))
        end
    end
    if ~roidata.isall
        set(handles.pushbutton_delete,'Enable','on')
        if ~isempty(manual.pos)
            set(handles.listbox_manual,'Enable','on')
            set(handles.pushbutton_detect,'Enable','on');
        end
    end
    set(handles.pushbutton_detect,'UserData',roidata)
    if cbparams.track.dosettrack
        set(handles.pushbutton_tracker_setup,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('wing_params',P_stages)) && cbparams.wingtrack.dosetwingtrack
        set(handles.pushbutton_WT,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('track1',P_stages)) && cbparams.track.DEBUG==1 && getappdata(0,'singleexp')
        set(handles.pushbutton_debuger,'Enable','on')
    end
else
    out=getappdata(0,'out');
    loadfile=fullfile(out.folder,cbparams.dataloc.roidatamat.filestr);
    if getappdata(0,'usefiles') && exist(loadfile,'file')
        try
            roidata=load(loadfile);
            manual=roidata.manual;
            list=roidata.list;
            logfid=open_log('roi_log');
            s=sprintf('Loading ROI data data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
            write_log(logfid,experiment,s)
            if logfid > 1,
              fclose(logfid);
            end
            isempty(roidata.cbdetectrois_version);
            roidata.params.dosetROI=cbparams.detect_rois.dosetROI;
            params=roidata.params;
            colors = jet(roidata.nrois)*.7;
            axes(handles.axes_ROI)
            hold on
            handles.hroisT=nan(roidata.nrois,1);
            for i = 1:roidata.nrois,
                ROIpos=[roidata.centerx(i)-roidata.radii(i),roidata.centery(i)-roidata.radii(i),2*roidata.radii(i),2*roidata.radii(i)];
                handles.hrois(i,1)=imellipse(handles.axes_ROI,ROIpos);
                handles.hrois(i,1).setFixedAspectRatioMode(1);
                handles.hrois(i,1).setColor(colors(i,:));
                handles.hroisT(i,1)=text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
                  'Color',colors(i,:),'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
                if ~isempty(manual.pos)
                    for j=1:length(manual.pos{i})
                        manual.pos_h{i}(j)=plot(manual.pos{i}(j,1),manual.pos{i}(j,2),'rx');
                    end
                    set(handles.listbox_manual,'string',vertcat(list.text{:}),'Value',numel(vertcat(list.text{:})))
                end
            end
            maual.detected=true;
            if ~roidata.isall
                set(handles.pushbutton_delete,'Enable','on')
                if ~isempty(manual.pos)
                    set(handles.listbox_manual,'Enable','on')
                    set(handles.pushbutton_detect,'Enable','on');
                end
            end
        catch
            logfid=open_log('roi_log');
            s=sprintf('File %s could not be loaded.',loadfile);
            write_log(logfid,experiment,s)
            if logfid > 1,
              fclose(logfid);
            end
            waitfor(mymsgbox(50,190,14,'Helvetica',{['File ', loadfile,' could not be loaded.'];'Trying to detect ROIs automatically'},'Warning','warn','modal'))
            params=cbparams.detect_rois;
            if isempty(params.roimus.x) || isempty(params.roimus.y) || ~cbparams.track.computeBG
                roidata=AllROI(BG.bgmed);
            else
                params.roimus=[params.roimus.x',params.roimus.y'];
                [handles,roidata] = DetectROIsGUI(bgmed,cbparams,params,handles);
                roidata.ignore=params.ignorebowls;
                set(handles.pushbutton_delete,'Enable','on')
            end
        end
    else
        params=cbparams.detect_rois;
        if isempty(params.roimus.x) || isempty(params.roimus.y) || ~cbparams.track.computeBG
            roidata=AllROI(BG.bgmed);
        else
            params.roimus=[params.roimus.x',params.roimus.y'];
            [handles,roidata] = DetectROIsGUI(bgmed,cbparams,params,handles);
            roidata.ignore=params.ignorebowls;
            set(handles.pushbutton_delete,'Enable','on')
            manual.detected=true;
        end
    end
    roidata.isnew=true;
end
% set parameter in the GUI
if ~cbparams.track.dosetBG
    set(handles.pushbutton_BG,'Enable','off')
end
set(handles.edit_set_ROId,'String', num2str(params.roidiameter_mm))
set(handles.edit_set_rot,'String', num2str(params.baserotateby))
set(handles.edit_set_thres1,'String', num2str(params.cannythresh(1)))
set(handles.edit_set_thres2,'String', num2str(params.cannythresh(2)))
set(handles.edit_set_std,'String', num2str(params.cannysigma))

% Update handles structure
set(handles.radiobutton_manual,'UserData',manual);
set(handles.listbox_manual,'UserData',list);
set(handles.cbtrackGUI_ROI,'UserData',GUI);
set(handles.uipanel_settings,'Userdata',params)
set(handles.pushbutton_detect,'Userdata',roidata);
guidata(hObject, handles);

uiwait(handles.cbtrackGUI_ROI)


function varargout = cbtrackGUI_ROI_OutputFcn(hObject, eventdata, handles)  %#ok<STOUT>


function axes_ROI_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


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

roidata=get(handles.pushbutton_detect,'UserData');
manual=get(handles.radiobutton_manual,'UserData');
list=get(handles.listbox_manual,'UserData');
cbparams=getappdata(0,'cbparams');
params=get(handles.uipanel_settings,'UserData');

if isempty(roidata) || size(fieldnames(roidata),1)==0 || isempty(roidata.centerx)
    BG=getappdata(0,'BG');    
    roidata=AllROI(BG.bgmed);
    params.roimus.x=[];
    params.roimus.y=[];
else
    new_nrois=length(handles.hrois);
    new_position=nan(4,new_nrois);
    for i=1:new_nrois
        new_position(:,i)=handles.hrois(i).getPosition;
    end
    new_centerx=new_position(1,:)+new_position(3,:)./2;
    new_centery=new_position(2,:)+new_position(4,:)./2;
    new_radii=new_position(3,:)./2;
    if new_nrois~=roidata.nrois || any(abs(new_centerx-roidata.centerx)>1) || any(abs(new_centery-roidata.centery)>1) || any(abs(new_radii-roidata.radii)>1)
        roidata = updateROIs(cbparams,params,roidata,[new_centerx;new_centery;new_radii]);
        roidata.isnew=true;
    end
    params.roimus.x=roidata.centerx;
    params.roimus.y=roidata.centery;
end

isnew=roidata.isnew;
setappdata(0,'isnew',isnew)
restart='';
setappdata(0,'restart',restart)

if isnew
    if isempty(params.nflies_per_roi) || numel(params.nflies_per_roi)~=roidata.nrois
        params.nflies_per_roi=2*ones(1,roidata.nrois);
    end
    
    if isfield(roidata,'nflies_per_roi')
        roidata=rmfield(roidata,'nflies_per_roi');
    end

    if isappdata(0,'visdata')
        rmappdata(0,'visdata')
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
    roidata.isnew=false;
    roidata.manual=manual;
    roidata.list=list;
    roidata.params=params;
    cbparams.detect_rois=params;
    setappdata(0,'roidata',roidata)
    setappdata(0,'cbparams',cbparams)
    
    out=getappdata(0,'out');
    logfid=open_log('roi_log');
    savefile = fullfile(out.folder,cbparams.dataloc.roidatamat.filestr);
    s=sprintf('Saving ROI data to file %s...\n',savefile);
    write_log(logfid,getappdata(0,'experiment'),s)
    if exist(savefile,'file'),
      delete(savefile);
    end
    save(savefile,'-struct','roidata');
    imsavename = fullfile(out.folder,cbparams.dataloc.roiimage.filestr);
    s=sprintf('Outputting visualization of results to %s...\n\n***\n',imsavename);
    write_log(logfid,getappdata(0,'experiment'),s)
    if logfid>1
        fclose(logfid);
    end
    if exist(imsavename,'file'),
      delete(imsavename);
    end
    hfig=figure;
    set(hfig,'Visible','off')
    copyobj(handles.axes_ROI,hfig)
    save2png(imsavename,hfig);
    close(hfig)
    setappdata(0,'P_stage','params')
    if cbparams.track.dosave
        savetemp({'roidata'})
    end
end

setappdata(0,'iscancel',false)
setappdata(0,'isskip',false)
uiresume(handles.cbtrackGUI_ROI)
if isfield(handles,'cbtrackGUI_ROI') && ishandle(handles.cbtrackGUI_ROI)
    delete(handles.cbtrackGUI_ROI)
end

setappdata(0,'button','body')


function cbtrackGUI_ROI_ResizeFcn(hObject, eventdata, handles)
GUIscale=getappdata(0,'GUIscale');
GUIscale=GUIresize(handles,hObject,GUIscale);
setappdata(0,'GUIscale',GUIscale)


function text_load_Callback(hObject, eventdata, handles)


function edit_load_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_load_Callback(hObject, eventdata, handles)
[file_ROI, folder_ROI]=open_files2('mat');
if ~file_ROI{1}==0
    try
        set(handles.edit_load,'String',fullfile(folder_ROI,file_ROI{1}),'HorizontalAlignment','right')
        manual=get(handles.radiobutton_manual,'UserData');
        [handles,~,~,~]=deleterois(handles,manual);
        set(handles.texth,'String','ROIs loaded from file'); 
        roidata=load(fullfile(folder_ROI,file_ROI{1}));
        manual=roidata.manual;
        list=roidata.list;
        colors = jet(roidata.nrois)*.7;
        axes(handles.axes_ROI)
        hold on
        handles.hroisT=nan(roidata.nrois,1);
        for i = 1:roidata.nrois,
            ROIpos=[roidata.centerx(i)-roidata.radii(i),roidata.centery(i)-roidata.radii(i),2*roidata.radii(i),2*roidata.radii(i)];
            handles.hrois(i,1)=imellipse(handles.axes_ROI,ROIpos);
            handles.hrois(i,1).setFixedAspectRatioMode(1);
            handles.hrois(i,1).setColor(colors(i,:));
            handles.hroisT(i,1)=text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
              'Color',colors(i,:),'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
            if ~isempty(manual.pos)
                for j=1:length(manual.pos{i})
                    manual.pos_h{i}(j)=plot(manual.pos{i}(j,1),manual.pos{i}(j,2),'rx');
                end
                set(handles.listbox_manual,'string',vertcat(list.text{:}),'Value',numel(vertcat(list.text{:})))
            end
        end
        roidata.isnew=true;
        if isfield(roidata,'nflies_per_roi')
            roidata=rmfield(roidata,'nflies_per_roi');
        end
        params=get(handles.uipanel_settings,'Userdata');
        roidata.params.dosetROI=params.dosetROI;
        manual.on=0;
        manual.detected=1;
        manual.delete=0;
        if ~roidata.isall
            set(handles.pushbutton_delete,'Enable','on')
            if ~isempty(manual.pos)
                set(handles.listbox_manual,'Enable','on')
                set(handles.pushbutton_detect,'Enable','on');
            end
        end

        set(handles.pushbutton_delete,'String','Delete');
        set(handles.radiobutton_manual,'UserData',manual)
        set(handles.listbox_manual,'UserData',list);
        set(handles.pushbutton_detect,'UserData',roidata);
        set(handles.uipanel_settings,'Userdata',roidata.params)
    catch
        mymsgbox(50,190,14,'Helvetica','ROI data could not be loaded','error')
    end
end
guidata(handles.cbtrackGUI_ROI, handles);




function listbox_manual_Callback(hObject, eventdata, handles)
list=get(handles.listbox_manual,'UserData');
manual=get(handles.radiobutton_manual,'UserData');
roidata=get(handles.pushbutton_detect,'UserData');
rem_v=get(hObject,'Value');
rem_roi=list.ind_mat(rem_v,1);
rem_proi=list.ind_mat(rem_v,2);

if manual.add==3 %use when the button "add" has been pushed; no point is removed and roi and proi are set acordingly
    if manual.proi(manual.roi)==0
        manual.oldroi=manual.roi;
    else
        manual.oldroi=manual.roi+1;
    end
    manual.oldproi=manual.proi(manual.roi);
    manual.roi=rem_roi;
    manual.add=2;
    set(handles.texth,'String',['Selecting ROI ', num2str(manual.roi),' point ', num2str(manual.proi(manual.roi)+1)]);    
    set(handles.radiobutton_manual,'UserData',manual);
    return
end
  
if manual.delete 
    msg_manual_lb=myquestdlg(14,'Helvetica','Are you sure you would like to delete the selected item/s?','Delete Point?','Yes','No','No'); 
    if isempty(msg_manual_lb)
        msg_manual_lb='No';
    end
    if strcmp('Yes',msg_manual_lb) %remove selected point from the list and plot
        if rem_proi==0
            set(handles.listbox_manual,'string',vertcat(list.text{:}),'Value',numel(vertcat(list.text{:}))) 
            msg_manual_lb2=myquestdlg(14,'Helvetica',{'Would you like to select new points for this ROI?';' - ''Yes'' will maintain the same ROI number. You must select new ROI points';' - ''No'' will reasing the ROI numbers'},'Replace ROI points?','Yes','No','No'); 
            if isempty(msg_manual_lb2)
                msg_manual_lb2='No';
            end
            if strcmp('Yes',msg_manual_lb2) || manual.roi==rem_roi
                list.text{rem_roi}=[];
                list.ind{rem_roi}=[];
                manual.pos{rem_roi}=[];
                axes(handles.axes_ROI);
                if isfield(manual,'pos_h') 
                    delete(manual.pos_h{rem_roi}(ishandle(manual.pos_h{rem_roi})))
                    manual.pos_h{rem_roi}=[];
                end
                if manual.detected && length(handles.hroisT)>=rem_roi
                    set(handles.hrois(rem_roi),'Visible','off')                    
                    set(handles.hroisT(rem_roi),'Visible','off') 
                    roidata.centerx(rem_roi)=nan;
                    roidata.centery(rem_roi)=nan;
                    roidata.radii(rem_roi)=nan;
                    roidata.scores(rem_roi)=nan;
                    roidata.roibbs(rem_roi,:)=nan(1,4);
                    roidata.inrois{rem_roi}=[];
                end
                manual.add=2;
                manual.oldroi=manual.roi+1;
                manual.oldproi=0;
                manual.roi=rem_roi;
                manual.proi(manual.roi)=0;
                manual.delete=0;
                set(handles.pushbutton_delete,'String','Delete')
            else
                list.text(rem_roi)=[];
                list.ind(rem_roi)=[];
                for i=rem_roi:length(list.text)
                    k=find(list.text{i}{1}==' ');
                    list.text{i}{1}=['ROI ',num2str(str2double(list.text{i}{1}(k+1:end-1))-1),':'];
                    list.ind{i}(:,1)=list.ind{i}(:,1)-1;
                end
                manual.pos(rem_roi)=[];
                axes(handles.axes_ROI);
                if isfield(manual,'pos_h') 
                    delete(manual.pos_h{rem_roi}(ishandle(manual.pos_h{rem_roi})))
                    manual.pos_h(rem_roi)=[];
                end
                if manual.detected && length(handles.hroisT)>=rem_roi
                    delete(handles.hrois(rem_roi)) 
                    handles.hrois(rem_roi)=[];
                    delete(handles.hroisT(rem_roi))                    
                    handles.hroisT(rem_roi)=[];
                    roidata.centerx(rem_roi)=[];
                    roidata.centery(rem_roi)=[];
                    roidata.radii(rem_roi)=[];
                    roidata.scores(rem_roi)=[];
                    roidata.roibbs(rem_roi,:)=[];
                    roidata.inrois(rem_roi)=[];
                    roidata.nrois=roidata.nrois-1;
                    for i=rem_roi:length(handles.hroisT)
                        set(handles.hroisT(i,1),'String',['ROI: ',num2str(i)]);
                    end
                end
                manual.proi(manual.roi)=[];
                ind=cat(1,list.ind{:});
                manual.roi=max(ind(:,1))+1;
                manual.proi(manual.roi)=0;
            end
        else
            list.text{rem_roi}(rem_proi+1)=[];
            list.ind{rem_roi}(rem_proi+1:end,2)=list.ind{rem_roi}(rem_proi+1:end,2)-1; list.ind{rem_roi}(rem_proi+1,:)=[]; %Reset the indexes
            list.ind_mat=vertcat(list.ind{:}); list.ind_mat=sortrows(list.ind_mat);
            manual.pos{rem_roi}(rem_proi,:)=[];
            axes(handles.axes_ROI);
            if isfield(manual,'pos_h') && ishandle(manual.pos_h{rem_roi}(rem_proi))
                delete(manual.pos_h{rem_roi}(rem_proi))
                manual.pos_h{rem_roi}(rem_proi)=[];
            end
            if manual.detected && length(handles.hroisT)>=rem_roi
                set(handles.hrois(rem_roi),'Visible','off')                    
                set(handles.hroisT(rem_roi),'Visible','off')
                roidata.centerx(rem_roi)=nan;
                roidata.centery(rem_roi)=nan;
                roidata.radii(rem_roi)=nan;
                roidata.scores(rem_roi)=nan;
                roidata.roibbs(rem_roi,:)=nan(1,4);
                roidata.inrois{rem_roi}=[];
            end
            manual.proi(rem_roi)=max(list.ind{rem_roi}(:,2));
            %Add new points to the ROI if there are less than 3 poitns
            if manual.proi(rem_roi)<3 && manual.roi~=rem_roi
                msg_manual=mymsgbox(50,190,14,'Helvetica',{'You need at least THREE points per ROI';'Please, select one more point for this ROI'},'Error','error','modal'); %#ok<NASGU>
                set(handles.radiobutton_load,'Enable','off')
                set(handles.radiobutton_automatic,'Enable','off')
                set(handles.radiobutton_manual,'Enable','off')
                set(handles.listbox_manual,'Enable','off')
                set(handles.pushbutton_nextROI,'Enable','off')
                set(handles.pushbutton_add,'Enable','off')
                set(handles.pushbutton_detect,'Enable','off')
                manual.add=1;
                manual.oldroi=manual.roi+1;
                manual.oldproi=manual.proi(manual.roi);
                manual.roi=rem_roi;
            end
            if manual.roi~=rem_roi
                ind=cat(1,list.ind{:});
                manual.roi=max(ind(:,1))+1;
                manual.proi(manual.roi)=0;
            end        
        end
    end
    set(handles.texth,'string',['Selecting ROI ', num2str(manual.roi),' point ', num2str(manual.proi(manual.roi)+1)])
    set(handles.listbox_manual,'string',vertcat(list.text{:}),'value',1)
    set(handles.radiobutton_manual,'UserData',manual);
    set(handles.listbox_manual,'UserData',list);
    set(handles.pushbutton_detect,'UserData',roidata);
    guidata(handles.cbtrackGUI_ROI,handles);
end


function listbox_manual_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_detect_Callback(hObject, eventdata, handles)
cbparams=getappdata(0,'cbparams');
params=get(handles.uipanel_settings,'UserData');
params.roidiameter_mm=str2double(get(handles.edit_set_ROId,'String'));
if isnan(params.roidiameter_mm)
    params.roidiameter_mm=1;
end
params.baserotateby=str2double(get(handles.edit_set_rot,'String'));
params.cannythresh=[str2double(get(handles.edit_set_thres1,'String')),str2double(get(handles.edit_set_thres2,'String'))];
params.cannysigma=str2double(get(handles.edit_set_std,'String'));

if isnan(params.baserotateby) || any(isnan(params.cannythresh)) || isnan (params.cannysigma)
    mymsgbox(50,190,14,'Helvetica',{'Please, input numeric values for the setting parametes'},'Error','error','modal')
else
    manual=get(handles.radiobutton_manual,'UserData');
    if manual.proi(manual.roi)<3 && manual.proi(manual.roi)~=0
        msg_manual=mymsgbox(50,190,14,'Helvetica',{'Please, select at least THREE points in the current ROI'},'Error','error','modal'); %#ok<NASGU>
    else
        if isfield(handles,'hrois') 
            delete(handles.hrois)
            handles=rmfield(handles,'hrois');
        end
        if isfield(handles,'hroisT') 
            delete(handles.hroisT(ishandle(handles.hroisT)))
            handles.hroisT=[];
        end

        axes(handles.axes_ROI)
        xc=zeros(length(manual.pos),1);
        yc=zeros(length(manual.pos),1);
        radius=zeros(length(manual.pos),1);
        for i=1:length(manual.pos)
            [xc(i),yc(i),radius(i)] = fit_circle_to_points(manual.pos{i}(:,1), manual.pos{i}(:,2));
        end
        params.roimus.x=xc;
        params.roimus.y=yc;
        if isempty(params.meanroiradius)
            params.meanroiradius=mean(radius);
        end
        if isempty(params.maxdcenter)
            params.maxdcenter=ceil(params.meanroiradius/20);
        end
        if isempty(params.maxdradius)
            params.maxdradius=ceil(params.meanroiradius/20);
        end
        set([manual.pos_h{:}],'Color',[0 1 0])

        manual.detected=1;
        params.roimus=[xc,yc];
        params.ignorebowls=[];
        BG=getappdata(0,'BG');
        bgmed=BG.bgmed;
        [handles,roidata] = DetectROIsGUI(bgmed,cbparams,params,handles);
        roidata.ignore=[];
        roidata.isnew=true;        
        manual.on=0;
        set(hObject,'UserData',roidata)
        set(handles.radiobutton_manual,'UserData',manual)
        set(handles.uipanel_settings,'Userdata',params)
        guidata(handles.cbtrackGUI_ROI,handles)
    end 
end


function pushbutton_nextROI_Callback(hObject, eventdata, handles)
manual=get(handles.radiobutton_manual,'UserData');
if manual.proi(manual.roi)<3
    msg_manual=mymsgbox(50,190,14,'Helvetica',{'Please, select at least THREE points in the current ROI'},'Error','error','modal'); %#ok<NASGU>
else
    if manual.add==2
        manual.roi=manual.oldroi-1;
        manual.add=0;
    end
    manual.roi=manual.roi+1;
    manual.proi(manual.roi)=0;
    set(handles.texth,'string',['Selecting ROI ', num2str(manual.roi),' point ', num2str(manual.proi(manual.roi)+1)])
    set(handles.radiobutton_manual,'UserData',manual);
    set([manual.pos_h{:}],'Color',[0 1 0])
end


function uipanel_method_SelectionChangeFcn(hObject, eventdata, handles)
%Select the method to detect circles
manual=get(handles.radiobutton_manual,'UserData');
roidata=get(handles.pushbutton_detect,'UserData');
if eventdata.NewValue==handles.radiobutton_load %Load a preexisting ROI data file in txt format
    set(handles.edit_load,'Enable','on')
    set(handles.pushbutton_load,'Enable','on')
    set(handles.listbox_manual,'Enable','off')
    set(handles.pushbutton_nextROI,'Enable','off')
    set(handles.pushbutton_add,'Enable','off')
    set(handles.pushbutton_clear,'Enable','on')
    set(handles.pushbutton_detect,'Enable','off')
    manual.on=0;
elseif eventdata.NewValue==handles.radiobutton_automatic %???
    set(handles.edit_load,'Enable','off')
    set(handles.pushbutton_load,'Enable','off')
    set(handles.listbox_manual,'Enable','off')
    set(handles.pushbutton_nextROI,'Enable','off')
    set(handles.pushbutton_add,'Enable','off')
    set(handles.pushbutton_delete,'Enable','off')
    set(handles.pushbutton_clear,'Enable','on')
    set(handles.pushbutton_detect,'Enable','off')
    manual.on=0;
elseif eventdata.NewValue==handles.radiobutton_manual %The user clicks points of each ROI
    set(handles.edit_load,'Enable','off')
    set(handles.pushbutton_load,'Enable','off')
    set(handles.listbox_manual,'Enable','on')
    set(handles.pushbutton_nextROI,'Enable','on')
    set(handles.pushbutton_add,'Enable','on')
    set(handles.pushbutton_delete,'Enable','on')
    set(handles.pushbutton_clear,'Enable','on')
    set(handles.pushbutton_detect,'Enable','on')
    if ~isempty(manual.pos) || (isfield(roidata,'radii') && ~isempty(roidata.radii))
        msg_manual_exist=myquestdlg(14,'Helvetica',{'You have already selected some points to detect your ROIs.';'Would you like to delete them?'}','Existing data','Yes','No','No'); 
        if isempty(msg_manual_exist)
            msg_manual_exist='No';
        end
        if strcmp('Yes',msg_manual_exist)
            [handles,manual,list,roidata]=deleterois(handles,manual);
            set(handles.listbox_manual,'UserData',list);
            set(handles.pushbutton_detect,'UserData',roidata);
        end
    else
        manual.detected=0;
    end
    if manual.roi==1 && manual.proi==0
        set(handles.texth,'String','Selecting ROI 1, point 1');   
        msg_manual=mymsgbox(50,190,14,'Helvetica',{'Please, select at least three points in the at the edge of the first ROI.'; '  - Press ''Next ROI'' to select the next set of points.';'  - Click any ROI or point to remove it from the list';'  - Press ''Detect'' to finish'},'Manua detection','help','modal'); %#ok<NASGU>
    end
    manual.on=1;
    manual.delete=0;
end

%Update user and gui data
guidata(hObject, handles);
set(handles.radiobutton_manual,'UserData',manual);
guidata(handles.cbtrackGUI_ROI,handles)


function pushbutton_add_Callback(hObject, eventdata, handles)
manual=get(handles.radiobutton_manual,'UserData');
if manual.proi(manual.roi)<3 && manual.proi(manual.roi)~=0
    msg_manual=mymsgbox(50,190,14,'Helvetica',{'Please, select at least THREE points in the current ROI'},'Error','error','modal'); %#ok<NASGU>
    return
end
msg_add=mymsgbox(50,190,14,'Helvetica',{'Selec the ROI form the list to which you want to add new points'},'Manua detection','help','modal'); %#ok<NASGU>
manual.add=3;
set(handles.radiobutton_manual,'UserData',manual);


function axes_ROI_ButtonDownFcn(hObject, eventdata, handles)
%Gets the coordinates of the cliked point and ads it to the listbox_manual
handles=guidata(hObject);
manual=get(handles.radiobutton_manual,'UserData');
pos_ij = get(handles.axes_ROI,'CurrentPoint');     
xlim=get(handles.axes_ROI,'XLim');
ylim=get(handles.axes_ROI,'YLim');
isin=pos_ij(1,1)>=xlim(1)&&pos_ij(1,1)<=xlim(2)&&pos_ij(1,2)>=ylim(1)&&pos_ij(1,2)<=ylim(2);

if manual.on==1 && manual.delete==0 && isin
    list=get(handles.listbox_manual,'UserData');
    pos=manual.pos;
    roi=manual.roi;
    proi=manual.proi(roi)+1;
    pos{roi}(proi,:) = round(pos_ij(1,1:2));

    %Plot the selected point
    axes(handles.axes_ROI)
    hold on
    manual.pos_h{roi}(proi)=plot(pos{roi}(proi,1),pos{roi}(proi,2),'rx');
    hold off

    %Add the points to the list
    if proi==1
        list.text{roi}{proi,1}=['ROI ',num2str(roi),':'];
        list.ind{roi}(1,1:2)=[roi,0];
    end
    list.text{roi}{proi+1,1}=['    (',num2str(pos{roi}(proi,1)),',',num2str(pos{roi}(proi,2)),')'];
    list.ind{roi}(proi+1,1:2)=[roi,proi];list.ind_mat=vertcat(list.ind{:}); list.ind_mat=sortrows(list.ind_mat);
    manual.pos=pos;
    if manual.add==1
        roi=manual.oldroi;
        proi=0;
        set(handles.radiobutton_load,'Enable','on')
        set(handles.radiobutton_automatic,'Enable','on')
        set(handles.radiobutton_manual,'Enable','off')
        set(handles.listbox_manual,'Enable','on')
        set(handles.pushbutton_nextROI,'Enable','on')
        set(handles.pushbutton_add,'Enable','on')
        set(handles.pushbutton_detect,'Enable','on')
        manual.add=0;
    end
    manual.roi=roi;
    manual.proi(manual.roi)=proi;
    set(handles.texth,'string',['Selecting ROI ', num2str(roi),' point ', num2str(proi+1)])

    %Update user and gui data
    guidata(hObject, handles);
    set(handles.listbox_manual,'String',vertcat(list.text{:}),'Value',numel(vertcat(list.text{:})))
    set(handles.radiobutton_manual,'UserData',manual);
    set(handles.listbox_manual,'UserData',list);
elseif manual.delete==1 && manual.detected==1
    roidata=get(handles.pushbutton_detect,'UserData');
    new_position=nan(4,roidata.nrois);
    for i=1:roidata.nrois
        new_position(:,i)=handles.hrois(i).getPosition;
    end
    new_centerx=new_position(1,:)+new_position(3,:)./2;
    new_centery=new_position(2,:)+new_position(4,:)./2;
    new_radii=new_position(3,:)./2;
    dist2=(pos_ij(1,1)-new_centerx).^2+(pos_ij(1,2)-new_centery).^2;
    [mindist2,nearROI]=min(dist2);
    if mindist2<=new_radii(nearROI)^2
        list=get(handles.listbox_manual,'UserData');
        manual=get(handles.radiobutton_manual,'UserData');
        rem_roi=nearROI;     
        msg_manual_lb=myquestdlg(14,'Helvetica','Are you sure you would like to delete the selected item/s?','Delete Point?','Yes','No','No'); 
        if isempty(msg_manual_lb)
            msg_manual_lb='No';
        end
        if strcmp('Yes',msg_manual_lb) %remove selected point from the list and plot
            set(handles.listbox_manual,'string',vertcat(list.text{:}),'Value',numel(vertcat(list.text{:}))) 
            msg_manual_lb2=myquestdlg(14,'Helvetica',{'Would you like to select new points for this ROI?';' - ''Yes'' will maintain the same ROI number. You must select new ROI points';' - ''No'' will reasing the ROI numbers'},'Replace ROI points?','Yes','No','No'); 
            if isempty(msg_manual_lb2)
                msg_manual_lb2='No';
            end
            if strcmp('Yes',msg_manual_lb2) || manual.roi==rem_roi
                if ~isempty(list.text)
                    list.text{rem_roi}=[];
                    list.ind{rem_roi}=[];
                    manual.pos{rem_roi}=[];
                    axes(handles.axes_ROI);
                    delete(manual.pos_h{rem_roi}(ishandle(manual.pos_h{rem_roi})))
                    manual.pos_h{rem_roi}=[];
                end
                if manual.detected && length(handles.hroisT)>=rem_roi
                    set(handles.hrois(rem_roi),'Visible','off')                    
                    set(handles.hroisT(rem_roi),'Visible','off')
                    roidata.centerx(rem_roi)=nan;
                    roidata.centery(rem_roi)=nan;
                    roidata.radii(rem_roi)=nan;
                    roidata.scores(rem_roi)=nan;
                    roidata.roibbs(rem_roi,:)=nan(1,4);
                    roidata.inrois{rem_roi}=[];
                end
                manual.on=1;
                manual.add=2;
                manual.oldroi=manual.roi+1;
                manual.oldproi=0;
                manual.roi=rem_roi;
                manual.proi(manual.roi)=0;
                manual.delete=0;
                set(handles.pushbutton_delete,'String','Delete')
            else
                if ~isempty(list.text)
                    list.text(rem_roi)=[];
                    list.ind(rem_roi)=[];
                    for i=rem_roi:length(list.text)
                        k=find(list.text{i}{1}==' ');
                        list.text{i}{1}=['ROI ',num2str(str2double(list.text{i}{1}(k+1:end-1))-1),':'];
                        list.ind{i}(:,1)=list.ind{i}(:,1)-1;
                    end
                    manual.pos(rem_roi)=[];
                    axes(handles.axes_ROI);
                    delete(manual.pos_h{rem_roi}(ishandle(manual.pos_h{rem_roi})))
                    manual.pos_h(rem_roi)=[];
                    manual.proi(manual.roi)=[];
                    ind=cat(1,list.ind{:});
                    manual.roi=max(ind(:,1))+1;
                    manual.proi(manual.roi)=0;
                end
                if manual.detected && length(handles.hroisT)>=rem_roi
                    delete(handles.hrois(rem_roi)) 
                    handles.hrois(rem_roi)=[];
                    delete(handles.hroisT(rem_roi))                    
                    handles.hroisT(rem_roi)=[];                    
                    roidata.centerx(rem_roi)=[];
                    roidata.centery(rem_roi)=[];
                    roidata.radii(rem_roi)=[];
                    roidata.scores(rem_roi)=[];
                    roidata.roibbs(rem_roi,:)=[];
                    roidata.inrois(rem_roi)=[];
                    roidata.nrois=roidata.nrois-1;
                    for i=rem_roi:length(handles.hroisT)
                        set(handles.hroisT(i,1),'String',['ROI: ',num2str(i)]);
                    end
                end
            end               
        end
        set(handles.texth,'string',['Selecting ROI ', num2str(manual.roi),' point ', num2str(manual.proi(manual.roi)+1)])
        set(handles.listbox_manual,'string',vertcat(list.text{:}),'value',1)
        set(handles.radiobutton_manual,'UserData',manual);
        set(handles.listbox_manual,'UserData',list);   
        set(handles.pushbutton_detect,'UserData',roidata);
    end
end
guidata(handles.cbtrackGUI_ROI,handles);


function pushbutton_clear_Callback(hObject, eventdata, handles)
msg_clear=myquestdlg(14,'Helvetica',{'Would you like to delete all the points and ROIs?'},'Clear points?','Yes','No','No'); 
if isempty(msg_clear)
    msg_clear='No';
end
if strcmp('Yes',msg_clear)
    manual=get(handles.radiobutton_manual,'UserData');
    [handles,manual,list,roidata]=deleterois(handles,manual);
    if manual.on
        set(handles.texth,'String','Selecting ROI 1, point 1');
    end
    set(handles.pushbutton_delete,'Enable','off')
    set(handles.radiobutton_manual,'UserData',manual);
    set(handles.pushbutton_detect,'UserData',roidata);
    set(handles.listbox_manual,'UserData',list);
    guidata(handles.cbtrackGUI_ROI,handles)
%     set(handles.BG_img,'ButtonDownFcn',{@axes_ROI_ButtonDownFcn,handles});
end



function edit_set_std_Callback(hObject, eventdata, handles)


function edit_set_std_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_thres1_Callback(hObject, eventdata, handles)


function edit_set_thres1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_rot_Callback(hObject, eventdata, handles)


function edit_set_rot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_ROId_Callback(hObject, eventdata, handles)


function edit_set_ROId_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_nframes_Callback(hObject, eventdata, handles)


function edit_nframes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_set_thres2_Callback(hObject, eventdata, handles)


function edit_set_thres2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_advanced_Callback(hObject, eventdata, handles)
temp_ROIparams=get(handles.uipanel_settings,'UserData');
[new_ROIparams]=advanced_ROI(temp_ROIparams);
set(handles.uipanel_settings,'UserData',new_ROIparams);


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


function pushbutton_delete_Callback(hObject, eventdata, handles)
manual=get(handles.radiobutton_manual,'UserData');
%When the user decides to delete any point, the previous rois is considered to be completed    
if manual.proi(manual.roi)<3 && manual.proi(manual.roi)~=0 %the user must have selected at least three points in the last ROI before starting a selection process unless the deleted point belong to such a ROI
    msg_manual=mymsgbox(50,190,14,'Helvetica',{'Please, select at least THREE points in the current ROI'},'Error','error','modal'); %#ok<NASGU>
    return
end    

if manual.delete==0
    set(hObject,'String','Stop Deleting')
    manual.delete=1;
else
    manual.delete=0;
    set(hObject,'String','Delete')
end
set(handles.radiobutton_manual,'UserData',manual)



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

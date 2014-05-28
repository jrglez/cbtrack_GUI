function cbtrackGUI_BG(varargin)
% CBTRACKGUI_BG MATLAB code for cbtrackGUI_BG.fig
%      CBTRACKGUI_BG, by itself, creates a new CBTRACKGUI_BG or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_BG returns the handle to a new CBTRACKGUI_BG or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_BG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_BG.M with the given input arguments.
%
%      CBTRACKGUI_BG('Property','Value',...) creates a new CBTRACKGUI_BG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_BG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_BG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_BG

% Last Modified by GUIDE v2.5 14-May-2014 09:10:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_BG_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_BG_OutputFcn, ...
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


% --- Executes just before cbtrackGUI_BG is made visible.
function cbtrackGUI_BG_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

GUIsize(handles,hObject)

experiment=getappdata(0,'experiment');
cbparams=getappdata(0,'cbparams');
tracking_params=cbparams.track;
BG.expdir=getappdata(0,'expdir');
BG.moviefile=getappdata(0,'moviefile');
BG.analysis_protocol=getappdata(0,'analysis_protocol');
out=getappdata(0,'out');
loadfile=fullfile(out.folder,cbparams.dataloc.bgmat.filestr);

P_stages={'BG','ROIs','params','wing_params','track1','track2'};
P_curr_stage='BG';
P_stage=getappdata(0,'P_stage');
if find(strcmp(P_stage,P_stages))>find(strcmp(P_curr_stage,P_stages))
    BG.data=getappdata(0,'BG');
    if cbparams.detect_rois.dosetROI
        set(handles.pushbutton_ROIs,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('params',P_stages)) && cbparams.track.dosettrack
        set(handles.pushbutton_tracker_setup,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('wing_params',P_stages)) && cbparams.wingtrack.dosetwingtrack
        set(handles.pushbutton_WT,'Enable','on')
    end
    if find(strcmp(P_stage,P_stages))>=find(strcmp('track1',P_stages)) && cbparams.track.DEBUG==1 && getappdata(0,'singleexp')
        set(handles.pushbutton_debuger,'Enable','on')
    end
else
    if getappdata(0,'usefiles') && exist(loadfile,'file')
        try
            BG.data=load(loadfile);
            BG.data.isnew=true;
            isempty(BG.data.bgmed);
            tracking_params=BG.data.params;
            tracking_params.DEBUG=cbparams.track.DEBUG;
            tracking_params.dosetBG=cbparams.track.dosetBG;
            tracking_params.dosettrack=cbparams.track.dosettrack;
            tracking_params.dotrack=cbparams.track.dotrack;
            tracking_params.dotrackwings=cbparams.track.dotrackwings;


            logfid=open_log('bg_log',cbparams,out.folder);
            fprintf(logfid,'Loading background data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
            if logfid > 1,
              fclose(logfid);
            end
        catch
            logfid=open_log('bg_log',cbparams,out.folder);
            fprintf(logfid,'File %s could not be loaded.',loadfile);
            if logfid > 1,
              fclose(logfid);
            end
            waitfor(mymsgbox(50,190,14,'Helvetica',{['File ', loadfile,' could not be loaded.'];'Trying to compute the background automatically'},'Warning','warn','modal'))
            BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,tracking_params,'analysis_protocol',BG.analysis_protocol);
        end            
    elseif tracking_params.computeBG
        BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,tracking_params,'analysis_protocol',BG.analysis_protocol);
    else
        [readframe,~,fid,~] = get_readframe_fcn(getappdata(0,'moviefile')); %#ok<*NASGU>
        im = readframe(1);
        BG.data.cbestimatebg_version='Not computed';
        BG.data.cbestimatebg_timestamp=datestr(now,TimestampFormat);
        BG.data.analysis_protocol=getappdata(0,'analysis_protocol');
        BG.data.bgmed=255*ones(size(im));
        if isa(im,'uint8')
            BG.data.bgmed=uint8(BG.data.bgmed);
        end
        BG.data.isnew=true;
        if fid > 1,
            fclose(fid);
        end
        set(handles.text_Nframes,'Enable','off')
        set(handles.edit_Nframes,'Enable','off')
        set(handles.text_Lframe,'Enable','off')
        set(handles.edit_Lframe,'Enable','off')
        set(handles.pushbutton_recalc,'Enable','off')
        set(handles.pushbutton_manual,'Enable','off')
        set(handles.pushbutton_auto,'Enable','off')
        set(handles.text_load,'Enable','off')
        set(handles.pushbutton_load,'Enable','off')
    end
end

% Set parameters in the GUI
set(handles.edit_Nframes,'String',num2str(tracking_params.bg_nframes))
set(handles.edit_Lframe,'String',num2str(tracking_params.bg_lastframe))
set(handles.checkbox_BG,'Value',tracking_params.computeBG)
bgmodes={'LIGHTBKGD';'DARKBKGD';'OTHERBKGD'};
bgmode=find(strcmp(tracking_params.bgmode,bgmodes));
if isempty(bgmode)
    bgmode=1;
end
set(handles.popupmenu_BGtype,'Value',bgmode)


if getappdata(0,'cancel_hwait')
    if exist('hObject','var') && ishandle(hObject)
        delete(hObject)
    end
    cbtrackGUI_files
else
    bgmed=BG.data.bgmed;
    aspect_ratio=size(bgmed,2)/size(bgmed,1);
    pos1=get(handles.axes_BG,'position'); %axes 1 position

    if aspect_ratio<=1 
        old_width=pos1(3); new_width=pos1(4)*aspect_ratio; pos1(3)=new_width; %Recalculate the width of the axes to fit the figure aspect ratio
        pos1(1)=pos1(1)-(new_width-old_width)/2; %Recalculate the new horizontal position of the axes
        set(handles.axes_BG,'position',pos1) %reset axes position and size
    else
        old_height=pos1(4); new_height=pos1(3)/aspect_ratio; pos1(4)=new_height; %Recalculate the width of the axes to fit the figure aspect ratio
        pos1(2)=pos1(2)-(new_height-old_height)/2; %Recalculate the new horizontal position of the axes
        set(handles.axes_BG,'position',pos1) %reset axes position and size
    end

    axes(handles.axes_BG);
    colormap('gray')
    imagesc(bgmed);
    set(handles.axes_BG,'XTick',[],'YTick',[])
    axis equal

    set(handles.text_exp,'FontSize',24,'HorizontalAlignment','center','units','pixels','FontUnits','pixels','String',experiment);

    % Update handles structure
    guidata(hObject, handles);
    set(hObject,'UserData',BG);
    set(handles.pushbutton_recalc,'UserData',tracking_params)
    
    uiwait(handles.cbtrackGUI_BG);
end


function varargout = cbtrackGUI_BG_OutputFcn(hObject, eventdata, handles) %#ok<STOUT>
% Get default command line output from handles structure


function axes_BG_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>


function popupmenu_BGtype_Callback(hObject, eventdata, handles)


function popupmenu_BGtype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_Nframes_Callback(hObject, eventdata, handles)


function edit_Nframes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_Lframe_Callback(hObject, eventdata, handles)


function edit_Lframe_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.cbtrackGUI_BG)


function pushbutton_recalc_Callback(hObject, eventdata, handles)
bg_nframes=str2double(get(handles.edit_Nframes,'String'));
bg_lastframe=str2double(get(handles.edit_Lframe,'String'));
if isnan(bg_nframes) || bg_nframes<1
	mymsgbox(50,190,14,'Helvetica','Please, input a valid value for the number of frames','Error','error')
elseif isnan(bg_lastframe) || bg_lastframe<1
    mymsgbox(50,190,14,'Helvetica','Please, input a valid value for the last frame','Error','error')    
else
    tracking_params=get(handles.pushbutton_recalc,'UserData');
    BG=get(handles.cbtrackGUI_BG,'UserData');
    tracking_params.bg_nframes=bg_nframes;
    tracking_params.bg_lastframes=bg_lastframe;
    BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,tracking_params,'analysis_protocol',BG.analysis_protocol);
    if ~getappdata(0,'cancel_hwait')
        bgmed=BG.data.bgmed;
        axes(handles.axes_BG);
        colormap('gray')
        imagesc(bgmed);
        set(handles.axes_BG,'XTick',[],'YTick',[])
        set(handles.cbtrackGUI_BG,'UserData',BG)
    end
    set(handles.pushbutton_recalc,'UserData',tracking_params)
end


function pushbutton_manual_Callback(hObject, eventdata, handles)
cbparams=getappdata(0,'cbparams');
BG=get(handles.cbtrackGUI_BG,'UserData');
bgmed=BG.data.bgmed;
moviefile=getappdata(0,'moviefile');
tracking_params=cbparams.track;
[bgmed,bgfixdata] = FixBgModelGUI(bgmed,moviefile,tracking_params,handles);
BG.data.bgmed=bgmed;
BG.data.fixdata=bgfixdata;
BG.data.isnew=true;
set(handles.cbtrackGUI_BG,'UserData',BG);
out=getappdata(0,'out');

logfid=open_log('bg_log',cbparams,out.folder);
fprintf(logfid,'Background model fixed manualy at %s\n',datestr(now,'yyyymmddTHHMMSS'));
if logfid > 1,
  fclose(logfid);
end


function pushbutton_accept_Callback(hObject, eventdata, handles) %#ok<*INUSL>
%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_BG,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

BG=get(handles.cbtrackGUI_BG,'UserData');

bgmodes={'LIGHTBKGD';'DARKBKGD';'OTHERBKGD'};
bgmode=bgmodes{get(handles.popupmenu_BGtype,'Value')};
cbparams=getappdata(0,'cbparams');
if ~strcmp(cbparams.track.bgmode,bgmode)
    BG.data.isnew=true;
    cbparams.track.bgmode=bgmode;
end

computeBG=get(handles.checkbox_BG,'Value');
if computeBG~=cbparams.track.computeBG
    BG.data.isnew=true;
    cbparams.track.computeBG=computeBG;
end
isnew=BG.data.isnew;

restart='';
setappdata(0,'restart',restart)

if isnew
    if isappdata(0,'roidata')
        rmappdata(0,'roidata')
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
    BG.data.isnew=false;
    tracking_params=get(handles.pushbutton_recalc,'UserData');
    cbparams.track=tracking_params;
    if ~computeBG
        [readframe,~,fid,~] = get_readframe_fcn(getappdata(0,'moviefile')); %#ok<*NASGU>
        BG.data.cbestimatebg_version='Not computed';
        BG.data.cbestimatebg_timestamp=datestr(now,TimestampFormat);
        BG.data.analysis_protocol=getappdata(0,'analysis_protocol');
        BG.data.bgmed=255*ones(size(BG.data.bgmed));
        if isa(readframe(1),'uint8')
            BG.data.bgmed=uint8(BG.data.bgmed);
        end
        if fid>1
            fclose(fid);
        end
        cbparams.track.bg_nframes=nan;
        cbparams.track.bg_lastframe=nan;
    elseif computeBG && all(all(BG.data.bgmed==255))
        BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,tracking_params,'analysis_protocol',BG.analysis_protocol);
    end
    cbparams.track.computeBG=computeBG;
    bgmed=BG.data.bgmed;
    setappdata(0,'BG',BG.data)
    setappdata(0,'cbparams',cbparams)
    
    % Save BG data
    out=getappdata(0,'out');
    logfid=open_log('bg_log',cbparams,out.folder);
    cbestimatebg_version=BG.data.cbestimatebg_version; 
    cbestimatebg_timestamp=BG.data.cbestimatebg_timestamp; 
    params=cbparams.track;  
    savefile = fullfile(out.folder,cbparams.dataloc.bgmat.filestr);
    fprintf(logfid,'Saving background model to file %s...\n',savefile);
    if exist(savefile,'file'),
      delete(savefile);
    end
    save(savefile,'bgmed','cbestimatebg_version','cbestimatebg_timestamp','params');
    setappdata(0,'P_stage','ROIs');
    if cbparams.track.dosave
        savetemp({'BG'})
    end
    
    bgimagefile = fullfile(out.folder,cbparams.dataloc.bgimage.filestr); 
    fprintf(logfid,'Saving image of background model to file %s...\n\n***\n',bgimagefile);
    imwrite(bgmed,bgimagefile,'png');
    if logfid > 1,
        fclose(logfid);
    end
end

% Clean up
fidBG=getappdata(0,'fidBG');
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_BG)
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
end

if cbparams.detect_rois.dosetROI
    cbtrackGUI_ROI
elseif cbparams.track.dosettrack
    if isnew
        cbtrackNOGUI_ROI
    end
    cbtrackGUI_tracker
else
    if isnew
        cbtrackNOGUI_ROI
        cbtrackNOGUI_tracker
    end
    if cbparams.wingtrack.dosetwingtrack
        cbtrackGUI_WingTracker
    elseif getappdata(0,'singleexp') && cbparams.track.dotrack
        if ~cbparams.track.DEBUG
            WriteParams
            setappdata(0,'P_stage','track1');
            cbtrackGUI_tracker_NOvideo
        else
            if isnew
                WriteParams
                setappdata(0,'P_stage','track1');
                cbtrackGUI_tracker_video
            else
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
            end        
        end
    end
end


function pushbutton_BG_Callback(hObject, eventdata, handles)


function pushbutton_ROIs_Callback(hObject, eventdata, handles)
fidBG=getappdata(0,'fidBG');
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_BG,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_BG)
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
end

cbtrackGUI_ROI



function pushbutton_tracker_setup_Callback(hObject, eventdata, handles)
fidBG=getappdata(0,'fidBG');
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_BG,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_BG)
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
end

cbtrackGUI_tracker


function pushbutton_debuger_Callback(hObject, eventdata, handles)
fidBG=getappdata(0,'fidBG');
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_BG,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_BG)
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
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


function pushbutton_manual_ButtonDownFcn(hObject, eventdata, handles)
mymsgbox(50,190,14,'Helvetica','Please, select the regions you wish to correct. Press ''Correct'' when you are done.','Correct','help')


function cbtrackGUI_BG_ResizeFcn(hObject, eventdata, handles)
GUIresize(handles,hObject)


function pushbutton_manual_KeyPressFcn(hObject, eventdata, handles)


function cbtrackGUI_BG_CloseRequestFcn(hObject, eventdata, handles)
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
fidBG=getappdata(0,'fidBG'); 
if strcmp('Yes',msg_cancel)
    setappdata(0,'iscancel',true)
    uiresume(handles.cbtrackGUI_BG)
    if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
        delete(handles.cbtrackGUI_BG)
    end
end


function pushbutton_auto_Callback(hObject, eventdata, handles)
BG=get(handles.cbtrackGUI_BG,'UserData');
bgmed=BG.data.bgmed;
[bgmed,bgfixdata] = FixBgModel_auto_GUI(bgmed,handles);
BG.data.bgmed=bgmed;
BG.data.fixdata=bgfixdata;
BG.data.isnew=true;
set(handles.cbtrackGUI_BG,'UserData',BG);
out=getappdata(0,'out');

logfid=open_log('bg_log',getappdata(0,'cbparams'),out.folder);
fprintf(logfid,'Background model fixed automatically at %s\n',datestr(now,'yyyymmddTHHMMSS'));
if logfid > 1,
  fclose(logfid);
end

 
function pushbutton_ROIs_DeleteFcn(hObject, eventdata, handles)


function pushbutton_load_Callback(hObject, eventdata, handles)
[file_BG, folder_BG]=open_files2('mat');
if ~file_BG{1}==0
    loadfile=fullfile(folder_BG,file_BG{1});
    set(handles.text_load,'String',loadfile,'HorizontalAlignment','right')
    BG.data=load(loadfile);
    BG.data.isnew=true;
    tracking_params=BG.data.params;
    % Set parameters in the GUI
    set(handles.edit_Nframes,'String',num2str(tracking_params.bg_nframes))
    set(handles.edit_Lframe,'String',num2str(tracking_params.bg_lastframe))
    bgmodes={'LIGHTBKGD';'DARKBKGD';'OTHERBKGD'};
    bgmode=find(strcmp(tracking_params.bgmode,bgmodes));
    if isempty(bgmode)
        bgmode=1;
    end
    set(handles.popupmenu_BGtype,'Value',bgmode)
    bgmed=BG.data.bgmed;
    set(imhandles(handles.axes_BG),'CData',bgmed);
    set(hObject,'UserData',BG);
    set(handles.pushbutton_recalc,'UserData',tracking_params)
    out=getappdata(0,'out');
    
    logfid=open_log('bg_log',getappdata(0,'cbparams'),out.folder);
    fprintf(logfid,'Loading background data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
    if logfid > 1,
      fclose(logfid);
    end
end


function pushbutton_WT_Callback(hObject, eventdata, handles)
fidBG=getappdata(0,'fidBG');
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

%Save size
GUIscale=getappdata(0,'GUIscale');
new_pos=get(handles.cbtrackGUI_BG,'position'); 
old_pos=GUIscale.original_position;
GUIscale.rescalex=new_pos(3)/old_pos(3);
GUIscale.rescaley=new_pos(4)/old_pos(4);
GUIscale.position=new_pos;
setappdata(0,'GUIscale',GUIscale)

setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_BG)
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
end

cbtrackGUI_WingTracker


function checkbox_BG_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.text_Nframes,'Enable','on')
    set(handles.edit_Nframes,'Enable','on')
    set(handles.text_Lframe,'Enable','on')
    set(handles.edit_Lframe,'Enable','on')
    set(handles.pushbutton_recalc,'Enable','on')
    set(handles.pushbutton_manual,'Enable','on')
    set(handles.pushbutton_auto,'Enable','on')
    set(handles.text_load,'Enable','on')
    set(handles.pushbutton_load,'Enable','on')
else
    set(handles.text_Nframes,'Enable','off')
    set(handles.edit_Nframes,'Enable','off')
    set(handles.text_Lframe,'Enable','off')
    set(handles.edit_Lframe,'Enable','off')
    set(handles.pushbutton_recalc,'Enable','off')
    set(handles.pushbutton_manual,'Enable','off')
    set(handles.pushbutton_auto,'Enable','off')
    set(handles.text_load,'Enable','off')
    set(handles.pushbutton_load,'Enable','off')
end

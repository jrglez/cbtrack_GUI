function varargout = cbtrackGUI_BG_queue(varargin)
% CBTRACKGUI_BG_QUEUE MATLAB code for cbtrackGUI_BG_queue.fig
%      CBTRACKGUI_BG_QUEUE, by itself, creates a new CBTRACKGUI_BG_QUEUE or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_BG_QUEUE returns the handle to a new CBTRACKGUI_BG_QUEUE or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_BG_QUEUE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_BG_QUEUE.M with the given input arguments.
%
%      CBTRACKGUI_BG_QUEUE('Property','Value',...) creates a new CBTRACKGUI_BG_QUEUE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_BG_queue_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_BG_queue_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_BG_queue

% Last Modified by GUIDE v2.5 06-Mar-2014 11:59:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_BG_queue_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_BG_queue_OutputFcn, ...
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


% --- Executes just before cbtrackGUI_BG_queue is made visible.
function cbtrackGUI_BG_queue_OpeningFcn(hObject, eventdata, handles, varargin)
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

P_stages={'BG','ROIs'};
P_curr_stage='BG';
P_stage=getappdata(0,'P_stage');
if find(strcmp(P_stage,P_stages))>find(strcmp(P_curr_stage,P_stages))
    BG.data=getappdata(0,'BG');
    set(handles.pushbutton_ROIs,'Enable','on')
else
    if exist(loadfile,'file')
        msg_load=myquestdlg(14,'Helvetica',['There is a file that contains backgound data for experiment ''',experiment,'''. Would you like to load it?'],'Existing BG data','Yes','No','No');  
    end

    if exist('msg_load','var') && strcmp(msg_load,'Yes')
        BG.data=load(loadfile);
        BG.data.isnew=true;
        tracking_params=BG.data.params;
        
        logfid=open_log('bg_log',cbparams,out.folder);
        fprintf(logfid,'Loading background data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
        if logfid > 1,
          fclose(logfid);
        end
    else
        BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,tracking_params,'analysis_protocol',BG.analysis_protocol);
    end
end

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

handles.textexp=text(250,445,'','FontSize',24,'Color',[1 0 0],'HorizontalAlignment','center','units','pixels','String',experiment);

% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',BG);
set(handles.pushbutton_recalc,'UserData',tracking_params)

uiwait(handles.cbtrackGUI_BG);



function varargout = cbtrackGUI_BG_queue_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles;
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
end


function popupmenu_BGtype_CreateFcn(hObject, eventdata, handles)%#ok<*INUSD,*DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_Nframes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

if BG.data.isnew
    if isappdata(0,'roidata')
        rmappdata(0,'roidata')
    end
    BG.data.isnew=false;
    setappdata(0,'BG',BG.data)
    bgmed=BG.data.bgmed;
    cbparams.track=get(handles.pushbutton_recalc,'UserData');
    setappdata(0,'cbparams',cbparams)
    setappdata(0,'P_stage','ROIs');
    
    % Save BG data
    out=getappdata(0,'out');
    logfid=open_log('bg_log',cbparams,out.folder);
    cbestimatebg_version=BG.data.cbestimatebg_version; %#ok<NASGU>
    cbestimatebg_timestamp=BG.data.cbestimatebg_timestamp; %#ok<NASGU>
    params=cbparams.track; %#ok<NASGU>    
    savefile = fullfile(out.folder,cbparams.dataloc.bgmat.filestr);
    fprintf(logfid,'Saving background model to file %s...\n',savefile);
    if exist(savefile,'file'),
      delete(savefile);
    end
    save(savefile,'bgmed','cbestimatebg_version','cbestimatebg_timestamp','params');

    bgimagefile = fullfile(out.folder,cbparams.dataloc.bgimage.filestr); 
    fprintf(logfid,'Saving image of background model to file %s...\n\n***\n',bgimagefile);
    imwrite(bgmed,bgimagefile,'png');
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
if logfid > 1,
  fclose(logfid);
end
setappdata(0,'iscancel',false)
uiresume(handles.cbtrackGUI_BG)


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
setappdata(0,'iscancel',true)
uiresume(handles.cbtrackGUI_BG)


function pushbutton_manual_ButtonDownFcn(hObject, eventdata, handles)
mymsgbox(50,190,14,'Helvetica','Please, select the regions you wish to correct. Press ''Correct'' when you are done.','Correct','help')


function cbtrackGUI_BG_ResizeFcn(hObject, eventdata, handles)
GUIresize(handles,hObject)


function cbtrackGUI_BG_CloseRequestFcn(hObject, eventdata, handles)
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
fidBG=getappdata(0,'fidBG'); %#ok<NASGU>
if strcmp('Yes',msg_cancel)
    setappdata(0,'iscancel',true)
    uiresume(hObject)
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

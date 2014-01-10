function varargout = cbtrackGUI_BG(varargin)
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

% Last Modified by GUIDE v2.5 08-Jan-2014 01:09:52

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbtrackGUI_BG (see VARARGIN)

% Choose default command line output for cbtrackGUI_BG
handles.output = hObject;

GUIsize(handles,hObject)

cbparams=getappdata(0,'cbparams');
tracking_params=cbparams.track;
expdirs=getappdata(0,'expdirs');%(expdirs)
BG.expdir=expdirs.test{1}; %(expdirs)
BG.moviefile=getappdata(0,'moviefile');
BG.analysis_protocol=getappdata(0,'analysis_protocol');
out=getappdata(0,'out');
loadfile=fullfile(out.folder,cbparams.dataloc.bgmat.filestr);


fidBG=getappdata(0,'fidBG'); %#ok<NASGU>


if isappdata(0,'BG')
    BG.data=getappdata(0,'BG');
    set(handles.pushbutton_ROIs,'Enable','on')
    if isappdata(0,'roidata')
        set(handles.pushbutton_tracker_setup,'Enable','on')
        roidata=getappdata(0,'roidata');
        if isfield(roidata,'nflies_per_roi')
            set(handles.pushbutton_debuger,'Enable','on')
        end
    end
else
    if exist(loadfile,'file')
        msg_load=myquestdlg(14,'Helvetica','There is a file that contains backgound data. Would you like to load it?','Existing BG data','Yes','No','No');  
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
    
    % Update handles structure
    guidata(hObject, handles);
    set(hObject,'UserData',BG);
    set(handles.pushbutton_recalc,'UserData',tracking_params)
end


% UIWAIT makes cbtrackGUI_BG wait for user response (see UIRESUME)
% uiwait(handles.cbtrackGUI_BG);


% --- Outputs from this function are returned to the command line.
function varargout = cbtrackGUI_BG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes during object creation, after setting all properties.
function axes_BG_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to axes_BG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: place code in OpeningFcn to populate axes_BG


% --- Executes on selection change in popupmenu_BGtype.
function popupmenu_BGtype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_BGtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_BGtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_BGtype


% --- Executes during object creation, after setting all properties.
function popupmenu_BGtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_BGtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Nframes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Nframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Nframes as text
%        str2double(get(hObject,'String')) returns contents of edit_Nframes as a double


% --- Executes during object creation, after setting all properties.
function edit_Nframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Nframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Lframe_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Lframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Lframe as text
%        str2double(get(hObject,'String')) returns contents of edit_Lframe as a double


% --- Executes during object creation, after setting all properties.
function edit_Lframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Lframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.cbtrackGUI_BG)


% --- Executes on button press in pushbutton_recalc.
function pushbutton_recalc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_recalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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





% --- Executes on button press in pushbutton_manual.
function pushbutton_manual_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% rect=getrect(handles.axes_BG);
% rectangle('position',rect);
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



% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

if BG.data.isnew
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

    BG.data.isnew=false;
    setappdata(0,'BG',BG.data)
    bgmed=BG.data.bgmed;
    cbparams=getappdata(0,'cbparams');
    cbparams.track=get(handles.pushbutton_recalc,'UserData');
    setappdata(0,'cbparams',cbparams)
    
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
    savetemp

    bgimagefile = fullfile(out.folder,cbparams.dataloc.bgimage.filestr); 
    fprintf(logfid,'Saving image of background model to file %s...\n\n***\n',bgimagefile);
    imwrite(bgmed,bgimagefile,'png');
end
if isfield(handles,'cbtrackGUI_BG') && ishandle(handles.cbtrackGUI_BG)
    delete(handles.cbtrackGUI_BG)
end
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
cbtrackGUI_ROI


% --- Executes on button press in pushbutton_BG.
function pushbutton_BG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_BG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_ROIs.
function pushbutton_ROIs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

delete(handles.cbtrackGUI_BG)
cbtrackGUI_ROI



% --- Executes on button press in pushbutton_tracker_setup.
function pushbutton_tracker_setup_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tracker_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

delete(handles.cbtrackGUI_BG)
cbtrackGUI_tracker

% --- Executes on button press in pushbutton_debuger.
function pushbutton_debuger_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_debuger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

delete(handles.cbtrackGUI_BG)
cbtrackGUI_tracker_video



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_manual.
function pushbutton_manual_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mymsgbox(50,190,14,'Helvetica','Please, select the regions you wish to correct. Press ''Correct'' when you are done.','Correct','help')
%Display explanation when "correct" is pushed





% --- Executes when cbtrackGUI_BG is resized.
function cbtrackGUI_BG_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_BG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUIresize(handles,hObject)


% --- Executes on key press with focus on pushbutton_manual and none of its controls.
function pushbutton_manual_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_manual (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close cbtrackGUI_BG.
function cbtrackGUI_BG_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_BG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg_cancel=myquestdlg(14,'Helvetica','Cancel current project? All setup options will be lost','Cancel','Yes','No','No'); 
if isempty(msg_cancel)
    msg_cancel='No';
end
fidBG=getappdata(0,'fidBG'); %#ok<NASGU>
if strcmp('Yes',msg_cancel)
    cancelar
end


% --- Executes on button press in pushbutton_auto.
function pushbutton_auto_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

 


% --- Executes during object deletion, before destroying properties.
function pushbutton_ROIs_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

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

% Last Modified by GUIDE v2.5 15-Nov-2013 17:28:27

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

cbparams=getappdata(0,'cbparams');
expdirs=getappdata(0,'expdirs');%(expdirs)
BG.expdir=expdirs.test{1}; %(expdirs)
BG.moviefile=getappdata(0,'moviefile');
BG.analysis_protocol=getappdata(0,'analysis_protocol');
loadfile=fullfile(expdirs.test{1},cbparams.dataloc.bgmat.filestr);

if exist(loadfile,'file')
    msg_cancel=myquestdlg(14,'Helvetica','There is a file that contains backgound data. Would you like to load it?','Existing BG data','Yes','No','No');  
end

fidBG=getappdata(0,'fidBG'); %#ok<NASGU>

set(handles.edit_Nframes,'String',num2str(cbparams.track.bg_nframes))
set(handles.edit_Lframe,'String',num2str(cbparams.track.bg_lastframe))

if exist('msg_cancel','var') && strcmp(msg_cancel,'Yes')
    BG.data=load(loadfile);
else
    BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,cbparams.track,'analysis_protocol',BG.analysis_protocol);
end

if getappdata(0,'cancel_hwait')
    delete(hObject)
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
    %GUI original sieze
    BG.old_pos=get(hObject,'position');

    % Update handles structure
    guidata(hObject, handles);
    set(hObject,'UserData',BG);
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
bgmodes={'LIGHTBKGD';'DARKBKGD';'OTHERBKGD'};
cbparams=getappdata(0,'cbparams');
cbparams.track.bgmode=bgmodes{get(hObject,'Value')};
setappdata(0,'cbparams',cbparams)
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
cbparams=getappdata(0,'cbparams');
bg_nframes=str2double(get(handles.edit_Nframes,'String'));
bg_lastframe=str2double(get(handles.edit_Nframes,'String'));
if isnan(bg_nframes) || bg_nframes<1
	mymsgbox(50,190,14,'Helvetica','Please, input a valid value for the number of frames','Error','error')
elseif isnan(bg_lastframe) || bg_lastframe<1
    mymsgbox(50,190,14,'Helvetica','Please, input a valid value for the last frame','Error','error')    
else
    BG=get(handles.cbtrackGUI_BG,'UserData');
    BG.data=cbtrackGUI_EstimateBG(BG.expdir,BG.moviefile,cbparams.track,'analysis_protocol',BG.analysis_protocol);
    cbparams.track.bg_nframes=bg_nframes;
    cbparams.track.bg_lastframes=bg_lastframe;
    setappdata(0,'cbparams',cbparams)
    if ~getappdata(0,'cancel_hwait')
        bgmed=BG.data.bgmed;
        axes(handles.axes_BG);
        colormap('gray')
        imagesc(bgmed);
        set(handles.axes_BG,'XTick',[],'YTick',[])
        set(handles.cbtrackGUI_BG,'UserData',BG)
    end
end





% --- Executes on button press in pushbutton_fix.
function pushbutton_fix_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fix (see GCBO)
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
set(handles.cbtrackGUI_BG,'UserData',BG);






% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BG=get(handles.cbtrackGUI_BG,'UserData');
setappdata(0,'BG',BG.data)
bgmed=BG.data.bgmed;
expdirs=getappdata(0,'expdirs');
cbparams=getappdata(0,'cbparams');
cbestimatebg_version=BG.data.cbestimatebg_version; %#ok<NASGU>
cbestimatebg_timestamp=BG.data.cbestimatebg_timestamp; %#ok<NASGU>
params=cbparams.track; %#ok<NASGU>
delete(handles.cbtrackGUI_BG)
fidBG=getappdata(0,'fidBG');
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

savefile = fullfile(expdirs.test{1},cbparams.dataloc.bgmat.filestr);
% fprintf(logfid,'Saving background model to file %s...\n',savefile);
if exist(savefile,'file'),
  delete(savefile);
end
save(savefile,'bgmed','cbestimatebg_version','cbestimatebg_timestamp','params');

bgimagefile = fullfile(expdirs.test{1},cbparams.dataloc.bgimage.filestr); %(expdirs)
% fprintf(logfid,'Saving image of background model to file %s...\n',bgimagefile);
imwrite(bgmed,bgimagefile,'png');
cbtrackGUI_ROI



% --- Executes on button press in pushbutton_files.
function pushbutton_files_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_files (see GCBO)
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
close all
cbtrackGUI_files


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
close all
cbtrackGUI_ROI



% --- Executes on button press in pushbutton_tracker.
function pushbutton_tracker_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tracker (see GCBO)
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
close all
cbtrackGUI_tracker



% --- Executes on button press in pushbutton_video.
function pushbutton_video_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_fix.
function pushbutton_fix_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_fix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mymsgbox(50,190,14,'Helvetica','Please, select the regions you wish to correct. Press ''Correct'' when you are done.','Correct','help')
%Display explanation when "correct" is pushed





% --- Executes when cbtrackGUI_BG is resized.
function cbtrackGUI_BG_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to cbtrackGUI_BG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BG=get(hObject,'UserData');
BG.new_pos=get(hObject,'position');
rescalex=BG.new_pos(3)/BG.old_pos(3);
rescaley=BG.new_pos(4)/BG.old_pos(4) ;
h=fieldnames(handles);
    
for i=2:length(h)
    obj_handle=handles.(h{i});
    if ~strcmp(h{i},'output')
        if isprop(obj_handle,'position')        
            old_pos=get(obj_handle,'position');
            if ~isprop(obj_handle,'xTick') %not a figure
                new_pos([1,3])=old_pos([1,3])*rescalex;
                new_pos([2,4])=old_pos([2,4])*rescaley;
                set(obj_handle,'position',new_pos)
            elseif isprop(obj_handle,'xTick') %figure
                rescale=min(rescalex,rescaley);
                new_pos(1)=old_pos(1)*rescalex+(old_pos(3)*(rescalex-rescale)/2);
                new_pos(2)=old_pos(2)*rescaley+(old_pos(4)*(rescaley-rescale)/2);
                new_pos([3,4])=old_pos([3,4])*rescale;
                set(obj_handle,'position',new_pos)        
            end
        end
        if isprop(obj_handle,'FontSize')
            old_fontsize=get(obj_handle,'FontSize');
            new_fontsize=max(12,old_fontsize*min(rescalex,rescaley));
            set(obj_handle,'FontSize',new_fontsize)
        end
    end
end
BG.old_pos=BG.new_pos;
set(hObject,'UserData',BG)



% --- Executes on key press with focus on pushbutton_fix and none of its controls.
function pushbutton_fix_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_fix (see GCBO)
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

function varargout = DuoTrax(varargin)
% DUOTRAX MATLAB code for DuoTrax.fig
%      DUOTRAX, by itself, creates a new DUOTRAX or raises the existing
%      singleton*.
%
%      H = DUOTRAX returns the handle to a new DUOTRAX or the handle to
%      the existing singleton*.
%
%      DUOTRAX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DUOTRAX.M with the given input arguments.
%
%      DUOTRAX('Property','Value',...) creates a new DUOTRAX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DuoTrax_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DuoTrax_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DuoTrax

% Last Modified by GUIDE v2.5 13-Jan-2015 15:04:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DuoTrax_OpeningFcn, ...
                   'gui_OutputFcn',  @DuoTrax_OutputFcn, ...
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


function DuoTrax_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for DuoTrax
handles.output = hObject;

funpath=fileparts(fileparts(which('DuoTrax')));
DuoTrax_path=genpath(funpath);
addpath(DuoTrax_path);

% Update handles structure
guidata(hObject, handles);


function varargout = DuoTrax_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_in_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>


function edit_in_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_in_Callback(hObject, eventdata, handles)
VidDirOrTxt=get(handles.uipanel_folder,'SelectedObject');
if VidDirOrTxt==handles.radiobutton_Vid
    filetypes={  '*.ufmf','MicroFlyMovieFormat (*.ufmf)'; ...
      '*.fmf','FlyMovieFormat (*.fmf)'; ...
      '*.sbfmf','StaticBackgroundFMF (*.sbfmf)'; ...
      '*.avi','AVI (*.avi)'
      '*.mp4','MP4 (*.mp4)'
      '*.mov','MOV (*.mov)'
      '*.mmf','MMF (*.mmf)'
      '*.*','*.*'};
    [file,folder]=open_files2(filetypes); %in.folder is a structure as is required by the main code. 
    if file{1}~=0
        set(handles.edit_in,'String',[folder,file{1}])
    end
elseif VidDirOrTxt==handles.radiobutton_Dir
    expdir=uigetdir;
    if expdir~=0
        set(handles.edit_in,'String',expdir)
    end
elseif VidDirOrTxt==handles.radiobutton_Txt
    filetypes={  '*.txt','Text file (*.txt)'};
    [file,folder]=open_files2(filetypes);
    if file{1}~=0
        set(handles.edit_in,'String',[folder,file{1}])
    end
end


function pushbutton_accept_Callback(hObject, eventdata, handles)
setappdata(0,'grayscale',true) % Remove if I want to open color videos
if get(handles.checkbox_restart,'Value')
    restart=get(handles.edit_restart,'String');
    if ~exist(restart,'file')
        mymsgbox(50,190,14,'Helvetica',{'File does not exist'},'Error','error','modal');
        return
    else
        load(restart);
        appdatalist={'isnew','button','usefiles','viewlog','h_log','expdir','experiment','moviefile','out',...
    'analysis_protocol','P_stage','cbparams','restart','GUIscale','startframe','endframe','vign','H0','BG','roidata',...
    'roidata_rs','visdata','debugdata_WT','pff_all','t','trackdata','iscancel','isskip','allow_stop','isstop'};
        for i=1:length(appdatalist)
            if exist(appdatalist{i},'var')
                setappdata(0,appdatalist{i},eval(appdatalist{i}))
            end
        end
        logfid=open_log('main_log'); 
        s=sprintf('\n\n***\nRestarting experiment %s from %s at %s\n',experiment,restart,datestr(now,'yyyymmddTHHMMSS'));
        write_log(logfid,experiment,s)
        if logfid > 1,
          fclose(logfid);
        end
        setappdata(0,'singleexp',true)
        expdirs={expdir}; %#ok<*NODEF>
        moviefile={moviefile};
        exps={experiment};
        out={out};
        expparams={cbparams};
        omitedexp_all=[];
        success=true;
    end
else
    if ~exist(get(handles.edit_in,'String'),'file')
        mymsgbox(50,190,14,'Helvetica','The file or directory does not exist','Error','error','modal')
        return
    else
        % Check for videos
        [expdirs,moviefile,exps,analysis_protocol,paramsfile,omitedexp_all]=getfiles(handles);
        if ~isempty(omitedexp_all)
            waitfor(mymsgbox(50,190,14,'Helvetica',['The following experiment directories contained no video or more than one videos and will be omited:',sprintf('\n\t- %s',omitedexp_all{:})],'Warning','warn','modal'))
        elseif numel(expdirs)==0
            mymsgbox(50,190,14,'Helvetica','There are no valid videos in the selected directory','Error','error','modal')
            return
        end

        setappdata(0,'singleexp',numel(exps)==1);
        
        % Read parameters
        if numel(paramsfile)==1
            paramsfile=repmat(paramsfile,size(expdirs));
        end
        expparams=cell(size(paramsfile));
        success=true(1,numel(expdirs));
        for i=1:numel(paramsfile) 
            [expparams{i},success(i)]=cbtrackNOGUI_readparams(paramsfile{i},handles);
        end
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[];
        expdirs(~success)=[];
        moviefile(~success)=[];
        success(~success)=[];
        if ~isempty(omitedexp)
            waitfor(mymsgbox(50,190,14,'Helvetica',['The parameters file could not be found for the following experiments and will be omited:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn','modal'))
        elseif numel(expdirs)==0
            mymsgbox(50,190,14,'Helvetica','There are no valid videos in the selected directory','Error','error','modal')
            return
        end
        
        % Autmatic check incomings for all experiments
        out=cell(numel(expdirs),1);
        hwait=waitbar(0,'Checking incomings');
        for i=1:numel(expdirs)
            out{i}.folder=expdirs{i};            
            out{i}.temp=strcat('Temp_',datestr(now,TimestampFormat),'_',exps{i},'.mat');
            out{i}.temp_full=fullfile(out{i}.folder,out{i}.temp);
            if get(handles.checkbox_doAcI,'Value')
                [experiment,success(i)]=cbtrackNOGUI_AcI(expdirs{i},moviefile{i},analysis_protocol,expparams{i},out{i});
                waitbar(i/numel(expdirs),hwait,['Checking incomings for experiment ',experiment]);
            end
        end
        delete(hwait);
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[]; 
        expdirs(~success)=[];
        moviefile(~success)=[];
        success(~success)=[];
    end
    restart='';
end

% Setup and track        
BG=cell(numel(expdirs),1);
roidata=cell(numel(expdirs),1);
for i=1:numel(expdirs)
    experiment=exps{i};
    experiment(experiment=='_')=' ';
    
    if isempty(restart)
        P_stage='BG';
        button='BG';
    end
    
    mysetappdata('next',false,'isnew',true,'button',button,'expdirs',expdirs,'expdir',expdirs{i},...
        'experiment',experiment,'moviefile',moviefile{i},'out',out{i},'analysis_protocol',analysis_protocol,...
        'cbparams',expparams{i},'P_stage',P_stage,'restart',restart,'usefiles',expparams{i}.track.usefiles,...
        'iscancel',false,'isskip',false,'isstop',false)
    try
        while ~getappdata(0,'next')
            button = getappdata(0,'button');
            switch button
                case 'BG'
                    if expparams{i}.track.dosetBG
                        cbtrackGUI_BG
                    else
                        cbtrackNOGUI_BG
                    end
                case 'ROI'
                    if expparams{i}.detect_rois.dosetROI
                        cbtrackGUI_ROI
                    elseif getappdata(0,'isnew')
                        cbtrackNOGUI_ROI
                    else
                        setappdata(0,'button','body')
                    end
                case 'body'
                    if expparams{i}.track.dosettrack
                        cbtrackGUI_tracker
                    elseif getappdata(0,'isnew')
                        cbtrackNOGUI_tracker
                    else
                        setappdata(0,'button','wing')
                    end
                case 'wing'
                    if expparams{i}.wingtrack.dosetwingtrack
                        cbtrackGUI_WingTracker
                    else
                        if getappdata(0,'singleexp')
                            setappdata(0,'button','track')
                            setappdata(0,'P_stage','track1')
                        else
                            setappdata(0,'next',true)
                        end
                    end
                case 'track'
                    cbparams_temp=getappdata(0,'cbparams');
                    if cbparams_temp.track.DEBUG
                        P_stage=getappdata(0,'P_stage');
                        if strcmp(P_stage,'track1');
                            cbtrackGUI_tracker_video
                        elseif strcmp(P_stage,'track2');
                            CourtshipBowlTrack_GUI2
                        end
                    else
                         cbtrackGUI_tracker_NOvideo
                    end
                otherwise
                    setappdata(0,'next',true)
            end
            if get(handles.checkbox_savetemp,'Value')
                savetemp([]);
            end
            if getappdata(0,'iscancel')
                cancelar
                return
            elseif getappdata(0,'isskip')
                success(i)=false;
                setappdata(0,'next',true)
                continue
            end 
            WriteParams
        end

        BG{i}=getappdata(0,'BG');
        expparams{i}=getappdata(0,'cbparams');
        roidata{i}=getappdata(0,'roidata');
    catch ME
        stage_error=getappdata(0,'P_stage');
        switch stage_error
            case 'BG'
                log_type='bg_log';
                where='Background computation';
            case 'ROIs'
                log_type='roi_log';
                where='ROI detection';
            case 'params'
                log_type='track_log';
                where='Body tracking parameters setup';
            case 'wing_params'
                log_type='track_log';
                where='Wing tracking parameters setup';
            case 'track1'
                log_type='track_log';
                where='Body tracking';
            case 'track2'
                log_type='track_log';
                where='Wing Tracking';
        end
        logfid2=open_log(log_type);
        s=sprintf('%s failed for experiment %s: %s\n',where,experiment,ME.message);
        write_log(logfid2,experiment,s)
        waitfor(mymsgbox(50,190,14,'Helvetica',[where,' failed for ', experiment,' and will be omitted'],'Warning','warn','modal'))

        if logfid2>1
            fclose(logfid2);
        end
        success(i)=false;
        continue
    end
end
omitedexp=exps(~success);
omitedexp_all=[omitedexp_all,omitedexp];
exps(~success)=[];
expdirs(~success)=[];
moviefile(~success)=[];
out(~success)=[];
expparams(~success)=[];
BG(~success)=[];
roidata(~success)=[];
success(~success)=[];

if isempty(success)
    mymsgbox(50,190,14,'Helvetica','Tracking Done','Done','help','modal')
    return
end    

% Track (if multiple files)
if get(handles.checkbox_dotrack,'Value') && ~getappdata(0,'singleexp')
    for i=1:numel(expdirs)
        experiment=exps{i};
        experiment(experiment=='_')=' ';

        mysetappdata('expdir',expdirs{i},'experiment',experiment,'moviefile',moviefile{i},...
            'out',out{i},'analysis_protocol',analysis_protocol,'cbparams',expparams{i},...
            'BG',BG{i},'roidata',roidata{i},'P_stage','track1','iscancel',false,'isskip',false,...
            'isstop',false,'button','track');

        try
            if expparams{i}.track.DEBUG
                cbtrackGUI_tracker_video
                CourtshipBowlTrack_GUI2
            else
                cbtrackGUI_tracker_NOvideo
            end
            if getappdata(0,'iscancel')
                cancelar
                return
            elseif getappdata(0,'isskip')
                success(i)=false;
                error_msg='Skipped by user';
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

        catch ME
            error_msg=ME.message;
            success(i)=false;
        end  
        if ~success(i)  
            logfid2=open_log('track_log');
            switch getappdata(0,'P_stage');
                case 'track1'
                    s=sprintf('Body tracking failed for experiment %s: %s\n',experiment,error_msg);
                case 'track2'
                    s=sprintf('Wing tracking failed for experiment %s: %s\n',experiment,error_msg);
            end
            write_log(logfid2,experiment,s)
            if logfid2>1
                fclose(logfid2);
            end
        end
    end

    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[];
    expdirs(~success)=[];
    moviefile(~success)=[];
    out(~success)=[];
    expparams(~success)=[];
    success(~success)=[];
    if ~isempty(omitedexp)
        mymsgbox(50,190,14,'Helvetica',['Tracking failed or was skipped for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn');
    end
end

% Reuslts movie
if get(handles.checkbox_domovie,'Value') && strcmp(getappdata(0,'P_stage'),'results_movie')      
    for i=1:numel(expdirs)
        [success(i)]=cbtrackNOGUI_resultsmovie(exps{i},expdirs{i},...
            moviefile{i},out{i},analysis_protocol,expparams{i});
        if getappdata(0,'iscancel')
            cancelar
            return
        end
    end
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[];
    expdirs(~success)=[];
    out(~success)=[];
    expparams(~success)=[];
    success(~success)=[];
    if ~isempty(omitedexp)
        mymsgbox(50,190,14,'Helvetica',['Results movie could not be created for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn')
    end
else
    setappdata(0,'P_stage','PFF')
end

%PFF
if get(handles.checkbox_dopff,'Value') && strcmp(getappdata(0,'P_stage'),'PFF');
    for i=1:numel(expdirs)
        [success(i)]=cbtrackNOGUI_PFF(exps{i},out{i},analysis_protocol,expparams{i});
        if getappdata(0,'iscancel')
            cancelar
            return
        end
    end
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[];
    expdirs(~success)=[];
    out(~success)=[];
    expparams(~success)=[];
    success(~success)=[];
    if ~isempty(omitedexp)
        mymsgbox(50,190,14,'Helvetica',['Perframe features could not be computed for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn');
    end
else
    setappdata(0,'P_stage','AcC')
end

% Autmatic check complete for all experiments
hwait=waitbar(0,'Checking complete');
if get(handles.checkbox_doAcC,'Value') && strcmp(getappdata(0,'P_stage'),'AcC');
    for i=1:numel(expdirs)
        [success(i)]=cbtrackNOGUI_AcC(exps{i},out{i},expparams{i});
        waitbar(i/numel(expdirs),hwait,['Checking Complete for experiment ',experiment]);
    end
    delete(hwait);
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
else
    setappdata(0,'P_stage','done')
end

if isempty(omitedexp_all)
    s='Tracking done.';
else
    s=['Tracking Done. Failed experiments:',sprintf('\n\t- %s',omitedexp_all{:})];
end
mymsgbox(50,190,14,'Helvetica',s,'Done','help','modal')
logfid=open_log('main_log'); 
write_log(logfid,experiment,s)
if logfid > 1,
  fclose(logfid);
end

clear_all


function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
cancelar


function checkbox_dotrack_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_dotrackwings,'Enable','on')
    set(handles.checkbox_doAcC,'Enable','on')
    set(handles.checkbox_domovie,'Enable','on')
    set(handles.checkbox_dopff,'Enable','on')
else
    set(handles.checkbox_dotrackwings,'Enable','off','Value',false)
    set(handles.checkbox_doAcC,'Enable','off','Value',false)
    set(handles.checkbox_domovie,'Enable','off','Value',false)
    set(handles.checkbox_dopff,'Enable','off','Value',false)
end


function edit_restart_Callback(hObject, eventdata, handles)


function edit_restart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_restart_Callback(hObject, eventdata, handles)
[restart_file,restart_folder]=open_files2('mat');  
if restart_file{1}~=0
    restart=fullfile(restart_folder,restart_file{1});
    set(handles.edit_restart,'String',restart)
end


function checkbox_restart_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.text_restart,'Enable','on')
    set(handles.edit_restart,'Enable','on')
    set(handles.pushbutton_restart,'Enable','on')
    set(handles.radiobutton_Vid,'Enable','off')
    set(handles.radiobutton_Dir,'Enable','off')
    set(handles.radiobutton_Txt,'Enable','off')
	set(handles.text_in,'Enable','off')
    set(handles.edit_in,'Enable','off')
    set(handles.pushbutton_in,'Enable','off')
    set(handles.checkbox_usefiles,'Enable','off')
    set(handles.checkbox_dosetBG,'Enable','off')
    set(handles.checkbox_dosetROI,'Enable','off')
    set(handles.checkbox_dosetT,'Enable','off')
    set(handles.checkbox_dosetWT,'Enable','off')
    set(handles.checkbox_dotrack,'Enable','off')
    set(handles.checkbox_dotrackwings,'Enable','off')
    set(handles.checkbox_doAcI,'Enable','off')
    set(handles.checkbox_doAcC,'Enable','off')
    set(handles.checkbox_domovie,'Enable','off')
    set(handles.checkbox_dopff,'Enable','off')
    set(handles.checkbox_log,'Enable','off')
    set(handles.checkbox_savetemp,'Enable','off')
else
    set(handles.text_restart,'Enable','off')
    set(handles.edit_restart,'Enable','off')
    set(handles.pushbutton_restart,'Enable','off')
    set(handles.radiobutton_Vid,'Enable','on')
    set(handles.radiobutton_Dir,'Enable','on')
    set(handles.radiobutton_Txt,'Enable','on')
	set(handles.text_in,'Enable','on')
    set(handles.edit_in,'Enable','on')
    set(handles.pushbutton_in,'Enable','on')
    set(handles.checkbox_usefiles,'Enable','on')
    set(handles.checkbox_dosetBG,'Enable','on')
    set(handles.checkbox_dosetROI,'Enable','on')
    set(handles.checkbox_dosetT,'Enable','on')
    set(handles.checkbox_dosetWT,'Enable','on')
    set(handles.checkbox_dotrack,'Enable','on')
    set(handles.checkbox_dotrackwings,'Enable','on')
    set(handles.checkbox_doAcI,'Enable','on')
    set(handles.checkbox_doAcC,'Enable','on')
    set(handles.checkbox_domovie,'Enable','on')
    set(handles.checkbox_dopff,'Enable','on')
    set(handles.checkbox_log,'Enable','on')
    set(handles.checkbox_savetemp,'Enable','on')
end


function checkbox_usefiles_Callback(hObject, eventdata, handles)


function checkbox_dosetBG_Callback(hObject, eventdata, handles)


function checkbox_dosetROI_Callback(hObject, eventdata, handles)


function checkbox_dosetT_Callback(hObject, eventdata, handles)


function checkbox_dosetWT_Callback(hObject, eventdata, handles)


function checkbox_doAcI_Callback(hObject, eventdata, handles)


function checkbox_domovie_Callback(hObject, eventdata, handles)


function checkbox_dotrackwings_Callback(hObject, eventdata, handles)


function checkbox_doAcC_Callback(hObject, eventdata, handles)


function checkbox_dopff_Callback(hObject, eventdata, handles)


function checkbox_savetemp_Callback(hObject, eventdata, handles)


function checkbox_log_Callback(hObject, eventdata, handles)

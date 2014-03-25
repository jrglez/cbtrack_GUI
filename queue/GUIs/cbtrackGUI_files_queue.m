function varargout = cbtrackGUI_files_queue(varargin)
% CBTRACKGUI_FILES_QUEUE MATLAB code for cbtrackGUI_files_queue.fig
%      CBTRACKGUI_FILES_QUEUE, by itself, creates a new CBTRACKGUI_FILES_QUEUE or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_FILES_QUEUE returns the handle to a new CBTRACKGUI_FILES_QUEUE or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_FILES_QUEUE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_FILES_QUEUE.M with the given input arguments.
%
%      CBTRACKGUI_FILES_QUEUE('Property','Value',...) creates a new CBTRACKGUI_FILES_QUEUE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_files_queue_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_files_queue_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_files_queue

% Last Modified by GUIDE v2.5 04-Mar-2014 15:30:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_files_queue_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_files_queue_OutputFcn, ...
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


% --- Executes just before cbtrackGUI_files_queue is made visible.
function cbtrackGUI_files_queue_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for cbtrackGUI_files_queue
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


function varargout = cbtrackGUI_files_queue_OutputFcn(hObject, eventdata, handles) 
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
if ~exist(get(handles.edit_in,'String'),'file')
    mymsgbox(50,190,14,'Helvetica','The file or directory does not exist','Error','error','modal')
else
    VidDirOrTxt=get(handles.uipanel_folder,'SelectedObject');
    omitedexp_all=[];
    if VidDirOrTxt==handles.radiobutton_Vid
        fullfilein=get(handles.edit_in,'String');
        [expdirs{1},moviefile{1},ext]=fileparts(fullfilein);
        movie_name=moviefile;
        exps{1}=splitdir(expdirs{1},'last');
        moviefile=strcat(moviefile{1},ext); moviefile=fullfile(expdirs,moviefile);
        analysis_protocol=splitdir(expdirs{1},'last');
        paramsfile=fullfile(expdirs{1},'params.xml');
        success=true;
    elseif VidDirOrTxt==handles.radiobutton_Dir
        expdir=get(handles.edit_in,'String');
        content=dir(expdir);
        aredirs=[content.isdir];
        for i=1:numel(aredirs)
            aredirs(i)=aredirs(i)&&~strcmp(content(i).name(1),'.');
        end    
        exps={content(aredirs).name};

        movie_name=cell(1,numel(exps));
        filetypes={'.ufmf','.fmf','.sbfmf','.avi','.mp4','.mov','.mmf'};
        expdirs=fullfile(expdir,exps);
        success=true(1,numel(expdirs));
        for i=1:numel(expdirs)
            expcontent=(dir(expdirs{i}));        
            nmovies=0;
            for j=1:numel(expcontent)
                [~,ext]=splitext(expcontent(j).name);
                if any(strcmp(ext,filetypes))
                    nmovies=nmovies+1;
                    movie_name{i}=expcontent(j).name;
                end                    
            end
            if nmovies~=1
                success(i)=false;            
            end
        end
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[];
        expdirs(~success)=[];
        movie_name(~success)=[];
        success(~success)=[];
        if ~isempty(omitedexp)
            waitfor(mymsgbox(50,190,14,'Helvetica',['The following experiment directories contained no video or more than one videos and will be omited:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn','modal'))
        elseif numel(expdirs)==0
            mymsgbox(50,190,14,'Helvetica','There are no valid videos in the selected directory','Error','error','modal')
            return
        end
        moviefile=fullfile(expdir,exps,movie_name);
        analysis_protocol = splitdir(expdir,'last');
        paramsfile=fullfile(expdir,'params.xml');
    elseif VidDirOrTxt==handles.radiobutton_Txt
        fullfiletxt=get(handles.edit_in,'String');
        [analysis_protocol,paramsfile,expdirs] = ReadGroupedExperimentList_queue(fullfiletxt);
        
        exps=cell(1,numel(expdirs));
        movie_name=cell(1,numel(expdirs));
        filetypes={'.ufmf','.fmf','.sbfmf','.avi','.mp4','.mov','.mmf'};
        success=true(1,numel(expdirs));
        for i=1:numel(expdirs)
            exps{i}=splitdir(expdirs{i},'last');
            expcontent=(dir(expdirs{i}));        
            nmovies=0;
            for j=1:numel(expcontent)
                [~,ext]=splitext(expcontent(j).name);
                if any(strcmp(ext,filetypes))
                    nmovies=nmovies+1;
                    movie_name{i}=expcontent(j).name;
                end                    
            end
            if nmovies~=1
                success(i)=false;         
            end
        end
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[];
        expdirs(~success)=[];
        movie_name(~success)=[];
        success(~success)=[];
        if ~isempty(omitedexp)
            waitfor(mymsgbox(50,190,14,'Helvetica',['The following experiment directories contained no video or more than one videos and will be omited:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn','modal'))
        elseif numel(expdirs)==0
            mymsgbox(50,190,14,'Helvetica','There are no valid videos in the selected directory','Error','error','modal')
            return
        end
        
        moviefile=fullfile(expdirs,movie_name);
    end
    
    if ~exist(paramsfile,'file')
        mymsgbox(50,190,14,'Helvetica','Invalid or missing Parameters File','Error','error','modal')
        return
    end
    
    cbparams = ReadXMLParams(paramsfile);
    cbparams.track.DEBUG=false;
    if ~get(handles.checkbox_log,'Value')
        cbparams.dataloc.ufmf_log.filestr=[];
        cbparams.dataloc.fbdc_log.filestr=[];
        cbparams.dataloc.automaticchecks_incoming_log.filestr=[];
        cbparams.dataloc.bg_log.filestr=[];
        cbparams.dataloc.roi_log.filestr=[];
        cbparams.dataloc.track_log.filestr=[];
        cbparams.dataloc.perframefeature_log.filestr=[];
        cbparams.dataloc.resultsmovie_log.filestr=[];
        cbparams.dataloc.automaticchecks_complete_log.filestr=[];
    end
    cbparams.track.dotrack=get(handles.checkbox_dotrack,'Value');
    cbparams.track.dotrackwings=get(handles.checkbox_dotrackwings,'Value');
    cbparams.compute_perframe_features.dopff=get(handles.checkbox_dopff,'Value');
    cbparams.results_movie.dovideo=get(handles.checkbox_domovie,'Value');

    % Autmatich check incomings for all experiments
    out=cell(numel(expdirs),1);
    hwait=waitbar(0,'Checking incomings');
    for i=1:numel(expdirs)
        experiment=splitdir(expdirs{i},'last');
        experiment(experiment=='_')=' ';

        out{i}.folder=expdirs{i};            
        out{i}.temp=strcat('Temp_',datestr(now,TimestampFormat),'_',experiment,'.mat');
        out{i}.temp_full=fullfile(out{i}.folder,out{i}.temp);
        
        setappdata(0,'experiment',experiment);
        setappdata(0,'out',out{i});
        setappdata(0,'cbparams',cbparams)

        if get(handles.checkbox_doAcI,'Value')
            logfid=open_log('automaticchecks_incoming_log',cbparams,out{i}.folder);
            try
              fprintf(logfid,'AutomaticChecks_Incoming for experiment %s...\n',experiment);
              waitbar(i/numel(expdirs),hwait,['Checking incomings for experiment ',experiment]);
              [success(i),msgs,iserror] = CourtshipBowlAutomaticChecks_Incoming(expdirs{i},'analysis_protocol',analysis_protocol); %#ok<*NASGU>
              if ~success(i),
                fprintf(logfid,'AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment);
                fprintf(logfid,'%s\n',msgs{:});
                continue;
              end      
            catch ME,
              success(i)=false;
              msgs = {sprintf('Error running AutomaticChecks_Incoming:\n%s',getReport(ME))};
              fprintf(logfid,'AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment);
              fprintf(logfid,'%s\n',msgs{:});
              continue;
            end
        end        
    end
    delete(hwait);
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[]; 
    expdirs(~success)=[];
    movie_name(~success)=[];
    success(~success)=[];
    
    % Compute background and ROIs for all the experiments
    BG=cell(numel(expdirs),1);
    roidata=cell(numel(expdirs),1);
    expparams=cell(numel(expdirs),1);
    for i=1:numel(expdirs)
        experiment=exps{i};
        experiment(experiment=='_')=' ';
        
        setappdata(0,'expdir',expdirs{1});
        setappdata(0,'experiment',experiment);
        setappdata(0,'moviefile',moviefile{1});
        setappdata(0,'out',out{i});
        setappdata(0,'analysis_protocol',analysis_protocol);
        setappdata(0,'cbparams',cbparams);
        setappdata(0,'P_stage','BG');
        setappdata(0,'restart','');
        
        try
            cbtrackGUI_BG_queue;
            if getappdata(0,'iscancel')
                cancelar
                return
            end
            BG{i}=getappdata(0,'BG');
        catch ME
            success(i)=false;
            waitfor(mymsgbox(50,190,14,'Helvetica',['The background computation failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
            continue
        end
        
        try
            cbtrackGUI_ROI_queue
            if getappdata(0,'iscancel')
                cancelar
                return
            end
            expparams{i}=getappdata(0,'cbparams');
            roidata{i}=getappdata(0,'roidata');
        catch ME
            success(i)=false;
            waitfor(mymsgbox(50,190,14,'Helvetica',['The ROI detection failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
            continue
        end        
        WriteParams
    end
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[];
    expdirs(~success)=[];
    movie_name(~success)=[];
    success(~success)=[];
    
    % Track
    if cbparams.track.dotrack
        for i=1:numel(expdirs)
            experiment=exps{i};
            experiment(experiment=='_')=' ';

            setappdata(0,'expdir',expdirs{1});
            setappdata(0,'experiment',experiment);
            setappdata(0,'moviefile',moviefile{1});
            setappdata(0,'out',out{i});
            setappdata(0,'analysis_protocol',analysis_protocol);
            setappdata(0,'cbparams',expparams{i}) ;   
            setappdata(0,'BG',BG{i});
            setappdata(0,'roidata',roidata{i});

            try
                [readframe,nframes] = get_readframe_fcn(moviefile{i});
                roidata{i}.nflies_per_roi = CountFliesPerROI_GUI_queue(readframe,nframes,BG{i}.bgmed,roidata{i},expparams{i}.detect_rois,expparams{i}.track);
                setappdata(0,'roidata',roidata{i});
            catch ME
                success(i)=false;
                continue
            end

            try
                cbtrackGUI_tracker_NOvideo
            catch ME
                success(i)=false;
                continue
            end  
        end
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[];
        expdirs(~success)=[];
        movie_name(~success)=[];
        success(~success)=[];
        if ~isempty(omitedexp)
            waitfor(mymsgbox(50,190,14,'Helvetica',['Tracking failed for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn','modal'))
        end
    end
end 
cancelar
delete(handles.figure1)

%%% Aquí. Continuar con la lista principal. Continuar traqueando el video
%%% de Shelby (poner db stop if)

function pushbutton_cancel_Callback(hObject, eventdata, handles)
close(handles.figure1)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
cancelar

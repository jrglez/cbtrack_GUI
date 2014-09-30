function varargout = cbtrackGUI_files(varargin)
% CBTRACKGUI_FILES MATLAB code for cbtrackGUI_files.fig
%      CBTRACKGUI_FILES, by itself, creates a new CBTRACKGUI_FILES or raises the existing
%      singleton*.
%
%      H = CBTRACKGUI_FILES returns the handle to a new CBTRACKGUI_FILES or the handle to
%      the existing singleton*.
%
%      CBTRACKGUI_FILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBTRACKGUI_FILES.M with the given input arguments.
%
%      CBTRACKGUI_FILES('Property','Value',...) creates a new CBTRACKGUI_FILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbtrackGUI_files_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbtrackGUI_files_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbtrackGUI_files

% Last Modified by GUIDE v2.5 22-Sep-2014 16:26:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cbtrackGUI_files_OpeningFcn, ...
                   'gui_OutputFcn',  @cbtrackGUI_files_OutputFcn, ...
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


function cbtrackGUI_files_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for cbtrackGUI_files
handles.output = hObject;

funpath=fileparts(which('cbtrackGUI_files'));
cbtrack_path=genpath(funpath(1:end-4));
addpath(cbtrack_path);

% Update handles structure
guidata(hObject, handles);


function varargout = cbtrackGUI_files_OutputFcn(hObject, eventdata, handles) 
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
    if exist(restart,'file')
        load(restart);
        appdatalist={'viewlog','h_log','expdir','experiment','moviefile','out',...
    'analysis_protocol','P_stage','cbparams','restart','GUIscale',...
    'startframe','endframe','BG','roidata','visdata','debugdata_WT',...
    'pff_all','t','trackdata','iscancel','isskip','allow_stop','isstop','twing'};
        for i=1:length(appdatalist)
            if exist(appdatalist{i},'var')
                setappdata(0,appdatalist{i},eval(appdatalist{i}))
            end
        end
        logfid=open_log('main_log'); 
        s=sprintf('\n\n***\nRestarting experiment %s from %s at %s\n',experiment,restart,datestr(now,'yyyymmddTHHMMSS')); %#ok<NODEF>
        write_log(logfid,experiment,s)
        if logfid > 1,
          fclose(logfid);
        end
        setappdata(0,'singleexp',true)
        setappdata(0,'iscancel',false)
        setappdata(0,'isskip',false)
        setappdata(0,'isstop',false)
        if ishandle(handles.figure1)
            delete(handles.figure1)
        end
        switch P_stage
            case strcmp(P_stage,'track2') 
                CourtshipBowlTrack_GUI2
            case strcmp(P_stage,'track1')
                if cbparams.track.DEBUG
                    cbtrackGUI_tracker_video
                elseif ~cbparams.track.DEBUG
                    cbtrackGUI_tracker_NOvideo
                end
            case strcmp(P_stage,'wing_params')
                cbtrackGUI_WingTracker
            case strcmp(P_stage,'params')
                cbtrackGUI_tracker
            case strcmp(P_stage,'ROIs')
                cbtrackGUI_ROI
            case strcmp(P_stage,'BG')
                cbtrackGUI_BG
        end 
        if getappdata(0,'iscancel')
            cancelar
            return
        elseif getappdata(0,'isskip')
            clear_all
            return
        end
        
        % Reuslts movie 
        if cbparams.results_movie.dovideo
            try
                CourtshipBowlMakeResultsMovie_GUI;
                if getappdata(0,'iscancel')
                    cancelar
                    return
                elseif getappdata(0,'isskip')
                    clear_all
                    return
                end
            catch ME
                experiment=getappdata(0,'experiment');
                experiment(experiment=='_')=' ';
                logfid2=open_log('resultsmovie_log');
                s=sprintf('Results movie could not be created for experiment %s: %s\n',getappdata(0,'experiment'),ME.message);
                write_log(logfid2,experiment,s)
                if logfid2>1
                    fclose(logfid2);
                end
                waitfor(mymsgbox(50,190,14,'Helvetica',['Results movie could not be created for the following experiments:',sprintf('\n\t- %s',getappdata(0,'experiment'))],'Warning','warn','modal'))
            end
        end

        %PFF
        if cbparams.compute_perframe_features.dopff && strcmp(getappdata(0,'P_stage'),'pff')
            try
                [~] = CourtshipBowlComputePerFrameFeatures_GUI(1);
                if getappdata(0,'iscancel')
                    cancelar
                    return
                elseif getappdata(0,'isskip')
                    clear_all
                    return
                end
            catch ME
                experiment=getappdata(0,'experiment');
                experiment(experiment=='_')=' ';
                logfid2=open_log('perframefeature_log');
                s=sprintf('Perframe features could not be computed for the following experiment %s: %s\n',getappdata(0,'experiment'),ME.message);
                write_log(logfid2,experiment,s)
                if logfid2>1
                    fclose(logfid2);
                end
                waitfor(mymsgbox(50,190,14,'Helvetica',['Perframe features could not be computed for the following experiments:',sprintf('\n\t- %s',getappdata(0,'experiment'))],'Warning','warn','modal'))
            end
        end
        
        % Autmatic check complete for all experiments
        if get(handles.checkbox_doAcC,'Value')
            experiment=getappdata(0,'experiment');
            experiment(experiment=='_')=' ';
            out=getappdata(0,'out');

            logfid=open_log('automaticchecks_incoming_log');
            try
              s=sprintf('AutomaticChecks_Complete for experiment %s...\n',experiment);
              write_log(logfid,experiment,s)
              [success,msgs] = CourtshipBowlAutomaticChecks_Complete(out.folder);
              if ~success,
                  s={sprintf('AutomaticChecks_Complete error/warning for experiment %s:\n',experiment);...
                      sprintf('%s\n',msgs{:})};
                  write_log(logfid,experiment,s)
                  if logfid>1
                    fclose(logfid);
                  end
              end      
            catch ME,
              msgs = {sprintf('Error running AutomaticChecks_Complete:\n%s',ME.message)};
              s={sprintf('AutomaticChecks_Complete error/warning for experiment %s:\n',experiment);...
              sprintf('%s\n',msgs{:})};
              write_log(logfid,experiment,s)
              if logfid>1
                  fclose(logfid);
              end
            end
        end
    else
        msg_error=mymsgbox(50,190,14,'Helvetica',{'File does not exist'},'Error','error','modal');
    end
else
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
            moviefile=strcat(moviefile{1},ext); moviefile={fullfile(expdirs{1},moviefile)};
            analysis_protocol=splitdir(expdirs{1},'last');
            paramsfile={fullfile(expdirs{1},'params.xml')};
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
            if exist(paramsfile,'file')
                paramsfile={paramsfile};
            else
                paramsfile=fullfile(expdirs,'params.xml');
            end
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
        setappdata(0,'singleexp',numel(exps)==1);

        if numel(paramsfile)==1
            paramsfile=repmat(paramsfile,size(expdirs));
        end
        expparams=cell(size(paramsfile));
        success=true(1,numel(expdirs));
        for i=1:numel(paramsfile) 
            if ~exist(paramsfile{i},'file')
                mymsgbox(50,190,14,'Helvetica','Invalid or missing Parameters File','Error','error','modal')
                success(i)=false;
            end
            expparams{i} = ReadXMLParams(paramsfile{i});
            setappdata(0,'viewlog',get(handles.checkbox_log,'Value'))
            expparams{i}.track.dosave=get(handles.checkbox_savetemp,'Value');
            expparams{i}.track.dosetBG=get(handles.checkbox_dosetBG,'Value');
            expparams{i}.detect_rois.dosetROI=get(handles.checkbox_dosetROI,'Value');
            expparams{i}.track.dosettrack=get(handles.checkbox_dosetT,'Value');
            expparams{i}.wingtrack.dosetwingtrack=get(handles.checkbox_dosetWT,'Value');
            expparams{i}.auto_checks_incoming.doAcI=get(handles.checkbox_doAcI,'Value');
            expparams{i}.auto_checks_complete.doAcC=get(handles.checkbox_doAcC,'Value');
            expparams{i}.track.dotrack=get(handles.checkbox_dotrack,'Value');
            expparams{i}.track.dotrackwings=get(handles.checkbox_dotrackwings,'Value');
            expparams{i}.compute_perframe_features.dopff=get(handles.checkbox_dopff,'Value');
            expparams{i}.results_movie.dovideo=get(handles.checkbox_domovie,'Value');
        end
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[];
        expdirs(~success)=[];
        movie_name(~success)=[];
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
            experiment=splitdir(expdirs{i},'last');

            out{i}.folder=expdirs{i};            
            out{i}.temp=strcat('Temp_',datestr(now,TimestampFormat),'_',experiment,'.mat');
            out{i}.temp_full=fullfile(out{i}.folder,out{i}.temp);
            
            experiment(experiment=='_')=' ';

            setappdata(0,'experiment',experiment);
            setappdata(0,'expdir',expdirs{i});
            setappdata(0,'moviefile',moviefile{i});
            setappdata(0,'analysis_protocol',analysis_protocol);
            setappdata(0,'out',out{i});
            setappdata(0,'cbparams',expparams{i})

            if get(handles.checkbox_doAcI,'Value')
                logfid=open_log('automaticchecks_incoming_log');
                try
                  s=sprintf('AutomaticChecks_Incoming for experiment %s...\n',experiment);
                  write_log(logfid,experiment,s)
                  waitbar(i/numel(expdirs),hwait,['Checking incomings for experiment ',experiment]);
                  [success(i),msgs,iserror] = CourtshipBowlAutomaticChecks_Incoming_GUI(out{i}.folder,'analysis_protocol',analysis_protocol); %#ok<*NASGU>
                  if ~success(i),
                    waitfor(mymsgbox(50,190,14,'Helvetica',sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment),'Warning','warn','modal'))
                    s={sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment);...
                        sprintf('%s\n',msgs{:})};
                    write_log(logfid,experiment,s)
                    if logfid>1
                      fclose(logfid);
                    end
                    continue;
                  end      
                catch ME,
                  success(i)=false;
                  msgs = {sprintf('Error running AutomaticChecks_Incoming:\n%s',ME.message)};
                  waitfor(mymsgbox(50,190,14,'Helvetica',sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment),'Warning','warn','modal'))
                  s={sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment);...
                  sprintf('%s\n',msgs{:})};
                  write_log(logfid,experiment,s)
                  if logfid>1
                      fclose(logfid);
                  end
                  continue;
                end
            end
            if expparams{i}.track.dosave
                savetemp({'viewlog','out','expdir','moviefile','experiment','analysis_protocol','P_stage'});
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
        logfid=open_log('main_log');
        s=sprintf('\n\n***\n*** SETUP STARTED AT %s ***\n',datestr(now,'yyyymmddTHHMMSS')); 
        write_log(logfid,'',s)
        if logfid > 1,
          fclose(logfid);
        end
        
        BG=cell(numel(expdirs),1);
        roidata=cell(numel(expdirs),1);
        for i=1:numel(expdirs)
            experiment=exps{i};
            experiment(experiment=='_')=' ';

            setappdata(0,'expdirs',expdirs);
            setappdata(0,'expdir',expdirs{i});
            setappdata(0,'experiment',experiment);
            setappdata(0,'moviefile',moviefile{i});
            setappdata(0,'out',out{i});
            setappdata(0,'analysis_protocol',analysis_protocol);
            setappdata(0,'cbparams',expparams{i});
            setappdata(0,'P_stage','BG');
            setappdata(0,'restart','');
            setappdata(0,'usefiles',get(handles.checkbox_usefiles,'Value'));
            setappdata(0,'iscancel',false);
            setappdata(0,'isskip',false);
            setappdata(0,'isstop',false);

            try
                if expparams{i}.track.dosetBG
                    cbtrackGUI_BG;
                elseif expparams{i}.detect_rois.dosetROI
                    cbtrackNOGUI_BG
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end
                    cbtrackGUI_ROI
                elseif expparams{i}.track.dosettrack
                    cbtrackNOGUI_BG
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end
                    cbtrackNOGUI_ROI
                    cbtrackGUI_tracker
                elseif expparams{i}.wingtrack.dosetwingtrack
                    cbtrackNOGUI_BG
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end
                    cbtrackNOGUI_ROI
                    cbtrackNOGUI_tracker
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end
                    cbtrackGUI_WingTracker
                else
                    cbtrackNOGUI_BG
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end
                    cbtrackNOGUI_ROI
                    cbtrackNOGUI_tracker
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end
                    WriteParams
                    if expparams{i}.track.DEBUG && expparams{i}.track.dotrack && getappdata(0,'singleexp')
                        cbtrackGUI_tracker_video
                    elseif expparams{i}.track.dotrack && getappdata(0,'singleexp')
                        cbtrackGUI_tracker_NOvideo
                    end
                end
                if getappdata(0,'iscancel')
                    cancelar
                    return
                elseif getappdata(0,'isskip')
                    success(i)=false;
                    continue
                end

                BG{i}=getappdata(0,'BG');
                expparams{i}=getappdata(0,'cbparams');
                roidata{i}=getappdata(0,'roidata');
            catch ME
                stage_error=getappdata(0,'P_stage');
                switch stage_error
                    case 'BG'
                        logfid2=open_log('bg_log');
                        s=sprintf('Backgroud computation failed for experiment %s: %s\n',experiment,ME.message);
                        write_log(logfid2,experiment,s)
                        if logfid2>1
                            fclose(logfid2);
                        end
                        waitfor(mymsgbox(50,190,14,'Helvetica',['Backgroud computation failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
                    case 'ROIs'
                        logfid2=open_log('roi_log');
                        s=sprintf('ROI detection failed for experiment %s: %s\n',experiment,ME.message);
                        write_log(logfid2,experiment,s)
                        if logfid2>1
                            fclose(logfid2);
                        end
                        waitfor(mymsgbox(50,190,14,'Helvetica',['ROI detection failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))                        
                    case 'params'
                        logfid2=open_log('track_log');
                        s=sprintf('Body tracking parameters setup failed for experiment %s: %s\n',experiment,ME.message);
                        write_log(logfid2,experiment,s)
                        if logfid2>1
                            fclose(logfid2);
                        end
                        waitfor(mymsgbox(50,190,14,'Helvetica',['Body tracking parameters setup failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
                    case 'wings_params'
                        logfid2=open_log('track_log');
                        s=sprintf('Wing tracking parameters setup failed for experiment %s: %s\n',experiment,ME.message);
                        write_log(logfid2,experiment,s)
                        if logfid2>1
                            fclose(logfid2);
                        end
                        waitfor(mymsgbox(50,190,14,'Helvetica',['Wing tracking parameters setup failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
                    case 'track1'
                        logfid2=open_log('track_log');
                        s=sprintf('Body tracking failed for experiment %s: %s\n',experiment,ME.message);
                        write_log(logfid2,experiment,s)
                        if logfid2>1
                            fclose(logfid2);
                        end
                        waitfor(mymsgbox(50,190,14,'Helvetica',['Body tracking failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
                    case 'track2'
                        logfid2=open_log('track_log');
                        s=sprintf('Wing Tracking failed for experiment %s: %s\n',experiment,ME.message);
                        write_log(logfid2,experiment,s)
                        if logfid2>1
                            fclose(logfid2);
                        end
                        waitfor(mymsgbox(50,190,14,'Helvetica',['Wing tracking failed for ', experiment,' and will be ommited'],'Warning','warn','modal'))
                end
                success(i)=false;
                continue
            end
            if ~getappdata(0,'singleexp') || ~expparams{i}.track.dotrack
                WriteParams
            end
        end
        omitedexp=exps(~success);
        omitedexp_all=[omitedexp_all,omitedexp];
        exps(~success)=[];
        expdirs(~success)=[];
        movie_name(~success)=[];
        out(~success)=[];
        expparams(~success)=[];
        BG(~success)=[];
        roidata(~success)=[];
        success(~success)=[];

        if isempty(success)
            mymsgbox(50,190,14,'Helvetica','Tracking Done','Done','help','modal')
            return
        end    

        % Track
        logfid=open_log('main_log');
        s=sprintf('\n\n***\n*** TRACK STARTED AT %s ***\n',datestr(now,'yyyymmddTHHMMSS'));
        write_log(logfid,'',s)
        if logfid > 1,
          fclose(logfid);
        end
        
        trackdata=cell(numel(expdirs),1);
        stage_error=cell(numel(expdirs),1);
        error_msg=cell(numel(expdirs),1);
        if get(handles.checkbox_dotrack,'Value') && ~getappdata(0,'singleexp')
            for i=1:numel(expdirs)
                experiment=exps{i};
                experiment(experiment=='_')=' ';

                setappdata(0,'expdir',expdirs{i});
                setappdata(0,'experiment',experiment);
                setappdata(0,'moviefile',moviefile{i});
                setappdata(0,'out',out{i});
                setappdata(0,'analysis_protocol',analysis_protocol);
                setappdata(0,'cbparams',expparams{i}) ;   
                setappdata(0,'BG',BG{i});
                setappdata(0,'roidata',roidata{i});
                setappdata(0,'P_stage','track1');
                setappdata(0,'iscancel',false);
                setappdata(0,'isskip',false);
                setappdata(0,'isstop',false);

                try
                    if expparams{i}.track.DEBUG
                        cbtrackGUI_tracker_video
                    else
                        cbtrackGUI_tracker_NOvideo
                    end
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        continue
                    end

                    trackdata{i}=getappdata(0,'trackdata');
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

                catch ME
                    stage_error{i}=getappdata(0,'P_stage');
                    error_msg{i}=ME.message;
                    success(i)=false;
                    continue
                end  
            end

            omitedexp=exps(~success);
            omitedexp_all=[omitedexp_all,omitedexp];
            if ~isempty(omitedexp)
                idomited=find(~success);
                for k=1:numel(omitedexp)
                    setappdata(0,'out',out{idomited(k)});
                    setappdata(0,'cbparams',expparams{idomited(k)});
                    experiment=exps{idomited(k)};
                    experiment(experiment=='_')=' ';
                    logfid2=open_log('track_log');
                    switch stage_error{idomited(k)}
                        case 'track1'
                            s=sprintf('Body tracking failed for experiment %s: %s\n',experiment,error_msg{idomited(k)});
                        case 'track2'
                            s=sprintf('Wing tracking failed for experiment %s: %s\n',experiment,error_msg{idomited(k)});
                    end
                    write_log(logfid2,experiment,s)
                    if logfid2>1
                        fclose(logfid2);
                    end
                end
                mymsgbox(50,190,14,'Helvetica',['Tracking failed or was skipped for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn');
            end
            exps(~success)=[];
            expdirs(~success)=[];
            movie_name(~success)=[];
            out(~success)=[];
            expparams(~success)=[];
            success(~success)=[];
        else
            try
                trackdata{1}=getappdata(0,'trackdata');
            catch ME
                success=false;
                mymsgbox(50,190,14,'Helvetica',['An error occurred while saving data from following experiments:',sprintf('\n\t- %s',experiment)],'Warning','warn');
            end
        end

        % Reuslts movie 
        if get(handles.checkbox_domovie,'Value')
            logfid=open_log('main_log');
            s=sprintf('\n\n***\n*** RESULTS MOIVIES STARTED AT %s ***\n',datestr(now,'yyyymmddTHHMMSS'));
            write_log(logfid,'',s)
            if logfid > 1,
              fclose(logfid);
            end
            
            stage_error=cell(numel(expdirs),1);
            error_msg=cell(numel(expdirs),1);
            for i=1:numel(expdirs)
                try
                    experiment=exps{i};
                    experiment(experiment=='_')=' ';
                    setappdata(0,'expdir',expdirs{i});
                    setappdata(0,'experiment',experiment);
                    setappdata(0,'moviefile',moviefile{i});
                    setappdata(0,'out',out{i});
                    setappdata(0,'analysis_protocol',analysis_protocol);
                    setappdata(0,'cbparams',expparams{i});
                    CourtshipBowlMakeResultsMovie_GUI
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        error_msg{i}='Experiment skipped by user';
                        continue
                    end
                catch ME
                    stage_error{i}=getappdata(0,'P_stage');
                    error_msg{i}=ME.message;
                    success(i)=false;
                    continue
                end
            end
            omitedexp=exps(~success);
            omitedexp_all=[omitedexp_all,omitedexp];
            if ~isempty(omitedexp)
                idomited=find(~success);
                for k=1:numel(omitedexp)
                    setappdata(0,'out',out{idomited(k)});
                    setappdata(0,'cbparams',expparams{idomited(k)});
                    experiment=exps{idomited(k)};
                    experiment(experiment=='_')=' ';
                    logfid2=open_log('resultsmovie_log');
                    s=sprintf('Results movie could not be created for experiment %s: %s\n',experiment,error_msg{idomited(k)});
                    write_log(logfid2,experiment,s)
                    if logfid2>1
                        fclose(logfid2);
                    end
                end
                mymsgbox(50,190,14,'Helvetica',['Results movie could not be created for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn')
            end
            exps(~success)=[];
            expdirs(~success)=[];
            movie_name(~success)=[];
            out(~success)=[];
            expparams(~success)=[];
            success(~success)=[];
        end

        %PFF
        if get(handles.checkbox_dopff,'Value');
            logfid=open_log('main_log');
            s=sprintf('\n\n***\n*** PFF COMPUTATION STARTED AT %s ***\n',datestr(now,'yyyymmddTHHMMSS'));
            write_log(logfid,'',s)
            if logfid > 1,
              fclose(logfid);
            end
            
            stage_error=cell(numel(expdirs),1);
            error_msg=cell(numel(expdirs),1);
            for i=1:numel(expdirs)
                try
                    experiment=exps{i};
                    experiment(experiment=='_')=' ';
                    setappdata(0,'experiment',experiment);
                    setappdata(0,'out',out{i});
                    setappdata(0,'analysis_protocol',analysis_protocol);
                    setappdata(0,'cbparams',expparams{i}) ;   
                    [~] = CourtshipBowlComputePerFrameFeatures_GUI(1);
                    if getappdata(0,'iscancel')
                        cancelar
                        return
                    elseif getappdata(0,'isskip')
                        success(i)=false;
                        error_msg{i}='Experiment skipped by user';
                        continue
                    end
                catch ME
                    stage_error{i}=getappdata(0,'P_stage');
                    error_msg{i}=ME.message;
                    success(i)=false;
                    continue
                end
            end
            omitedexp=exps(~success);
            omitedexp_all=[omitedexp_all,omitedexp];
            if ~isempty(omitedexp)
                idomited=find(~success);
                for k=1:numel(omitedexp)
                    setappdata(0,'out',out{idomited(k)});
                    setappdata(0,'cbparams',expparams{idomited(k)});
                    experiment=exps{idomited(k)};
                    experiment(experiment=='_')=' ';
                    logfid2=open_log('perframefeature_log');
                    s=sprintf('Perframe features could not be computed for experiment %s: %s\n',experiment,error_msg{idomited(k)});
                    write_log(logfid2,experiment,s)
                    if logfid2>1
                        fclose(logfid2);
                    end
                end
                mymsgbox(50,190,14,'Helvetica',['Perframe features could not be computed for the following experiments:',sprintf('\n\t- %s',omitedexp{:})],'Warning','warn');
            end
            exps(~success)=[];
            expdirs(~success)=[];
            movie_name(~success)=[];
            out(~success)=[];
            expparams(~success)=[];
            success(~success)=[];
        end
        
        % Autmatic check complete for all experiments
        hwait=waitbar(0,'Checking complete');
        if get(handles.checkbox_doAcC,'Value')
            for i=1:numel(expdirs)
                experiment=exps{i};
                experiment(experiment=='_')=' ';
                setappdata(0,'experiment',experiment);
                setappdata(0,'out',out{i});
                setappdata(0,'cbparams',expparams{i});
                
                logfid=open_log('automaticchecks_incoming_log');
                try
                  s=sprintf('AutomaticChecks_Complete for experiment %s...\n',experiment);
                  write_log(logfid,experiment,s)
                  waitbar(i/numel(expdirs),hwait,['Checking Complete for experiment ',experiment]);
                  [success(i),msgs] = CourtshipBowlAutomaticChecks_Complete(out{i}.folder);
                  if ~success(i),
                      s={sprintf('AutomaticChecks_Complete error/warning for experiment %s:\n',experiment);...
                          sprintf('%s\n',msgs{:})};
                      write_log(logfid,experiment,s)
                      if logfid>1
                        fclose(logfid);
                      end
                      continue;
                  end      
                catch ME,
                  success(i)=false;
                  msgs = {sprintf('Error running AutomaticChecks_Complete:\n%s',ME.message)};
                  s={sprintf('AutomaticChecks_Complete error/warning for experiment %s:\n',experiment);...
                  sprintf('%s\n',msgs{:})};
                  write_log(logfid,experiment,s)
                  if logfid>1
                      fclose(logfid);
                  end
                  continue;
                end
            end
            delete(hwait);
            omitedexp=exps(~success);
            omitedexp_all=[omitedexp_all,omitedexp];
            exps(~success)=[]; 
            expdirs(~success)=[];
            movie_name(~success)=[];
            success(~success)=[];
        end
    end
end 
clear_all
mymsgbox(50,190,14,'Helvetica','Tracking Done','Done','help','modal')
% cancelar

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

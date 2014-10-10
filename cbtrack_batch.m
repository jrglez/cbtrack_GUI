function cbtrack_batch(fullfiletxt,usefiles)
warning('off','MATLAB:hg:NoDisplayNoFigureSupportSeeReleaseNotes')
setappdata(0,'viewlog',false)
setappdata(0,'grayscale',true)
setappdata(0,'iscancel',false)
setappdata(0,'isskip',false)
setappdata(0,'isstop',false)

[analysis_protocol,paramsfile,expdirs] = ReadGroupedExperimentList_queue(fullfiletxt);

out.folder=fileparts(fullfiletxt);
setappdata(0,'out',out)
exps=cell(1,numel(expdirs));
movie_name=cell(1,numel(expdirs));
omitedexp_all=[];
%% Check for videos
fprintf('Checking videos\n');
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
        fprintf('%s contained no video or more than one videos and will be omited:\n\t- %s\n\n',expdirs{:});
    end
end
omitedexp=exps(~success);
omitedexp_all=[omitedexp_all,omitedexp];
exps(~success)=[];
expdirs(~success)=[];
movie_name(~success)=[];
success(~success)=[];
if numel(expdirs)==0
    fsprintf('There are no valid videos in the selected directories\n\n');
    return
end
moviefile=fullfile(expdirs,movie_name);
fprintf('***\n\n');

%% load params
fprintf('Loading parameters\n');
if numel(paramsfile)==1
    paramsfile=repmat(paramsfile,size(expdirs));
end
expparams=cell(size(paramsfile));
success=true(1,numel(expdirs));
for i=1:numel(paramsfile) 
    if ~exist(paramsfile{i},'file')
        fprintf('Invalid or missing Parameters File %s\n\n',paramsfile);
        success(i)=false;
    end
    expparams{i} = ReadXMLParams(paramsfile{i});
end
omitedexp=exps(~success);
omitedexp_all=[omitedexp_all,omitedexp];
exps(~success)=[];
expdirs(~success)=[];
movie_name(~success)=[];
success(~success)=[];
if numel(expdirs)==0
    fprintf('Tracking done\n\n');
    return
end
fprintf('***\n\n');

%% Track all the experiments
out=cell(numel(expdirs),1);
for i=1:numel(expdirs)
    experiment=exps{i};
    experiment(experiment=='_')=' ';

    out{i}.folder=expdirs{i};            
    out{i}.temp=strcat('Temp_',datestr(now,TimestampFormat),'_',experiment,'.mat');
    out{i}.temp_full=fullfile(out{i}.folder,out{i}.temp);

    setappdata(0,'expdirs',expdirs);
    setappdata(0,'expdir',expdirs{i});
    setappdata(0,'experiment',experiment);
    setappdata(0,'moviefile',moviefile{i});
    setappdata(0,'out',out{i});
    setappdata(0,'analysis_protocol',analysis_protocol);
    setappdata(0,'cbparams',expparams{i});
    setappdata(0,'restart','');
    setappdata(0,'usefiles',usefiles);
    
    logfid0=open_log('main_log');
    try
        if expparams{i}.auto_checks_incoming.doAcI
            setappdata(0,'P_stage','AcI')
            s=sprintf('\n\n***\n*** AUTOMATIC CHECK INCOMINGS STARTED FOR EXPERIMENT %s AT %s ***\n',experiment,datestr(now,'yyyymmddTHHMMSS')); 
            write_log(logfid0,'',s)
            msgs = {''};
            [success(i),msgs] = CourtshipBowlAutomaticChecks_Incoming_GUI(out{i}.folder,'analysis_protocol',analysis_protocol); %#ok<*NASGU>
            if ~success(i),
                error('')
            end
            if expparams{i}.track.dosave
                savetemp({'viewlog','out','expdir','moviefile','experiment','analysis_protocol','P_stage'});
            end
        end
        
        if expparams{i}.track.dotrack
            setappdata(0,'P_stage','BG');
            s=sprintf('\n\n***\n*** SETUP STARTED FOR EXPERIMENT %s AT %s ***\n',experiment,datestr(now,'yyyymmddTHHMMSS')); 
            write_log(logfid0,'',s)
            cbtrackNOGUI_BG
            cbtrackNOGUI_ROI
            cbtrackNOGUI_tracker
            expparams{i}=getappdata(0,'cbparams');
            
            s=sprintf('\n\n***\n*** TRACKING STARTED FOR EXPERIMENT %s AT %s ***\n',experiment,datestr(now,'yyyymmddTHHMMSS')); 
            write_log(logfid0,'',s)
            cbtrackGUI_tracker_NOvideo
        end
        
        if expparams{i}.results_movie.dovideo
            setappdata(0,'P_stage','results_movie')
            s=sprintf('\n\n***\n*** RESUKTS MOVIE STARTED FOR EXPERIMENT %s AT %s ***\n',experiment,datestr(now,'yyyymmddTHHMMSS')); 
            write_log(logfid0,'',s)
            CourtshipBowlMakeResultsMovie_GUI
        end
        
        if expparams{i}.compute_perframe_features.dopff
            setappdata(0,'P_stage','PFF')
            s=sprintf('\n\n***\n*** PFF COMPUTATION STARTED FOR EXPERIMENT %s AT %s ***\n',experiment,datestr(now,'yyyymmddTHHMMSS')); 
            write_log(logfid0,'',s)
            [~] = CourtshipBowlComputePerFrameFeatures_GUI(1);
        end 
        
        if expparams{i}.auto_checks_complete.doAcC
            setappdata(0,'P_stage','AcC')
            s=sprintf('\n\n***\n*** AUTOMATIC CHECK COMPLETE STARTED FOR EXPERIMENT %s AT %s ***\n',experiment,datestr(now,'yyyymmddTHHMMSS')); 
            write_log(logfid0,'',s)
            msgs = {''};
            [success(i),msgs] = CourtshipBowlAutomaticChecks_Complete(out{i}.folder);
            if ~success(i),
                error('')
            end   
        end
    catch ME
        stage_error=getappdata(0,'P_stage');
        switch stage_error
            case 'AcI'
                if isempty(msgs)
                    msgs = {ME.message};
                end
                logfid2=open_log('automaticchecks_incoming_log');
                s={sprintf('AutomaticChecks_Incoming warning/error for experiment %s (experiment will be ignored):\n',experiment);...
                        sprintf('%s\n',msgs{:});...
                        sprintf('\n')};
                write_log(logfid2,experiment,s)
            case 'BG'
                logfid2=open_log('bg_log');
                s=sprintf('Backgroud computation failed for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'ROIs'
                logfid2=open_log('roi_log');
                s=sprintf('ROI detection failed for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'params'
                logfid2=open_log('track_log');
                s=sprintf('Body tracking parameters setup failed for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'track1'
                logfid2=open_log('track_log');
                s=sprintf('Body tracking failed for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'track2'
                logfid2=open_log('track_log');
                s=sprintf('Wing Tracking failed for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'resultsmovie_log'
                logfid2=open_log('results_movie_log');
                s=sprintf('Results movie could not be created for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'perframefeature_log'
                logfid2=open_log('perframefeature_log');
                s=sprintf('PFF could not be computed for experiment %s: %s\n\n',experiment,ME.message);
                write_log(logfid2,experiment,s)
            case 'AcC'
                if isempty(msgs)
                    msgs = {ME.message};
                end
                logfid2=open_log('automaticchecks_complete_log');
                s={sprintf('AutomaticChecks_Complete warning/error for experiment %s:\n',experiment);...
                        sprintf('%s\n',msgs{:});...
                        sprintf('\n')};
                write_log(logfid2,experiment,s)
        end
        if exist('logfid2','var') && logfid2>1
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
movie_name(~success)=[];
out(~success)=[];
expparams(~success)=[];
success(~success)=[];

s='Tracking done';
write_log(logfid0,'',s)
if logfid0>1
  fclose(logfid0);
end

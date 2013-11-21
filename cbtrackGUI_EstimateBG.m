function bgdata = cbtrackGUI_EstimateBG(expdir,moviefile,tracking_params,varargin)

version = '0.1.0';
timestamp = datestr(now,TimestampFormat);

bgdata = struct;
bgdata.cbestimatebg_version = version;
bgdata.cbestimatebg_timestamp = timestamp;

%% parse inputs
ParseCourtshipBowlParams_GUI;
experiment_name = splitdir(expdir,'last');
experiment_name(experiment_name=='_')=' ';

cbparams=getappdata(0,'cbparams');

% read parameters
for i = 1:2:numel(leftovers)-1,  %#ok<USENS>
  if isfield(params,leftovers{i}),
    params.(leftovers{i}) = leftovers{i+1};
  end
end

% %% open log file
% 
% if isfield(cbparams.dataloc,'BG_log'),
%   logfile = fullfile(expdir,cbparams.dataloc.BG_log.filestr);
%   logfid = fopen(logfile,'a');
%   if logfid < 1,
%     warning('Could not open log file %s\n',logfile);
%     logfid = 1;
%   end
% else
%   logfid = 1;
% end
% 
% fprintf(logfid,'\n\n***\nRunning CourtshipBowlEstimateBG version %s analysis_protocol %s at %s\n',version,real_analysis_protocol,timestamp);
% bgdata.analysis_protocol = real_analysis_protocol;
% 
%% open movie

% fprintf(logfid,'Opening movie file %s...\n',moviefile);
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile); %#ok<*NASGU>
im = readframe(1);
setappdata(0,'fidBG',fid)

%% estimate the background model

% compute background model
%fprintf(logfid,'Computing background model for %s...\n',experiment_name);
buffer = readframe(1);
buffer = repmat(buffer,[1,1,tracking_params.bg_nframes]);
frames = round(linspace(1,min(nframes,tracking_params.bg_lastframe),tracking_params.bg_nframes));
hwait=waitbar(0,['Reading frame 0 of ', num2str(tracking_params.bg_nframes)],'CreateCancelBtn','setappdata(0,''cancel_hwait'',1)');
setappdata(0,'cancel_hwait',0)
for i = 1:tracking_params.bg_nframes,
  t = frames(i);
  buffer(:,:,i) = readframe(t);
  waitbar(i/tracking_params.bg_nframes,hwait,['Reading frame ', num2str(i),' of ', num2str(tracking_params.bg_nframes)]);
  if getappdata(0,'cancel_hwait')
    buffer = readframe(1);
    buffer = repmat(buffer,[1,1,tracking_params.bg_nframes]);
    clear t
    delete(hwait)
    return 
  end
end
delete(hwait)
hwait=waitbar(0,['Computing background model for experiment ''',experiment_name,'''']);
bgmed = uint8(median(single(buffer),3));
waitbar(1,hwait);
bgdata.bgmed=bgmed;
delete(hwait)

%savefile = fullfile(expdir,cbparams.dataloc.bgmat.filestr);
% fprintf(logfid,'Saving background model to file %s...\n',savefile);
% if exist(savefile,'file'),
%   delete(savefile);
% end
% save(savefile,'bgmed','version','timestamp','tracking_params');

% bgimagefile = fullfile(expdir,cbparams.dataloc.bgimage.filestr);
% fprintf(logfid,'Saving image of background model to file %s...\n',bgimagefile);
% imwrite(bgmed,bgimagefile,'png');
setappdata(0,'cbparams',cbparams)
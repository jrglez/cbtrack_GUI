function bgdata = cbtrackGUI_EstimateBG(expdir,moviefile,tracking_params,varargin)

version = '0.1.0';
timestamp = datestr(now,TimestampFormat);
out=getappdata(0,'out');

bgdata = struct;
bgdata.cbestimatebg_version = version;
bgdata.cbestimatebg_timestamp = timestamp;

%% parse inputs
ParseCourtshipBowlParams_GUI;
experiment=getappdata(0,'experiment');


% read parameters
for i = 1:2:numel(leftovers)-1,  %#ok<USENS>
  if isfield(params,leftovers{i}),
    params.(leftovers{i}) = leftovers{i+1};
  end
end

%% open log file

logfid=open_log('bg_log',cbparams,out.folder);


fprintf(logfid,'\n\n***\nEstimating background for experiment %s at %s\n',experiment,timestamp);
bgdata.analysis_protocol = real_analysis_protocol;

%% open movie

fprintf(logfid,'Opening movie file %s...\n',moviefile);
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile); %#ok<*NASGU>
im = readframe(1);
setappdata(0,'fidBG',fid)

%% estimate the background model

% compute background model
fprintf(logfid,'Computing background model for %s...\n',experiment);
buffer = readframe(1);
buffer = repmat(buffer,[1,1,tracking_params.bg_nframes]);
frames = round(linspace(1,min(nframes,tracking_params.bg_lastframe),tracking_params.bg_nframes));
hwait=waitbar(0,{['Experiment ',experiment];['Reading frame 0 of ', num2str(tracking_params.bg_nframes)]},'CreateCancelBtn','setappdata(0,''cancel_hwait'',1)');
setappdata(0,'cancel_hwait',0)
for i = 1:tracking_params.bg_nframes,
  t = frames(i);
  buffer(:,:,i) = readframe(t);
  waitbar(i/tracking_params.bg_nframes,hwait,{['Experiment ',experiment];['Reading frame ', num2str(i),' of ', num2str(tracking_params.bg_nframes)]});
  if getappdata(0,'cancel_hwait')
    buffer = readframe(1);
    buffer = repmat(buffer,[1,1,tracking_params.bg_nframes]);
    clear t
    delete(hwait)
    return 
  end
end
delete(hwait)
hwait=waitbar(0,['Computing background model for experiment ''',experiment,'''']);
bgmed = uint8(median(single(buffer),3));
waitbar(1,hwait);
bgdata.bgmed=bgmed;
delete(hwait)
bgdata.isnew=true;

fprintf(logfid,'Finished computting the Background at %s.\n***\n',datestr(now,'yyyymmddTHHMMSS'));
if logfid > 1,
  fclose(logfid);
end
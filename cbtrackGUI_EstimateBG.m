function bgdata = cbtrackGUI_EstimateBG(expdir,moviefile,tracking_params,varargin)

version = '0.1.0';
timestamp = datestr(now,TimestampFormat);

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

logfid=open_log('bg_log');

s=sprintf('\n\n***\nEstimating background for experiment %s at %s\n',experiment,timestamp);
write_log(logfid,experiment,s)
bgdata.analysis_protocol = real_analysis_protocol;

%% open movie

s=sprintf('Opening movie file %s...\n',moviefile);
write_log(logfid,experiment,s)
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile); %#ok<*NASGU>
im = readframe(1);
im_class = class(im);

%% estimate the background model

% compute background model
s=sprintf('Computing background model for %s...\n',experiment);
write_log(logfid,experiment,s)
buffer = readframe(1);
buffer = repmat(buffer,[1,1,tracking_params.bg_nframes]);
frames = round(linspace(1,min(nframes,tracking_params.bg_lastframe),tracking_params.bg_nframes));
hwait=waitbar(0,{['Experiment ',experiment];['Reading frame 0 of ', num2str(tracking_params.bg_nframes)]},'CreateCancelBtn','cancel_waitbar');
for i = 1:tracking_params.bg_nframes,
  if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')
    bgdata=[];
    return
  end
  t = frames(i);
  buffer(:,:,i) = readframe(t);
%   bufferi = readframe(t);
%   if any(tracking_params.eq_method==[1,2])
%     H0=getappdata(0,'H0');
%     bufferi=histeq(uint8(bufferi),H0);
%   elseif tracking_params.eq_method==3
%     bufferi=eq_image(bufferi);
%   end
%   bufferi = double(bufferi)./vign;
%   buffer(:,:,i) = bufferi;
  waitbar(i/tracking_params.bg_nframes,hwait,{['Experiment ',experiment];['Reading frame ', num2str(i),' of ', num2str(tracking_params.bg_nframes)]});
end
delete(hwait)
hwait=waitbar(0,['Computing background model for experiment ''',experiment,'''']);
bgmed = median(single(buffer),3);
bgmed = any_class(bgmed,im_class);

waitbar(1,hwait);
bgdata.bgmed=bgmed;
delete(hwait)
bgdata.isnew=true;

s=sprintf('Finished computting the Background at %s.\n***\n',datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,experiment,s)
if logfid > 1,
  fclose(logfid);
end

if exist('fid','var') && ~isempty(fid)&&  fid > 0,
    try
        fclose(fid);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',ME.message],'Warning','warn')
    end
end

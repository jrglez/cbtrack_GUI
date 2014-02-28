function [trx,wingtrxcurr,perframedata,wingplotdata,info,units,debugdata] = TrackWingsHelper_GUI_old(handles,trx,moviefile,bgmodel,isarena,params,debugdata,varargin)
global ISPAUSE
info.trackwings_version = '0.1';
info.trackwings_timestamp = datestr(now,'yyyymmddTHHMMSS');
out=getappdata(0,'out');
trackdata=getappdata(0,'trackdata');
%% parse parameters
[firstframe,debugdata.DEBUG,framestrack,perframedata] = ...
  myparse(varargin,...
  'firstframe',1,...
  'debug',false,...
  'framestrack',[],...
  'perframedata',[]);

restart=getappdata(0,'restart');

% choose histogram bins for wing pixel angles for fitting wings
params.edges_dthetawing = linspace(-params.max_wingpx_angle,params.max_wingpx_angle,params.nbins_dthetawing+1);
params.centers_dthetawing = (params.edges_dthetawing(1:end-1)+params.edges_dthetawing(2:end))/2;
params.wing_peak_min_frac = 1/params.nbins_dthetawing*params.wing_peak_min_frac_factor;

% morphology structural elements
params.se_dilate_body = strel('disk',params.radius_dilate_body);
params.se_open_wing = strel('disk',params.radius_open_wing);

% for sub-bin accuracy in fitting the wings
params.subbin_x = (-params.wing_radius_quadfit_bins:params.wing_radius_quadfit_bins)';    

% units for everything
units = struct(...
  'nwingsdetected',parseunits('unit'),...
  'wing_areal',parseunits('px^2'),...
  'wing_arear',parseunits('px^2'),...
  'wing_trough_angle',parseunits('rad'));

%% open movie

[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile); %#ok<NASGU,ASGLU>
[nr,nc,~] = size(readframe(1));
nflies = numel(trx);
npx = nr*nc; %#ok<NASGU>

%% allocate

[XGRID,YGRID] = meshgrid(1:nc,1:nr);



% trajectories for the current frame
trxcurr = struct(...
  'x',cell(1,nflies),...
  'y',cell(1,nflies),...
  'a',cell(1,nflies),...
  'b',cell(1,nflies),...
  'theta',cell(1,nflies),...
  'firstframe',cell(1,nflies),...
  'endframe',cell(1,nflies),...
  'nframes',cell(1,nflies),...
  'off',cell(1,nflies)...
  );
  

%% start tracking

wingtrxprev = [];

if any([ischar(restart),ISPAUSE]) && isfield(trackdata,'twing'),
  trx=trackdata.trx;
  perframedata=trackdata.perframedata;
  wingplotdata=trackdata.wingplotdata;
  t=trackdata.twing;
  wingtrxprev=trackdata.wingtrxprev;
  fprintf('Restarting tracking at frame %d...\n',t);
  startframe = t;
else
  startframe = firstframe;
end

if isempty(perframedata),
  perframedata = struct;
  perframedata.nwingsdetected = cell(1,nflies);
  perframedata.wing_areal = cell(1,nflies);
  perframedata.wing_arear = cell(1,nflies);
  perframedata.wing_trough_angle = cell(1,nflies);
  
  for fly = 1:nflies,
    trx(fly).wing_anglel = nan(1,trx(fly).nframes);
    trx(fly).wing_angler = nan(1,trx(fly).nframes);
    perframedata.nwingsdetected{fly} = nan(1,trx(fly).nframes);
    perframedata.wing_areal{fly} = nan(1,trx(fly).nframes);
    perframedata.wing_arear{fly} = nan(1,trx(fly).nframes);
    perframedata.wing_trough_angle{fly} = nan(1,trx(fly).nframes);
  end
end

if isempty(framestrack),
  framestrack = max(startframe,min([trx.firstframe])):max([trx.endframe]);
end

%% initialize debug plots
if debugdata.DEBUG 
  if ~isfield(debugdata,'colors') 
    debugdata.colors = hsv(nflies);
    debugdata.colors = debugdata.colors(randperm(nflies),:);
  end
  if ~exist('wingplotdata','var')
    wingplotdata.idxfore_thresh=cell(debugdata.nframestrack,1);
    wingplotdata.fore2flywing=cell(debugdata.nframestrack,1);
  end
elseif  ~debugdata.DEBUG
      debugdata.hwait=waitbar(0,'Tracking wings','CreateCancelBtn','setappdata(0,''cancel_hwait'',1)');
end
if ~isfield(debugdata,'framestrack')
debugdata.framestrack=framestrack;
debugdata.nframestrack=length(debugdata.framestrack);
end
if ~isfield(debugdata,'framestracked')
framestracked=[];
debugdata.framestracked=framestracked;
debugdata.nframestracked=0;
end

%for t = round(linspace(max(firstframe,min([trx.firstframe])),max([trx.endframe]),50)),
%for t = max(startframe,min([trx.firstframe])):max([trx.endframe]),

debugdata.lastframe=framestrack(end)-framestrack(1)+1;
ISPAUSE=false;
for t = framestrack(:)',
setappdata(0,'twing',t);
  if ISPAUSE
      debugdata.track=0;%#ok<UNRCH>
      fprintf('Wing tracking paused at frame %i at %s...\n',t,datestr(now,'yyyymmddTHHMMSS')); 
      break; 
  end
  debugdata.framestracked=[debugdata.framestracked,t];
  debugdata.nframestracked=length(debugdata.framestracked);

  for fly = 1:nflies,
     if t < trx(fly).firstframe || t > trx(fly).endframe,
      trxcurr(fly).x = [];
      trxcurr(fly).y = [];
      trxcurr(fly).a = [];
      trxcurr(fly).b = [];
      trxcurr(fly).theta = [];
     else
       i = trx(fly).off+t;
       trxcurr(fly).x = trx(fly).x(i);
       trxcurr(fly).y = trx(fly).y(i);
       trxcurr(fly).a = trx(fly).a(i);
       trxcurr(fly).b = trx(fly).b(i);
       trxcurr(fly).theta = trx(fly).theta(i);
    end
  end
  
  % fit this frame
  im = double(readframe(t));
  if debugdata.DEBUG,
    debugdata.im = im;
  end
  if debugdata.DEBUG
      set(handles.text_info,'String',['Tracking wings: frame ',num2str(t),' (',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),', ',num2str(debugdata.nframestracked*100/(debugdata.nframestrack),'%.1f'),'%).'])
  else
      waitbar(debugdata.nframestracked/debugdata.nframestrack,debugdata.hwait,['Tracking wings: frame ',num2str(t),' (',num2str(debugdata.nframestracked),' of ',num2str(debugdata.nframestrack),')']);
  end
  [wingtrxcurr,debugdata,idxfore_thresh,fore2flywing] = TrackWingsOneFrame_GUI_old(im,bgmodel,isarena,trxcurr,wingtrxprev,params,XGRID,YGRID,debugdata);
  
  % store results
  for fly = 1:nflies,
    
    if t < trx(fly).firstframe || t > trx(fly).endframe,
      continue;
    end
    i = trx(fly).off+t;
    
    trx(fly).wing_anglel(i) = wingtrxcurr(fly).wing_anglel;
    trx(fly).wing_angler(i) = wingtrxcurr(fly).wing_angler;
    
    perframedata.nwingsdetected{fly}(i) = wingtrxcurr(fly).nwingsdetected;
    perframedata.wing_areal{fly}(i) = wingtrxcurr(fly).wing_areal;
    perframedata.wing_arear{fly}(i) = wingtrxcurr(fly).wing_arear;
    perframedata.wing_trough_angle{fly}(i) = wingtrxcurr(fly).wing_trough_angle;    
  end
  
  wingplotdata.idxfore_thresh{debugdata.nframestracked}=idxfore_thresh;
  wingplotdata.fore2flywing{debugdata.nframestracked}=fore2flywing;
  
  if ~isdeployed && mod(t,5000) == 0,
    trackdata.trackwings_timestamp2 = info.trackwings_timestamp;
    trackdata.trackwings_version = info.trackwings_version;
    trackdata.trx = trx;
    trackdata.perframedata = perframedata;
    trackdata.perframeunits = units;
    trackdata.twing = t;
    trackdata.wingtrxprev = wingtrxcurr;
    save(out.temp_full,'trackdata','-append')
  end

  wingtrxprev = wingtrxcurr;
end
if isfield(debugdata,'hwait')
    delete(debugdata.hwait(ishandle(debugdata.hwait)))
end

%% add in x, y positions for plotting

for fly = 1:nflies,    
  trx(fly).xwingl = trx(fly).x + 4*trx(fly).a.*cos(trx(fly).theta+ pi+trx(fly).wing_anglel);
  trx(fly).ywingl = trx(fly).y + 4*trx(fly).a.*sin(trx(fly).theta+ pi+trx(fly).wing_anglel);
  trx(fly).xwingr = trx(fly).x + 4*trx(fly).a.*cos(trx(fly).theta+ pi+trx(fly).wing_angler);
  trx(fly).ywingr = trx(fly).y + 4*trx(fly).a.*sin(trx(fly).theta+ pi+trx(fly).wing_angler);
end

%% clean up
fclose(fid);
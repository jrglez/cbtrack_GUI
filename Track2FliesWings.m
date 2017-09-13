function trackdata = Track2FliesWings(handles,moviefile,bgmed,roidata,...
  params,Wparams,varargin)

global ISPAUSE
trackdata=getappdata(0,'trackdata');

version = '0.1';
timestamp = datestr(now,TimestampFormat);

experiment=getappdata(0,'experiment');
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');

[restart] = myparse(varargin,...
  'restart','');

trxExternal = getappdata(0,'trxExternal');
tfTrxExternal = ~isempty(trxExternal);

dorestart = false;
if ~isempty(restart) && ~isempty(trackdata)
  restartstage = trackdata.stage;
  dorestart = true;
else
  restartstage = '';
end

logfid=open_log('track_log');

SetBackgroundTypes;
flycolors = {'r','b'};
stages = {'maintracking','reformat','chooseorientations','trackwings1','assignids','chooseorientations2','trackwings2'};

%% open movie

write_log(logfid,getappdata(0,'experiment'),sprintf('Opening movie...\n'));
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile);

if tfTrxExternal
  write_log(logfid,getappdata(0,'experiment'),sprintf('Using external trx.\n'));
end

%% initialize

nrois = roidata.nrois;
nframes_track = min(params.lastframetrack,nframes)-params.firstframetrack+1;

if ~dorestart && any([~ISPAUSE,~isfield(trackdata,'trxx')]),
  write_log(logfid,getappdata(0,'experiment'),sprintf('Allocating...\n'));
  trackdata = struct;
  trxx = nan(2,nrois,nframes_track);
  trxy = nan(2,nrois,nframes_track);
  trxa = nan(2,nrois,nframes_track);
  trxb = nan(2,nrois,nframes_track);
  trxtheta = nan(2,nrois,nframes_track);
  trxwing_anglel = nan(2,nrois,nframes_track,2^2);
  trxwing_angler = nan(2,nrois,nframes_track,2^2);
  trxarea = nan(2,nrois,nframes_track);
  time_stamp = nan(1,nframes_track);
  istouching = nan(nrois,nframes_track);
  gmm_isbadprior = nan(nrois,nframes_track);
  trxpriors=nan(2,nrois,nframes_track);
  
  perframedata = struct('nwingsdetected',nan(2,nrois,nframes_track,2^2),...
    'wing_areal',nan(2,nrois,nframes_track,2^2),'wing_arear',nan(2,nrois,nframes_track,2^2),...
    'wing_trough_angle',nan(2,nrois,nframes_track,2^2));
  
  pred = struct('mix',gmm(2,2,'full'),'x',nan(2,1),'y',nan(2,1),'theta',nan(2,1),...
    'area',nan(2,1),'isfirstframe',true);
  pred = repmat(pred,[1,nrois]);
  
  trxcurr = struct('x',nan(2,1),'y',nan(2,1),'a',nan(2,1),'b',nan(2,1),...
    'theta',nan(2,1),'area',nan(2,1),'wing_anglel',nan(2,1,2^2),...
    'wing_angler',nan(2,1,2^2),'istouching',nan,'gmm_isbadprior',nan,...
    'priors',nan(1,2));
  trxcurr = repmat(trxcurr,[1,roidata.nrois]);
  if tfTrxExternal
    FLDSKEEP = {'x' 'y' 'a' 'b' 'theta' 'off'};
    fldsRm = setdiff(fieldnames(trxExternal),FLDSKEEP);
    trxExternal = rmfield(trxExternal,fldsRm);
    assert(roidata.nrois==1,'Only 1 ROI supported.');
  end
  
  pfdatacurr = struct('nwingsdetected',nan(2,1,2^2),'wing_areal',nan(2,1,2^2),...
    'wing_arear',nan(2,1,2^2),'wing_trough_angle',nan(2,1,2^2));
  pfdatacurr = repmat(pfdatacurr,[1,roidata.nrois]);
  
  handles.hell = nan(2,nrois);
  handles.htrx = nan(2,nrois);
  handles.him = nan;
elseif dorestart || ISPAUSE
  trxx = trackdata.trxx;
  trxy = trackdata.trxy;
  trxa = trackdata.trxa;
  trxb = trackdata.trxb;
  trxtheta = trackdata.trxtheta;
  trxwing_anglel = trackdata.trxwing_anglel;
  trxwing_angler = trackdata.trxwing_angler;
  trxarea = trackdata.trxarea;
  time_stamp = trackdata.time_stamp;
  istouching = trackdata.istouching;
  gmm_isbadprior = trackdata.gmm_isbadprior;
  pred = trackdata.pred;
  trxcurr = trackdata.trxcurr;
  assert(~tfTrxExternal);
  perframedata = trackdata.perframedata;
end
trackdata.trac2flieswings_version = version;
trackdata.track2flieswing_timestamp = timestamp;

%% set parameters
% choose histogram bins for wing pixel angles for fitting wings
Wparams.edges_dthetawing = linspace(-Wparams.max_wingpx_angle,Wparams.max_wingpx_angle,Wparams.nbins_dthetawing+1);
Wparams.centers_dthetawing = (Wparams.edges_dthetawing(1:end-1)+Wparams.edges_dthetawing(2:end))/2;
Wparams.wing_peak_min_frac = 1/Wparams.nbins_dthetawing*Wparams.wing_peak_min_frac_factor;

% morphology structural elements
params.se_open_body=strel('disk',params.radius_open_body);
Wparams.se_dilate_body = strel('disk',Wparams.radius_dilate_body);
Wparams.se_open_wing = strel('disk',Wparams.radius_open_wing);

% for sub-bin accuracy in fitting the wings
Wparams.subbin_x = (-Wparams.wing_radius_quadfit_bins:Wparams.wing_radius_quadfit_bins)';
assert(numel(Wparams.subbin_x)==3,'subbin must have 3 coeffs for quadratic fit');
%% loop over frames

stage = 'maintracking';

if ~dorestart || find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  
  if all([dorestart, strcmp(stage,restartstage)]) || all([ISPAUSE,isfield(trackdata,'t')])
    startframe = trackdata.t;
  else
    startframe = params.firstframetrack;
  end
  
  ISPAUSE=false;
  
  write_log(logfid,getappdata(0,'experiment'),sprintf('Starting main tracking from frame %i at %s...\n',startframe,datestr(now,'yyyymmddTHHMMSS')));
  if ~params.DEBUG
    setappdata(0,'allow_stop',false)
    hwait=waitbar(0,{['Experiment ',experiment];['Tracking flies: frame ',num2str(startframe),'(0 of ',num2str(nframes_track),')']},'CreateCancelBtn','cancel_waitbar');
  end
  
  vign = getappdata(0,'vign');
  bgmed=double(bgmed);
  
  % Set normalization matrix
  if params.normalize
    normalize=bgmed;
  else
    normalize=ones(size(bgmed));
  end
  
  for t = startframe:min(params.lastframetrack,nframes),
    if ISPAUSE
      write_log(logfid,getappdata(0,'experiment'),sprintf('Main tracking paused at frame %i at %s...\n',t,datestr(now,'yyyymmddTHHMMSS'))); %#ok<UNRCH>
      break;
    end
    iframe = t - params.firstframetrack + 1;
    if mod(iframe,1000) == 0,
      write_log(logfid,getappdata(0,'experiment'),sprintf('Frame %d / %d\n',iframe,nframes_track));
    end
    
    % read in frame
    try
      [im,time_stamp(iframe)] = readframe(t);
    catch
      im = readframe(t);
    end
    
    % resize, equalize and de-vignet
    if any(params.eq_method==[1,2])
      H0=getappdata(0,'H0');
      im=histeq(uint8(im),H0);
    elseif params.eq_method==3
      im=eq_image(im);
    end
    im=double(im)./vign;
    im_rs = imresize(im,1/params.down_factor);
    
    [dbkgd,isfore_body,iswing,isfore_wing] = TrackFlyWings_BackSub(im,...
      bgmed,params,Wparams,normalize);
    
    % track this frame
    pffdataprev = pfdatacurr;
    if tfTrxExternal
      assert(trxExternal(1).off==trxExternal(2).off);
      iTrxExt = t+trxExternal(1).off;
      trxcurrExt = struct(...
        'x',[trxExternal(1).x(iTrxExt); trxExternal(2).x(iTrxExt)],...
        'y',[trxExternal(1).y(iTrxExt); trxExternal(2).y(iTrxExt)],...
        'a',2*[trxExternal(1).a(iTrxExt); trxExternal(2).a(iTrxExt)],...
        'b',2*[trxExternal(1).b(iTrxExt); trxExternal(2).b(iTrxExt)],...
        'theta',[trxExternal(1).theta(iTrxExt); trxExternal(2).theta(iTrxExt)],...
        'area',nan(2,1),...
        'wing_anglel',nan(2,1,4),...
        'wing_angler',nan(2,1,4),...
        'istouching',nan,...
        'gmm_isbadprior',nan,...
        'priors',nan(1,2));
      trxprev = trxcurr; % In this branch, trxcurr is guaranteed to be 
                           % "empty"/init trxcurr. We still need to pass
                           % this in as this is used for initializtion
                           % within
    else
      trxcurrExt = [];
      trxprev = trxcurr;
    end
    % waitbar(t/min(params.lastframetrack,nframes),hwait, ['Tracking frame ',num2str(t),' of ', num2str(min(params.lastframetrack,nframes))]);
    [trxcurr,pred,pfdatacurr] = Track2FliesWings1Frame(im_rs,dbkgd,...
      isfore_body,iswing,isfore_wing,pred,trxprev,pffdataprev,roidata,...
      params,Wparams,'trxcurrExt',trxcurrExt);
    
    trxx(:,:,iframe) = cat(2,trxcurr.x);
    trxy(:,:,iframe) = cat(2,trxcurr.y);
    trxa(:,:,iframe) = cat(2,trxcurr.a);
    trxb(:,:,iframe) = cat(2,trxcurr.b);
    trxwing_anglel(:,:,iframe,:) = cat(2,trxcurr.wing_anglel);
    trxwing_angler(:,:,iframe,:) = cat(2,trxcurr.wing_angler);
    trxtheta(:,:,iframe) = cat(2,trxcurr.theta);
    trxarea(:,:,iframe) = cat(2,trxcurr.area);
    istouching(:,iframe) = cat(1,trxcurr.istouching);
    gmm_isbadprior(:,iframe) = cat(1,trxcurr.gmm_isbadprior);
    trxpriors(:,:,iframe)=cat(1,trxcurr.priors)';
    
    perframedata.nwingsdetected(:,:,iframe,:) = cat(2,pfdatacurr.nwingsdetected);
    perframedata.wing_areal(:,:,iframe,:) = cat(2,pfdatacurr.wing_areal);
    perframedata.wing_arear(:,:,iframe,:) = cat(2,pfdatacurr.wing_arear);
    perframedata.wing_trough_angle(:,:,iframe,:) = cat(2,pfdatacurr.wing_trough_angle);
    
    % plot
    
    if params.DEBUG,
      hold on
      set(handles.video_img,'CData',im_rs);
      isnewplot = false;
      title(num2str(t));
      
      for roii = 1:roidata.nrois,
        
        roibb = roidata.roibbs(roii,:);
        offx = roibb(1)-1;
        offy = roibb(3)-1;
        
        for i = 1:2,
          if isnewplot || ~ishandle(handles.hell(i,roii)),
            handles.hell(i,roii) = drawellipse(trxx(i,roii,iframe)+offx,trxy(i,roii,iframe)+offy,trxtheta(i,roii,iframe),trxa(i,roii,iframe),trxb(i,roii,iframe),[flycolors{i},'-']);
          else
            updateellipse(handles.hell(i,roii),trxx(i,roii,iframe)+offx,trxy(i,roii,iframe)+offy,trxtheta(i,roii,iframe),trxa(i,roii,iframe),trxb(i,roii,iframe));
          end
          if isnewplot || ~ishandle(handles.htrx(i,roii)),
            handles.htrx(i,roii) = plot(squeeze(trxx(i,roii,max(iframe-30,1):iframe)+offx),squeeze(trxy(i,roii,max(iframe-30,1):iframe)+offy),[flycolors{i},'.-']);
          else
            set(handles.htrx(i,roii),'XData',squeeze(trxx(i,roii,max(iframe-30,1):iframe)+offx),...
              'YData',squeeze(trxy(i,roii,max(iframe-30,1):iframe)+offy));
          end
        end
      end
      set(handles.text_info,'String',{['Experiment ',experiment];['Tracking flies: frame ',num2str(t),' (',num2str(iframe),' of ',num2str(nframes_track),', ',num2str(iframe*100/nframes_track,'%.1f'),'%).']})
    else
      if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')
        trackdata=[];
        return
      end
      waitbar(iframe/nframes_track,hwait,{['Experiment ',experiment];['Tracking flies: frame ',num2str(t),' (',num2str(iframe),' of ',num2str(nframes_track),')']});
    end
    
    if params.DEBUG || mod(t,1) == 0,
      drawnow;
    end
    
    if mod(iframe,5000) == 0,
      trackdata.t = t;
      trackdata.trxx = trxx;
      trackdata.trxy = trxy;
      trackdata.trxa = trxa;
      trackdata.trxb = trxb;
      trackdata.trxtheta = trxtheta;
      trackdata.trxwing_anglel = trxwing_anglel;
      trackdata.trxwing_angler = trxwing_angler;
      trackdata.trxarea = trxarea;
      trackdata.time_stamp = time_stamp;
      trackdata.istouching = istouching;
      trackdata.gmm_isbadprior = gmm_isbadprior;
      trackdata.pred = pred;
      trackdata.trxcurr = trxcurr;
      trackdata.trxpriors = trxpriors;
      trackdata.headerinfo = headerinfo;
      trackdata.stage = stage;
      trackdata.perframedata = perframedata;
      if cbparams.track.dosave
        save(out.temp_full,'trackdata','-append')
      end
      write_log(logfid,getappdata(0,'experiment'),sprintf('Saving temporary file after %i frames at %s...\n',iframe,datestr(now,'yyyymmddTHHMMSS')));
    end
    setappdata(0,'t',t);
  end
  if exist('hwait','var') && ishandle(hwait)
    delete(hwait)
  end
  trackdata.t = t-(t~=min(params.lastframetrack,nframes));
  
  trackdata.trxx = trxx;
  trackdata.trxy = trxy;
  trackdata.trxa = trxa;
  trackdata.trxb = trxb;
  trackdata.trxtheta = trxtheta;
  trackdata.trxwing_anglel = trxwing_anglel;
  trackdata.trxwing_angler = trxwing_angler;
  trackdata.trxarea = trxarea;
  trackdata.time_stamp = time_stamp;
  trackdata.istouching = istouching;
  trackdata.gmm_isbadprior = gmm_isbadprior;
  trackdata.pred = pred;
  trackdata.trxcurr = trxcurr;
  trackdata.trxpriors = trxpriors;
  trackdata.headerinfo = headerinfo;
  trackdata.stage = stage;
  trackdata.perframedata = perframedata;
end

%% clean up

% write_log(logfid,getappdata(0,'experiment'),sprintf('Clean up...\n');
if params.DEBUG
  guidata(handles.cbtrackGUI_ROI,handles)
end

if fid > 1,
  try
    fclose(fid);
  catch ME,
    warning('Could not close movie: %s',getReport(ME));
  end
end
if logfid > 1,
  fclose(logfid);
end


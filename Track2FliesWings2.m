function trackdata=Track2FliesWings2(moviefile,bgmed,roidata,params,varargin)
nrois=roidata.nrois;
version = '0.1.1';
timestamp = datestr(now,TimestampFormat);
[restart] = myparse(varargin,'restart',''); %[restart,tmpfilename,logfid] = myparse(varargin,'restart','','tmpfilename',tmpfilename,'logfid',1);
SetBackgroundTypes;
stages = {'maintracking','reformat','chooseorientations','assignids','chooseorientations2','trackwings','realunits','arena','end'};

logfid=open_log('track_log');

%% open movie

write_log(logfid,getappdata(0,'experiment'),sprintf('Opening movie for header info...\n'));
[~,~,~,headerinfo] = get_readframe_fcn(moviefile);

trackdata=getappdata(0,'trackdata');

restartstage = trackdata.stage;
if ~isempty(restart),
  write_log(logfid,getappdata(0,'experiment'),sprintf('Restarting from stage %s...\n',trackdata.stage));
end
t=trackdata.t;
nframes_track = t - params.firstframetrack + 1;

stage = 'reformat';

if isfield(headerinfo,'timestamps'),
  timestamps = headerinfo.timestamps(1:nframes_track);
elseif ~all(isnan(trackdata.time_stamp))
  timestamps = trackdata.time_stamp;
elseif isfield(headerinfo,'FrameRate'),
  timestamps = (0:nframes_track-1)/headerinfo.FrameRate;
elseif isfield(headerinfo,'fps'),
  timestamps = (0:nframes_track-1)/headerinfo.fps;
else
  warning('No frame rate info found for movie');
  timestamps = nan(1,nframes_track);
end
nflies = nansum(roidata.nflies_per_roi);
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages))
  %% correct for bounding box of rois
  trackdata.stage=stage;
  % initialize
  trxx = trackdata.trxx(:,:,1:nframes_track);
  trxy = trackdata.trxy(:,:,1:nframes_track);
  trxa = trackdata.trxa(:,:,1:nframes_track);
  trxb = trackdata.trxb(:,:,1:nframes_track);
  trxtheta = trackdata.trxtheta(:,:,1:nframes_track);
  trxwing_anglel = trackdata.trxwing_anglel(:,:,1:nframes_track,:);
  trxwing_angler = trackdata.trxwing_angler(:,:,1:nframes_track,:);
  timestamps = timestamps(1:nframes_track);
  istouching = trackdata.istouching(:,1:nframes_track);
  gmm_isbadprior = trackdata.gmm_isbadprior(:,1:nframes_track);
  nwingsdetected = trackdata.perframedata.nwingsdetected(:,:,1:nframes_track,:);
  wing_areal = trackdata.perframedata.wing_areal(:,:,1:nframes_track,:);
  wing_arear = trackdata.perframedata.wing_arear(:,:,1:nframes_track,:);
  wing_trough_angle = trackdata.perframedata.wing_trough_angle(:,:,1:nframes_track,:);
  
  write_log(logfid,getappdata(0,'experiment'),sprintf('Correcting for ROI bounding boxes...\n'));
  for roii = 1:nrois,
    roibb = roidata.roibbs(roii,:);
    trxx(:,roii,:) = trxx(:,roii,:) + roibb(1) - 1;
    trxy(:,roii,:) = trxy(:,roii,:) + roibb(3) - 1;
  end
  
  %% reformat
  
  write_log(logfid,getappdata(0,'experiment'),sprintf('Reformatting...\n'));
  
  trackdata.tracktwoflies_version = version;
  trackdata.tracktwoflies_timestamp = timestamp;
  trackdata.timestamps = timestamps;
  
  trx = struct;
  trx = repmat(trx,[nflies,1]);
  perframedata.nwingsdetected = cell(1,nansum(roidata.nflies_per_roi));
  perframedata.wing_areal = cell(1,nansum(roidata.nflies_per_roi));
  perframedata.wing_arear = cell(1,nansum(roidata.nflies_per_roi));
  perframedata.wing_trough_angle = cell(1,nansum(roidata.nflies_per_roi));
  trackdata.s = nan(nframes_track,nflies);
  
  j = 1;
  fly2roiid = [];
  for i = 1:nrois,
    if isnan(roidata.nflies_per_roi(i)),
      continue;
    end
    for jj = 1:roidata.nflies_per_roi(i),
      trx(j).x = reshape(trxx(jj,i,:),[1,nframes_track]);
      trx(j).y = reshape(trxy(jj,i,:),[1,nframes_track]);
      % saved quarter-major, quarter-minor axis
      trx(j).a = reshape(trxa(jj,i,:)/2,[1,nframes_track]);
      trx(j).b = reshape(trxb(jj,i,:)/2,[1,nframes_track]);
      trx(j).theta = reshape(trxtheta(jj,i,:),[1,nframes_track]);
      trx(j).wing_anglel = reshape(trxwing_anglel(jj,i,:,:),[1,nframes_track,4]);
      trx(j).wing_angler = reshape(trxwing_angler(jj,i,:,:),[1,nframes_track,4]);
      
      trx(j).firstframe = params.firstframetrack;
      trx(j).endframe = params.firstframetrack+nframes_track-1;
      trx(j).nframes = nframes_track;
      trx(j).off = 1-params.firstframetrack;
      trx(j).roi = i;
      trx(j).arena = struct;
      
      perframedata.nwingsdetected{j} = reshape(nwingsdetected(jj,i,:,:),[1,nframes_track,4]);
      perframedata.wing_areal{j} = reshape(wing_areal(jj,i,:,:),[1,nframes_track,4]);
      perframedata.wing_arear{j} = reshape(wing_arear(jj,i,:,:),[1,nframes_track,4]);
      perframedata.wing_trough_angle{j} = reshape(wing_trough_angle(jj,i,:,:),[1,nframes_track,4]);
      
      if ~roidata.isall,
        trx(j).arena.arena_radius_mm = roidata.radii(i);
        trx(j).arena.arena_center_mm_x = roidata.centerx(i);
        trx(j).arena.arena_center_mm_y = roidata.centery(i);
      end
      %trx(j).roipts = rois{i};
      %trx(j).roibb = roibbs(i,:);
      trx(j).moviefile = moviefile;
      trx(j).dt = diff(timestamps);
      trx(j).timestamps = timestamps;
      fly2roiid(j) = jj;  %#ok<AGROW>
      j = j + 1;
    end
  end
  trackdata.trx = trx;
  trackdata.perframedata = perframedata;
  trackdata.istouching = istouching;
  trackdata.gmm_isbadprior = gmm_isbadprior;
  trackdata.fly2roiid = fly2roiid;
  trackdata.nframetrack = nframes_track;
  trackdata.firstframetrack = params.firstframetrack;
  trackdata.lastframetrack = t;
  trackdata.stage=stages{find(strcmp(stage,stages))+1};
  trackdata=rmfield(trackdata,{'trxx','trxy','trxa','trxb','trxtheta','trxwing_anglel','trxwing_angler','trxarea','trxpriors','trxcurr','pred'});
  setappdata(0,'trackdata',trackdata)
  if params.dosave
    savetemp({'trackdata'})
  end
end

%%
trxExternal = getappdata(0,'trxExternal');
tfTrxExternal = ~isempty(trxExternal);
if tfTrxExternal
  write_log(logfid,getappdata(0,'experiment'),...
    sprintf('TrxExternal is on. Skipping ''chooseorientations'', ''assignids'', ''chooseorientations2''.\n'));
end

%% resolve head/tail ambiguity
if ~tfTrxExternal
  
stage = 'chooseorientations';
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  write_log(logfid,getappdata(0,'experiment'),sprintf('Choosing orientations 1...\n'));
  setappdata(0,'allow_stop',false)
  hwait = waitbar(0,{['Experiment ',getappdata(0,'experiment')];'Computing fly orientations'},'CreateCancelBtn','cancel_waitbar');
  for roii = 1:roidata.nrois
    nfpr = roidata.nflies_per_roi(roii);
    if isnan(nfpr)
      continue;
    end
    isroi = [trackdata.trx.roi]==roii;
    x = vertcat(trackdata.trx(isroi).x);
    y = vertcat(trackdata.trx(isroi).y);
    theta = vertcat(trackdata.trx(isroi).theta);
    
    dx = [zeros(nfpr,1),diff(x,1,2)];
    dy = [zeros(nfpr,1),diff(y,1,2)];
    v = sqrt(dx.^2 + dy.^2);
    phi = atan2(dy,dx);
    
    
    % don't use velocity when touching, just keep angle consistent
    % to do this, set max_velocity_angle_weight to 0 when flies are touching
    istouching = repmat(trackdata.istouching(roii,:) > .5,[nfpr,1]);
    isjumping = v>=params.choose_orientations_min_jump_speed;
    isjumping = [false(nfpr,1),isjumping(:,1:end-2)|isjumping(:,3:end),false(nfpr,1)];
    weight_phi = min(params.choose_orientations_max_velocity_angle_weight,params.choose_orientations_velocity_angle_weight.*v);
    weight_phi(istouching|isjumping) = 0;
    
    % also don't rely on change in orientation as much when the fly is circular
    a = vertcat(trackdata.trx(isroi).a);
    b = vertcat(trackdata.trx(isroi).b);
    ecc = b ./ a;
    parama = (params.choose_orientations_min_ecc_factor-1)/(1-params.choose_orientations_max_ecc_confident);
    paramb = params.choose_orientations_min_ecc_factor - parama;
    ecc_factor = parama.*ecc + paramb;
    weight_theta = max(params.choose_orientations_min_ecc_factor,min(1,ecc_factor)) .* params.choose_orientations_weight_theta;
    
    wing_areal = vertcat(trackdata.perframedata.wing_areal{isroi});
    wing_arear = vertcat(trackdata.perframedata.wing_arear{isroi});
    Warea = nansum(cat(4,wing_areal,wing_arear),4);
    sqrtWarea = squeeze(sqrt(nansum(Warea,1)));
    weight_Warea = params.choose_orientations_weight_Warea*ones(size(sqrtWarea));
    
    [~,s] = choose_orientations3(theta,phi,sqrtWarea,weight_theta,weight_phi,weight_Warea);
    
    flies = find(isroi);
    for j = 1:nfpr
      trackdata.s(:,flies(j)) = s;
    end
    
    waitbar(roii/roidata.nrois,hwait)
  end
  
  if ishandle(hwait)
    delete(hwait)
  end
  
  trackdata.stage=stages{find(strcmp(stage,stages))+1};
  setappdata(0,'trackdata',trackdata)
  if params.dosave
    savetemp({'trackdata'})
  end
end

%% assign identities based on size of something

stage = 'assignids';

if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  write_log(logfid,getappdata(0,'experiment'),...
    sprintf('Assigning identities based on %s...\n',params.assignidsby));
  
  assignids_nflips = nan(1,nrois);
  switch params.assignidsby,
    case 'size',
      mudatafit = nan(2,3,nrois);
      sigmadatafit = nan(2,3,nrois);
    case 'wingsize',
      mudatafit = nan(2,1,nrois);
      sigmadatafit = nan(2,1,nrois);
      wingarea = cell(1,nflies);
      for i = 1:nflies,
        winga_areal = trackdata.perframedata.wing_areal{i};
        winga_arear = trackdata.perframedata.wing_arear{i};
        s = sub2ind(size(winga_areal),ones(nframes_track,1),(1:nframes_track)',trackdata.s(:,i));
        wingarea{i} = winga_areal(s)'+winga_arear(s)';
      end
    otherwise,
      error('Unknown assignidsby value');
  end
  niters_assignids_em = nan(1,nrois);
  cost_assignids = nan(1,nrois);
  sigmamotionfit = nan(1,nrois);
  idsfit = nan(2,nrois,nframes_track);
  
  oldtrx = trackdata.trx;
  if isfield(trackdata,'perframedata'),
    perframefns = fieldnames(trackdata.perframedata);
    oldperframedata = trackdata.perframedata;
  end
  trxfns = intersect({'x','y','a','b','theta'},fieldnames(trackdata.trx));
  trxfnsW = intersect({'xwingl','ywingl','xwingr','ywingr','wing_anglel','wing_angler'},fieldnames(trackdata.trx));
  setappdata(0,'allow_stop',false)
  hwait = waitbar(0,{['Experiment ',getappdata(0,'experiment')];'Asigning IDs'},'CreateCancelBtn','cancel_waitbar');
  for roii = 1:nrois,
    if getappdata(0,'iscancel') || getappdata(0,'isskip')
      trackdata = [];
      return
    end
    waitbar(roii/nrois,hwait)
    if isnan(roidata.nflies_per_roi(roii)) || roidata.nflies_per_roi(roii) < 2,
      continue;
    end
    
    flies = find([trackdata.trx.roi]==roii);
    
    x = cat(1,trackdata.trx(flies).x);
    y = cat(1,trackdata.trx(flies).y);
    appearanceweight = double(~trackdata.istouching(roii,:));
    
    switch params.assignidsby,
      case 'size',
        a = cat(1,trackdata.trx(flies).a);
        b = cat(1,trackdata.trx(flies).b);
        area = a.*b.*pi*4;
        iddata = cat(3,area,a,b);
      case 'wingsize',
        iddata = cat(1,wingarea{flies});
      otherwise,
        error('Unknown assignidsby value');
    end
    [idsfit_curr,mudatafit_curr,sigmadatafit_curr,sigmamotionfit_curr,cost_curr,niters_curr] = ...
      AssignIdentities_GUI(x,y,iddata,'vel_dampen',params.err_dampen_pos,'appearanceweight',appearanceweight);
    assignids_nflips(roii) = nnz(idsfit_curr(1,1:end-1)~=idsfit_curr(1,2:end));
    write_log(logfid,getappdata(0,'experiment'),sprintf('Roi %d, flipped ids %d times\n',roii,assignids_nflips(roii)));
    
    tf12 = idsfit_curr==1 | idsfit_curr==2;
    assert(all(tf12(:)),'Expect two targets.');
    for i = 1:2,
      for j = 1:2,
        idx = idsfit_curr(i,:)==j;
        if i==j
          idxWingCombs = 1:4;
        else
          idxWingCombs = [1 3 2 4];
        end
        
        for k = 1:numel(trxfns),
          trackdata.trx(flies(i)).(trxfns{k})(idx) = oldtrx(flies(j)).(trxfns{k})(idx);
        end
        for k = 1:numel(trxfnsW),
          assert(size(trackdata.trx(flies(i)).(trxfnsW{k}),3)==4,...
            'Expected 4 combinations.');
          trackdata.trx(flies(i)).(trxfnsW{k})(1,idx,:) = ...
            oldtrx(flies(j)).(trxfnsW{k})(1,idx,idxWingCombs);
        end
        if isfield(trackdata,'perframedata'),
          for k = 1:numel(perframefns),
            tmp = trackdata.perframedata.(perframefns{k}){flies(i)};
            assert(isequal(size(tmp),[1 numel(idx) 4]),...
              'Expected 4 combinations.');
            trackdata.perframedata.(perframefns{k}){flies(i)}(1,idx,:) = ...
              oldperframedata.(perframefns{k}){flies(j)}(1,idx,idxWingCombs);
          end
        end
      end
    end
    
    mudatafit(:,:,roii) = mudatafit_curr;
    sigmadatafit(:,:,roii) = sigmadatafit_curr;
    niters_assignids_em(roii) = niters_curr;
    cost_assignids(roii) = cost_curr;
    sigmamotionfit(roii) = sigmamotionfit_curr;
    idsfit(:,roii,:) = idsfit_curr;
  end
  if ishandle(hwait)
    delete(hwait)
  end
  
  idx = find(roidata.nflies_per_roi == 2);
  areas_male = mudatafit(1,1,idx);
  areas_female = mudatafit(2,1,idx);
  area_thresh = (mean(areas_male)+mean(areas_female))/2;
  
  iRoiSingles = find(roidata.nflies_per_roi == 1);
  typeperroi = cell(1,nrois);
  for iRoi = iRoiSingles(:)'
    fly = find([trackdata.trx.roi]==iRoi);
    % AL: fly need not be scalar? case 'size' implies this, yet case
    % 'wingsize' implies the opposite
    switch params.assignidsby
      case 'size',
        a = cat(1,trackdata.trx(fly).a);
        b = cat(1,trackdata.trx(fly).b);
        areacurr = a.*b.*pi*4;
      case 'wingsize',
        assert(isscalar(fly));
        areacurr = wingarea{fly};
      otherwise,
        error('Unknown assignidsby value');
    end
    meanareacurr = nanmean(areacurr(:));
    write_log(logfid,getappdata(0,'experiment'),sprintf('ROI %d (1 fly): meanarea=%f\n',iRoi,meanareacurr));
    if meanareacurr <= area_thresh,
      typeperroi{iRoi} = params.typesmallval;
    else
      typeperroi{iRoi} = params.typebigval;
    end
  end
  
  trackdata.assignids = struct;
  trackdata.assignids.nflips = assignids_nflips;
  trackdata.assignids.mudatafit = mudatafit;
  trackdata.assignids.sigmadatafit = sigmadatafit;
  trackdata.assignids.niters_em = niters_assignids_em;
  trackdata.assignids.cost = cost_assignids;
  trackdata.assignids.sigmamotionfit = sigmamotionfit;
  trackdata.assignids.idsfit = idsfit;
  
  for i = 1:nflies,
    roii = trackdata.trx(i).roi;
    switch roidata.nflies_per_roi(roii)
      case 2
        if trackdata.fly2roiid(i) == 1,
          trackdata.trx(i).(params.typefield) = repmat({params.typesmallval},[1,nframes_track]);
        else
          trackdata.trx(i).(params.typefield) = repmat({params.typebigval},[1,nframes_track]);
        end
      case 1
        assert(~isempty(typeperroi{roii}));
        trackdata.trx(i).(params.typefield) = repmat(typeperroi(roii),[1,nframes_track]);
      otherwise
        assert(false,'Fly/trx assigned to roi with no flies');
    end
  end
  trackdata.stage=stages{find(strcmp(stage,stages))+1};
  setappdata(0,'trackdata',trackdata)
  if params.dosave
    savetemp({'trackdata'})
  end
end

%% resolve head/tail ambiguity again, since it is pretty quick

% ALXXX 20150626: big cut+paste (in this file)

stage = 'chooseorientations2';
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  write_log(logfid,getappdata(0,'experiment'),sprintf('Choosing orientations 2...\n'));
  isflip = false(nflies,nframes_track);
  hwait = waitbar(0,{['Experiment ',getappdata(0,'experiment')];'Computing fly orientations'},'CreateCancelBtn','cancel_waitbar');
  setappdata(0,'allow_stop',false)
  for roii = 1:roidata.nrois
    nfpr = roidata.nflies_per_roi(roii);
    if isnan(nfpr)
      continue;
    end
    isroi = [trackdata.trx.roi]==roii;
    x = vertcat(trackdata.trx(isroi).x);
    y = vertcat(trackdata.trx(isroi).y);
    theta = vertcat(trackdata.trx(isroi).theta);
    
    dx = [zeros(nfpr,1),diff(x,1,2)];
    dy = [zeros(nfpr,1),diff(y,1,2)];
    v = sqrt(dx.^2 + dy.^2);
    phi = atan2(dy,dx);
    
    
    % don't use velocity when touching, just keep angle consistent
    % to do this, set max_velocity_angle_weight to 0 when flies are touching
    istouching = repmat(trackdata.istouching(roii,:) > .5,[nfpr,1]);
    isjumping = v>=params.choose_orientations_min_jump_speed;
    isjumping = [false(nfpr,1),isjumping(:,1:end-2)|isjumping(:,3:end),false(nfpr,1)];
    weight_phi = min(params.choose_orientations_max_velocity_angle_weight,params.choose_orientations_velocity_angle_weight.*v);
    weight_phi(istouching|isjumping) = 0;
    
    % also don't rely on change in orientation as much when the fly is circular
    a = vertcat(trackdata.trx(isroi).a);
    b = vertcat(trackdata.trx(isroi).b);
    ecc = b ./ a;
    parama = (params.choose_orientations_min_ecc_factor-1)/(1-params.choose_orientations_max_ecc_confident);
    paramb = params.choose_orientations_min_ecc_factor - parama;
    ecc_factor = parama.*ecc + paramb;
    weight_theta = max(params.choose_orientations_min_ecc_factor,min(1,ecc_factor)) .* params.choose_orientations_weight_theta;
    
    wing_areal = vertcat(trackdata.perframedata.wing_areal{isroi});
    wing_arear = vertcat(trackdata.perframedata.wing_arear{isroi});
    Warea = nansum(cat(4,wing_areal,wing_arear),4);
    sqrtWarea = squeeze(sqrt(nansum(Warea,1)));
    weight_Warea = params.choose_orientations_weight_Warea*ones(size(sqrtWarea));
    
    [theta,s,combsTmp] = choose_orientations3(theta,phi,sqrtWarea,weight_theta,weight_phi,weight_Warea);
    
    flies = find(isroi);
    for j = 1:nfpr
      isflip(j,:) = round(abs(modrange(theta(j,:)-trackdata.trx(flies(j)).theta,-pi,pi))/pi) > 0;
      trackdata.trx(flies(j)).theta = theta(j,:);
      write_log(logfid,getappdata(0,'experiment'),sprintf('N. orientation flips = %d\n',nnz(isflip(j,:))));
      trackdata.s(:,flies(j)) = s;
    end
    waitbar(roii/roidata.nrois,hwait)
  end
  
  if ishandle(hwait)
    delete(hwait)
  end
  
  trackdata.stage=stages{find(strcmp(stage,stages))+1};
  
  setappdata(0,'trackdata',trackdata)
  if params.dosave
    savetemp({'trackdata'})
  end
end

end % if ~tfTrxExternal 

%% track wings
stage = 'trackwings';

if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  if params.dotrackwings
    if ~isfield(trackdata,'twing')
      for fly = 1:nflies
        if tfTrxExternal
          s = sub2ind(size(trackdata.trx(fly).wing_anglel),...
            ones(nframes_track,1),(1:nframes_track)',ones(nframes_track,1));
          trxflyOrig = trackdata.trx(fly);
          tdPFDOrig = trackdata.perframedata;
        else
          s = sub2ind(size(trackdata.trx(fly).wing_anglel),...
            ones(nframes_track,1),(1:nframes_track)',trackdata.s(:,fly));
        end
        trackdata.trx(fly).wing_anglel = trackdata.trx(fly).wing_anglel(s)';
        trackdata.trx(fly).wing_angler = trackdata.trx(fly).wing_angler(s)';
        trackdata.trx(fly).xwingl = trackdata.trx(fly).x + ...
          4*trackdata.trx(fly).a.*cos(trackdata.trx(fly).theta+pi+trackdata.trx(fly).wing_anglel);
        trackdata.trx(fly).ywingl = trackdata.trx(fly).y + ...
          4*trackdata.trx(fly).a.*sin(trackdata.trx(fly).theta+pi+trackdata.trx(fly).wing_anglel);
        trackdata.trx(fly).xwingr = trackdata.trx(fly).x + ...
          4*trackdata.trx(fly).a.*cos(trackdata.trx(fly).theta+pi+trackdata.trx(fly).wing_angler);
        trackdata.trx(fly).ywingr = trackdata.trx(fly).y + ...
          4*trackdata.trx(fly).a.*sin(trackdata.trx(fly).theta+pi+trackdata.trx(fly).wing_angler);
        trackdata.perframedata.wing_areal{fly} = trackdata.perframedata.wing_areal{fly}(s);
        trackdata.perframedata.wing_arear{fly} = trackdata.perframedata.wing_arear{fly}(s);
        trackdata.perframedata.wing_trough_angle{fly} = trackdata.perframedata.wing_trough_angle{fly}(s);
        trackdata.perframedata.nwingsdetected{fly} = trackdata.perframedata.nwingsdetected{fly}(s);
        
        if tfTrxExternal
          for wtDebugSval = 2:4
            trxFly = trxflyOrig;
            sTMP = sub2ind(size(trxFly.wing_anglel),...
              ones(nframes_track,1),(1:nframes_track)',...
              repmat(wtDebugSval,nframes_track,1));
            trxFly.wing_anglel = trxFly.wing_anglel(sTMP)';
            trxFly.wing_angler = trxFly.wing_angler(sTMP)';
            wAngleL = trxFly.theta+pi+trxFly.wing_anglel;
            wAngleR = trxFly.theta+pi+trxFly.wing_angler;
            trxFly.xwingl = trxFly.x + 4*trxFly.a.*cos(wAngleL);
            trxFly.ywingl = trxFly.y + 4*trxFly.a.*sin(wAngleL);
            trxFly.xwingr = trxFly.x + 4*trxFly.a.*cos(wAngleR);
            trxFly.ywingr = trxFly.y + 4*trxFly.a.*sin(wAngleR);
            
            trackdata.WTDEBUG{wtDebugSval}.trx(fly) = trxFly;
            
            trackdata.WTDEBUG{wtDebugSval}.perframedata.wing_areal{fly} = ...
              tdPFDOrig.wing_areal{fly}(sTMP);
            trackdata.WTDEBUG{wtDebugSval}.perframedata.wing_arear{fly} = ...
              tdPFDOrig.wing_arear{fly}(sTMP);
            trackdata.WTDEBUG{wtDebugSval}.perframedata.wing_trough_angle{fly} = ...
              tdPFDOrig.wing_trough_angle{fly}(sTMP);
            trackdata.WTDEBUG{wtDebugSval}.perframedata.nwingsdetected{fly} = ...
              tdPFDOrig.nwingsdetected{fly}(sTMP);
          end
        end
      end
    end
    setappdata(0,'trackdata',trackdata)
    if params.DEBUG
      cbtrackGUI_WingTracker_video
    end
    if getappdata(0,'iscancel') || getappdata(0,'isskip') || ~strcmp(getappdata(0,'button'),'track')
      trackdata = [];
      return
    end
    if params.dosave
      savetemp({'trackdata'})
    end
  end
end

%% convert to real units
stage='realunits';
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  if isfield(roidata,'pxpermm')
    
    dorotate = isfield(roidata,'rotateby');
    dotranslate = all(isfield(roidata,{'centerx','centery'}))&&~roidata.isall;
    if dorotate,
      costheta = cos(roidata.rotateby);
      sintheta = sin(roidata.rotateby);
      R = [costheta,-sintheta;sintheta,costheta];
    end
    
    for fly = 1:numel(trackdata.trx),
      
      roii = trackdata.trx(fly).roi;
      x = trackdata.trx(fly).x;
      if dotranslate,
        x = x - roidata.centerx(roii);
      end
      x = x / roidata.pxpermm;
      y = trackdata.trx(fly).y;
      if dotranslate,
        y = y - roidata.centery(roii);
      end
      y = y / roidata.pxpermm;
      a = trackdata.trx(fly).a / roidata.pxpermm;
      b = trackdata.trx(fly).b / roidata.pxpermm;
      theta = trackdata.trx(fly).theta;
      if dorotate,
        p = R*[x;y];
        x = p(1,:);
        y = p(2,:);
        theta = modrange(theta + roidata.rotateby,-pi,pi);
      end
      
      trackdata.trx(fly).x_mm = x;
      trackdata.trx(fly).y_mm = y;
      trackdata.trx(fly).theta_mm = theta;
      trackdata.trx(fly).a_mm = a;
      trackdata.trx(fly).b_mm = b;
      
      trackdata.trx(fly).pxpermm = roidata.pxpermm;
      trackdata.trx(fly).fps = 1/median(timestamps);
      
    end
    
  end
  
  dt = diff(timestamps);
  if all(isnan(dt)),
    fps = 30;
    warning('Unknown fps, assigning to 30');
    mediandt = 1/fps;
  else
    mediandt = median(dt(~isnan(dt)));
    fps = 1/mediandt;
  end
  for fly = 1:nflies,
    trackdata.trx(fly).fps = fps;
  end
  
  if isfield(params,'usemediandt') && params.usemediandt,
    
    for fly = 1:nflies,
      trackdata.trx(fly).dt = repmat(mediandt,[1,trackdata.trx(fly).nframes-1]);
    end
  end
  trackdata.stage=stages{find(strcmp(stage,stages))+1};
  setappdata(0,'trackdata',trackdata);
end

%% add arena parameters
stage='arena';
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
  if all(isfield(roidata,{'centerx','centery','radii'})) && ~isnan(roidata.pxpermm) && ~roidata.isall,
    for i = 1:nflies,
      roii = trackdata.trx(i).roi;
      trackdata.trx(i).arena.arena_radius_mm = roidata.radii(roii) / roidata.pxpermm;
      trackdata.trx(i).arena.arena_center_mm_x = 0;
      trackdata.trx(i).arena.arena_center_mm_y = 0;
    end
  end
  trackdata.stage=stages{find(strcmp(stage,stages))+1};
  setappdata(0,'trackdata',trackdata)
end
%% clean up
write_log(logfid,getappdata(0,'experiment'),sprintf('Clean up...\n'));


% if exist(out.temp_full,'file'),
%   try
%     delete(out.temp_full);
%   catch ME,
%     warning('Could not delete tmp file: %s',getReport(ME));
%   end
% end
if logfid > 1,
  fclose(logfid);
end

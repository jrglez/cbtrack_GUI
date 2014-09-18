function trackdata=TrackTwoFlies_GUI_debug2(moviefile,bgmed,roidata,params,varargin)
nrois=roidata.nrois;
version = '0.1.1';
timestamp = datestr(now,TimestampFormat);
[restart] = myparse(varargin,'restart',''); %[restart,tmpfilename,logfid] = myparse(varargin,'restart','','tmpfilename',tmpfilename,'logfid',1);
SetBackgroundTypes;
flycolors = {'r','b'};
stages = {'maintracking','reformat','chooseorientations','trackwings1','assignids','chooseorientations2','trackwings2','realunits','arena','end'};

cbparams=getappdata(0,'cbparams');
out=getappdata(0,'out');
logfid=open_log('track_log');

%% open movie

write_log(logfid,getappdata(0,'experiment'),sprintf('Opening movie...\n'));
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile);

trackdata=getappdata(0,'trackdata');

restartstage = trackdata.stage;
if ~isempty(restart),
  write_log(logfid,getappdata(0,'experiment'),sprintf('Restarting from stage %s...\n',trackdata.stage));
end
t=trackdata.t;
nframes_track = t - params.firstframetrack + 1;



stage = 'reformat'; 

if isfield(headerinfo,'timestamps'),
  timestamps = headerinfo.timestamps;
elseif isfield(headerinfo,'FrameRate'),
  timestamps = (0:nframes-1)/headerinfo.FrameRate;
elseif isfield(headerinfo,'fps'),
  timestamps = (0:nframes-1)/headerinfo.fps;
else
  warning('No frame rate info found for movie');
  timestamps = nan(1,nframes);
end
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages))
    %% correct for bounding box of rois
    trackdata.stage=stage;
    % initialize
    trxx = trackdata.trxx(:,:,1:nframes_track); 
    trxy = trackdata.trxy(:,:,1:nframes_track); 
    trxa = trackdata.trxa(:,:,1:nframes_track); 
    trxb = trackdata.trxb(:,:,1:nframes_track); 
    trxtheta = trackdata.trxtheta(:,:,1:nframes_track); 
    istouching = trackdata.istouching(:,1:nframes_track);
    gmm_isbadprior = trackdata.gmm_isbadprior(:,1:nframes_track);

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

    trackdata.trx = struct;
    j = 1;
    fly2roiid = [];
    for i = 1:nrois,
      if isnan(roidata.nflies_per_roi(i)),
        continue;
      end
      for jj = 1:roidata.nflies_per_roi(i),
        trackdata.trx(j).x = reshape(trxx(jj,i,:),[1,nframes_track]);
        trackdata.trx(j).y = reshape(trxy(jj,i,:),[1,nframes_track]);
        % saved quarter-major, quarter-minor axis
        trackdata.trx(j).a = reshape(trxa(jj,i,:)/2,[1,nframes_track]);
        trackdata.trx(j).b = reshape(trxb(jj,i,:)/2,[1,nframes_track]);
        trackdata.trx(j).theta = reshape(trxtheta(jj,i,:),[1,nframes_track]);

        trackdata.trx(j).firstframe = params.firstframetrack;
        trackdata.trx(j).endframe = params.firstframetrack+nframes_track-1;
        trackdata.trx(j).nframes = nframes_track;
        trackdata.trx(j).off = 1-params.firstframetrack;
        trackdata.trx(j).roi = i;
        trackdata.trx(j).arena = struct;
        if ~roidata.isall,
            trackdata.trx(j).arena.arena_radius_mm = roidata.radii(i);
            trackdata.trx(j).arena.arena_center_mm_x = roidata.centerx(i);            
            trackdata.trx(j).arena.arena_center_mm_y = roidata.centery(i);
        end
        %trackdata.trx(j).roipts = rois{i};
        %trackdata.trx(j).roibb = roibbs(i,:);
        trackdata.trx(j).moviefile = moviefile;
        trackdata.trx(j).dt = diff(timestamps(trackdata.trx(j).firstframe:trackdata.trx(j).endframe));
        trackdata.trx(j).timestamps = timestamps(trackdata.trx(j).firstframe:trackdata.trx(j).endframe);    
        fly2roiid(j) = jj;  %#ok<AGROW>
        j = j + 1;
      end
    end
    trackdata.istouching = istouching;
    trackdata.gmm_isbadprior = gmm_isbadprior;
    trackdata.stage=stages{find(strcmp(stage,stages))+1};
    trackdata=rmfield(trackdata,{'trxx','trxy','trxa','trxb','trxtheta','trxarea','trxpriors','trxcurr','pred'});
    if cbparams.track.dosave
        save(out.temp_full,'trackdata','-append')
    end
    setappdata(0,'trackdata',trackdata)
end
nflies = numel(trackdata.trx); 

%% resolve head/tail ambiguity

stage = 'chooseorientations';  
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
    write_log(logfid,getappdata(0,'experiment'),sprintf('Choosing orientations 1...\n'));
    setappdata(0,'allow_stop',false)
    hwait = waitbar(0,{['Experiment ',getappdata(0,'experiment')];'Computing fly orientations'},'CreateCancelBtn','cancel_waitbar');
    for i = 1:nflies,
      if getappdata(0,'iscancel') || getappdata(0,'isskip')
          trackdata = [];
          return
      end
      waitbar(i/nflies,hwait)
      x = trackdata.trx(i).x;
      y = trackdata.trx(i).y;
      theta = trackdata.trx(i).theta;
      roii = trackdata.trx(i).roi;

      dx = diff(x);
      dy = diff(y);
      v = sqrt(dx.^2 + dy.^2);

      % don't use velocity when touching, just keep angle consistent
      % to do this, set max_velocity_angle_weight to 0 when flies are touching
      istouching = trackdata.istouching(roii,:) > .5;
      isjumping = v>=params.choose_orientations_min_jump_speed;
      isjumping = [false,isjumping(1:end-1)|isjumping(2:end),false];
      weight_phi = min(params.choose_orientations_max_velocity_angle_weight,params.choose_orientations_velocity_angle_weight.*[0,v]);
      weight_phi(istouching|isjumping) = 0;

      % also don't rely on change in orientation as much when the fly is circular
      ecc = trackdata.trx(i).b ./ trackdata.trx(i).a;

      parama = (params.choose_orientations_min_ecc_factor-1)/(1-params.choose_orientations_max_ecc_confident);
      paramb = params.choose_orientations_min_ecc_factor - parama;

      ecc_factor = parama.*ecc + paramb;
      weight_theta = max(params.choose_orientations_min_ecc_factor,min(1,ecc_factor)) .* params.choose_orientations_weight_theta;

      trackdata.trx(i).theta = choose_orientations2(x,y,theta,weight_theta,weight_phi);
    end
    if ishandle(hwait)
        delete(hwait)
    end

    trackdata.stage=stages{find(strcmp(stage,stages))+1};
    if cbparams.track.dosave
        save(out.temp_full,'trackdata','-append')
    end
    setappdata(0,'trackdata',trackdata)
end

%% plot updated results

if params.DEBUG > 1,

  hell = nan(1,nflies);
  htrx = nan(1,nflies);
  him = nan;

  for iframe = 1:min(nframes_track,500),

    t = iframe+params.firstframetrack-1;
    im = readframe(t);

    if t == params.firstframetrack || ~exist('him','var') || ~ishandle(him),
      hold off;
      him = imagesc(im,[0,255]);
      axis image;
      colormap gray;
      hold on;
      isnewplot = true;
    else
      set(him,'CData',im);
      isnewplot = false;
    end
    title(num2str(t));

    for i = 1:nflies,
      fly = fly2roiid(i);
      if isnewplot || ~ishandle(hell(i)),
        hell(i) = drawflyo(trackdata.trx(i).x(iframe),trackdata.trx(i).y(iframe),...
          trackdata.trx(i).theta(iframe),trackdata.trx(i).a(iframe),...
          trackdata.trx(i).b(iframe),[flycolors{fly},'-']);
      else
        updatefly(hell(i),trackdata.trx(i).x(iframe),trackdata.trx(i).y(iframe),trackdata.trx(i).theta(iframe),...
          trackdata.trx(i).a(iframe),trackdata.trx(i).b(iframe));
      end
      if isnewplot || ~ishandle(htrx(i)),
        htrx(i) = plot(trackdata.trx(i).x(max(iframe-30,1):iframe),trackdata.trx(i).y(max(iframe-30,1):iframe),[flycolors{fly},'.-']);
      else
        set(htrx(i),'XData',trackdata.trx(i).x(max(iframe-30,1):iframe),...
          'YData',trackdata.trx(i).y(max(iframe-30,1):iframe));
      end
    end
    drawnow;
  end
end

%% track wings if using wings

stage = 'trackwings1'; 

didtrackwings = false;

if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
    if strcmp(params.assignidsby,'wingsize') && cbparams.track.dotrackwings,

      write_log(logfid,getappdata(0,'experiment'),sprintf('Tracking wings 1...\n'));

      [nr,nc,~] = size(readframe(1));
      if roidata.isall
          isarena=true(nr,nc);
      else
          isarena = false(nr,nc);
          [XGRID,YGRID] = meshgrid(1:nc,1:nr);
          for roii = 1:nrois,
            if roidata.nflies_per_roi(roii) == 0,
              continue;
            end
            isarena = isarena | ...
              ( ((XGRID - roidata.centerx(roii)).^2 + ...
              (YGRID - roidata.centery(roii)).^2) ...
              <= roidata.radii(roii)^2 );
          end
      end
      
      if ~params.DEBUG
          debugdata.track=1;
          debugdata.vis=0;
          [wingtrx,wingperframedata,~,wingtrackinfo,wingperframeunits,~] = TrackWingsHelper_GUI([],trackdata.trx,moviefile,double(bgmed),isarena,params.wingtracking_params,debugdata,...
            'firstframe',params.firstframetrack,...
            'debug',params.DEBUG);
          if getappdata(0,'iscancel') || getappdata(0,'isskip')
              return
          end
          didtrackwings = true;
          trackdata.trackwings_timestamp = wingtrackinfo.trackwings_timestamp;
          trackdata.trackwings_version = wingtrackinfo.trackwings_version;
          trackdata.trx = wingtrx;
          trackdata.perframedata = wingperframedata;
          trackdata.perframeunits = wingperframeunits;
      else
          cbtrackGUI_WingTracker_video
          if getappdata(0,'iscancel') || getappdata(0,'isskip')
              return
          end
          trackdata=getappdata(0,'trackdata');
      end

    end
    trackdata.stage=stages{find(strcmp(stage,stages))+1};
    if cbparams.track.dosave
        twing=getappdata(0,'twing'); %#ok<NASGU>
        debugdata_WT=getappdata(0,'debugdata_WT'); %#ok<NASGU>
        save(out.temp_full,'trackdata','twing','debugdata_WT','-append')
    end
    setappdata(0,'trackdata',trackdata)
end

%% assign identities based on size of something


stage = 'assignids'; 

if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
    write_log(logfid,getappdata(0,'experiment'),sprintf('Assigning identities based on %s...\n',params.assignidsby));

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
          wingarea{i} = trackdata.perframedata.wing_areal{i}+trackdata.perframedata.wing_arear{i};
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
    trxfns = intersect({'x','y','a','b','theta','xwingl','ywingl','xwingr','ywingr','wing_anglel','wing_angler'},fieldnames(trackdata.trx));
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

      for i = 1:2,
        for j = 1:2,
          idx = idsfit_curr(i,:)==j;
          for k = 1:numel(trxfns),
            trackdata.trx(flies(i)).(trxfns{k})(idx) = oldtrx(flies(j)).(trxfns{k})(idx);
          end
          if isfield(trackdata,'perframedata'),
            for k = 1:numel(perframefns),
              trackdata.perframedata.(perframefns{k}){flies(i)}(idx) = ...
                oldperframedata.(perframefns{k}){flies(j)}(idx);
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

    idx = find(roidata.nflies_per_roi == 1);
    typeperroi = cell(1,nrois);
    for ii = 1:numel(idx),
      i = idx(ii);
      fly = find([trackdata.trx.roi]==roii);
      switch params.assignidsby,
        case 'size',
          a = cat(1,trackdata.trx(fly).a);
          b = cat(1,trackdata.trx(fly).b);
          areacurr = a.*b.*pi*4;
        case 'wingsize',
          areacurr = wingarea{fly};
        otherwise,
          error('Unknown assignidsby value');
      end
      meanareacurr = nanmean(areacurr(:));
      write_log(logfid,getappdata(0,'experiment'),sprintf('%d: %f\n',i,meanareacurr));
      if meanareacurr <= area_thresh, 
        typeperroi{i} = params.typesmallval;
      else
        typeperroi{i} = params.typebigval;
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
      if roidata.nflies_per_roi(roii) == 2,
        if fly2roiid(i) == 1,
          trackdata.trx(i).(params.typefield) = repmat({params.typesmallval},[1,nframes_track]);
        else
          trackdata.trx(i).(params.typefield) = repmat({params.typebigval},[1,nframes_track]);
        end
      elseif roidata.nflies_per_roi(i) == 1,
        trackdata.trx(i).(params.typefield) = repmat(typeperroi(i),[1,nframes_track]);
      end
    end
    trackdata.stage=stages{find(strcmp(stage,stages))+1};
    if cbparams.track.dosave
        save(out.temp_full,'trackdata','-append')
    end
    setappdata(0,'trackdata',trackdata)
end

%% resolve head/tail ambiguity again, since it is pretty quick

stage = 'chooseorientations2'; 
if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
    write_log(logfid,getappdata(0,'experiment'),sprintf('Choosing orientations 2...\n'));
    isflip = false(nflies,nframes_track);
    setappdata(0,'allow_stop',false)
    hwait = waitbar(0,{['Experiment ',getappdata(0,'experiment')];'Computing fly orientations'},'CreateCancelBtn','cancel_waitbar');
    for i = 1:nflies,
      if getappdata(0,'iscancel') || getappdata(0,'isskip')
          trackdata = [];
          return
      end
      waitbar(i/nflies,hwait)

      % if there is some kind of flip
      roii = trackdata.trx(i).roi;
      if trackdata.assignids.nflips(roii) == 0,
        continue;
      end
      x = trackdata.trx(i).x;
      y = trackdata.trx(i).y;
      theta = trackdata.trx(i).theta;
      write_log(logfid,getappdata(0,'experiment'),sprintf('Re-choosing orientations for fly %d (nidflips = %d)\n',i,trackdata.assignids.nflips(roii)));
      trackdata.trx(i).theta = choose_orientations(x,y,theta,params.choose_orientations_velocity_angle_weight,params.choose_orientations_max_velocity_angle_weight);
      isflip(i,:) = round(abs(modrange(theta-trackdata.trx(i).theta,-pi,pi))/pi) > 0;
      write_log(logfid,getappdata(0,'experiment'),sprintf('N. orientation flips = %d\n',nnz(isflip(i,:))));

    end
    if ishandle(hwait)
      delete(hwait)
    end
    trackdata.stage=stages{find(strcmp(stage,stages))+1};
    if cbparams.track.dosave
        save(out.temp_full,'trackdata','-append')
    end
    setappdata(0,'trackdata',trackdata)
end

%% track wings
stage = 'trackwings2'; 

if find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),
    if didtrackwings,
      framestrack = cell(1,nrois);
      for roii = 1:nrois,
        flies = find([trackdata.trx.roi]==roii);
        if isempty(flies),
          continue;
        end
        framestrack{roii} = find(any(isflip(flies,:),1))+params.firstframetrack-1;
      end
      roistrack = find(~cellfun(@isempty,framestrack));
    else
      roistrack = 1:nrois;
    end

    if params.dotrackwings && ~isempty(roistrack),

      write_log(logfid,getappdata(0,'experiment'),sprintf('Tracking wings 2...\n'));

      [nr,nc,~] = size(readframe(1));
      if roidata.isall
          isarena=true(nr,nc);
      else
          isarena = false(nr,nc);
          [XGRID,YGRID] = meshgrid(1:nc,1:nr);
          for roii = roistrack,
            if roidata.nflies_per_roi(roii) == 0,
              continue;
            end
            isarena = isarena | ...
              ( ((XGRID - roidata.centerx(roii)).^2 + ...
              (YGRID - roidata.centery(roii)).^2) ...
              <= roidata.radii(roii)^2 );
          end
      end
      
      if didtrackwings,
          debugdata.track=1;
          debugdata.vis=0;
          if isfield(debugdata,'framestrack')
              debugdata=rmfield(debugdata,{'framestrak','nframestrack','framestracked','nframestracked'});
          end
          [wingtrx,wingperframedata,~,wingtrackinfo,wingperframeunits,~] = TrackWingsHelper_GUI([],trackdata.trx,moviefile,double(bgmed),isarena,params.wingtracking_params,debugdata,...
              'firstframe',params.firstframetrack,...
              'debug',false,...
              'framestrack',unique(cat(2,framestrack{:})),...
              'perframedata',trackdata.perframedata);
          if getappdata(0,'iscancel') || getappdata(0,'isskip')
              return
          end
          trackdata.trackwings_timestamp = wingtrackinfo.trackwings_timestamp;
          trackdata.trackwings_version = wingtrackinfo.trackwings_version;
          trackdata.trx = wingtrx;
          trackdata.perframedata = wingperframedata;
          trackdata.perframeunits = wingperframeunits;
      else  
          if ~params.DEBUG
              debugdata.track=1;
              debugdata.vis=0;
              %[wingtrx,wingperframedata,~,wingtrackinfo,wingperframeunits,~] = TrackWingsHelper_GUI_old([],trackdata.trx,moviefile,double(bgmed),isarena,params.wingtracking_params,debugdata,...
              %    'firstframe',params.firstframetrack,...
              %    'debug',params.DEBUG);
              [wingtrx,wingperframedata,~,wingtrackinfo,wingperframeunits,~] = TrackWingsHelper_GUI([],trackdata.trx,moviefile,double(bgmed),isarena,params.wingtracking_params,debugdata,...
                  'firstframe',params.firstframetrack,...
                  'debug',params.DEBUG);
              if getappdata(0,'iscancel') || getappdata(0,'isskip')
                 return
              end

              trackdata.trackwings_timestamp = wingtrackinfo.trackwings_timestamp;
              trackdata.trackwings_version = wingtrackinfo.trackwings_version;
              trackdata.trx = wingtrx;
              trackdata.perframedata = wingperframedata;
              trackdata.perframeunits = wingperframeunits;
          else
              cbtrackGUI_WingTracker_video
              if getappdata(0,'iscancel') || getappdata(0,'isskip')
                  return
              end
              trackdata=getappdata(0,'trackdata');             
          end
      end       
    end
    trackdata.stage=stages{find(strcmp(stage,stages))+1};
    if cbparams.track.dosave
        twing=getappdata(0,'twing'); %#ok<NASGU>
        debugdata_WT=getappdata(0,'debugdata_WT'); %#ok<NASGU>
        save(out.temp_full,'trackdata','twing','debugdata_WT','-append')
    end 
    setappdata(0,'trackdata',trackdata);
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


if fid > 1,
  try
    fclose(fid);
  catch ME,
    warning('Could not close movie: %s',getReport(ME));
  end
end

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
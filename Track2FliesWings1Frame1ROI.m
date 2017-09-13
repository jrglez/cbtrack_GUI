function [trxcurr,pred,perframedata] = Track2FliesWings1Frame1ROI(...
  im,dbkgdbb,isfore_bodybb,iswingbb,isfore_wingbb,npxfore_wing,...
  fore2bodybb,pred,trxprev,perframedataprev,nflies_per_roi,params,Wparams,...
  varargin)

  trxcurrExt = myparse(varargin,...
    'trxcurrExt',[]);
  
  tfTrxSupplied = ~isempty(trxcurrExt);
  
  if tfTrxSupplied
    % trxprev ignored
    trxcurr = trxcurrExt;
  else
    % initialize
    trxcurr = trxprev;
    trxcurr.gmm_isbadprior = 0;
    trxcurr.istouching = 0;
    trxpriors = zeros(1,2);

    %% fit connected components
    FitFlies  
    
    %% predicted position for next frame
    pred.area = trxcurr.area;
    if pred.isfirstframe,
      pred.x = trxcurr.x;
      pred.y = trxcurr.y;
      pred.theta = trxcurr.theta;
    else
      pred.x = (2-params.err_dampen_pos)*trxcurr.x - (1-params.err_dampen_pos)*trxprev.x;
      pred.y = (2-params.err_dampen_pos)*trxcurr.y - (1-params.err_dampen_pos)*trxprev.y;
      dtheta = modrange(trxcurr.theta-trxprev.theta,-pi/2,pi/2);
      pred.theta = trxcurr.theta+(1-params.err_dampen_theta)*dtheta;
    end

    % switch around priors, move toward .5, .5
    pred.mix.priors = (1-params.err_dampen_priors)*trxpriors(order) + params.err_dampen_priors*.5;
    % set centres, covars to predicted positions
    pred.mix.centres = [pred.x,pred.y];
    pred.mix.covars = axes2cov(trxcurr.a,trxcurr.b,pred.theta);

    pred.isfirstframe = false;
    trxcurr.priors=trxpriors(order);    
  end
  
    %% fit wings
    combs = dec2bin(0:2^numel(1:nflies_per_roi)-1,numel(1:nflies_per_roi))-'0'+1; combs=combs';
    ncombs = size(combs,2);
    dthetawing = cell(nflies_per_roi,ncombs);
    perframedata = perframedataprev;

    if params.dotrackwings
        SegmentWings
        FitWings
    else
        perframedata.wing_areal(:) = 0;
        perframedata.wing_arear(:) = 0;
    end

    function FitFlies  
        cc = bwconncomp(isfore_bodybb);

        cc.Area = cellfun(@numel,cc.PixelIdxList);
        isbigenough = cc.Area >= params.minccarea;
        ncc_bigenough = nnz(isbigenough);

        %% only one fly

        if nflies_per_roi == 1,

          % store in position 1
          i = 1;
          if ncc_bigenough == 1,
            % use this connected component
            isbig = cc.Area >= params.minccarea;
            idx = cc.PixelIdxList{isbig};
          else
            idx = cat(1,cc.PixelIdxList{:});
          end
          [y,x] = ind2sub(size(isfore_bodybb),idx);
          w = dbkgdbb(idx);
          if isempty(x) || isempty(y)
            mu=nan(1,2);
            S=nan(2);
          else
            [mu,S] = weighted_mean_cov([x(:),y(:)],w);
          end
          [trxcurr.a(i),trxcurr.b(i),trxcurr.theta(i)] = cov2ell(S);
          trxcurr.x(i) = mu(1);
          trxcurr.y(i) = mu(2);
          if ~isempty(cc.PixelIdxList)
            trxcurr.area(i) = numel(cc.PixelIdxList{i});
          end
          trxpriors(i) = 1;

          trxcurr.istouching = 0;
          order = [1,2];    

        else
          %% two flies

          % fit ellipses

          if cc.NumObjects > 2 && ncc_bigenough < 2 && params.bgthresh_low < params.bgthresh,

            % try to connect split apart connected components
            isforebb_low = dbkgdbb >= params.bgthresh_low;
            cc_low = bwconncomp(isforebb_low);
            if cc.NumObjects == 2 || cc.NumObjects == 1,
              cc = cc_low;
              cc.Area = cellfun(@numel,cc.PixelIdxList);
              isbigenough = cc.Area >= params.minccarea;
              ncc_bigenough = nnz(isbigenough);
            end

          end

          % separate connected components
          if ncc_bigenough == 2,
            ccidx = find(isbigenough);
            for i = 1:2,
              j = ccidx(i);
              [y,x] = ind2sub(size(isfore_bodybb),cc.PixelIdxList{j});
              w = dbkgdbb(cc.PixelIdxList{j});
              [mu,S] = weighted_mean_cov([x(:),y(:)],w);
              [trxcurr.a(i),trxcurr.b(i),trxcurr.theta(i)] = cov2ell(S);
              trxcurr.x(i) = mu(1);
              trxcurr.y(i) = mu(2);
              trxcurr.area(i) = numel(cc.PixelIdxList{j});
              trxpriors(i) = sum(w);
            end
            trxpriors = trxpriors / sum(trxpriors);
            trxcurr.istouching = 0;

          elseif cc.NumObjects == 0,
            warning('No flies detected in ROI');

          else

            % GMM clustering of all foreground pixels
            idx = cat(1,cc.PixelIdxList{:});
            [y,x] = ind2sub(size(isfore_bodybb),idx);
            w = dbkgdbb(idx);
            if pred.isfirstframe,
              [mu,S,trxpriors,post,nll,mixprev] = mygmm([x,y],2,...
                'Replicates',params.gmmem_nrestarts_firstframe,...
                'precision',params.gmmem_precision,...
                'MaxIters',params.gmmem_maxiters,...
                'weights',w); %#ok<NASGU,ASGLU>
            else
              [mu,S,trxpriors,post,nll,mixprev] = mygmm([x,y],2,...
                'Start',pred.mix,...
                'precision',params.gmmem_precision,...
                'MaxIters',params.gmmem_maxiters,...
                'weights',w); %#ok<NASGU>

              % check that all went well
              if any(trxpriors <= params.gmmem_min_obsprior),
                logfid=open_log('track_log');
                write_log(logfid,getappdata(0,'experiment'),sprintf('Bad prior found, trying to reinitialize\n'));
                trxcurr.gmm_isbadprior = true;

                [mu1,S1,obspriors1,post1,nll1,mixprev1] = mygmm([x,y],2,...
                  'Replicates',params.gmmem_nrestarts_firstframe,...
                  'precision',params.gmmem_precision,...
                  'MaxIters',params.gmmem_maxiters,...
                  'weights',w);

                if nll1 <= nll,
                  write_log(logfid,getappdata(0,'experiment'),sprintf('Using results from reinitialization, which improve nll by %f\n',nll-nll1));
                  mu = mu1;
                  S = S1;
                  trxpriors = obspriors1(:)';
                  post = post1;
                  nll = nll1; %#ok<NASGU>
                  mixprev = mixprev1; %#ok<NASGU>
                else
                  write_log(logfid,getappdata(0,'experiment'),sprintf('Reinitialization does not improve nll.\n'));
                end
                
                if logfid > 1,
                  fclose(logfid);
                end
              end
            end

            for i = 1:2,
              [trxcurr.a(i),trxcurr.b(i),trxcurr.theta(i)] = cov2ell(S(:,:,i));
              trxcurr.x(i) = mu(i,1);
              trxcurr.y(i) = mu(i,2);
              trxcurr.area(i) = sum(post(:,i));
            end
            trxcurr.istouching = true;

          end

          % match

          order = 1:2;
          if ~pred.isfirstframe,      

            besterr = inf;
            for i = 1:2,
              if i == 1,
                ordercurr = [1,2];
              else
                ordercurr = [2,1];
              end

              dpos2 = (pred.x-trxcurr.x(ordercurr)).^2 + (pred.y-trxcurr.y(ordercurr)).^2;
              dtheta = abs(modrange(pred.theta-trxcurr.theta(ordercurr),-pi/2,pi/2));
              darea = abs(pred.area-trxcurr.area(ordercurr));

              errcurr = sqrt(sum(dpos2))*params.err_weightpos + ...
                sqrt(sum(dtheta.^2))*params.err_weighttheta + ...
                sqrt(sum(darea.^2))*params.err_weightarea;

              if errcurr < besterr,
                order = ordercurr;
                besterr = errcurr;
              end
            end

          end

          trxcurr.x = trxcurr.x(order);
          trxcurr.y = trxcurr.y(order);
          trxcurr.a = trxcurr.a(order);
          trxcurr.b = trxcurr.b(order);
          trxcurr.theta = trxcurr.theta(order);
          trxcurr.area = trxcurr.area(order);
        end
    end

    function SegmentWings
        persistent hx hy se_boundary;
        
        [nr,nc] = size(isfore_wingbb);
        [XGRID,YGRID] = meshgrid(1:nc,1:nr);
        %% assign targets to connected components
        [L,ncc] = bwlabel(isfore_wingbb);
        fore2cc = L(isfore_wingbb);
        fly2cc = nan(1,nflies_per_roi);
        pcurr = [];
        
        for fly = 1:nflies_per_roi,
          if isempty(trxcurr.x(fly)),
            continue;
          end
          x = round(trxcurr.x(fly));
          y = round(trxcurr.y(fly));
          if y >= 1 && y <= nr && x >= 1 && x <= nc && ...
              isfore_wingbb(y,x),
            fly2cc(fly) = L(y,x);
          elseif any(isnan([x,y]))
            fly2cc(fly) = nan; 
          else
            if isempty(pcurr),
              pcurr = [XGRID(isfore_wingbb),YGRID(isfore_wingbb)];
            end
            mu = [trxcurr.x(fly),trxcurr.y(fly)];
            S = axes2cov(trxcurr.a(fly)*2,trxcurr.b(fly)*2,trxcurr.theta(fly));
            diffs = bsxfun(@minus,pcurr,mu);
            c = chol(S);
            temp = diffs/c;
            dcurr = sum(temp.^2, 2);
            [mind,j] = min(dcurr);
            if mind>Wparams.max_wingcc_dist
                continue
            end
            fly2cc(fly) = fore2cc(j);
          end
        end

        %% assign unassigned connected components to flies
        fly2nccs = ones(1,nflies_per_roi);
        unassignedcc = setdiff(1:ncc,fly2cc);
        if ~isempty(unassignedcc) && ~any(isnan([x,y])),
          mus = nan(nflies_per_roi,2);
          for fly = 1:nflies_per_roi,
            if isempty(trxcurr.x(fly)),
              continue;
            end
            mus(fly,:) = [trxcurr.x(fly),trxcurr.y(fly)];
          end
          for cci = unassignedcc,
            % remove small connected components
            if nnz(L==cci) < Wparams.min_wingcc_area,
              continue;
            end
            x = XGRID(L==cci);
            y = YGRID(L==cci);
            D = dist2([x(:),y(:)],mus);
            d = min(D,[],1);
            [mind,fly] = min(d);
            mind = mind/(trxcurr.a(fly)*4);
            if mind > Wparams.max_wingcc_dist,
              continue;
            end
            L(L==cci) = fly2cc(fly);
            fore2cc(fore2cc==cci) = fly2cc(fly);
            fly2nccs(fly) = fly2nccs(fly) + 1;
          end
        end

        %% loop over connected components, assign pixels to flies
        unique_cc = unique(fly2cc(~isnan(fly2cc)));
        % fore2fly corresponds to isfore_thresh

        xgrid_isfore = XGRID(isfore_wingbb);
        ygrid_isfore = YGRID(isfore_wingbb);

        % for watershed
        if isempty(hy),
          hy = fspecial('sobel');
          hx = hy';
          se_boundary = strel('disk',1);
        end
        
        % compute distance from each current body pixel to fly
        fore2wing = iswingbb(isfore_wingbb); 
        dthetawing1 = cell(nflies_per_roi,2);
        if ~isempty(unique_cc)
            for cci = unique_cc,
              flies = find(fly2cc == cci);
              fore2curr = fore2cc == cci;
              % all pixels belong to one fly
              if numel(flies) == 1,
                x = trxcurr.x(flies);
                y = trxcurr.y(flies);
                theta = modrange(trxcurr.theta(flies)+[0,pi],-pi,pi);
                idx_fly = fore2wing&fore2curr;
                xwing = xgrid_isfore(idx_fly);
                ywing = ygrid_isfore(idx_fly);
                ors1 = combs==1;
                ors2 = combs==2;
                dthetawing1(flies,:) = ...
                    {modrange(bsxfun(@minus,atan2(ywing-y,xwing-x),theta(1)+pi),-pi,pi), ...
                    modrange(bsxfun(@minus,atan2(ywing-y,xwing-x),theta(2)+pi),-pi,pi)};
                isallowed = cellfun(@(x) abs(x)<=Wparams.max_wingpx_angle, dthetawing1(flies,:),'UniformOutput',false);
                dthetawing1{flies,1}(~isallowed{1}) = []; 
                dthetawing1{flies,2}(~isallowed{2}) = [];
                dthetawing(flies,ors1(flies,:)) = dthetawing1(flies,1); 
                dthetawing(flies,ors2(flies,:)) = dthetawing1(flies,2);
                continue;
              end
              
              %fprintf(2,'AL: Unexpected SegmentWings codepath.\n');
              % assign body pixels based on mahdist

              % indices of foreground pixels in the current cc
              curr2fore = find(fore2curr);

              % ncurr x 1, whether current cc pixels are body or not
              curr2body = fore2bodybb(fore2curr);

              % nbodycurr x 1, indices of current cc pixels in body
              body2curr = find(curr2body);
              nbodycurr = numel(body2curr);

              pbody = [xgrid_isfore(curr2fore(body2curr)),ygrid_isfore(curr2fore(body2curr))];
              pcurr = [xgrid_isfore(fore2curr),ygrid_isfore(fore2curr)];
              xlims = [floor(min(pcurr(:,1)))-1,ceil(max(pcurr(:,1)))+1];
              ylims = [floor(min(pcurr(:,2)))-1,ceil(max(pcurr(:,2)))+1];
              xlims = max(1,min(nc,xlims));
              ylims = max(1,min(nr,ylims));
              dx = diff(xlims)+1;
              dy = diff(ylims)+1;
              bw = L(ylims(1):ylims(2),xlims(1):xlims(2)) == cci;

              % superpixel segmentation
              imbb = im(ylims(1):ylims(2),xlims(1):xlims(2));
              imbb(~isfore_wingbb(ylims(1):ylims(2),xlims(1):xlims(2))) = ...
                mean(imbb(~isfore_wingbb(ylims(1):ylims(2),xlims(1):xlims(2))));
              Iy = imfilter(imbb, hy, 'replicate');
              Ix = imfilter(imbb, hx, 'replicate');
              gradmag = sqrt(Ix.^2 + Iy.^2);
              isboundary = ~bw & imdilate(bw,se_boundary);
              gradmag(isboundary) = inf;

              Lseg = watershed(gradmag);

              % remove bg segments
              nsegcurr = max(Lseg(:));
              for segi = 1:nsegcurr,
                segcurr = Lseg==segi;
                tmp = bw(segcurr);
                tmp(isnan(tmp)) = [];
                if isempty(tmp),
                  continue;
                end
                if nnz(tmp) < numel(tmp)/2,
                  Lseg(segcurr) = nan;
                end
              end

              imbb(~bw|isnan(Lseg)) = nan;

              % assign watershed pixels based on intensity difference
              [rw,cw] = find(Lseg==0);
              iw = sub2ind(size(Lseg),rw,cw);
              nwatershed = numel(rw);
              mind = inf(nwatershed,1);
              Lw = nan(nwatershed,1);
              for dc = -1:1,
                for dr = -1:1,
                  if dc == 0 && dr == 0,
                    continue;
                  end
                  % adjacent pixel
                  r1 = rw + dr;
                  c1 = cw + dc;
                  % make sure it is in bounds
                  idxw = find(r1 >= 1 & r1 <= dy & c1 >= 1 & c1 <= dx);
                  iw1 = sub2ind(size(Lseg),r1(idxw),c1(idxw));
                  % also make sure it does not have Lseg == 0, and is foreground
                  idxw(Lseg(iw1)==0 | ~bw(iw1)) = [];
                  iw1 = sub2ind(size(Lseg),r1(idxw),c1(idxw));
                  % compute intensity difference
                  dcurr = nan(nwatershed,1);
                  lcurr = nan(nwatershed,1);
                  dcurr(idxw) = abs(imbb(iw(idxw))-imbb(iw1));
                  lcurr(idxw) = Lseg(iw1);
                  idxw1 = dcurr < mind;
                  if any(isnan(lcurr(idxw1))),
                    keyboard;
                  end
                  %fprintf('dr = %d, dc = %d, assigning for: %s\n',dr,dc,mat2str(find(idxw1)));
                  mind(idxw1) = dcurr(idxw1);
                  Lw(idxw1) = lcurr(idxw1);
                end
              end

              Lseg(iw) = Lw;
              Lseg(~bw) = nan;

              for comb=1:ncombs % Loop over all the possible orientation combinations
                mind = inf(nbodycurr,1);
                body2id = nan(nbodycurr,1);
                body2isback = false(nbodycurr,1);
                flycc=1;
                for fly = flies,
                    mu = [trxcurr.x(fly),trxcurr.y(fly)];
                    diffs = bsxfun(@minus,pbody,mu);
                    comb2or=combs(flycc,comb);
                    theta=modrange(trxcurr.theta(fly)+pi*(comb2or-1),-pi,pi);
                    S = axes2cov(trxcurr.a(fly)*2,trxcurr.b(fly)*2,theta);
                    c = chol(S);
                    temp = diffs/c;
                    dcurr = sum(temp.^2, 2);
                    isbackcurr = diffs(:,1)*cos(theta) + diffs(:,2)*sin(theta) <= 0;
                    idx = dcurr < mind;
                    body2id(idx) = fly;
                    mind(idx) = dcurr(idx);
                    body2isback(idx) = isbackcurr(idx);
                    flycc=flycc+1;
                end
                
                % compute distance from each non-body pixel to each body pixel
                % pixels we can go through
                mind = inf(size(bw));
                flycurr = nan(size(bw));
                for fly = flies,
                    % pixels we are finding the distance to
                    c = pbody(body2id==fly&body2isback,1)-xlims(1)+1;
                    r = pbody(body2id==fly&body2isback,2)-ylims(1)+1;

                    % find distance within foreground pixels
                    dcurr = bwdistgeodesic(bw,c,r,'quasi-euclidean');

                    % assign if smaller
                    tmpidx = dcurr < mind;
                    mind(tmpidx) = dcurr(tmpidx);
                    flycurr(tmpidx) = fly;
                end

                % pixels that have infinite distance
                infidx = bw & isinf(mind);
                if any(infidx(:)),
                    [infy,infx] = find(infidx);
                    infmind = inf(1,numel(infy));
                    infflycurr = nan(1,numel(infy));
                    for fly = flies,
                      % pixels we are finding the distance to
                      c = pbody(body2id==fly&body2isback,1)-xlims(1)+1;
                      r = pbody(body2id==fly&body2isback,2)-ylims(1)+1;
                      if isempty(c),
                        continue;
                      end

                      % find distance to a foreground pixel through any pixel
                      dcurr = min(dist2([c(:),r(:)],[infx(:),infy(:)]),[],1);

                      % assign if smaller
                      tmpidx = dcurr < infmind;
                      infmind(tmpidx) = dcurr(tmpidx);
                      infflycurr(tmpidx) = fly;
                    end
                    mind(infidx) = infmind; %#ok<NASGU>
                    flycurr(infidx) = infflycurr;
                end

                % for each superpixel, take the majority vote
                nsegcurr = max(Lseg(:));
                flycurrcomb = nan(size(flycurr));
                for segi = 1:nsegcurr,
                  segcurr = Lseg==segi;
                  tmp = flycurr(segcurr);
                  tmp(isnan(tmp)) = [];
                  if isempty(tmp),
                      continue;
                  end
                  flyseg = mode(tmp);
                  flycurrcomb(segcurr) = flyseg;
                end

                fore2flycomb = nan(npxfore_wing,1);
                fore2flycomb(fore2curr) = flycurrcomb(bw);
                for fly=flies
                  x = trxcurr.x(fly);
                  y = trxcurr.y(fly);
                  comb2or=combs(fly,comb);
                  theta=modrange(trxcurr.theta(fly)+pi*(comb2or-1),-pi,pi);
                  idxcomb_fly = fore2wing&fore2flycomb==fly;
                  xwing = xgrid_isfore(idxcomb_fly);
                  ywing = ygrid_isfore(idxcomb_fly);
                  dthetawing_fly = modrange(atan2(ywing-y,xwing-x)-(theta+pi),-pi,pi);
                  isallowed = abs(dthetawing_fly) <= Wparams.max_wingpx_angle;
                  dthetawing_fly(~isallowed) = [];
                  dthetawing{fly,comb}=dthetawing_fly;
                end
              end
            end
        end
    end

    function FitWings
        % initialize output
        
        for comb = 1:ncombs
            for fly = 1:nflies_per_roi,

              % find pixels that belong to each fly's wings
              if isempty(trxcurr.x(fly)),
                continue;
              end

              % fit wings  
              wingtrx = TrackWings_FitWings_Peak(dthetawing{fly,comb},Wparams);
              trxcurr.wing_anglel(fly,1,comb) = wingtrx.wing_anglel;
              trxcurr.wing_angler(fly,1,comb) = wingtrx.wing_angler;
              perframedata.nwingsdetected(fly,1,comb) = wingtrx.nwingsdetected;
              perframedata.wing_areal(fly,1,comb) = wingtrx.wing_areal;
              perframedata.wing_arear(fly,1,comb) = wingtrx.wing_arear;
              perframedata.wing_trough_angle(fly,1,comb) = wingtrx.wing_trough_angle;
            end
        end
    end
end
function trx=fit_to_ellipse_GUI(roidata,nflies_per_roi,dbkgd,isfore,tracking_params)
% Find/track flies in one frame
%
% trx: column vector of trxstructs, length nansum(nflies_per_roi)

assert(all(ismember(nflies_per_roi,[0 1 2]) | isnan(nflies_per_roi)));

nrois = roidata.nrois;
ntrx = nansum(nflies_per_roi);
trx = trxstruct(ntrx,1);

trxcurr = struct;
trxcurr.x = nan(2,1);
trxcurr.y = nan(2,1);
trxcurr.a = nan(2,1);
trxcurr.b = nan(2,1);
trxcurr.theta = nan(2,1);
trxcurr.area = nan(2,1);
trxcurr.istouching = nan;
trxcurr.gmm_isbadprior = nan;
trxcurr = repmat(trxcurr,[1,nrois]);
k=1;
for j=1:nrois
    if any(roidata.ignore==j)
      continue;
    end
    assert(~isnan(nflies_per_roi(j)));
    
    roibb = roidata.roibbs(j,:);
    roibb([1,3]) = floor(roibb([1,3])/tracking_params.down_factor);
    roibb([2,4]) = ceil(roibb([2,4])/tracking_params.down_factor);
    roibb(roibb==0)=1;
    dbkgdbb = double(dbkgd(roibb(3):roibb(4),roibb(1):roibb(2)));
    dbkgdbb(~roidata.inrois{j}) = 0;
    isforebb = isfore(roibb(3):roibb(4),roibb(1):roibb(2));
    isforebb(~roidata.inrois{j}) = false;
    pred.isfirstframe=1;
    [trxi,~] = TrackTwoFliesOneFrameOneROI_GUI(isforebb,dbkgdbb,pred,trxcurr(j),nflies_per_roi(j),tracking_params);
    trxi.x = trxi.x+roibb(1)-1;
    trxi.y = trxi.y+roibb(3)-1;
    for i=1:nflies_per_roi(j)
        trx(k).x = trxi.x(i);
        trx(k).y = trxi.y(i);
        trx(k).a = trxi.a(i);
        trx(k).b = trxi.b(i);
        trx(k).theta = trxi.theta(i);
        k=k+1;
    end
end

assert(k==ntrx+1,'ROI/trx mismatch.');

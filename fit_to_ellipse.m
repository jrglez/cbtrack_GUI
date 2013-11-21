function trx=fit_to_ellipse(roidata, dbkgd, isfore,tracking_params)
nrois = numel(roidata.centerx);
trx=cell(nrois,1);

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
for j=1:nrois
    roibb = roidata.roibbs(j,:);
    dbkgdbb = double(dbkgd(roibb(3):roibb(4),roibb(1):roibb(2)));
    dbkgdbb(~roidata.inrois{j}) = 0;
    isforebb = isfore(roibb(3):roibb(4),roibb(1):roibb(2));
    isforebb(~roidata.inrois{j}) = false;
    pred.isfirstframe=1;
    [trx{j},~] = TrackTwoFliesOneFrameOneROI(isforebb,dbkgdbb,pred,trxcurr(j),roidata.nflies_per_roi(j),tracking_params);
    trx{j}.x=trx{j}.x+roibb(1)-1;
    trx{j}.y=trx{j}.y+roibb(3)-1;
end

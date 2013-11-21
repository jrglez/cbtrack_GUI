function [isfore_in,cc_ind,flies_ind,trx] = ChangeParams_GUI(im,bgmed,dbkgd,roidata,roiparams,tracking_params)
% do background subtraction to count flies in each roi
nrois = numel(roidata.centerx);
areassample = cell(nrois,1);
cc_ind=cell(nrois,1);
flies_ind=cell(nrois,1);
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

% threshold
isfore = dbkgd >= tracking_params.bgthresh;
isfore_in=isfore; isfore_in(~roidata.inrois_all)=1;

for j = 1:nrois,
    roibb = roidata.roibbs(j,:);
    isforebb = isfore(roibb(3):roibb(4),roibb(1):roibb(2));
    isforebb(~roidata.inrois{j}) = false;
    cc = bwconncomp(isforebb);
    areassample{j} = cellfun(@numel,cc.PixelIdxList);    
    isfly=[areassample{j}]>=tracking_params.minccarea;
    [y,x]=cellfun(@(x) ind2sub(size(isforebb),x),cc.PixelIdxList,'UniformOutpu',0);
    cc_ind{j}=cellfun(@(x,y) cat(2,x+roibb(1)-1,y+roibb(3)-1),x,y,'UniformOutpu',0);
    flies_ind{j}=cellfun(@(x,y) cat(2,x+roibb(1)-1,y+roibb(3)-1),x(isfly),y(isfly),'UniformOutpu',0);

    dbkgdbb = double(dbkgd(roibb(3):roibb(4),roibb(1):roibb(2)));
    dbkgdbb(~roidata.inrois{j}) = 0;
    isforebb(~roidata.inrois{j}) = false;
    pred.isfirstframe=1;
    [trx{j},~] = TrackTwoFliesOneFrameOneROI(isforebb,dbkgdbb,pred,trxcurr(j),roidata.nflies_per_roi(j),tracking_params);
    trx{j}.x=trx{j}.x+roibb(1)-1;
    trx{j}.y=trx{j}.y+roibb(3)-1;
end
  

function [trxcurr,pred,pfdatacurr] = Track2FliesWings1Frame(im,dbkgd,...
  isfore_body,iswing,isfore_wing,pred,trxprev,pffdataprev,roidata,params,...
  Wparams,varargin)

trxcurr = trxprev;
pfdatacurr = pffdataprev;
% loop over rois  
for roii = 1:roidata.nrois,

  if isnan(roidata.nflies_per_roi(roii)) || ...
      roidata.nflies_per_roi(roii) == 0 || ...
      roidata.nflies_per_roi(roii) > 2,
    continue;
  end
  
  % crop out roi  
  roibb = roidata.roibbs(roii,:);
  isfore_bodybb = isfore_body(roibb(3):roibb(4),roibb(1):roibb(2));
  iswingbb = iswing(roibb(3):roibb(4),roibb(1):roibb(2));
  isfore_wingbb = isfore_wing(roibb(3):roibb(4),roibb(1):roibb(2));
  dbkgdbb = double(dbkgd(roibb(3):roibb(4),roibb(1):roibb(2)));
  dbkgdbb(~roidata.inrois{roii}) = 0;
  isfore_bodybb(~roidata.inrois{roii}) = false;
  iswingbb(~roidata.inrois{roii}) = false;
  isfore_wingbb(~roidata.inrois{roii}) = false;
  
  npxfore_wing = nnz(isfore_wingbb);

  fore2dbkgdbb = dbkgdbb(isfore_wingbb);
  fore2bodybb = fore2dbkgdbb >= Wparams.mindbody;
  
  % main work
  [trxcurr(roii),pred(roii),pfdatacurr(roii)] = Track2FliesWings1Frame1ROI...
    (im,dbkgdbb,isfore_bodybb,iswingbb,isfore_wingbb,npxfore_wing,...
    fore2bodybb,pred(roii),trxcurr(roii),pfdatacurr(roii),...
    roidata.nflies_per_roi(roii),params,Wparams,varargin{:});
end

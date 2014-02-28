function [wingtrx,debugdata,idxfore_thresh,fore2flywing] = TrackWingsOneFrame_GUI_old(im,bgmodel,isarena,trxcurr,wingtrxprev,params,XGRID,YGRID,debugdata)


%% morphology to get foreground, body wing pixels
[iswing,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,fore2dbkgd,debugdata] = ...
  TrackWings_BackSub(im,bgmodel,isarena,params,debugdata);

[fore2fly,xgrid_isfore,ygrid_isfore,debugdata] = TrackWings_SegmentFlies_GUI_old(im,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,...
  trxcurr,params,XGRID,YGRID,debugdata);

[wingtrx,debugdata,fore2flywing] = TrackWings_FitWings_GUI_old(fore2fly,xgrid_isfore,ygrid_isfore,isfore_thresh,iswing,fore2dbkgd,idxfore_thresh,trxcurr,wingtrxprev,params,debugdata);



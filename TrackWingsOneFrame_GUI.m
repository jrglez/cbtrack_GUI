function [wingtrx,debugdata,idxfore_thresh,fore2flywing] = TrackWingsOneFrame_GUI(im,bgmodel,isarena,trxcurr,params,XGRID,YGRID,debugdata)


%% morphology to get foreground, body wing pixels
[iswing,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,debugdata] = ...
  TrackWings_BackSub(im,bgmodel,isarena,params,debugdata);

[fore2flywing,dthetawing,trxcurr,debugdata] = TrackWings_SegmentFlies_GUI(...
  im,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,iswing,...
  trxcurr,params,XGRID,YGRID,debugdata);

[wingtrx,debugdata] = TrackWings_FitWings_GUI(fore2flywing,dthetawing,idxfore_thresh,trxcurr,params,debugdata);


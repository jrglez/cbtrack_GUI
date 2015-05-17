function [dbkgd,isfore_body,iswing,isfore_wing] = ...
  TrackFlyWings_BackSub(im,bgmodel,params,Wparams,normalize)
cbparams=getappdata(0,'cbparams');

switch cbparams.track.bgmode,
    case 'DARKBKGD',
      dbkgd = imsubtract(im,bgmodel)./normalize;
    case 'LIGHTBKGD',
      dbkgd = imsubtract(bgmodel,im)./normalize;
    case 'OTHERBKGD',
      dbkgd = imabsdiff(im,bgmodel)./normalize;
    otherwise
      error('Unknown background type');
end
dbkgd=imresize(dbkgd,1/cbparams.track.down_factor);

%% morphology to get foreground, body wing pixels
isfore_body = dbkgd >= params.bgthresh;
isfore_body=imopen(isfore_body,params.se_open_body);

isbody_thresh = dbkgd >= Wparams.mindbody;
% se_open = strel('disk',cbparams.track.radius_open_body);
% isbody_thresh = imopen(isbody_thresh,se_open);
isbody = imdilate(isbody_thresh,Wparams.se_dilate_body);

iswing_high = ~isbody & dbkgd >= Wparams.mindwing_high;
iswing_low = ~isbody & dbkgd >= Wparams.mindwing_low;
iswing = imreconstruct(iswing_high,iswing_low,4);
iswing = imopen(iswing,Wparams.se_open_wing);
iswing = imclose(iswing,Wparams.se_open_wing);
iswing = bwareaopen(iswing,Wparams.min_wingcc_area);

isfore_wing = imclose(isbody_thresh | iswing,Wparams.se_dilate_body);

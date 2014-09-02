function [debugdata,trxcurr]=TrackWingsSingle_GUI(trxcurr,bgmodel,isarena,params,im,debugdata)

% choose histogram bins for wing pixel angles for fitting wings
params.edges_dthetawing = linspace(-params.max_wingpx_angle,params.max_wingpx_angle,params.nbins_dthetawing+1);
params.centers_dthetawing = (params.edges_dthetawing(1:end-1)+params.edges_dthetawing(2:end))/2;
params.wing_peak_min_frac = 1/params.nbins_dthetawing*params.wing_peak_min_frac_factor;

% morphology structural elements
params.se_dilate_body = strel('disk',params.radius_dilate_body);
params.se_open_wing = strel('disk',params.radius_open_wing);

% for sub-bin accuracy in fitting the wings
params.subbin_x = (-params.wing_radius_quadfit_bins:params.wing_radius_quadfit_bins)';    

roidata=getappdata(0,'roidata');
[nr,nc,~] = size(im);
nflies = nansum(roidata.nflies_per_roi);
npx = nr*nc; %#ok<NASGU>
%% initialize debug plots

if ~isfield(debugdata,'DEBUG')
    debugdata.DEBUG = 1;
    debugdata.colors = hsv(nflies);
    debugdata.colors = debugdata.colors(randperm(nflies),:);
end
if ~isfield(debugdata,'vid')
    debugdata.vid = 0;
end


[XGRID,YGRID] = meshgrid(1:nc,1:nr);

%% start tracking
  % fit this frame
im=double(im);
debugdata.im = im;
debugdata.track=0;
bgmodel=double(bgmodel);
[iswing,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,debugdata] = TrackWings_BackSub(im,bgmodel,isarena,params,debugdata);
if debugdata.vis>5
    [fore2flywing,dthetawing,trxcurr,debugdata] = TrackWings_SegmentFlies_GUI(im,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,iswing,...
      trxcurr,params,XGRID,YGRID,debugdata);
  if debugdata.vis==8
        [wingtrxcurr,debugdata] = TrackWings_FitWings_GUI(fore2flywing,dthetawing,idxfore_thresh,trxcurr,params,debugdata);
  end
end

if debugdata.vid
    for fly = 1:nflies,    
        wing_anglel = wingtrxcurr(fly).wing_anglel;
        wing_angler = wingtrxcurr(fly).wing_angler;    
        trxcurr(fly).xwingl = trxcurr(fly).x + 4*trxcurr(fly).a.*cos(trxcurr(fly).theta+ pi+wing_anglel);
        trxcurr(fly).ywingl = trxcurr(fly).y + 4*trxcurr(fly).a.*sin(trxcurr(fly).theta+ pi+wing_anglel);
        trxcurr(fly).xwingr = trxcurr(fly).x + 4*trxcurr(fly).a.*cos(trxcurr(fly).theta+ pi+wing_angler);
        trxcurr(fly).ywingr = trxcurr(fly).y + 4*trxcurr(fly).a.*sin(trxcurr(fly).theta+ pi+wing_angler);
    end
end

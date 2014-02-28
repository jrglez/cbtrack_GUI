function debugdata=TrackWingsSingle_GUI(trx,bgmodel,isarena,params,im,debugdata)

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
nrois = numel(trx);
nflies = sum(roidata.nflies_per_roi);
npx = nr*nc; %#ok<NASGU>
%% initialize debug plots

if ~isfield(debugdata,'DEBUG')
    debugdata.DEBUG = 1;
    debugdata.colors = hsv(nflies);
    debugdata.colors = debugdata.colors(randperm(nflies),:);
end

%% allocate
[XGRID,YGRID] = meshgrid(1:nc,1:nr);

% trajectories for the current frame
trxcurr = struct(...
  'x',cell(1,nflies),...
  'y',cell(1,nflies),...
  'a',cell(1,nflies),...
  'b',cell(1,nflies));
  

%% start tracking

k=1;
for iroi = 1:nrois,
    for fly=1:roidata.nflies_per_roi(iroi)
        trxcurr(k).x = trx{iroi}.x(fly);
        trxcurr(k).y = trx{iroi}.y(fly);
        trxcurr(k).a = trx{iroi}.a(fly);
        trxcurr(k).b = trx{iroi}.b(fly);
        trxcurr(k).theta = trx{iroi}.theta(fly);
        k=k+1;
    end
end
  
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
        [~,debugdata] = TrackWings_FitWings_GUI(fore2flywing,dthetawing,idxfore_thresh,trxcurr,params,debugdata);
  end
end


% % store results
% for fly = 1:nflies,    
% trx(fly).wing_anglel = wingtrxcurr(fly).wing_anglel;
% trx(fly).wing_angler = wingtrxcurr(fly).wing_angler;    
% end
% 
% %% add in x, y positions for plotting
% 
% for fly = 1:nflies,    
%   trx(fly).xwingl = trx(fly).x + 4*trx(fly).a.*cos(trx(fly).theta+ pi+trx(fly).wing_anglel);
%   trx(fly).ywingl = trx(fly).y + 4*trx(fly).a.*sin(trx(fly).theta+ pi+trx(fly).wing_anglel);
%   trx(fly).xwingr = trx(fly).x + 4*trx(fly).a.*cos(trx(fly).theta+ pi+trx(fly).wing_angler);
%   trx(fly).ywingr = trx(fly).y + 4*trx(fly).a.*sin(trx(fly).theta+ pi+trx(fly).wing_angler);
% end

function [iswing,isfore_thresh,idxfore_thresh,npxfore_thresh,fore2body,debugdata] = ...
  TrackWings_BackSub_setup(dbkgd,bgmodel,params,debugdata)
%% morphology to get foreground, body wing pixels

isbody_thresh = dbkgd >= params.mindbody;
% se_open = strel('disk',cbparams.track.radius_open_body);
% isbody_thresh = imopen(isbody_thresh,se_open);
isbody = imdilate(isbody_thresh,params.se_dilate_body);
if debugdata.DEBUG && debugdata.vis==3
    DebugPlot_BackSub_IsX(isbody)
end


iswing_high = ~isbody & dbkgd >= params.mindwing_high;
iswing_low = ~isbody & dbkgd >= params.mindwing_low;
iswing = imreconstruct(iswing_high,iswing_low,4);
iswing = imopen(iswing,params.se_open_wing);
iswing = imclose(iswing,params.se_open_wing);
iswing = bwareaopen(iswing,params.min_wingcc_area);
if debugdata.DEBUG && debugdata.vis==4
    DebugPlot_BackSub_IsX(iswing)
end

isfore_thresh = imclose(isbody_thresh | iswing,params.se_dilate_body);
if debugdata.DEBUG && debugdata.vis==5
    DebugPlot_BackSub_IsX(isfore_thresh)
end

%isfore_thresh = dbkgd > params.mindwing_high;
idxfore_thresh = find(isfore_thresh);
npxfore_thresh = nnz(isfore_thresh);

fore2dbkgd = dbkgd(isfore_thresh);
fore2body = fore2dbkgd >= params.mindbody;

if debugdata.DEBUG && debugdata.vis==6,
  DebugPlot_BackSub();
end

    function DebugPlot_BackSub_IsX(X)
      imtmp=uint8(debugdata.im);
      imtmp_r=imtmp; imtmp_r(X)=min(255,imtmp_r(X)*3);
      imtmp=repmat(imtmp,[1,1,3]); imtmp(:,:,1)=imtmp_r;
      set(debugdata.him,'CData',imtmp);
      if isfield(debugdata,'htext')
          delete(debugdata.htext(ishandle(debugdata.htext)));
      end
      if isfield(debugdata,'hwing'),
        delete(debugdata.hwing(ishandle(debugdata.hwing)));
      end
      if isfield(debugdata,'htrough'),
        delete(debugdata.htrough(ishandle(debugdata.htrough)));
      end
      debugdata.htext = [];
      debugdata.hwing = [];
      debugdata.htrough = [];
      drawnow;
  end
  function DebugPlot_BackSub()
      [nr,nc,~] = size(debugdata.im);
      imtmp = repmat(debugdata.im(:),[1,3]);
      imtmp(isbody,1) = min(imtmp(isbody,1)+100,255);
      imtmp(iswing,2) = min(imtmp(iswing,2)+100,255);
      imtmp = uint8(reshape(imtmp,[nr,nc,3]));
      set(debugdata.him,'CData',imtmp);
      if isfield(debugdata,'htext')
          delete(debugdata.htext(ishandle(debugdata.htext)));
      end
      if isfield(debugdata,'hwing'),
        delete(debugdata.hwing(ishandle(debugdata.hwing)));
      end
      if isfield(debugdata,'htrough'),
        delete(debugdata.htrough(ishandle(debugdata.htrough)));
      end
      debugdata.htext = [];
      debugdata.hwing = [];
      debugdata.htrough = [];
      drawnow;
  end
end
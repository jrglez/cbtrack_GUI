function [wingtrx,debugdata] = TrackWings_FitWings_GUI(fore2flywing,dthetawing,idxfore_thresh,trx,params,debugdata)

% initialize output

nflies = numel(trx);
wingtrx = struct('wing_anglel',cell(1,nflies),...
  'wing_angler',cell(1,nflies),...
  'nwingsdetected',cell(1,nflies),...
  'wing_areal',cell(1,nflies),...
  'wing_arear',cell(1,nflies),...
  'wing_trough_angle',cell(1,nflies));

for fly = 1:nflies,
  
  % find pixels that belong to each fly's wings
  if isempty(trx(fly).x),
    continue;
  end

  % fit wings  
  wingtrx(fly) = TrackWings_FitWings_Peak(dthetawing{fly},params);
  
end

% plot

if debugdata.DEBUG && debugdata.vis==8,
  DebugPlot_FitWings();
end

  function DebugPlot_FitWings()
    hvis=get(get(debugdata.haxes,'Parent'),'HandleVisibility');
    set(get(debugdata.haxes,'Parent'),'HandleVisibility','on')
    imtmp = repmat(debugdata.im(:),[1,3]);
    for dfly = 1:nflies,
      idx1 = idxfore_thresh(fore2flywing==dfly);
      imtmp(idx1,:) = min(bsxfun(@plus,imtmp(idx1,:)*3,255*debugdata.colors(dfly,:))/4,255);
    end
    [nr,nc,~] = size(debugdata.im);
    
    set(debugdata.him,'CData',uint8(reshape(imtmp,[nr,nc,3])));
    
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

    for dfly = 1:nflies,
      if isempty(trx(dfly).x),
        continue;
      end
      hold on
      xwing = [nan,trx(dfly).x,nan];
      ywing = [nan,trx(dfly).y,nan];
      wing_angles = [wingtrx(dfly).wing_anglel,wingtrx(dfly).wing_angler];
      xwing([1,3]) = trx(dfly).x + 4*trx(dfly).a*cos(trx(dfly).theta+pi+wing_angles);
      ywing([1,3]) = trx(dfly).y + 4*trx(dfly).a*sin(trx(dfly).theta+pi+wing_angles);
      xtrough = trx(dfly).x+2*trx(dfly).a*cos(trx(dfly).theta+pi+wingtrx(dfly).wing_trough_angle);
      ytrough = trx(dfly).y+2*trx(dfly).a*sin(trx(dfly).theta+pi+wingtrx(dfly).wing_trough_angle);
      debugdata.hwing(end+1) = plot(xwing,ywing,'.-','color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);
      debugdata.htrough(end+1) = plot(xtrough,ytrough,'x','color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);
      %debugdata.htext2(end+1) = text(xwing(1),ywing(1),sprintf('%.1f',wingtrx(dfly).wing_areal));
      %debugdata.htext2(end+1) = text(xwing(3),ywing(3),sprintf('%.1f',wingtrx(dfly).wing_arear));
    end
    
    for dfly = 1:nflies,
      if isempty(trx(dfly).x),
        continue;
      end
      s = sprintf('%d',dfly);
      x = trx(dfly).x;
      y = trx(dfly).y;
      debugdata.htext = [debugdata.htext,text(x,y,s,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on','Color','w','Parent',debugdata.haxes)];
    end
    set(get(debugdata.haxes,'Parent'),'HandleVisibility',hvis)
  end
    if debugdata.track==1
        drawnow
    end
end

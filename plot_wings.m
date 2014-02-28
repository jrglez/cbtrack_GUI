function debugdata=plot_wings(iframe,debugdata,frame)
trackdata=getappdata(0,'trackdata');

hvis=get(get(debugdata.haxes,'Parent'),'HandleVisibility');
set(get(debugdata.haxes,'Parent'),'HandleVisibility','on')
imtmp = repmat(frame(:),[1,3]);
trx=trackdata.trx;
nflies=numel(trx);

idxfore_thresh=trackdata.wingplotdata.idxfore_thresh{iframe};
fore2flywing=trackdata.wingplotdata.fore2flywing{iframe};
for dfly = 1:nflies,
  idx1 = idxfore_thresh(fore2flywing==dfly);
  imtmp(idx1,:) = min(bsxfun(@plus,imtmp(idx1,:)*3,255*debugdata.colors(dfly,:))/4,255);
end
[nr,nc,~] = size(frame);

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
  x=trx(dfly).x(iframe); 
  y=trx(dfly).y(iframe);
  a=trx(dfly).a(iframe);
  theta=trx(dfly).theta(iframe);
  wing_anglel=trx(dfly).wing_anglel(iframe);
  wing_angler=trx(dfly).wing_angler(iframe);
  wing_trough_angle=trackdata.perframedata.wing_trough_angle{dfly}(iframe);
  
  xwing = [nan,x,nan];
  ywing = [nan,y,nan];
  wing_angles = [wing_anglel,wing_angler];
  xwing([1,3]) = x + 4*a*cos(theta+pi+wing_angles);
  ywing([1,3]) = y + 4*a*sin(theta+pi+wing_angles);
  xtrough = x+2*a*cos(theta+pi+wing_trough_angle);
  ytrough = y+2*a*sin(theta+pi+wing_trough_angle);
  debugdata.hwing(end+1) = plot(xwing,ywing,'.-','color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);
  debugdata.htrough(end+1) = plot(xtrough,ytrough,'x','color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);

  s = sprintf('%d',dfly);
  debugdata.htext = [debugdata.htext,text(x,y,s,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on','Color','w','Parent',debugdata.haxes)];
end

set(get(debugdata.haxes,'Parent'),'HandleVisibility',hvis)
if debugdata.play==1
    drawnow
end

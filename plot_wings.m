function debugdata=plot_wings(iframe,debugdata,frame)
trackdata=getappdata(0,'trackdata');

hvis=get(get(debugdata.haxes,'Parent'),'HandleVisibility');
set(get(debugdata.haxes,'Parent'),'HandleVisibility','on')
trx=trackdata.trx;
nflies=numel(trx);

set(debugdata.him,'CData',frame);

if isfield(debugdata,'htext')
    delete(debugdata.htext(ishandle(debugdata.htext)));
end
if isfield(debugdata,'hfly'),
  delete(debugdata.hfly(ishandle(debugdata.hfly)));
end
if isfield(debugdata,'hwing'),
  delete(debugdata.hwing(ishandle(debugdata.hwing)));
end
if isfield(debugdata,'htrough'),
  delete(debugdata.htrough(ishandle(debugdata.htrough)));
end
debugdata.htext = [];
debugdata.hfly = [];
debugdata.hwing = [];
debugdata.htrough = [];

if ~isfield(debugdata,'color') || isempty(debugdata.colors)
        debugdata.colors=lines(nflies);
end

hold on
for dfly = 1:nflies,
  if isempty(trx(dfly).x),
    continue;
  end
  x=trx(dfly).x(iframe); 
  y=trx(dfly).y(iframe);
  a=trx(dfly).a(iframe);
  b=trx(dfly).b(iframe);
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
  debugdata.hfly(end+1) = drawflyo(x,y,theta,a,b,'color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);
  debugdata.hwing(end+1) = plot(xwing,ywing,'.-','color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);
  debugdata.htrough(end+1) = plot(xtrough,ytrough,'x','color',debugdata.colors(dfly,:),'Parent',debugdata.haxes);

  s = sprintf('%d',dfly);
  debugdata.htext = [debugdata.htext,text(x,y,s,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on','Color','w','Parent',debugdata.haxes)];
end
hold off

set(get(debugdata.haxes,'Parent'),'HandleVisibility',hvis)
if debugdata.play==1
    drawnow
end

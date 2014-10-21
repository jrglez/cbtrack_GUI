function [bgmed,bgfixdata] = FixBgModel_auto_GUI(bgmed,handles)
hax=handles.axes_BG;
hroi = [];

[~,~,ncolors] = size(bgmed);
if ncolors > 1,
	mymsgbox(50,190,14,'Helvetica','Not implemented for color images yet','Error','error')
end

bgfixdata = struct;
bgfixdata.xs = {};
bgfixdata.ys = {};
msg_correct=mymsgbox(50,190,14,'Helvetica','Please, select the regions you wish to correct. Press ''Correct'' when you are done.','Correct','help','modal'); %#ok<NASGU>



while true,
  
  bgmedprev = bgmed;
  
  [x,y] = getline(hax,'closed');
  hold(hax,'on')
  hroi(end+1) = plot(hax,x,y,'.-','Color',[.8,0,0],'LineWidth',2); %#ok<AGROW>
  
  bgmed=roifill(bgmed,x,y);

  bgfixdata.xs{end+1} = x;
  bgfixdata.ys{end+1} = y;
  
  set(imhandles(handles.axes_BG),'CData',bgmed);
  set(hroi(end),'Color',[0 1 0])
  
  
  res = questdlg('What next?','What next?','Fix new region','Undo','Finished','Finished');
  if strcmp(res,'Finished'),
    break;
  elseif strcmp(res,'Undo'),
    bgmed = bgmedprev;
    if ishandle(hroi(end)),
      delete(hroi(end));
      hroi(end) = [];
    end
    bgfixdata.xs(end) = [];
    bgfixdata.ys(end) = [];
    set(imhandles(handles.axes_BG),'CData',bgmed);
  end    
  
end
delete(hroi)

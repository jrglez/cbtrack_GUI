function [bgmed,bgfixdata] = FixBgModelGUI(bgmed,moviefile,tracking_params,handles)
hax=handles.axes_BG;
hroi = [];

hplayfmf = playfmf_GUI('moviefile',moviefile);
set(hplayfmf,'Visible','off')

[readframe,nframes,fidfix] = get_readframe_fcn(moviefile); %#ok<ASGLU>

[nr,nc,ncolors] = size(bgmed);
if ncolors > 1,
	mymsgbox(50,190,14,'Helvetica','Not implemented for color images yet','Error','error')
end
[XGRID,YGRID] = meshgrid(1:nc,1:nr);

bgfixdata = struct;
bgfixdata.xs = {};
bgfixdata.ys = {};
msg_correct=mymsgbox(50,190,14,'Helvetica','Please, select the regions you wish to correct. Press ''Correct'' when you are done.','Correct','help','modal'); %#ok<NASGU>



while true,
  
  bgmedprev = bgmed;
  
  [x,y] = getline(hax,'closed');
  hold(hax,'on')
  hroi(end+1) = plot(hax,x,y,'.-','Color',[.8,0,0],'LineWidth',2); %#ok<AGROW>
  
  if ~ishandle(hplayfmf),
    hplayfmf = playfmf('moviefile',moviefile);
  end
    handles.hplayfmf = guidata(hplayfmf);


  holdstate = ishold(handles.hplayfmf.axes_Video);

  hold(handles.hplayfmf.axes_Video,'on');
  hextra = plot(handles.hplayfmf.axes_Video,x,y,'.-','Color',[.8,0,0],'LineWidth',2);
  if ~holdstate,
    hold(handles.hplayfmf.axes_Video,'off');
  end
  set(hplayfmf,'Visible','on')
  waitfor(hplayfmf,'Visible','off')
  startframe=getappdata(0,'startframe');
  endframe=getappdata(0,'endframe');
  hwait=waitbar(0,'Recomputing background model');
  inroi = inpolygon(XGRID,YGRID,x,y);
  if endframe - startframe + 1 <= tracking_params.bg_nframes,
    fs = startframe:endframe;
  else
    fs = unique(round(linspace(startframe,endframe,tracking_params.bg_nframes)));
  end
  
  buffer = readframe(1);
  buffer = buffer(inroi);
  buffer = repmat(buffer,[1,numel(fs)]);
  for i = 1:numel(fs),
    f = fs(i);
    tmp = readframe(f);
    buffer(:,i) = tmp(inroi);
  end
  bgmedcurr = uint8(median(single(buffer),2));

  bgmed(inroi) = bgmedcurr;
  
  if ishandle(hextra),
    delete(hextra);
  end
  
  bgfixdata.xs{end+1} = x;
  bgfixdata.ys{end+1} = y;
  
  waitbar(1,hwait)
  set(imhandles(handles.axes_BG),'CData',bgmed);
  set(hroi(end),'Color',[0 1 0])
  close(hwait)
  
  
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

if fidfix > 0,
  fclose(fidfix);
end
close(hplayfmf)

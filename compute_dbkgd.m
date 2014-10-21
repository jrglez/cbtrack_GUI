function [im,dbkgd]=compute_dbkgd(readframe,nframes,nframessample,tracking_params,bgmed,inrois_all)
experiment=getappdata(0,'experiment');
framessample = round(linspace(tracking_params.bg_firstframe,min(nframes,tracking_params.bg_lastframe),nframessample));
im=cell(1,nframessample);
dbkgd=cell(1,nframessample);

setappdata(0,'allow_stop',false)
hwait=waitbar(0,{['Experiment ',experiment];['Reading frame 0 of ', num2str(nframessample)]},'CreateCancelBtn','cancel_waitbar');

for i = 1:nframessample,
  if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')
    im=[];
    dbkgd=[];
    return
  end  
  waitbar(i/nframessample,hwait,{['Experiment ',experiment];['Reading frame ',num2str(i),' of ', num2str(nframessample)]});
  im{i} = readframe(framessample(i));
  switch tracking_params.bgmode,
    case 'DARKBKGD',
      dbkgd{i} = imsubtract(im{i},bgmed);
    case 'LIGHTBKGD',
      dbkgd{i} = imsubtract(bgmed,im{i});
    case 'OTHERBKGD',
      dbkgd{i} = imabsdiff(im{i},bgmed);
    otherwise
      error('Unknown background type');
  end
end
delete (hwait)
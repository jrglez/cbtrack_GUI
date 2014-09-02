function [im,dbkgd_in]=compute_dbkgd(readframe,nframes,nframessample,bgmode,bgmed,inrois_all)
experiment=getappdata(0,'experiment');
framessample = round(linspace(1,nframes,nframessample));
im=cell(1,nframessample);
dbkgd=cell(1,nframessample);
dbkgd_in=cell(1,nframessample);

setappdata(0,'allow_stop',false)
hwait=waitbar(0,{['Experiment ',experiment];['Reading frame 0 of ', num2str(nframessample)]},'CreateCancelBtn','cancel_waitbar');

for i = 1:nframessample,
  if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')
    im=[];
    dbkgd_in=[];
    return
  end  
  waitbar(i/nframessample,hwait,{['Experiment ',experiment];['Reading frame ',num2str(i),' of ', num2str(nframessample)]});
  im{i} = readframe(framessample(i));
  switch bgmode,
    case 'DARKBKGD',
      dbkgd{i} = imsubtract(im{i},bgmed);
    case 'LIGHTBKGD',
      dbkgd{i} = imsubtract(bgmed,im{i});
    case 'OTHERBKGD',
      dbkgd{i} = imabsdiff(im{i},bgmed);
    otherwise
      error('Unknown background type');
  end
  dbkgd_in{i}=dbkgd{i}; dbkgd_in{i}(~inrois_all)=255;  
end
delete (hwait)
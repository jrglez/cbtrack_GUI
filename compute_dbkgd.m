function [im,dbkgd_in]=compute_dbkgd(readframe,nframes,roiparams,tracking_params,bgmed,roidata)
framessample = round(linspace(1,nframes,roiparams.nframessample));
im=cell(1,roiparams.nframessample);
dbkgd=cell(1,roiparams.nframessample);
dbkgd_in=cell(1,roiparams.nframessample);

hwait=waitbar(0,['Reading frame 0 of ', num2str(roiparams.nframessample)]);

for i = 1:roiparams.nframessample,
  waitbar(i/roiparams.nframessample,hwait,['Reading frame ',num2str(i),' of ', num2str(roiparams.nframessample)]);
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
  dbkgd_in{i}=dbkgd{i}; dbkgd_in{i}(~roidata.inrois_all)=255;  
end
close (hwait)
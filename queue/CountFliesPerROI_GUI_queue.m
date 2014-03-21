function nflies_per_roi = CountFliesPerROI_GUI_queue(readframe,nframes,bgmed,roidata,roiparams,tracking_params)

framessample = round(linspace(1,nframes,roiparams.nframessample));

nrois = roidata.nrois;

experiment=getappdata(0,'experiment');
out=getappdata(0,'out');
logfid=open_log('roi_log',getappdata(0,'cbparams'),out.folder);
fprintf(logfid,'Counting flies per ROI at %s\n',datestr(now,'yyyymmddTHHMMSS'));

% do background subtraction to count flies in each roi
areassample = cell(nrois,roiparams.nframessample);

hwait=waitbar(0,{['Experiment ',experiment];['Counting flies: Analazing frame 0 of ', num2str(roiparams.nframessample)]});

for i = 1:roiparams.nframessample,
  waitbar(i/roiparams.nframessample,hwait,{['Experiment ',experiment];['Counting flies: Analazing frame ',num2str(i),' of ', num2str(roiparams.nframessample)]});  
  im = readframe(framessample(i));
  switch tracking_params.bgmode,
    case 'DARKBKGD',
      dbkgd = imsubtract(im,bgmed);
    case 'LIGHTBKGD',
      dbkgd = imsubtract(bgmed,im);
    case 'OTHERBKGD',
      dbkgd = imabsdiff(im,bgmed);
    otherwise
      error('Unknown background type');
  end

  % threshold
  isfore = dbkgd >= tracking_params.bgthresh;

  for j = 1:nrois,
    roibb = roidata.roibbs(j,:);
    isforebb = isfore(roibb(3):roibb(4),roibb(1):roibb(2));
    isforebb(~roidata.inrois{j}) = false;
    cc = bwconncomp(isforebb);
    areassample{j,i} = cellfun(@numel,cc.PixelIdxList);    
  end
end
close (hwait)

% heuristic: if mode ~= 1, use mode
% otherwise use 99th percentile
nflies_per_roi = nan(1,nrois);
for j = 1:nrois,
  
  if any(roidata.ignore==j),
    nflies_per_roi(j) = nan;
    continue;
  end
  
  nccs = cellfun(@(x) nnz(x >= tracking_params.minccarea),areassample(j,:));
  mode_nccs = mode(nccs);
  if mode_nccs ~= 1,
    nflies_per_roi(j) = mode_nccs;
  else
    nflies_per_roi(j) = round(prctile(nccs,99));
  end
end

fprintf(logfid,'nflies\tnrois\n');
for i = 0:2,
  fprintf(logfid,'%d\t%d\n',i,nnz(nflies_per_roi==i));
end
fprintf(logfid,'>2\t%d\n',nnz(nflies_per_roi>2));
fprintf(logfid,'ignored\t%d\n',nnz(isnan(nflies_per_roi)));
fprintf(logfid,'\n');
fprintf(logfid,'Finished counting flies per ROI at %s.\n',datestr(now,'yyyymmddTHHMMSS'));
if logfid > 1,
  fclose(logfid);
end






function [nflies_per_roi,im,dbkgd_in,isfore_in,cc_ind,flies_ind,trx] = CountFliesPerROI_GUI(readframe,bgmed,nframes,roidata,rigbowl,roiparams,tracking_params)

nrois = numel(roidata.centerx);

% do background subtraction to count flies in each roi
framessample = round(linspace(1,nframes,roiparams.nframessample));
areassample = cell(nrois,roiparams.nframessample);
im=cell(1,roiparams.nframessample);
dbkgd=cell(1,roiparams.nframessample);
dbkgd_in=cell(1,roiparams.nframessample);
isfore=cell(1,roiparams.nframessample);
isfore_in=cell(1,roiparams.nframessample);
cc_ind=cell(nrois,roiparams.nframessample);
flies_ind=cell(nrois,roiparams.nframessample);
trx=cell(nrois,roiparams.nframessample);
hwait=waitbar(0,['Counting flies: Analazing frame 0 of ', num2str(roiparams.nframessample)]);

for i = 1:roiparams.nframessample,
  waitbar(i/roiparams.nframessample,hwait,['Counting flies: Analazing frame ',num2str(i),' of ', num2str(roiparams.nframessample)]);
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
  
  % threshold
  isfore{i} = dbkgd{i} >= tracking_params.bgthresh;
  isfore_in{i}=isfore{i}; isfore_in{i}(~roidata.inrois_all)=1;

  for j = 1:nrois,
    roibb = roidata.roibbs(j,:);
    isforebb = isfore{i}(roibb(3):roibb(4),roibb(1):roibb(2));
    isforebb(~roidata.inrois{j}) = false;
    cc = bwconncomp(isforebb);
    areassample{j,i} = cellfun(@numel,cc.PixelIdxList);    
    isfly=[areassample{j,i}]>=tracking_params.minccarea;
    [y,x]=cellfun(@(x) ind2sub(size(isforebb),x),cc.PixelIdxList,'UniformOutpu',0);
    cc_ind{j,i}=cellfun(@(x,y) cat(2,x+roibb(1)-1,y+roibb(3)-1),x,y,'UniformOutpu',0);
    flies_ind{j,i}=cellfun(@(x,y) cat(2,x+roibb(1)-1,y+roibb(3)-1),x(isfly),y(isfly),'UniformOutpu',0);
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




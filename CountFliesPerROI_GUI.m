function [nflies_per_roi,isfore_in,cc_ind,flies_ind,trx] = CountFliesPerROI_GUI(dbkgd,roidata,roiparams,tracking_params)

nrois = roidata.nrois;

out=getappdata(0,'out');
logfid=open_log('roi_log',getappdata(0,'cbparams'),out.folder);
fprintf(logfid,'Counting flies per ROI at %s\n',datestr(now,'yyyymmddTHHMMSS'));

% do background subtraction to count flies in each roi
areassample = cell(nrois,roiparams.nframessample);
isfore=cell(1,roiparams.nframessample);
isfore_in=cell(1,roiparams.nframessample);
cc_ind=cell(nrois,roiparams.nframessample);
flies_ind=cell(nrois,roiparams.nframessample);
hwait=waitbar(0,['Counting flies: Analazing frame 0 of ', num2str(roiparams.nframessample)]);

for i = 1:roiparams.nframessample,
  waitbar(i/roiparams.nframessample,hwait,['Counting flies: Analazing frame ',num2str(i),' of ', num2str(roiparams.nframessample)]);  
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

hwait=waitbar(0,['Computing positions: Analazing frame 0 of ', num2str(roiparams.nframessample)]);
trx=cell(nrois,roiparams.nframessample);
for i=1:roiparams.nframessample,
    waitbar(i/roiparams.nframessample,hwait,['Computing positions: Analazing frame ',num2str(i),' of ', num2str(roiparams.nframessample)]);
    trx(:,i)=fit_to_ellipse(roidata,nflies_per_roi, dbkgd{i}, isfore_in{i},tracking_params);
end
close (hwait);

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






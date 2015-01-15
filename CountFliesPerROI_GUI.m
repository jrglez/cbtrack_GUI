function [nflies_per_roi,frames,im,dbkgd,trx] = CountFliesPerROI_GUI(frames,roidata,roiparams,tracking_params,dosetwingtrack,vign,H0)

nrois = roidata.nrois;
nframessample = roiparams.nframessample;

experiment=getappdata(0,'experiment');
logfid=open_log('roi_log');
s=sprintf('Counting flies per ROI at %s\n',datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,experiment,s)
hwait=waitbar(0,{['Experiment ',experiment];['Counting flies: Analazing frame 0 of ', num2str(nframessample)]},'CreateCancelBtn','cancel_waitbar');
% read frames if it's empty
if isempty(frames)
    moviefile = getappdata(0,'moviefile');
    [readframe,nframes,fidm] = get_readframe_fcn(moviefile);
    lastframe = min(tracking_params.count_lastframe,nframes);
    framessample = round(linspace(tracking_params.count_firstframe,lastframe,nframessample));
    frames = cell(1,nframessample);
end

% do background subtraction to count flies in each roi
im = cell(1,nframessample);
dbkgd = cell(1,nframessample);
isfore = cell(1,nframessample);
areassample = cell(nrois,nframessample);

BG = getappdata(0,'BG');
bgmed = BG.bgmed;

if tracking_params.normalize
    im_class='double';
elseif iscell(frames)
    im_class=class(frames{1});
else
    im_class=class(frames(1));
end

if tracking_params.normalize
    normalize=bgmed;
else
    normalize=ones(size(bgmed));
end

for i = 1:nframessample,
  if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')  
    nflies_per_roi = [];
    dbkgd = [];
    trx = [];
    return
  end
  waitbar(i/nframessample,hwait,{['Experiment ',experiment];['Counting flies: Analazing frame ',num2str(i),' of ', num2str(nframessample)]});  
  % read frames
  if isempty(frames{i})
      frames{i} = readframe(framessample(i));
  end
  % bg subtraction
  [im{i},dbkgd{i}] = compute_dbkgd1(frames{i},tracking_params,bgmed,roidata.inrois_all,H0,im_class,vign,normalize);
  % threshold
  isfore{i} = dbkgd{i} >= tracking_params.bgthresh;
  se_open = strel('disk',tracking_params.radius_open_body);
  isfore{i} = imopen(isfore{i},se_open);
  
  for j = 1:nrois,
    if any(roidata.ignore==j),
      areassample{i,j} = [];
      continue;
    end
    roibb = roidata.roibbs(j,:);
    roibb([1,3]) =  floor(roibb([1,3])/tracking_params.down_factor);
    roibb([2,4]) =  ceil(roibb([2,4])/tracking_params.down_factor);
    roibb(roibb==0)=1;
    isforebb = isfore{i}(roibb(3):roibb(4),roibb(1):roibb(2));
    inrois = imresize(roidata.inrois{j},1/tracking_params.down_factor);
    isforebb(~inrois) = false;
    cc = bwconncomp(isforebb);
    areassample{j,i} = cellfun(@numel,cc.PixelIdxList);    
  end
end
delete (hwait)

if exist('fidm','var')
    fclose(fidm);
end

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
    nflies_per_roi(j) = round(prctile(nccs,95));
  end
end

if dosetwingtrack
trx=struct('x',[],'y',[],'a',[],'b',[],'theta',[]);
trx=repmat(trx,[nansum(nflies_per_roi),nframessample]);
    hwait=waitbar(0,{['Experiment ',experiment];['Computing positions: Analazing frame 0 of ', num2str(nframessample)]},'CreateCancelBtn','cancel_waitbar');
    for i=1:nframessample,
        if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')  
          trx = [];
          return
        end
        waitbar(i/nframessample,hwait,{['Experiment ',experiment];['Computing positions: Analazing frame ',num2str(i),' of ', num2str(nframessample)]});
        trx(:,i)=fit_to_ellipse_GUI(roidata,nflies_per_roi, dbkgd{i}, isfore{i},tracking_params);
    end
    delete (hwait);
else
    trx=[];
end

s=sprintf('nflies\tnrois\n');
write_log(logfid,experiment,s)
for i = 0:2,
  write_log(logfid,experiment,sprintf('%d\t%d\n',i,nnz(nflies_per_roi==i)));
end
s={sprintf('>2\t%d\n',nnz(nflies_per_roi>2));...
sprintf('ignored\t%d\n',nnz(isnan(nflies_per_roi)));...
sprintf('\n');...
sprintf('Finished counting flies per ROI at %s.\n',datestr(now,'yyyymmddTHHMMSS'))};
write_log(logfid,experiment,s)
if logfid > 1,
  fclose(logfid);
end



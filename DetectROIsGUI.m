function roidata = DetectROIsGUI(bgmed,cbparams,params,handles)

version = '0.1.3';
timestamp = datestr(now,TimestampFormat);

roidata = struct;
roidata.cbdetectrois_version = version;
roidata.cbdetectrois_timestamp = timestamp;

expdirs=getappdata(0,'expdirs');
expdir=expdirs.test{1}; % (expdirs)
out=getappdata(0,'out');
experiment_name = splitdir(expdir,'last');
experiment_name(experiment_name=='_')=' ';

%% open log file

logfid=open_log('roi_log',cbparams,out.folder);

%% reformat roimus
roidata.params = cbparams;
roidata.params.detect_rois=params;

%% detect circles
fprintf(logfid,'Detecting ROIs for %s at %s...\n',experiment_name,timestamp);
[roidata.centerx,roidata.centery,roidata.radii,roidata.scores] = DetectCourtshipBowlROIs(bgmed,params);
nrois = numel(roidata.centerx);
roidata.nrois=nrois;
fprintf(logfid,'Detected %d ROIs with mean radius %f (std = %f, min = %f, max = %f)\n',...
  nrois,mean(roidata.radii),std(roidata.radii,1),min(roidata.radii),max(roidata.radii));

%% compute image to real-world transform

roidata.roidiameter_mm = params.roidiameter_mm;
roidata.pxpermm = nanmean(roidata.radii) / (roidata.roidiameter_mm/2);
fprintf(logfid,'Computed pxpermm = %f\n',roidata.pxpermm);

% find rotations
if isfield(params,'roirows') && nrois>1 && roidata.nrois>numel(fieldnames(params.roirows))
    
  roirownames = fieldnames(params.roirows);
  
  thetas = [];
  for i = 1:numel(roirownames),
    roiscurr = params.roirows.(roirownames{i});
    for roii1 = 1:numel(roiscurr)-1,
      roi1 = roiscurr(roii1);
      for roii2 = roii1+1:numel(roiscurr),
        roi2 = roiscurr(roii2);
        thetas(end+1) = modrange(atan2(roidata.centery(roi2)-roidata.centery(roi1),...
          roidata.centerx(roi2)-roidata.centerx(roi1)),-pi/2,pi/2); %#ok<AGROW>
      end
    end
  end
  
  dtheta = modrange(thetas-thetas(1),-pi,pi);
  meantheta = modrange(thetas(1) + mean(dtheta),-pi,pi);
  
  waitfor(mymsgbox(50,190,14,'Helvetica',['Based on ROI centroids, we want to rotate by ',...
      num2str(meantheta*180/pi),' deg (std = ',num2str(std(dtheta,1)*180/pi),', mn = ',...
      num2str(modrange(thetas(1) + min(dtheta),-pi,pi)*180/pi),', max = ',...
      num2str(modrange(thetas(1) + max(dtheta),-pi,pi)*180/pi),')'],'Warning','warn'))
  fprintf(logfid,'Based on ROI centroids, we want to rotate by %f deg (std = %f, min = %f, max = %f)\n',...
    meantheta*180/pi,std(dtheta,1)*180/pi,modrange(thetas(1) + min(dtheta),-pi,pi)*180/pi,...
    modrange(thetas(1) + max(dtheta),-pi,pi)*180/pi);
  
  didaddrotateby = false;
  if isfield(params,'baserotatebyperrigbowl'),
    rigbowl = '';
    metadatafile = fullfile(expdir,cbparams.dataloc.metadata.filestr);
    if exist(metadatafile,'file'),
      metadata = ReadMetadataFile(metadatafile);
      if isfield(metadata,'rig') && isfield(metadata,'bowl'),
        rigbowl = sprintf('rig%dbowl%s',metadata.rig,metadata.bowl);
      end
    end
    if isempty(rigbowl),
      metadata = parseExpDir(expdir,true);
      if isstruct(metadata) && isfield(metadata,'rig') && isfield(metadata,'bowl'),
        rigbowl = sprintf('rig%dbowl%s',metadata.rig,metadata.bowl);
      end
    end
    if ~isempty(rigbowl) && isfield(params.baserotatebyperrigbowl,rigbowl),
      baserotateby = params.baserotatebyperrigbowl.(rigbowl);
      meantheta = modrange(-meantheta+baserotateby*pi/180,-pi,pi);
      didaddrotateby = true;
      fprintf(logfid,'Adding in baserotateby %f selected for %s\n',baserotateby,rigbowl);
    end
    roidata.rigbowl=rigbowl;
  end
  if ~didaddrotateby && isfield(params,'baserotateby'),
    meantheta = modrange(-meantheta+params.baserotateby*pi/180,-pi,pi);
    fprintf(logfid,'Adding in default baserotateby %f\n',params.baserotateby);
  end
  roidata.rotateby = -meantheta;
  fprintf(logfid,'Final rotateby = %f\n',roidata.rotateby*180/pi);
  
end

%% create masks
fprintf(logfid,'Creating ROI masks...\n');
imwidth=size(bgmed,2);
imheight=size(bgmed,1);
[XGRID,YGRID] = meshgrid(1:imwidth,1:imheight);
roibbs = [max(1,floor(roidata.centerx(:)-roidata.radii(:))),...
  min(imwidth,ceil(roidata.centerx(:)+roidata.radii(:))),...
  max(1,floor(roidata.centery(:)-roidata.radii(:))),...
  min(imheight,ceil(roidata.centery(:)+roidata.radii(:)))];

idxroi = zeros(imheight,imwidth);
inrois = cell(1,nrois);
for i = 1:nrois,
  bb = roibbs(i,:);
  inrois{i} = (XGRID(bb(3):bb(4),bb(1):bb(2)) - roidata.centerx(i)).^2 + ...
    (YGRID(bb(3):bb(4),bb(1):bb(2)) - roidata.centery(i)).^2 ...
    <= roidata.radii(i)^2;
  tmp = idxroi(bb(3):bb(4),bb(1):bb(2));
  tmp(inrois{i}) = i;
  idxroi(bb(3):bb(4),bb(1):bb(2)) = tmp;
end
roidata.roibbs = roibbs;
roidata.idxroi = idxroi;
roidata.inrois = inrois;
roidata.inrois_all=(idxroi~=0);
roidata.isall=false;

%% plot results
colors = jet(nrois)*.7;
axes(handles.axes_ROI)
hold on
handles.hrois=nan(nrois,2);
for i = 1:nrois,
  handles.hrois(i,1)=drawellipse(roidata.centerx(i),roidata.centery(i),0,roidata.radii(i),roidata.radii(i),'Color',colors(i,:));
    handles.hrois(i,2)=text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
      'Color',colors(i,:),'HorizontalAlignment','center','VerticalAlignment','middle');
end

guidata(handles.cbtrackGUI_ROI, handles);

fprintf(logfid,'Finished detecting ROIs at %s.\n',datestr(now,'yyyymmddTHHMMSS'));
if logfid > 1,
  fclose(logfid);
end


function [handles,roidata] = DetectROIsGUI(bgmed,cbparams,params,handles)

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
[yc_s,yc_s_in]=sort(roidata.centery); yc_s=yc_s'; yc_s_in=yc_s_in';
n_row=[find(diff(yc_s)>100);length(yc_s)]; 
rowname='a':'z';
rowname=rowname(1:length(n_row));
roirows=struct;
row_i=1;
for i=1:length(n_row)
    ind_row=yc_s_in(row_i:n_row(i));
    [~,xc_s_in]=sort(roidata.centerx(ind_row)); xc_s_in=xc_s_in';
    ind_row=ind_row(xc_s_in);
    roirows=setfield(roirows,rowname(i),ind_row); %#ok<SFLD>
    row_i=n_row(i)+1;  
end
params.roirows=roirows;

if nrois>1 && roidata.nrois>numel(fieldnames(params.roirows))    
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
  
  if isfield(params,'baserotateby'),
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
handles.hroisT=nan(nrois,1);
for i = 1:nrois,
    ROIpos=[roidata.centerx(i)-roidata.radii(i),roidata.centery(i)-roidata.radii(i),2*roidata.radii(i),2*roidata.radii(i)];
    handles.hrois(i,1)=imellipse(handles.axes_ROI,ROIpos);
    handles.hrois(i,1).setFixedAspectRatioMode(1);
    handles.hrois(i,1).setColor(colors(i,:));
    handles.hroisT(i,1)=text(roidata.centerx(i),roidata.centery(i),['ROI: ',num2str(i)],...
      'Color',colors(i,:),'HorizontalAlignment','center','VerticalAlignment','middle');
end

fprintf(logfid,'Finished detecting ROIs at %s.\n',datestr(now,'yyyymmddTHHMMSS'));
if logfid > 1,
  fclose(logfid);
end


function CourtshipBowlTrack_GUI_debug(handles)
%% parse inputs
% ParseCourtshipBowlParams_GUI;
moviefile=getappdata(0,'moviefile');
cbparams = getappdata(0,'cbparams');
params=cbparams.track;
Wparams=cbparams.wingtrack;

SetBackgroundTypes;
if ischar(params.bgmode) && isfield(bgtypes,params.bgmode),
  params.bgmode = bgtypes.(params.bgmode);
end
restart = getappdata(0,'restart');

if ~isfield(params,'DEBUG'),
  params.DEBUG = 0;
end
if params.dotrackwings || strcmp(params.assignidsby,'wingsize'),
  params.wingtracking_params = cbparams.wingtrack;
end

%% load background model
BG=getappdata(0,'BG');
bgmed=BG.bgmed;
nr=size(imresize(bgmed,1/params.down_factor),1);
nc=size(imresize(bgmed,1/params.down_factor),2);

%% load roi info
roidata=getappdata(0,'roidata');
% resize roidata
roidata_rs=roidata;
roidata_rs.centerx=roidata.centerx/params.down_factor;
roidata_rs.centery=roidata.centery/params.down_factor;
roidata_rs.radii=roidata.radii/params.down_factor;
roidata_rs.pxpermm=roidata.pxpermm/params.down_factor;

roibbs=roidata.roibbs;
roibbs(:,[1 3]) = floor(roibbs(:,[1 3])/params.down_factor);
roibbs(:,[2 4]) = ceil(roibbs(:,[2 4])/params.down_factor);
roibbs(roibbs<1)=1;
roibbs(roibbs(:,2)>nc)=nc;
roibbs(roibbs(:,4)>nr)=nr;

roidata_rs.inrois_all=imresize(roidata.inrois_all,1/params.down_factor);
idxroi = zeros(nr,nc);
inrois = cell(1,roidata.nrois);
for i = 1:roidata.nrois,
  bb = roibbs(i,:);
  inrois{i} = roidata_rs.inrois_all(bb(3):bb(4),bb(1):bb(2));
  tmp = idxroi(bb(3):bb(4),bb(1):bb(2));
  tmp(inrois{i}) = i;
  idxroi(bb(3):bb(4),bb(1):bb(2)) = tmp;
end
roidata_rs.roibbs=roibbs;
roidata_rs.inrois=inrois;
roidata_rs.idxroi=idxroi;


%if ~isappdata(0,'roidata_rs')
setappdata(0,'roidata_rs',roidata_rs);
if params.dosave
  savetemp({'roidata_rs'})
end
%end
%% main function

trackdata = Track2FliesWings(handles,moviefile,bgmed,roidata_rs,params,Wparams,'restart',restart);
if getappdata(0,'iscancel') || getappdata(0,'isskip')
  return
end
setappdata(0,'trackdata',trackdata)


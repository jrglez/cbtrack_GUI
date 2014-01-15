function CourtshipBowlTrack_GUI_save(savefile,frame)
cbparams=getappdata(0,'cbparams');
params=cbparams.track;

trackdata=getappdata(0,'trackdata');
if strcmp(frame,'all')
    iframe=size(trackdata.trxx,3);
else
    iframe = trackdata.t - cbparams.track.firstframetrack + 1;
end

trxx=trackdata.trxx(:,:,1:iframe); %#ok<*NASGU>
trxy=trackdata.trxy(:,:,1:iframe);
trxa=trackdata.trxa(:,:,1:iframe);
trxb=trackdata.trxb(:,:,1:iframe);
trxtheta=trackdata.trxtheta(:,:,1:iframe);
trxarea=trackdata.trxarea(:,:,1:iframe);
istouching=trackdata.istouching(:,1:iframe);
gmm_isbadprior=trackdata.gmm_isbadprior(:,1:iframe);
pred=trackdata.pred;
trxcurr=trackdata.trxcurr;
t=iframe;

moviefile=getappdata(0,'moviefile');

BG=getappdata(0,'BG');
bgmed=BG.bgmed;

roidata=getappdata(0,'roidata');

stage=trackdata.stage;

if exist(savefile,'file'),
  delete(savefile);
end

save(savefile,'trxx','trxy','trxa','trxb','trxtheta','trxarea','istouching','gmm_isbadprior','pred','trxcurr','t','params','moviefile','bgmed','roidata','stage');

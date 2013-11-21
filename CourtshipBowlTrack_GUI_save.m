function CourtshipBowlTrack_GUI_save
trackdata=getappdata(0,'trackdata');
trxx=trackdata.trxx; %#ok<*NASGU>
trxy=trackdata.trxy;
trxa=trackdata.trxa;
trxb=trackdata.trxb;
trxtheta=trackdata.trxtheta;
trxarea=trackdata.trxarea;
istouching=trackdata.istouching;
gmm_isbadprior=trackdata.gmm_isbadprior;
pred=trackdata.pred;
trxcurr=trackdata.trxcurr;
t=trackdata.t;

cbparams=getappdata(0,'cbparams');
params=cbparams.track;

moviefile=getappdata(0,'moviefile');

BG=getappdata(0,'BG');
bgmed=BG.bgmed;

roidata=getappdata(0,'roidata');

stage=trackdata.stage;

[tempfile,tempdir]=uiputfile('.mat');
tempfile = fullfile(tempdir,tempfile);
save(tempfile,'trxx','trxy','trxa','trxb','trxtheta','trxarea','istouching','gmm_isbadprior','pred','trxcurr','t','params','moviefile','bgmed','roidata','stage');

function jspipeline(varargin)

[movFile,settingsDir,appDataFile,roiFile,trackXMLfile,trxFileFixed] = ...
  myparse(varargin,...
  'movFile',[],...
  'settingsDir','/groups/branson/home/leea30/jsp/settings',...
  'appDataFile','appdata.mat',...
  'roiFile','roidata.mat',...
  'trackXMLfile','',... % If supplied, xmlContents.track is overlaid on top of appData.cbparams.track
  'trxFileFixed','' ... % eg trxfile for movFile with manually-fixed IDs, orientations. 
);

if exist(movFile,'file')==0
  error('Cannot find movie: %s.',movFile);
end
if exist(settingsDir,'dir')==0
  error('Cannot find settings dir: %s.',settingsDir);
end
appDataFile = fullfile(settingsDir,appDataFile);
roiFile = fullfile(settingsDir,roiFile);
if exist(appDataFile,'file')==0
  error('Cannot find appData file: %s.',appDataFile);
end
if exist(roiFile,'file')==0
  error('Cannot find ROI file: %s.',roiFile);
end
tfTrxFileFixed = ~isempty(trxFileFixed);
if tfTrxFileFixed
  if exist(trxFileFixed,'file')==0
    error('Cannot find fixed trxfile: %s.',trxFileFixed);
  end
  trxFixed = load(trxFileFixed,'-mat','trx');
  trxFixed = trxFixed.trx;
  if ~strcmpi(trxFixed(1).moviefile,movFile)
    warningNoTrace('trxFixed.moviefile (%s) differs from movFile (%s)',...
      trxFixed(1).moviefile,movFile);
  end
end

% 20170420 hack: to match current desktop results, use up 4 RNs.
rand(4,1);

expdir = fileparts(movFile);
[~,expname] = fileparts(expdir);

fprintf('Movie is %s.\n',movFile);
fprintf('Expdir is %s.\n',expdir);
fprintf('Expname is %s.\n',expname);

% Load app data
fprintf('Clearing appdata...\n');
DTrax.clearAppData;
fprintf('Loading appdata file: %s\n',appDataFile);
ad = load(appDataFile);
ad.expdirs = {expdir};
ad.expdir = expdir;
ad.experiment = expname;
ad.moviefile = movFile;
ad.out.folder = expdir;
ad.out.temp = '';
ad.out.temp_full = '';

if ~isempty(trackXMLfile)
  prmsTrack = ReadXMLParams(trackXMLfile);
  fprintf(1,'Overlaying tracking parameters from: %s\n',trackXMLfile);
  ad.cbparams.track = structoverlay(ad.cbparams.track,prmsTrack.track,...
    'fldsIgnore',{'DEBUG' 'dosave' 'dosetBG' 'dosettrack'});
end

if tfTrxFileFixed
  ad.trxExternal = trxFixed;
else
  ad.trxExternal = [];
end
  

% Set appdata
flds = fieldnames(ad);
for f=flds(:)',f=f{1}; %#ok<FXSET>
  %fprintf(' setting appdata fld: %s\n',f);  
  setappdata(0,f,ad.(f));
end

% BG
cbtrackNOGUI_BG;
% Save BG data
BG = getappdata(0,'BG');
BG.params=ad.cbparams.track; 
out=getappdata(0,'out');
logfid=open_log('bg_log');
savefile = fullfile(out.folder,ad.cbparams.dataloc.bgmat.filestr);
s=sprintf('Saving background model to file %s...\n',savefile);
write_log(logfid,getappdata(0,'experiment'),s)
if exist(savefile,'file'),
  delete(savefile);
end
save(savefile,'-mat','-struct','BG');
%setappdata(0,'P_stage','ROIs');

bgimagefile = fullfile(out.folder,ad.cbparams.dataloc.bgimage.filestr);
s=sprintf('Saving image of background model to file %s...\n\n***\n',bgimagefile);
switch class(BG.bgmed)
  case {'double' 'single'}
    bgmedsave=BG.bgmed/255;
  otherwise
    bgmedsave=BG.bgmed;
end
write_log(logfid,getappdata(0,'experiment'),s)
imwrite(bgmedsave,bgimagefile,'png');
if logfid > 1,
  fclose(logfid);
end

% ROIs
setappdata(0,'usefiles',1);
cbtrackNOGUI_ROI('roifile',roiFile);
setappdata(0,'usefiles',0);

% Tracking
setappdata(0,'button','track');
cbtrackGUI_tracker_NOvideo;

WriteParams;
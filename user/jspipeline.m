function jspipeline(varargin)

[movFile,appDataFile,roiFile] = myparse(varargin,...
  'movFile',[],...
  'appDataFile','f:\jspr\settings\appdata.mat',...
  'roiFile','f:\jspr\settings\roidata.mat');

if exist(movFile,'file')==0
  error('Cannot find movie: %s.',movFile);
end
expdir = fileparts(movFile);
[~,expname] = fileparts(expdir);

fprintf('Movie is %s.\n',movFile);
fprintf('Expdir is %s.\n',expdir);
fprintf('Expname is %s.\n',expname);

% Set the app data
fprintf('Loading appdata file: %s\n',appDataFile);
ad = load(appDataFile);
ad = ad.ad;
ad.expdirs = {expdir};
ad.expdir = expdir;
ad.experiment = expname;
ad.moviefile = movFile;
ad.out.folder = expdir;
ad.out.temp = '';
ad.out.temp_full = '';
flds = fieldnames(ad);
for f=flds(:)',f=f{1}; %#ok<FXSET>
  fprintf(' setting appdata fld: %s\n',f);  
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

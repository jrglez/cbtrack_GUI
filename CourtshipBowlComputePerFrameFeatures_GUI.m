function pffdata = CourtshipBowlComputePerFrameFeatures_GUI(forcecompute)

version = '0.1.2';
timestamp = datestr(now,TimestampFormat);
expdirs=getappdata(0,'expdirs');
expdir=expdirs.test{1}; %(expdirs)
analysis_protocol=getappdata(0,'analysis_protocol');
cbparams = getappdata(0,'cbparams');
out=getappdata(0,'out');


pffdata = struct;
pffdata.cbpff_version = version;
pffdata.cbpff_timestamp = timestamp;

perframefns={};
perframe_params = cbparams.compute_perframe_features;
pffdata.perframe_params = perframe_params;
pffdata.forcecompute = forcecompute;

%% load the trx

fprintf('Initializing trx...\n');

% uses the Trx code in JAABA
trx = Trx('trxfilestr',cbparams.dataloc.trx.filestr,...
  'perframedir',cbparams.dataloc.perframedir.filestr,...
  'moviefilestr',cbparams.dataloc.movie.filestr,...
  'perframe_params',perframe_params);

fprintf('Loading trajectories for %s...\n',expdir);

trx.AddExpDir(expdir,'openmovie',false);

%% log file
logfid=open_log('perframefeature_log',cbparams,out.folder);
fprintf(logfid,'\n\n***\nRunning CourtshipBowlComputePerFrameFeatures version %s analysis_protocol %s at %s\n',version,analysis_protocol,timestamp);
pffdata.analysis_protocol = analysis_protocol;


%% compute per-frame features

if isempty(perframefns),
  perframefns = perframe_params.perframefns;
end
nfns = numel(perframefns);

fprintf(logfid,'Computing %d per-frame features:\n',nfns);
fprintf(logfid,'%s\n',perframefns{:});

% clean this data to force computation
if forcecompute,
  
  tmp = dir(fullfile(out.folder,cbparams.dataloc.perframedir.filestr,'*.mat'));
  if ~isempty(tmp),
    fprintf(logfid,'Deleting %d per-frame feature mat files:\n',numel(tmp));
    fprintf(logfid,'%s\n',tmp.name);
  end  
  %deletefns = setdiff(perframefns,Trx.TrajectoryFieldNames());
  trx.CleanPerFrameData();
end

% existing pf data
tmp = dir(fullfile(out.folder,cbparams.dataloc.perframedir.filestr,'*.mat'));
pffdata.existing_pffs = regexprep({tmp.name},'\.mat','');
if ~isempty(pffdata.existing_pffs),
  fprintf(logfid,'%d per-frame features exist already:\n',numel(pffdata.existing_pffs));
  fprintf(logfid,'%s\n',tmp.name);
end

% compute each
set(0,'DefaultTextInterpreter','none')
hwait=waitbar(0,'Computing Perframe Features','CreateCancelBtn','setappdata(0,''cancel_hwait'',1)');
for i = 1:nfns,
  waitbar(i/nfns,hwait,['Computing ',perframefns{i}]);
  fn = perframefns{i};
  fprintf(logfid,'Computing %s...\n',fn);
  trx.(fn); 
end
if ishandle(hwait)
    delete(hwait)
end
pffdata.perframefns = perframefns;

%% save to info file
filename = fullfile(out.folder,cbparams.dataloc.perframefeaturedatamat.filestr);
fprintf(logfid,'Saving info to mat file %s...\n',filename);
if exist(filename,'file'),
  delete(filename);
end
save(filename,'-struct','pffdata');

%% close log

fprintf(logfid,'Finished running CourtshipBowlComputePerFrameFeatures at %s.\n',datestr(now,'yyyymmddTHHMMSS'));

if logfid > 1,
  fclose(logfid);
end


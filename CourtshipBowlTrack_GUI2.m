function CourtshipBowlTrack_GUI2
version = '0.1.2';
timestamp = datestr(now,TimestampFormat);

%% parse inputs
% ParseCourtshipBowlParams_GUI;
expdir=getappdata(0,'expdir');
experiment=getappdata(0,'experiment');
out=getappdata(0,'out');
analysis_protocol=getappdata(0,'analysis_protocol');
moviefile=getappdata(0,'moviefile');
cbparams = getappdata(0,'cbparams');
params=cbparams.track;
metadatafile = fullfile(expdir,cbparams.dataloc.metadata.filestr);
metadata = ReadMetadataFile(metadatafile);

logfid=open_log('bg_log',cbparams,out.folder);

SetBackgroundTypes;
if ischar(params.bgmode) && isfield(bgtypes,params.bgmode),
  params.bgmode = bgtypes.(params.bgmode);
end
restart = getappdata(0,'restart');

if ~isfield(params,'DEBUG'),
  params.DEBUG = 0;
end
params.dotrackwings=1;
if params.dotrackwings || strcmp(params.assignidsby,'wingsize'),
  params.wingtracking_params = cbparams.wingtrack;
end

%% load background model
BG=getappdata(0,'BG');
bgmed=BG.bgmed;

%% load roi info
roidata=getappdata(0,'roidata');

%% Secondary tracking
fprintf(logfid,'Starting secondary tracking at %s for experiment %s.\n',datestr(now,'yyyymmddTHHMMSS'),experiment);
trackdata=TrackTwoFlies_GUI_debug2(moviefile,bgmed,roidata,params,'restart',restart);
iscancel=getappdata(0,'iscancel');
if iscancel
    return
end
trackdata.courtshipbowltrack_version = version;
trackdata.courtshipbowltrack_timestamp = timestamp;
trackdata.analysis_protocol = analysis_protocol;
trackdata.experiment=experiment;
trackdata.params = params;
trx = trackdata.trx; %#ok<NASGU>
timestamps = trackdata.timestamps; %#ok<NASGU>

% trx
outfilename = fullfile(out.folder,cbparams.dataloc.trx.filestr);
fprintf(logfid,'Saving final traking results to file %s...\n',outfilename);
if exist(outfilename,'file'),
  delete(outfilename);
end
save(outfilename,'trx','timestamps');

% perframe data
perframedir = fullfile(out.folder,cbparams.dataloc.perframedir.filestr);
fprintf(logfid,'Saving a bit of per-frame data to directory %s...\n',perframedir);
if ~exist(perframedir,'dir'),
  mkdir(perframedir);
end
perframefns = fieldnames(trackdata.perframedata);
for i = 1:numel(perframefns),
  perframefn = perframefns{i};
  filename = fullfile(perframedir,[perframefn,'.mat']);
  if exist(filename,'file'),
    delete(filename);
  end
  data = trackdata.perframedata.(perframefn); %#ok<NASGU>
  units = trackdata.perframeunits.(perframefn); %#ok<NASGU>
  save(filename,'data','units');
end
% also save sex
perframefns = {'sex','x_mm','y_mm','a_mm','b_mm','theta_mm','x','y','a','b','theta','timestamps','dt'};
for i = 1:numel(perframefns),
  perframefn = perframefns{i};
  filename = fullfile(perframedir,[perframefn,'.mat']);
  if strcmp(perframefn,'sex') && ~isfield(trackdata.trx,'sex'),
    data = cell(1,numel(trackdata.trx));
    if isfield(metadata,'gender') && ismember(lower(metadata.gender),{'m','b'}),
      gender = metadata.gender;
    else
      gender = '?';
    end
    for fly = 1:numel(trackdata.trx),
      data{fly} = repmat(gender,[1,trackdata.trx(fly).nframes]);
    end
    units = parseunits('unit'); %#ok<NASGU>
  elseif ~isfield(trackdata.trx,perframefn) || ~isfield(trackdata.perframeunits,perframefn),
    continue;
  else
    data = {trackdata.trx.(perframefn)}; %#ok<NASGU>
    units = trackdata.perframeunits.(perframefn);     %#ok<NASGU>
  end
  save(filename,'data','units');

end

setappdata(0,'trackdata',trackdata)

% tracking data without the trx
trackdata = rmfield(trackdata,{'trx','timestamps','perframedata','perframeunits'});
cbparams.dataloc.trackingdatamat.filestr='trackingdata.mat';
outfilename = fullfile(out.folder,cbparams.dataloc.trackingdatamat.filestr);
save(outfilename,'-struct','trackdata');
setappdata(0,'trackdata',trackdata)
%% close log file

fprintf(logfid,'Finished secondary tracking at %s for experiment %s.\n',datestr(now,'yyyymmddTHHMMSS'),experiment);
if logfid > 1,
  fclose(logfid);
end

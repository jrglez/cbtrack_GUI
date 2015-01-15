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
if exist(metadatafile,'file')
    metadata = ReadMetadataFile(metadatafile);
else
    metadata = [];
end

logfid=open_log('track_log');

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
roidata=getappdata(0,'roidata_rs');

%% Secondary tracking
s=sprintf('Starting secondary tracking at %s for experiment %s.\n',datestr(now,'yyyymmddTHHMMSS'),experiment);
write_log(logfid,experiment,s)
trackdata=Track2FliesWings2(moviefile,bgmed,roidata,params,'restart',restart);
if getappdata(0,'iscancel') || getappdata(0,'isskip') || ~strcmp(getappdata(0,'button'),'track')
    return
end
trackdata.courtshipbowltrack_version = version;
trackdata.courtshipbowltrack_timestamp = timestamp;
trackdata.analysis_protocol = analysis_protocol;
trackdata.experiment=experiment;
trackdata.params = params;
trx = trackdata.trx; 
timestamps = trackdata.timestamps; %#ok<NASGU>

% trx
% convert trx to the original size;
for i=1:numel(trx)
    trx(i).x = (trx(i).x-0.5)*cbparams.track.down_factor;
    trx(i).y = (trx(i).y-0.5)*cbparams.track.down_factor;
    trx(i).a = trx(i).a*cbparams.track.down_factor;
    trx(i).b = trx(i).b*cbparams.track.down_factor;
    if isfield(trx(i),'xwingl')
        trx(i).xwingl = (trx(i).xwingl-0.5)*cbparams.track.down_factor;
        trx(i).ywingl = (trx(i).ywingl-0.5)*cbparams.track.down_factor;
        trx(i).xwingr = (trx(i).xwingr-0.5)*cbparams.track.down_factor;
        trx(i).ywingr = (trx(i).ywingr-0.5)*cbparams.track.down_factor;
    end
end
outfilename = fullfile(out.folder,cbparams.dataloc.trx.filestr);
s=sprintf('Saving final traking results to file %s...\n',outfilename);
write_log(logfid,experiment,s)
if exist(outfilename,'file'),
  delete(outfilename);
end
save(outfilename,'trx','timestamps');

% perframe data
perframedir = fullfile(out.folder,cbparams.dataloc.perframedir.filestr);
trackdata.perframeunits = struct(...
  'nwingsdetected',parseunits('unit'),...
  'wing_areal',parseunits('px^2'),...
  'wing_arear',parseunits('px^2'),...
  'wing_trough_angle',parseunits('rad'));

pfd_files=dir(perframedir);
if ~isempty(pfd_files)
    delete(fullfile(perframedir,'*'))
end
if isfield(trackdata,'perframedata')
    s=sprintf('Saving a bit of per-frame data to directory %s...\n',perframedir);
    write_log(logfid,experiment,s)
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
  elseif ~isfield(trackdata.trx,perframefn) || ~isfield(trackdata,'perframeunits') || ~isfield(trackdata.perframeunits,perframefn),
    continue;
  else
    data = {trackdata.trx.(perframefn)}; %#ok<NASGU>
    units = trackdata.perframeunits.(perframefn);     %#ok<NASGU>
  end
  save(filename,'data','units');

end

setappdata(0,'trackdata',trackdata)

% tracking data without the trx
%trackdata = rmfield(trackdata,{'trx','timestamps','perframedata','perframeunits'}); % TO DO: cuando arregle el bug relacionado con esto, incluir trx en los fields que eliminar
cbparams.dataloc.trackingdatamat.filestr='trackingdata.mat';
outfilename = fullfile(out.folder,cbparams.dataloc.trackingdatamat.filestr);
save(outfilename,'-struct','trackdata');
setappdata(0,'trackdata',trackdata)
setappdata(0,'next',true)
setappdata(0,'button','')
setappdata(0,'P_stage','results_movie')
%% close log file

s=sprintf('Finished secondary tracking at %s for experiment %s.\n',datestr(now,'yyyymmddTHHMMSS'),experiment);
write_log(logfid,experiment,s)
if logfid > 1,
  fclose(logfid);
end

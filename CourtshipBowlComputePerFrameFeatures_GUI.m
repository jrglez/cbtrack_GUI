function pffdata = CourtshipBowlComputePerFrameFeatures_GUI(forcecompute)

version = '0.1.2';
timestamp = datestr(now,TimestampFormat);
analysis_protocol=getappdata(0,'analysis_protocol');
cbparams = getappdata(0,'cbparams');
experiment=getappdata(0,'experiment');
out=getappdata(0,'out');


pffdata = struct;
pffdata.cbpff_version = version;
pffdata.cbpff_timestamp = timestamp;

perframefns={};
perframe_params = cbparams.compute_perframe_features;
pffdata.perframe_params = perframe_params;
pffdata.forcecompute = forcecompute;
%% log file
logfid=open_log('perframefeature_log');
s=sprintf('\n\n***\nRunning CourtshipBowlComputePerFrameFeatures version %s experiment %s at %s\n',version,experiment,timestamp);
write_log(logfid,experiment,s)
pffdata.analysis_protocol = analysis_protocol;
pffdata.experiment=experiment;

%% load the trx

s=sprintf('Initializing trx...\n');
write_log(logfid,experiment,s)
% uses the Trx code in JAABA
trx = Trx('trxfilestr',cbparams.dataloc.trx.filestr,...
  'perframedir',cbparams.dataloc.perframedir.filestr,...
  'moviefilestr',cbparams.dataloc.movie.filestr,...
  'perframe_params',perframe_params);

s=sprintf('Loading trajectories for %s...\n',experiment);
write_log(logfid,experiment,s)

trx.AddExpDir(out.folder,'openmovie',false);

%% compute per-frame features

if isempty(perframefns),
  if ~isempty(perframe_params.perframefns) && cbparams.track.dotrack
    perframefns = perframe_params.perframefns;
    if cbparams.track.dotrackwings
        wingfns = {'dangle_biggest_wing';'dangle_smallest_wing';'darea_inmost_wing';...
            'darea_outmost_wing';'dmax_wing_angle';'dmax_wing_area';...
            'dmin_wing_angle';'dmin_wing_area';'dwing_angle_diff';...
            'dwing_angle_imbalance';'max_absdwing_angle';'max_absdwing_area';...
            'max_dwing_angle_in';'max_dwing_angle_out';'min_absdwing_angle';...
            'min_absdwing_area';'min_dwing_angle_in';'min_dwing_angle_out'};
        [~,iswingfn] = intersect(perframefns,wingfns);
        perframefns(iswingfn) = [];
    end
  else
    perframefns = {};
  end
end
nfns = numel(perframefns);

s={sprintf('Computing %d per-frame features:\n',nfns);...
    sprintf('%s\n',perframefns{:})};
write_log(logfid,experiment,s)

% clean this data to force computation
if forcecompute,
  
  tmp = dir(fullfile(out.folder,cbparams.dataloc.perframedir.filestr,'*.mat'));
  if ~isempty(tmp),
    s={sprintf('Deleting %d per-frame feature mat files:\n',numel(tmp));...
        sprintf('%s\n',tmp.name)};
    write_log(logfid,experiment,s)
  end  
  %deletefns = setdiff(perframefns,Trx.TrajectoryFieldNames());
  trx.CleanPerFrameData();
end

% existing pf data
tmp = dir(fullfile(out.folder,cbparams.dataloc.perframedir.filestr,'*.mat'));
pffdata.existing_pffs = regexprep({tmp.name},'\.mat','');
if ~isempty(pffdata.existing_pffs),
  s={sprintf('%d per-frame features exist already:\n',numel(pffdata.existing_pffs));...
      sprintf('%s\n',tmp.name)};
  write_log(logfid,experiment,s)
end

% compute each
set(0,'DefaultTextInterpreter','none')
setappdata(0,'allow_stop',false)
hwait=waitbar(0,{['Experiment ',experiment];'Computing Perframe Features'},'CreateCancelBtn','cancel_waitbar');
for i = 1:nfns,
  if getappdata(0,'iscancel') || getappdata(0,'isskip')
      pffdata=[];
      return
  end
  waitbar(i/nfns,hwait,{['Experiment ',experiment];['Computing ',perframefns{i}]});
  fn = perframefns{i};
  s=sprintf('Computing %s...\n',fn);
  write_log(logfid,experiment,s)
  trx.(fn); 
end
if ishandle(hwait)
    delete(hwait)
end
pffdata.perframefns = perframefns;

%% save to info file
filename = fullfile(out.folder,cbparams.dataloc.perframefeaturedatamat.filestr);
s=sprintf('Saving info to mat file %s...\n',filename);
write_log(logfid,experiment,s)
if exist(filename,'file'),
  delete(filename);
end
save(filename,'-struct','pffdata');

%% close log

s=sprintf('Finished running CourtshipBowlComputePerFrameFeatures for experiment %s at %s.\n',experiment,datestr(now,'yyyymmddTHHMMSS'));
write_log(logfid,experiment,s)
if logfid > 1,
  fclose(logfid);
end


if ~exist(expdir,'dir'),
  error('Experiment directory %s does not exist',expdir);
end

[analysis_protocol,settingsdir,paramsfilestr,leftovers] = ...
  myparse_nocheck(varargin,...
  'analysis_protocol','current',...
  'settingsdir','/Users/juan/Documents/janelia/cbtrack_mod/settings',...
  'paramsfilestr','params.xml');

analysis_protocol_dir = fullfile(settingsdir,analysis_protocol);
real_analysis_protocol_dir = readunixlinks(analysis_protocol_dir);
[~,real_analysis_protocol] = fileparts(analysis_protocol_dir);
cbparams = getappdata(0,'cbparams');
if isempty(cbparams)
    cbparams= ReadXMLParams(fullfile(analysis_protocol_dir,paramsfilestr));
end
if ~isfield(cbparams.track,'DEBUG')
    cbparams.track.DEBUG=false;
end

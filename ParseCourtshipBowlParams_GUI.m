if ~exist(expdir,'dir'),
  error('Experiment directory %s does not exist',expdir);
end

[analysis_protocol,paramsfilestr,leftovers] = ...
  myparse_nocheck(varargin,...
  'analysis_protocol','current',...
  'paramsfilestr','params.xml');

analysis_protocol_dir = expdir;
real_analysis_protocol_dir = readunixlinks(analysis_protocol_dir);
[~,real_analysis_protocol] = fileparts(analysis_protocol_dir);
cbparams = getappdata(0,'cbparams');
if isempty(cbparams)
    cbparams= ReadXMLParams(fullfile(expdir,paramsfilestr));
end

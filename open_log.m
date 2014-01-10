function logfid=open_log(log_type,cbparams,folder)
if isfield(cbparams.dataloc,log_type) && ~isempty(cbparams.dataloc.(log_type).filestr)
  logfile = fullfile(folder,cbparams.dataloc.(log_type).filestr);
  logfid = fopen(logfile,'a');
  if logfid < 1,
    warning('Could not open log file %s\n',logfile);
    logfid = 1;
  end
else
  logfid = 1;
end
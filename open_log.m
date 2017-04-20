function logfid=open_log(log_type)
cbparams=getappdata(0,'cbparams');
out=getappdata(0,'out');


if isempty(out)
  logfid=1;
  return;
end

  
folder=out.folder;
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
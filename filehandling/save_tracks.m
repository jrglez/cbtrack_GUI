% succeeded = save_tracks(trx,matname,...)
% optional arguments:
% 'doappend' = false
% 'varname' = trx
function succeeded = save_tracks(trx,matname,varargin)

[doappend,varname,timestamps] = myparse(varargin,'doappend',false,'varname','trx','timestamps',[]);

succeeded = false;

if isfield(trx,'f2i'),
  trx = rmfield(trx,'f2i');
end

try
  if ~strcmp(varname,'trx'),
    eval(sprintf('%s = trx;',varname));
  end
  if doappend && exist(matname,'file'),
    save('-append',matname,varname,'timestamps');
  else
    save(matname,varname,'timestamps');
  end
catch ME
  logfid=open_log('resultsmovie_log');
  s=sprintf('Error saving %s to %s. Error info:\n',varname,matname);
  write_log(logfid,getappdata(0,'experiment',s)
  disp(ME);
  if logfid>1
      fclose(logfid);
  end
  return;
end
succeeded = true;
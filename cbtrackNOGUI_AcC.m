function [success]=cbtrackNOGUI_AcC(experiment,out,cbparams)
experiment(experiment=='_')=' ';
mysetappdata('experiment',experiment,'out',out,'cbparams',cbparams);

logfid=open_log('automaticchecks_incoming_log');
try
  s=sprintf('AutomaticChecks_Complete for experiment %s...\n',experiment);
  write_log(logfid,experiment,s)
  [success,msgs] = CourtshipBowlAutomaticChecks_Complete(out.folder);
  if ~success,
      s={sprintf('AutomaticChecks_Complete error/warning for experiment %s:\n',experiment);...
          sprintf('%s\n',msgs{:})};
      write_log(logfid,experiment,s)
      if logfid>1
        fclose(logfid);
      end
  end      
catch ME,
  success=false;
  msgs = {sprintf('Error running AutomaticChecks_Complete:\n%s',ME.message)};
  s={sprintf('AutomaticChecks_Complete error/warning for experiment %s:\n',experiment);...
  sprintf('%s\n',msgs{:})};
  write_log(logfid,experiment,s)
  if logfid>1
      fclose(logfid);
  end
end
setappdata(0,'P_stage','done')
if cbparams.track.dosave
    savetemp([]);
end
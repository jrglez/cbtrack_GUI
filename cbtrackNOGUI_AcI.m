function [experiment,success]=cbtrackNOGUI_AcI(expdir,moviefile,analysis_protocol,cbparams,out)
experiment=splitdir(expdir,'last');
experiment(experiment=='_')=' ';

mysetappdata('experiment',experiment,'expdir',expdir,'moviefile',moviefile,...
    'analysis_protocol',analysis_protocol,'out',out,'cbparams',cbparams)

logfid=open_log('automaticchecks_incoming_log');
try
  s=sprintf('AutomaticChecks_Incoming for experiment %s...\n',experiment);
  write_log(logfid,experiment,s)
  [success,msgs,iserror] = CourtshipBowlAutomaticChecks_Incoming_GUI(out.folder,'analysis_protocol',analysis_protocol); %#ok<*NASGU>
  if ~success,
    waitfor(mymsgbox(50,190,14,'Helvetica',sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment),'Warning','warn','modal'))
    s={sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment);...
        sprintf('%s\n',msgs{:})};
    write_log(logfid,experiment,s)
    if logfid>1
      fclose(logfid);
    end
    return;
  end      
catch ME,
  success=false;
  msgs = {sprintf('Error running AutomaticChecks_Incoming:\n%s',ME.message)};
  waitfor(mymsgbox(50,190,14,'Helvetica',sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment),'Warning','warn','modal'))
  s={sprintf('AutomaticChecks_Incoming failed for experiment %s (experiment will be ignored):\n',experiment);...
  sprintf('%s\n',msgs{:})};
  write_log(logfid,experiment,s)
  if logfid>1
      fclose(logfid);
  end
  return;
end
if cbparams.track.dosave
    savetemp({'viewlog','out','expdir','moviefile','experiment','analysis_protocol','P_stage'});
end
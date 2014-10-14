function [success]=cbtrackNOGUI_resultsmovie(experiment,expdir,moviefile,out,analysis_protocol,cbparams)
success = true;
try
    experiment(experiment=='_')=' ';
    mysetappdata('expdir',expdir,'experiment',experiment,'moviefile',moviefile,...
        'out',out,'analysis_protocol',analysis_protocol,'cbparams',cbparams);
    CourtshipBowlMakeResultsMovie_GUI
    if getappdata(0,'iscancel') || getappdata(0,'isskip')
        success=false;
        error_msg='Canceled by the user';
    end
catch ME
    error_msg=ME.message;
    success=false;
end
if ~success
    logfid2=open_log('resultsmovie_log');
    s=sprintf('Results movie could not be created for experiment %s: %s\n',experiment,error_msg);
    write_log(logfid2,experiment,s)
    if logfid2>1
        fclose(logfid2);
    end
end
setappdata(0,'P_stage','PFF')
if cbparams.track.dosave
    savetemp([]);
end
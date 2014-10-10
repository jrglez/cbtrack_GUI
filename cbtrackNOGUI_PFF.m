function [success]=cbtrackNOGUI_PFF(experiment,out,analysis_protocol,cbparams)
success = true;
try
    experiment(experiment=='_')=' ';
    mysetappdata('experiment',experiment,'out',out,'analysis_protocol',analysis_protocol,...
        'cbparams',cbparams) ;   
    [~] = CourtshipBowlComputePerFrameFeatures_GUI(1);
    if getappdata(0,'iscancel') || getappdata(0,'isskip')
        success=false;
        error_msg='Canceled by the user';
    end
catch ME
    error_msg=ME.message;
    success=false;
end
if ~success
    logfid2=open_log('perframefeature_log');
    s=sprintf('Perframe features could not be computed for experiment %s: %s\n',experiment,error_msg);
    write_log(logfid2,experiment,s)
    if logfid2>1
        fclose(logfid2);
    end
end
setappdata(0,'P_stage','AcC')
savetemp([]);
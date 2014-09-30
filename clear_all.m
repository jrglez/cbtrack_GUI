appdatalist={'viewlog','h_log','expdir','experiment','moviefile','out',...
    'analysis_protocol','P_stage','cbparams','restart','GUIscale',...
    'startframe','endframe','BG','roidata','visdata','debugdata_WT',...
    'pff_all','t','trackdata','iscancel','isskip','allow_stop','isstop','twing'};
out=getappdata(0,'out');
experiment=getappdata(0,'experiment');
if ~isempty(out)
    logfid=open_log('main_log');
    s=sprintf('\n\n*****\nCanceling experiment %s at %s.\n*****\n',experiment, datestr(now,'yyyymmddTHHMMSS'));
    write_log(logfid,experiment,s)
end
for i=1:length(appdatalist)
    if isappdata(0,appdatalist{i})
        rmappdata(0,appdatalist{i})
    end
end

all_files=fopen('all');
if ~isempty(all_files)
    for i=1:length(all_files)
        try
            fclose(all_files(i));
        catch ME
            mymsgbox(50,190,14,'Helvetica',['Could not close all the opened files: ',ME.message],'Warning','warn')
        end
    end
end
clear
clearvars -global

appdatalist={'cancel_hwait','expdir','experiment','moviefile','out','analysis_protocol','P_stage','cbparams','restart','GUIscale','startframe','endframe','BG','roidata','visdata','debugdata_WT','pff_all','t','trackdata','iscancel','twing'};
out=getappdata(0,'out');
experiment=getappdata(0,'experiment');
if ~isempty(out)
    logfid=open_log('bg_log',getappdata(0,'cbparams'),out.folder);
    fprintf(logfid,'\n\n*****\nCanceling experiment %s at %s.\n*****\n',experiment, datestr(now,'yyyymmddTHHMMSS'));
end
for i=1:length(appdatalist)
    if isappdata(0,appdatalist{i})
        rmappdata(0,appdatalist{i})
    end
end

all_figs=findall(0);
if length(all_figs)>2
    try
        delete(all_figs(2:end))
    catch ME
        mymsgbox(50,190,14,'Helvetica',['Could not close all the GUI: ',getReport(ME)],'Warning','warn')
    end
end
all_files=fopen('all');
if ~isempty(all_files)
    for i=1:length(all_files)
        try
            fclose(all_files(i));
        catch ME
            mymsgbox(50,190,14,'Helvetica',['Could not close all the opened files: ',getReport(ME)],'Warning','warn')
        end
    end
end
clear
clearvars -global

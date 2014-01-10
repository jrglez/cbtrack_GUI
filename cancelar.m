appdatalist={'cancel_hwait','expdirs','moviefile','out','analysis_protocol','cbparams','restart','GUIscale','startframe','endframe','BG','fidBG','roidata','visdata','pff_all','t','trackdata'};
out=getappdata(0,'out');
if ~isempty(out)
    logfid=open_log('bg_log',getappdata(0,'cbparams'),out.folder);
    fprintf(logfid,'\n\n*****\nCanceling at %s.\n*****\n',datestr(now,'yyyymmddTHHMMSS'));
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

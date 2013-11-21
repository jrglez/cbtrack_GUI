appdatalist={'cancel_hwait','expdirs','moviefile','outdir','analysis_protocol','cbparams','restart','startframe','endframe','BG','fidBG','roidata','trackdata'};
for i=1:length(appdatalist)
    if isappdata(0,appdatalist{i})
        rmappdata(0,appdatalist{i})
    end
end
if exist('fidBG','var') && ~isempty(fidBG)&&  fidBG > 0,
    try
        fclose(fidBG);
    catch ME,
        mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
    end
end

if exist('hObject','var') && ishandle(hObject)
    delete(hObject)
end
close all    
clear

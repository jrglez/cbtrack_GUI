function savetemp(savelist)
if strcmp(savelist,'all')
    savelist={'expdir','moviefile','experiment','analysis_protocol','P_stage', 'cbparams','BG','roidata','visdata','trackdata','debugdata'};
end
savelist2={'P_stage','cbparams'};
out=getappdata(0,'out');

logfid=open_log('track_log',getappdata(0,'cbparams'),out.folder);
fprintf(logfid,'Saving temporary results to file %s...\n\n***\n',out.temp_full);
for i=1:length(savelist)
    if isappdata(0,savelist{i})
        eval([savelist{i},'=getappdata(0,''',savelist{i},''');'])
        if i==1 && ~exist(out.temp_full,'file')
            save(out.temp_full,savelist{i})
        else
            save(out.temp_full,savelist{i},'-append')
        end            
    end
end
for i=1:length(savelist2)
    if isappdata(0,savelist2{i})
        eval([savelist2{i},'=getappdata(0,''',savelist2{i},''');'])
        save(out.temp_full,savelist2{i},'-append')
    end
end


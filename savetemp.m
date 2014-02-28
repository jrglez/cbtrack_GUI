savelist={'expdirs','moviefile','analysis_protocol','P_stage','cbparams','BG','roidata','visdata','trackdata','debugdata'};
out=getappdata(0,'out');
save(out.temp_full,'out')
logfid=open_log('track_log',getappdata(0,'cbparams'),out.folder);
fprintf(logfid,'Saving temporary results to file %s...\n\n***\n',out.temp_full);
for i=1:length(savelist)
    if isappdata(0,savelist{i})
        assignin('caller',savelist{i},getappdata(0,savelist{i}))
        save(out.temp_full,savelist{i},'-append')
    end
end


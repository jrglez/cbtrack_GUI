function cbtrack_MakeResultsMovie_group(fullfiletxt)
[analysis_protocol,paramsfile,expdirs] = ReadGroupedExperimentList_queue(fullfiletxt);

for i=1:numel(expdirs)
    try
        cbtrack_MakeResultsMovie(expdirs{i},analysis_protocol,paramsfile{i})
    catch ME
        sprintf('Could not create results movie for %s: %s',expdirs{i},ME.message)
    end
end
    
function cbtrack_MakeResultsMovie(expdir,analysis_protocol,paramsfile)
experiment = splitdir(expdir,'last');
experiment(experiment=='_')=' ';

if nargin == 1
    analysis_protocol=splitdir(expdir,'last');
    
    paramsfile = fullfile(expdir,'out_params.xml');
end

if ~exist(paramsfile,'file')
    sprintf('Results movie could not be created. Parameters file %s does not exist.',paramsfile)
    return
end
cbparams = ReadXMLParams(paramsfile);

moviefile = fullfile(expdir,cbparams.dataloc.movie.filestr);

out.folder = expdir;

setappdata(0,'expdir',expdir);
setappdata(0,'analysis_protocol',analysis_protocol);
setappdata(0,'experiment',experiment);
setappdata(0,'cbparams',cbparams);
setappdata(0,'moviefile',moviefile);
setappdata(0,'out',out);
setappdata(0,'iscancel',false);
setappdata(0,'isskip',false);
CourtshipBowlMakeResultsMovie_GUI


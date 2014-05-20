function cbtrackNOGUI_BG
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
loadfile=fullfile(out.folder,cbparams.dataloc.bgmat.filestr);
if getappdata(0,'usefiles') && exist(loadfile,'file')
    try
        BG_data=load(loadfile);
        BG_data.isnew=true;
        isempty(BG_data.bgmed)
        BG_data.params.DEBUG=cbparams.track.DEBUG;
        BG_data.params.dosetBG=cbparams.track.dosetBG;
        BG_data.params.dosettrack=cbparams.track.dosettrack;
        BG_data.params.dotrack=cbparams.track.dotrack;
        BG_data.params.dotrackwings=cbparams.track.dotrackwings;
        cbparams.track=BG_data.params;
        logfid=open_log('bg_log',cbparams,out.folder);
        fprintf(logfid,'Loading background data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
        if logfid > 1,
          fclose(logfid);
        end
        setappdata(0,'cbparams',cbparams);
    catch
        logfid=open_log('bg_log',cbparams,out.folder);
        fprintf(logfid,'File %s could not be loaded.',loadfile);
        if logfid > 1,
          fclose(logfid);
        end
        waitfor(mymsgbox(50,190,14,'Helvetica',{['File ', loadfile,' could not be loaded.'];'Trying to compute the background automatically'},'Warning','warn','modal'))
        expdir=getappdata(0,'expdir');
        moviefile=getappdata(0,'moviefile');
        analysis_protocol=getappdata(0,'analysis_protocol');
        BG_data=cbtrackGUI_EstimateBG(expdir,moviefile,cbparams.track,'analysis_protocol',analysis_protocol);
    end
else
    expdir=getappdata(0,'expdir');
    moviefile=getappdata(0,'moviefile');
    analysis_protocol=getappdata(0,'analysis_protocol');
    BG_data=cbtrackGUI_EstimateBG(expdir,moviefile,cbparams.track,'analysis_protocol',analysis_protocol);    
end
BG_data.isnew=true;
setappdata(0,'BG',BG_data);
setappdata(0,'P_stage','ROIs')
if cbparams.track.dosave
    savetemp({'BG'})
end

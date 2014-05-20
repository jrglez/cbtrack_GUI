function cbtrackNOGUI_ROI
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
loadfile=fullfile(out.folder,cbparams.dataloc.roidatamat.filestr);
if getappdata(0,'usefiles') && exist(loadfile,'file')
    try
        roidata=load(loadfile);
        logfid=open_log('roi_log',cbparams,out.folder);
        fprintf(logfid,'Loading ROI data data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
        if logfid > 1,
          fclose(logfid);
        end
        isempty(roidata.cbdetectrois_version);
        roidata.params.dosetROI=cbparams.detect_rois.dosetROI;
        cbparams.detect_rois=roidata.params;
        setappdata(0,'cbparams',cbparams);
    catch
        logfid=open_log('roi_log',cbparams,out.folder);
        fprintf(logfid,'File %s could not be loaded.',loadfile);
        if logfid > 1,
          fclose(logfid);
        end
        waitfor(mymsgbox(50,190,14,'Helvetica',{['File ', loadfile,' could not be loaded.'];'Trying to detect ROIs automatically'},'Warning','warn','modal'))
        BG=getappdata(0,'BG');
        params=cbparams.detect_rois;
        if isempty(params.roimus)
            roidata=AllROI(BG.bgmed);
        else
            roimus=params.roimus;
            params.roimus=[roimus.x',roimus.y'];
            [~,roidata] = DetectROIsGUI(BG.bgmed,cbparams,params,[]);
            roidata.ignore=[];
            params.roimus=roimus;
        end
    end
else
    BG=getappdata(0,'BG');
    params=cbparams.detect_rois;
    if isempty(params.roimus)
        roidata=AllROI(BG.bgmed);
    else
        roimus=params.roimus;
        params.roimus=[roimus.x',roimus.y'];
        [~,roidata] = DetectROIsGUI(BG.bgmed,cbparams,params,[]);
        roidata.ignore=[];
        params.roimus=roimus;
    end
end
roidata.isnew=true;
setappdata(0,'roidata',roidata);
setappdata(0,'P_stage','params')
if cbparams.track.dosave
    savetemp({'roidata'})
end
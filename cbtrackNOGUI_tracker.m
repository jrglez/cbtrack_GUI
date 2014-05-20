function cbtrackNOGUI_tracker
cbparams=getappdata(0,'cbparams');
roidata=getappdata(0,'roidata');
if cbparams.wingtrack.dosetwingtrack || ~isfield(roidata,'nflies_per_roi') || ~getappdata(0,'usefiles')
    moviefile=getappdata(0,'moviefile');
    BG=getappdata(0,'BG');
    roi_params=cbparams.detect_rois;
    tracking_params=cbparams.track;
    [readframe,nframes,fid,~] = get_readframe_fcn(moviefile);
    [visdata.frames,visdata.dbkgd]=...
        compute_dbkgd(readframe,nframes,roi_params.nframessample,...
        tracking_params.bgmode,BG.bgmed,roidata.inrois_all);
    [nflies_per_roi,~,~,~,trx] = ...
        CountFliesPerROI_GUI(visdata.dbkgd,roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack);
    if cbparams.wingtrack.dosetwingtrack
        visdata.trx=struct('x',[],'y',[],'a',[],'b',[],'theta',[]);
        visdata.trx=repmat(visdata.trx,[sum(nflies_per_roi),roi_params.nframessample]);
        k=1;
        for iroi = 1:size(trx,1),
            for fly=1:nflies_per_roi(iroi)
                for t=1:size(trx,2)
                    visdata.trx(k,t).x = trx{iroi,t}.x(fly);
                    visdata.trx(k,t).y = trx{iroi,t}.y(fly);
                    visdata.trx(k,t).a = trx{iroi,t}.a(fly)/2;
                    visdata.trx(k,t).b = trx{iroi,t}.b(fly)/2;
                    visdata.trx(k,t).theta = trx{iroi,t}.theta(fly);           
                end
                k=k+1;
            end
        setappdata(0,'visdata',visdata)
        end
    end
    roidata.nflies_per_roi=nflies_per_roi;
    setappdata(0,'roidata',roidata);
    if fid > 0,
        try
            fclose(fid);
        catch ME,
            mymsgbox(50,190,14,'Helvetica',['Could not close movie file: ',getReport(ME)],'Warning','warn')
        end
    end
    if cbparams.track.dosave
        savetemp({'roidata','visdata'})
    end
else
    out=getappdata(0,'out');
    loadfile=fullfile(out.folder,cbparams.dataloc.roidatamat.filestr);
    logfid=open_log('roi_log',cbparams,out.folder);
    fprintf(logfid,'Loading number of flies from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
    if logfid > 1,
      fclose(logfid);
    end
end
setappdata(0,'P_stage','wing_params')


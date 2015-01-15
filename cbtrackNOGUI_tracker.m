function cbtrackNOGUI_tracker
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
tracking_params=cbparams.track;
roi_params=cbparams.detect_rois;
roidata=getappdata(0,'roidata');
logfid=open_log('roi_log');

BG=getappdata(0,'BG');
if tracking_params.computeBG || isempty(tracking_params.vign_coef)
    vign=ones(size(BG.bgmed));
    tracking_params.vign_coef=[1 0 0 0 0 0 0 0 0 0];
else
    [X,Y]=meshgrid(1:size(BG.bgmed,2),1:size(BG.bgmed,1));
    A=tracking_params.vign_coef;
    vign=ones(size(X)).*A(1)+X.*A(2)+Y.*A(3)+X.^2.*A(4)+X.*Y.*A(5)+Y.^2.*A(6)+X.^3.*A(7)+X.^2.*Y.*A(8)+X.*Y.^2.*A(9)+Y.^3.*A(10);
end
if any(tracking_params.eq_method==[1,2])
    H0=base_hist(tracking_params,roi_params);
else
    H0=[];
end

setappdata(0,'allow_stop',false)
[roidata.nflies_per_roi,visdata.frames,visdata.framesW,visdata.dbkgdW,visdata.trxW] = ...
    CountFliesPerROI_GUI([],roidata,roi_params,tracking_params,cbparams.wingtrack.dosetwingtrack,vign,H0);
if getappdata(0,'iscancel') || getappdata(0,'isskip')
    return
end 
if cbparams.wingtrack.dosetwingtrack
    setappdata(0,'visdata',visdata)
else
    visdata = []; %#ok<NASGU>
end
setappdata(0,'roidata',roidata);

if cbparams.wingtrack.dosetwingtrack
    setappdata(0,'P_stage','wing_params')
else
    setappdata(0,'P_stage','track1')
end
setappdata(0,'vign',vign)
setappdata(0,'H0',H0);
setappdata(0,'isnew',true)
setappdata(0,'button','wing')

if cbparams.track.dosave
    savetemp({'roidata','visdata','vign','H0'})
end

savefile = fullfile(out.folder,cbparams.dataloc.roidatamat.filestr);
s=sprintf('Saving ROI data to file %s...\n',savefile);
write_log(logfid,getappdata(0,'experiment'),s)
if exist(savefile,'file'),
      delete(savefile);
end
save(savefile,'-struct','roidata');
if logfid > 1,
  fclose(logfid);
end

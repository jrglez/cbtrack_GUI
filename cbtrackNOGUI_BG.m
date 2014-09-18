function cbtrackNOGUI_BG
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
loadfile=fullfile(out.folder,cbparams.dataloc.bgmat.filestr);
if getappdata(0,'usefiles') && exist(loadfile,'file')
    try
        BG_data=load(loadfile);
        BG_data.isnew=true;
        isempty(BG_data.bgmed);
        cbparams.track.bg_lastframe=BG_data.params.bg_lastframe;
        cbparams.track.bg_nframes=BG_data.params.bg_nframes;
        cbparams.track.bgmode=BG_data.params.bgmode;
        cbparams.track.computeBG=BG_data.params.computeBG;
        BG_data.params=cbparams.track;
        logfid=open_log('bg_log');
        s=sprintf('Loading background data from %s at %s\n',loadfile,datestr(now,'yyyymmddTHHMMSS'));
        write_log(logfid,getappdata(0,'experiment'),s)
        if logfid > 1,
          fclose(logfid);
        end
        setappdata(0,'cbparams',cbparams);
    catch
        logfid=open_log('bg_log');
        s=sprintf('File %s could not be loaded.',loadfile);
        if logfid > 1,
          fclose(logfid);
        end
        waitfor(mymsgbox(50,190,14,'Helvetica',{['File ', loadfile,' could not be loaded.'];'Trying to compute the background automatically'},'Warning','warn','modal'))
        expdir=getappdata(0,'expdir');
        moviefile=getappdata(0,'moviefile');
        analysis_protocol=getappdata(0,'analysis_protocol');
        if cbparams.track.computeBG
            setappdata(0,'allow_stop',false);
            BG_data=cbtrackGUI_EstimateBG(expdir,moviefile,cbparams.track,'analysis_protocol',analysis_protocol);
            if getappdata(0,'iscancel') || getappdata(0,'isskip')
                return
            end
        else
            [readframe,~,fid,~] = get_readframe_fcn(getappdata(0,'moviefile')); %#ok<*NASGU>
            im = readframe(1);
            BG_data.cbestimatebg_version='Not computed';
            BG_data.cbestimatebg_timestamp=datestr(now,TimestampFormat);
            BG_data.analysis_protocol=getappdata(0,'analysis_protocol');
            BG_data.bgmed=255*ones(size(im));
            BG_data.bgmed=any_class(BG_data.bgmed,class(im));
            if fid > 1,
                fclose(fid);
            end
        end
    end
else
    expdir=getappdata(0,'expdir');
    moviefile=getappdata(0,'moviefile');
    analysis_protocol=getappdata(0,'analysis_protocol');
    if cbparams.track.computeBG
        setappdata(0,'allow_stop',false)
        BG_data=cbtrackGUI_EstimateBG(expdir,moviefile,cbparams.track,'analysis_protocol',analysis_protocol);
        if getappdata(0,'iscancel') || getappdata(0,'isskip')
            return
        end
    else
        [readframe,~,fid,~] = get_readframe_fcn(getappdata(0,'moviefile')); %#ok<*NASGU>
        im = readframe(1);
        BG_data.cbestimatebg_version='Not computed';
        BG_data.cbestimatebg_timestamp=datestr(now,TimestampFormat);
        BG_data.analysis_protocol=getappdata(0,'analysis_protocol');
        BG_data.bgmed=255*ones(size(im));
        BG_data.bgmed=any_class(BG_data.bgmed,class(im));
        if fid > 1,
            fclose(fid);
        end
    end
end
BG_data.isnew=true;
setappdata(0,'BG',BG_data);
setappdata(0,'P_stage','ROIs')
if cbparams.track.dosave
    savetemp({'BG'})
end

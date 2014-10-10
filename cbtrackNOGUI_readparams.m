function [cbparams,success]=cbtrackNOGUI_readparams(paramsfile,handles)
if ~exist(paramsfile,'file')
    mymsgbox(50,190,14,'Helvetica','Invalid or missing Parameters File','Error','error','modal')
    success=false;
    cbparams=[];
    return
end
success=true;
cbparams = ReadXMLParams(paramsfile);
setappdata(0,'viewlog',get(handles.checkbox_log,'Value'))
cbparams.auto_checks_incoming.doAcI=get(handles.checkbox_doAcI,'Value');
cbparams.detect_rois.dosetROI=get(handles.checkbox_dosetROI,'Value');
cbparams.track.dosave=get(handles.checkbox_savetemp,'Value');
cbparams.track.dosetBG=get(handles.checkbox_dosetBG,'Value');
cbparams.track.dosettrack=get(handles.checkbox_dosetT,'Value');
cbparams.track.dotrack=get(handles.checkbox_dotrack,'Value');
cbparams.track.dotrackwings=get(handles.checkbox_dotrackwings,'Value');
cbparams.track.usefiles=get(handles.checkbox_usefiles,'Value');
cbparams.wingtrack.dosetwingtrack=get(handles.checkbox_dosetWT,'Value');
cbparams.auto_checks_complete.doAcC=get(handles.checkbox_doAcC,'Value');
cbparams.compute_perframe_features.dopff=get(handles.checkbox_dopff,'Value');
cbparams.results_movie.dovideo=get(handles.checkbox_domovie,'Value');

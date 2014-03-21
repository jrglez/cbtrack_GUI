function cbtrackGUI_tracker_NOvideo
cbparams=getappdata(0,'cbparams');
CourtshipBowlTrack_GUI_debug(struct);
setappdata(0,'P_stage','track2');
savetemp
CourtshipBowlTrack_GUI2
savetemp
if cbparams.results_movie.dovideo
    CourtshipBowlMakeResultsMovie_GUI
end
if cbparams.compute_perframe_features.dopff
    pffdata = CourtshipBowlComputePerFrameFeatures_GUI(1);
end
setappdata(0,'pffdata',pffdata)
cancelar
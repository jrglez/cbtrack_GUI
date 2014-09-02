function cbtrackGUI_tracker_NOvideo
CourtshipBowlTrack_GUI_debug(struct);
if getappdata(0,'iscancel') || getappdata(0,'isskip')
  return
end
setappdata(0,'P_stage','track2');
cbparams=getappdata(0,'cbparams');
if cbparams.track.dosave
    savetemp({'trackdata'})
end
CourtshipBowlTrack_GUI2
if getappdata(0,'iscancel') || getappdata(0,'isskip')
    return
end
if cbparams.track.dosave
    savetemp({'trackdata'})
end


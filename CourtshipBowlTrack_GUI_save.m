function CourtshipBowlTrack_GUI_save(savefile,frame)
out=getappdata(0,'out');
trackdata=getappdata(0,'trackdata');
if strcmp(frame,'all')
    iframe=size(trackdata.trxx,3);
else
    iframe = trackdata.t - cbparams.track.firstframetrack + 1;
end

clear_partial(iframe)

if exist(savefile,'file'),
  delete(savefile);
end

temp_full=out.tempfull;
out.tempfull=savefile;
setappdata(0,'out',out)

savetemp({trackdata});

out.temp_full=temp_full;
setappdata(0,'out',out)



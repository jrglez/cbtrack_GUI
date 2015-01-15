function clear_partial_wing(iframe)
trackdata=getappdata(0,'trackdata');
debugdata=getappdata(0,'debugdata_WT');
trackdata.twing=debugdata.framestracked(iframe);
for i=1:length(trackdata.trx)
    trackdata.trx(i).x(iframe+1:end)=[];
    trackdata.trx(i).y(iframe+1:end)=[];
    trackdata.trx(i).a(iframe+1:end)=[];
    trackdata.trx(i).b(iframe+1:end)=[];
    trackdata.trx(i).theta(iframe+1:end)=[];
    trackdata.trx(i).wing_anglel(iframe+1:end)=[];
    trackdata.trx(i).wing_anglel(iframe+1:end)=[];
    trackdata.trx(i).wing_angler(iframe+1:end)=[];
    trackdata.trx(i).xwingl(iframe+1:end)=[];
    trackdata.trx(i).ywingl(iframe+1:end)=[];
    trackdata.trx(i).xwingr(iframe+1:end)=[];
    trackdata.trx(i).ywingr(iframe+1:end)=[];
    trackdata.perframedata.nwingsdetected{i}(iframe+1:end)=[];
    trackdata.perframedata.wing_areal{i}(iframe+1:end)=[];
    trackdata.perframedata.wing_arear{i}(iframe+1:end)=[];
    trackdata.perframedata.wing_trough_angle{i}(iframe+1:end)=[];
    trackdata.trx(i).endframe = trackdata.trx(i).firstframe+iframe-1;
    trackdata.trx(i).nframes = iframe;
end
trackdata.t = iframe;
trackdata.nframetrack = iframe-trackdata.firstframetrack+1;
trackdata.lastframetrack = iframe;
debugdata.nframestrack=trackdata.nframetrack;
debugdata.framestracked(iframe+1:end)=[];
debugdata.nframestracked=length(debugdata.framestracked);
setappdata(0,'trackdata',trackdata);
setappdata(0,'debugdata_WT',debugdata);


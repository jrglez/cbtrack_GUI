function [trackdata,debugdata]=delete_partial_wing(iframe,trackdata,debugdata)
trackdata.twing=debugdata.framestracked(iframe);
for i=1:length(trackdata.trx)
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
end
trackdata.wingplotdata.idxfore_thresh(iframe+1:end)=[];   
trackdata.wingplotdata.fore2flywing(iframe+1:end)=[];   
debugdata.framestrack(iframe+1:end)=[];
debugdata.nframestrack=length(debugdata.framestracked);

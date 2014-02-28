function [trackdata,debugdata]=clear_partial_wing(iframe,trackdata,debugdata)
trackdata.twing=debugdata.framestracked(iframe);
for i=1:length(trackdata.trx)
    trackdata.trx(i).wing_anglel(iframe+1:end)=nan;
    trackdata.trx(i).wing_angler(iframe+1:end)=nan;
    trackdata.trx(i).xwingl(iframe+1:end)=nan;
    trackdata.trx(i).ywingl(iframe+1:end)=nan;
    trackdata.trx(i).xwingr(iframe+1:end)=nan;
    trackdata.trx(i).ywingr(iframe+1:end)=nan;
    trackdata.perframedata.nwingsdetected{i}(iframe+1:end)=nan;
    trackdata.perframedata.wing_areal{i}(iframe+1:end)=nan;
    trackdata.perframedata.wing_arear{i}(iframe+1:end)=nan;
    trackdata.perframedata.wing_trough_angle{i}(iframe+1:end)=nan;
end
trackdata.wingplotdata.idxfore_thresh(iframe+1:end)=cell(1);   
trackdata.wingplotdata.fore2flywing(iframe+1:end)=cell(1);   
debugdata.framestracked(iframe+1:end)=[];
debugdata.nframestracked=length(debugdata.framestracked);

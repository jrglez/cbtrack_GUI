function H0=base_hist(tracking_params,roi_params)
moviefile=getappdata(0,'moviefile');
experiment=getappdata(0,'experiment');
method=tracking_params.eq_method;

[readframe,n_frames,fid,~] = get_readframe_fcn(moviefile);
nframessample=roi_params.nframessample;
firstframe=tracking_params.bg_firstframe;
lastframe=min(n_frames,tracking_params.bg_lastframe);
frames_sample = round(linspace(firstframe,lastframe,nframessample));

logfid=open_log('track_log');
s=sprintf('Computing base histogram for experiment %s at %s.\n***\n',experiment,datestr(now,TimestampFormat));
write_log(logfid,experiment,s)
if method==1
    i=300;%randi([1,nframessample],1);
    im0=readframe(i);
    H0=imhist(uint8(im0));
elseif method==2
    h0=nan(256,nframessample);
    hwait=waitbar(0,{['Computing base histogram for experiment ',experiment];['Reading frame 0 of ', num2str(nframessample)]});
    for i=1:nframessample
        j=frames_sample(i);
        im0=readframe(j);
        h0(:,i)=imhist(uint8(im0));
        waitbar(i/nframessample,hwait,{['Computing base histogram for experiment ',experiment];['Reading frame ',num2str(i),' of ', num2str(nframessample)]});
    end
    H0=mean(h0,2);
    delete(hwait)
else
    H0=[];
end
if fid>1
    fclose(fid);
end
if logfid>1
    fclose(logfid);
end
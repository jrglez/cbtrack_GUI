function im=read_samples(readframe,nframes,nframessample,tracking_params)
experiment=getappdata(0,'experiment');
framessample = round(linspace(tracking_params.count_firstframe,min(nframes,tracking_params.count_lastframe),nframessample));
im=cell(1,nframessample);

setappdata(0,'allow_stop',false)
hwait=waitbar(0,{['Experiment ',experiment];['Reading frame 0 of ', num2str(nframessample)]},'CreateCancelBtn','cancel_waitbar');
for i = 1:nframessample,
  if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')
    im=[];
    return
  end  
  waitbar(i/nframessample,hwait,{['Experiment ',experiment];['Reading frame ',num2str(i),' of ', num2str(nframessample)]});
  im{i}=readframe(framessample(i));
end
delete (hwait)
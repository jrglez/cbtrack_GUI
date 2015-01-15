function [im,dbkgd]=compute_dbkgd(readframe,nframes,nframessample,tracking_params,bgmed,vign)
experiment=getappdata(0,'experiment');
framessample = round(linspace(tracking_params.count_firstframe,min(nframes,tracking_params.count_lastframe),nframessample));
im=cell(1,nframessample);
dbkgd=cell(1,nframessample);

if nframessample>1
    setappdata(0,'allow_stop',false)
    hwait=waitbar(0,{['Experiment ',experiment];['Reading frame 0 of ', num2str(nframessample)]},'CreateCancelBtn','cancel_waitbar');
end

vign=imresize(vign,1/tracking_params.down_factor);
H0=getappdata(0,'H0');
bgmed=imresize(bgmed,1/tracking_params.down_factor);
bgmed=double(bgmed);


if tracking_params.normalize
    im_class='double';
elseif iscell(readframe)
    im_class=class(readframe{1});
else
    im_class=class(readframe(1));
end


if tracking_params.normalize
    normalize=bgmed;
else
    normalize=ones(size(bgmed));
end

for i = 1:nframessample,
  if getappdata(0,'iscancel') || getappdata(0,'isskip') || getappdata(0,'isstop')
    im=[];
    dbkgd=[];
    return
  end  
  if exist('hwait','var') && ishandle(hwait)
    waitbar(i/nframessample,hwait,{['Experiment ',experiment];['Reading frame ',num2str(i),' of ', num2str(nframessample)]});
  end
  if iscell(readframe)
    frame=readframe{i};
  elseif isa(readframe,'function_handle')
    frame=readframe(framessample(i));
  else
    frame=readframe;
  end
  [im{i},dbkgd{i}]=compute_dbkgd1(frame,tracking_params,bgmed,H0,im_class,vign,normalize);
end
if numel(im)==1
  im=im{1};
  dbkgd=dbkgd{1};
end
if exist('hwait','var') && ishandle(hwait)
  delete (hwait)
end

function [imi,dbkgdi]=compute_dbkgd1(frame,tracking_params,bgmed,H0,im_class,vign,normalize)
imi=imresize(frame,1/tracking_params.down_factor);
% Equalize histogram using different methods (1 and 2 requires a
% reference histogram H0)
if any(tracking_params.eq_method==[1,2])
  imi=histeq(uint8(imi),H0);
elseif tracking_params.eq_method==3
  imi=eq_image(imi);
end

% Devignet and normalize
imi = double(imi)./vign;
switch tracking_params.bgmode,
case 'DARKBKGD',
  dbkgdi = imsubtract(imi,bgmed)./normalize;
case 'LIGHTBKGD',
  dbkgdi = imsubtract(bgmed,imi)./normalize;
case 'OTHERBKGD',
  dbkgdi = imabsdiff(imi,bgmed)./normalize;
otherwise
  error('Unknown background type');
end
imi=any_class(imi,im_class);
dbkgdi = any_class(dbkgdi,im_class);

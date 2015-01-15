function [imi,dbkgdi]=compute_dbkgd1(frame,tracking_params,bgmed,isarena,H0,im_class,vign,normalize)
% Equalize histogram using different methods (1 and 2 requires a
% reference histogram H0)
switch tracking_params.eq_method
    case 0
        imi=frame;
    case {1,2}
        imi = histeq(uint8(frame),H0);
    case 3
        imi = eq_image(frame);
end

% Devignet and normalize
imi = double(imi)./vign;
bgmed = double(bgmed);
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
imi = any_class(imresize(imi,1/tracking_params.down_factor),im_class);
dbkgdi(~isarena)=0;
dbkgdi = any_class(imresize(dbkgdi,1/tracking_params.down_factor),im_class);

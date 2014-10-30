function fs=goodfs(h,string)
box_pos=get(h,'Position');
txt_ext=get(h,'Extent');
fs=get(h,'FontSize');

while txt_ext(3)>box_pos(3) && fs>0
    fs=fs-2;
    set(h,'FontSize',fs)
    txt_ext=get(h,'Extent');
end
   
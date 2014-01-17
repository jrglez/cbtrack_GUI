function set_cmap(hObject,cmap)
hvis=get(hObject,'HandleVisibility');
set(hObject,'HandleVisibility','on')
colormap(hObject,cmap)
set(hObject,'HandleVisibility',hvis)

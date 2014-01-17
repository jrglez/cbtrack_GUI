function hold_GUI(hObject,hold_st)
hvis=get(hObject,'HandleVisibility');
hold(hObject,hold_st)
set(hObject,'HandleVisibility',hvis)
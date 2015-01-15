function cancel_waitbar_stop
msg_cancel_skip=myquestdlg(14,'Helvetica',...
    'Cancel current process?',...
    'Cancel?','Yes','No','No');
switch msg_cancel_skip
    case 'Yes'
        setappdata(0,'isstop',true)
        hwait=findobj('Tag','TMWWaitbar');
        delete(hwait)
        return 
end


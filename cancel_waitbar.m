function cancel_waitbar
if getappdata(0,'allow_stop')
    msg_cancel_skip=myquestdlg(14,'Helvetica',...
        {'Cancel: exit current project. All unsaved progress will be lost';...
        'Skip: skip current experiment. All unsaved progress in this experiment will be lost.'; ...
        'Stop: Cancel current process.';'Continue: continue tracking'},...
        'Cotinute','Cancel','Skip','Stop','Continue','Continue');
else
    msg_cancel_skip=myquestdlg(14,'Helvetica',...
    {'Cancel: exit current project. All unsaved progress will be lost.';...
    'Skip: skip current experiment. All unsaved progress in this experiment will be lost.'; ...
    'Continue: continue tracking'},'Cancel','Cancel','Skip','Continue','Continue');
end
switch msg_cancel_skip
    case 'Cancel'
        setappdata(0,'iscancel',true)
        setappdata(0,'isskip',true)
        setappdata(0,'isstop',true)
        hwait=findobj('Tag','TMWWaitbar');
        delete(hwait)
        return 
    case 'Skip'
        setappdata(0,'iscancel',false)
        setappdata(0,'isskip',true)
        setappdata(0,'isstop',true)
        hwait=findobj('Tag','TMWWaitbar');
        delete(hwait)
        return 
    case 'Stop'
        setappdata(0,'iscancel',false)
        setappdata(0,'isskip',false)
        setappdata(0,'isstop',true)
        hwait=findobj('Tag','TMWWaitbar');
        delete(hwait)
        return 
end


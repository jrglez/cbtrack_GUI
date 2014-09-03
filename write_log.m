function write_log(logfid,s_exp,s_log)
if ~iscell(s_log)
    s_log={s_log};
end
if logfid>1
    fprintf(logfid,'%s\n',s_log{:});
else
    h_log=getappdata(0,'h_log');
    if isempty(h_log) || any(~ishandle(h_log)) 
        h_log=log_GUI;
        setappdata(0,'h_log',h_log)
    end

    set(h_log(1),'String',['Current experiment: ',s_exp])

    curr_s=get(h_log(2),'String');
    if isempty(curr_s)
        curr_s={};
    end
    
    s_log=textwrap(h_log(2),s_log);
    curr_s=[curr_s;s_log];
    set(h_log(2),'String',curr_s,'Value',numel(curr_s))
    drawnow
end

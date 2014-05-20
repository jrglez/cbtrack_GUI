function GUIsize(handles,hObject)
GUIscale=getappdata(0,'GUIscale');

if ~isempty(GUIscale)
    h=fieldnames(handles);
    rescalex=GUIscale.rescalex;
    rescaley=GUIscale.rescaley;
    set(hObject,'position',GUIscale.position)
    for i=2:length(h)
        obj_handle=handles.(h{i});
        if ~strcmp(h{i},'output')
            if isprop(obj_handle,'position')        
                old_pos=get(obj_handle,'position');
                if iscell(old_pos)
                    old_pos=cell2mat(old_pos);
                end
                if ~isprop(obj_handle,'xTick') %not a figure
                    new_pos=old_pos;
                    new_pos(:,1:2:end)=old_pos(:,1:2:end)*rescalex;
                    new_pos(:,2:2:end)=old_pos(:,2:2:end)*rescaley;
                    for j=1:size(new_pos,1)
                        set(obj_handle(j),'position',new_pos(j,:))
                    end
                elseif isprop(obj_handle,'xTick') %figure
                    rescale=min(rescalex,rescaley);
                    new_pos(:,1)=old_pos(:,1)*rescalex+(old_pos(:,3)*(rescalex-rescale)/2);
                    new_pos(:,2)=old_pos(:,2)*rescaley+(old_pos(:,4)*(rescaley-rescale)/2);
                    new_pos(:,[3,4])=old_pos(:,[3,4])*rescale;
                    for j=1:size(new_pos,1)
                        set(obj_handle(j),'position',new_pos(j,:))
                    end        
                end
            end
            if isprop(obj_handle,'FontSize')
                old_fontsize=get(obj_handle,'FontSize');
                if iscell(old_fontsize)
                    old_fontsize=cell2mat(old_fontsize);
                end
                new_fontsize=max(12,old_fontsize.*min(rescalex,rescaley));
                for j=1:size(new_pos,1)
                    set(obj_handle(j),'FontSize',new_fontsize(j))
                end                
            end
        end
        clear new_pos
        clear new_fontsize
    end
elseif isempty(GUIscale)
    GUIscale.position=get(hObject,'position');
    GUIscale.rescalex=1;
    GUIscale.rescaley=1;
    if ~isfield(GUIscale,'original_position')
        GUIscale.original_position=GUIscale.position;
    end
    setappdata(0,'GUIscale',GUIscale)
end

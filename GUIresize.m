function GUIscale=GUIresize(handles,hObject,GUIscale)
new_pos_GUI=get(hObject,'position');
if isempty(GUIscale)
    old_pos_GUI=new_pos_GUI;
else
    old_pos_GUI=GUIscale.position;
end
rescalex=new_pos_GUI(3)/old_pos_GUI(3);
rescaley=new_pos_GUI(4)/old_pos_GUI(4) ;


if rescalex~=1 || rescaley~=1
    h=fieldnames(handles);
    for i=2:length(h)
        obj_handle=handles.(h{i});
        if ~strcmp(h{i},'output')
            if isprop(obj_handle,'position')        
                old_pos=get(obj_handle,'position');
                if iscell(old_pos)
                    old_pos=cell2mat(old_pos);
                end
                if strcmp(get(obj_handle,'Type'),'figure') %figure
                    rescale=min(rescalex,rescaley);
                    new_pos(:,1)=old_pos(:,1)*rescalex+(old_pos(:,3)*(rescalex-rescale)/2);
                    new_pos(:,2)=old_pos(:,2)*rescaley+(old_pos(:,4)*(rescaley-rescale)/2);
                    new_pos(:,[3,4])=old_pos(:,[3,4])*rescale;
                    for j=1:size(new_pos,1)
                        set(obj_handle(j),'position',new_pos(j,:))        
                    end
                elseif strcmp(get(obj_handle,'Type'),'text') %text
                    rescale=min(rescalex,rescaley);
                    new_pos=old_pos*rescale;
                else
                    new_pos=old_pos;
                    new_pos(:,1:2:end)=old_pos(:,1:2:end)*rescalex;
                    new_pos(:,2:2:end)=old_pos(:,2:2:end)*rescaley;
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
end
GUIscale.position=new_pos_GUI;


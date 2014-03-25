function [handles,manual,list,roidata]=deleterois(handles,manual)
if isfield(manual,'pos_h') 
    pos_h=cat(2,manual.pos_h{:});
    delete(pos_h(ishandle(cat(2,manual.pos_h{:}))));
end
if isfield(handles,'hrois') 
    delete(handles.hrois)
    handles=rmfield(handles,'hrois');
end
if isfield(handles,'hroisT') 
    delete(handles.hroisT(ishandle(handles.hroisT)))
    handles.hroisT=[];
end
roidata=struct;
manual.pos=cell(0);
manual.roi=1; %number of ROIS detected
manual.proi=0; %number of rois selected on esach ROI;
manual.pos_h=cell(0); %point plots handles
manual.add=0;
manual.pos_h=cell(0);
manual.detected=0;

list.text=cell(0); %list of selected points to display at listbox_manual
list.ind=cell(0);
list.ind_mat=[]; %(ROI,point) index matrix

set(handles.listbox_manual,'String',vertcat(list.text{:}),'Value',1)

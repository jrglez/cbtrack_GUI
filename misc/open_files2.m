%Abre los modelos seleccionados
function [file, folder]=open_files2(type,rcprop)
% type: optional. char or cellstr for FILTERSPEC, see uigetfile.
% rcprop: optional. RC property name containing default full filename.

if exist('type','var')==0
  type = {'*.*'};
end
if ischar(type)
  type = cellstr(type);
end
if ~iscellstr(type)
  error('Invalid input argument ''type''.');
end

tfRCprop = exist('rcprop','var')>0;
if tfRCprop
  defaultfile = RC.getprop(rcprop);
else
  defaultfile = [];
end
  
[file_,folder]=uigetfile(type,'Select files',defaultfile,'MultiSelect','on');
if iscell(file_)~=1
    file{1}=file_;
else
    file=file_;
end
if tfRCprop && ~isequal(file{1},0)
  RC.saveprop(rcprop,fullfile(folder,file{1}));
end
%Abre los modelos seleccionados
function [file, folder]=open_files2(type)
if nargin>1
    error('To many input arguments')
elseif  nargin==1 && ~iscell(type)
    if ~ischar(type)
        error('Input argument must be a string')
    end
elseif nargin==1 && iscell(type)
    if ~ischar(type{1})
        error('Input argument must be a string')
    end
else
    type='*.*';
end
[file_,folder]=uigetfile(type,'Select files','MultiSelect','on');
if iscell(file_)~=1
    file{1}=file_;
else
    file=file_;
end


% save([folder,'Data\angulo vs t\alfa_time.dat'],'alfa_depth_time','-ASCII')

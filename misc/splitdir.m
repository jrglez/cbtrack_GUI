% Splits dirname into al its subdirectories. If cual='all', the output is a
% cell containing each of the folders; if cual='last', only the last
% subdirectore is given as an output
function split=splitdir(dirname,cual)
if nargin==1
    cual='all';
end
if isunix
    slash='/';
else
    slash='\';
end
i=find(dirname==slash);
n_f=length(i)-1;
split=cell(n_f,1);
for j=1:n_f
    split{j}={dirname(i(j)+1:i(j+1)-1)};
end
if strcmp(cual,'last')
    split=cell2str(split{end});
end
function mysetappdata(varargin)
if rem(nargin,2) ~= 0
    error('Expected even numver of arguments')
end

for i =1:2:nargin
    setappdata(0,varargin{i},varargin{i+1})
end
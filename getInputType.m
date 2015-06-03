function inputType = getInputType(frame)
if isscalar(frame) && ishandle(frame) && (double(frame) > 0)
  inputType = get(frame,'type');
elseif isstruct(frame) && isfield(frame,'cdata')
  inputType = 'movie';
elseif isa(frame,'numeric')
  inputType = 'data';
else
  error('Invalid input argument.  Each frame must be a numeric matrix, a MATLAB movie structure, or a handle to a figure or axis.');
end

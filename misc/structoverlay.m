function s = structoverlay(sbase,sover,varargin)
% [s,baseused] = structoverlay(sbase,sover,varargin)
% Overlay 'leaf nodes' of sover onto sbase
%
% sbase: scalar base struct
% sover: scalar overlay struct
%
% s: scalar struct, result of overlay
% baseused: cellstr of 'paths' specifying fields where sbase values were
% used/retained
%
% optional PVs:
% - 'path'. String, defaults to ''. Current struct "path", eg
% .topfield.subfield.
% - 'dontWarnUnrecog'. Logical scalar, defaults to false. If true, don't 
% throw unrecognized field warning.

[path,dontWarnUnrecog,fldsIgnore] = myparse(varargin,...
  'path','',...
  'dontWarnUnrecog',false,...
  'fldsIgnore',cell(0,1));
fldsBase = fieldnames(sbase);
fldsOver = fieldnames(sover);
baseused = setdiff(fldsBase,fldsOver);
baseused = strcat(path,'.',baseused(:));

for f = fldsOver(:)',f=f{1}; %#ok<FXSET>
  newpath = [path '.' f];
  if any(strcmp(f,fldsIgnore))
    % none
  elseif ~isfield(sbase,f) 
    if ~dontWarnUnrecog
      warning('structoverlay:unrecognizedfield','Ignoring unrecognized field ''%s''.',...
        newpath);
    end
  elseif isstruct(sbase.(f)) && isstruct(sover.(f))
    assert(isscalar(sbase.(f)));
    % Allow nonscalar sover.(f)
    numOver = numel(sover.(f));
    assert(numOver>0);
    sbaseEl = sbase.(f);
    for i=1:numOver
      newpathindexed = [newpath sprintf('(%d)',i)];
      [sbase.(f)(i),tmpBU] = structoverlay(...
        sbaseEl,sover.(f)(i),...
        'path',newpathindexed,...
        'dontWarnUnrecog',dontWarnUnrecog);
      baseused = [baseused;tmpBU]; %#ok<AGROW>
    end
  elseif isstruct(sbase.(f)) && ~isstruct(sover.(f))
    warning('structoverlay:badval','Ignoring non-struct value of ''%s''.',...
      newpath);
    baseused{end+1,1} = newpath; %#ok<AGROW>
  else % sbase.(f) is not a struct
    if isequaln(sbase.(f),sover.(f))
      % TODO: update baseused
    else
      fprintf(1,'Using modified value for field ''%s''.\n',f);
      sbase.(f) = sover.(f);
    end
  end
end

s = sbase;
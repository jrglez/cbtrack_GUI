function [analysis_protocol,paramsfile,expdirs] = ReadGroupedExperimentList_queue(expfile)

fid = fopen(expfile,'r');
endread = false;
while true,
  
  isfirst = true;
  issecond = false;
  while true,
    l = fgetl(fid);
    if ~ischar(l),
      endread = true;
      break;
    end
    l = strtrim(l);
    if isempty(l),
      break;
    end
    if isfirst,
      analysis_protocol = l;
      expdirs = {};
      isfirst = false;
      issecond = true;
    elseif issecond
      paramsfile = l;
      issecond = false;
    else
      expdirs{end+1} = l; %#ok<AGROW>
    end    
  end
    
  if endread,
    break;
  end
end

fclose(fid);
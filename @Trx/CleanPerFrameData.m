function CleanPerFrameData(obj,fns,ns)

if ~exist('ns','var'),
  ns = 1:obj.nexpdirs;
end
if ~exist('fns','var') || isempty(fns),
  fns = setdiff(Trx.PerFrameFieldNames(),Trx.TrajectoryFieldNames());
end
if ~iscell(fns),
  fns = {fns};
end
for i = 1:numel(fns),
  fn = fns{i};
  for n = ns,
    filename = obj.GetPerFrameFile(fn,n);
    if exist(filename,'file'),
      logfid=open_log('perframefeature_log');
      s=sprintf('Deleting per-frame data file %s\n',filename);
      write_log(logfid,getappdata(0,'experiment'),s)
      delete(filename);
      if logfid > 1,
        fclose(logfid);
      end
    end
    
    % clear from cache
    j = find(strcmp(fn,obj.fnscached{n}),1);
    if ~isempty(j),
      obj.datacached{n}(j) = [];
      obj.fnscached{n}(j) = [];
      obj.nfnscached(n) = obj.nfnscached(n)-1;
    end    
  end
end
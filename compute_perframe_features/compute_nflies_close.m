function [data,units] = compute_nflies_close(trx,n,nbodylengths_near)

flies = trx.exp2flies{n};
nflies = numel(flies);
data = cell(1,nflies);

if nargin < 3,
  nbodylengths_near = trx.perframe_params.nbodylengths_near;
end

logfid=open_log('perframefeature_log');
for i1 = 1:nflies,
  fly1 = flies(i1);
  s=sprintf('fly1 = %d\n',fly1);
  write_log(logfid,getappdata(0,'experiment'),s)
  data{i1} = zeros(1,trx(fly1).nframes);
  for i2 = 1:nflies,
    if i1 == i2,
      continue;
    end
    fly2 = flies(i2);
    idx = isclose_pair(trx,fly1,fly2,nbodylengths_near);
    data{i1}(idx) = data{i1}(idx) + 1;
  end
end

if logfid>1
    fclose(logfid);
end

units = parseunits('unit');
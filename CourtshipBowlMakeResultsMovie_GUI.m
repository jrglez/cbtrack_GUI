% make results movies
function resultsmoviedata = CourtshipBowlMakeResultsMovie_GUI

version = '0.1.1';
timestamp = datestr(now,TimestampFormat);
expdir=getappdata(0,'expdir');
experiment=getappdata(0,'experiment');
analysis_protocol=getappdata(0,'analysis_protocol');
cbparams = getappdata(0,'cbparams');

resultsmoviedata = struct;
resultsmoviedata.cbresultsmovie_version = version;
resultsmoviedata.cbresultsmovie_timestamp = timestamp;

DEBUG=cbparams.track.DEBUG;



%% movie parameters
out=getappdata(0,'out');
resultsmovie_params = cbparams.results_movie;
defaulttempdatadir = fullfile(out.folder,'temp_results_movie');
if ~isfield(resultsmovie_params,'tempdatadir') || isempty(resutlsmovie_params.tempdatadir),
  resultsmovie_params.tempdatadir = defaulttempdatadir;
  cbparams.results_movie.tempdatadir = defaulttempdatadir;
  setappdata(0,'cbparams',cbparams)
elseif isunix
  [status1,res] = unix(sprintf('echo %s',resultsmovie_params.tempdatadir));
  if status1 == 0,
    resultsmovie_params.tempdatadir = strtrim(res);
  end
end

if ~exist(resultsmovie_params.tempdatadir,'dir'),
  [success1,msg1] = mkdir(resultsmovie_params.tempdatadir);
  if ~success1,
    error('Error making directory %s: %s',resultsmovie_params.tempdatadir,msg1);
  end
end

%% log file
logfid=open_log('resultsmovie_log');

s=sprintf('\n\n***\nRunning CourtshipBowlMakeResultsMovie version %s for experiment %s at %s\n',version,experiment,timestamp);
write_log(logfid,experiment,s)

resultsmoviedata.analysis_protocol = analysis_protocol;
resultsmoviedata.experiment=experiment;

%% location of data

[~,basename] = fileparts(expdir);
moviefile = getappdata(0,'moviefile');
trxfile = fullfile(out.folder,cbparams.dataloc.trx.filestr);
if ~isfield(cbparams.dataloc,'resultsavi') || ~isfield(cbparams.dataloc.resultsavi,'filestr') || isempty(cbparams.dataloc.resultsavi.filestr)
    avifilestr=sprintf('%s_%s','tracking_results_movie',basename);
else
    avifilestr = sprintf('%s_%s',cbparams.dataloc.resultsavi.filestr,basename);
end
avifile = fullfile(resultsmovie_params.tempdatadir,[avifilestr,'_temp.avi']);
xvidfile = fullfile(out.folder,[avifilestr,'.avi']);

%% read start and end of cropped trajectories

s=sprintf('Reading in trajectories...\n');
write_log(logfid,experiment,s)
load(trxfile,'trx');
end_frame = max([trx.endframe]);
start_frame = min([trx.firstframe]);
nframes = end_frame-start_frame + 1;
nflies = numel(trx);
if sum(resultsmovie_params.nframes)>nframes
    Dt=sum(resultsmovie_params.nframes)-nframes;
    D=ceil(resultsmovie_params.nframes*Dt/sum(resultsmovie_params.nframes));
    resultsmovie_params.nframes=resultsmovie_params.nframes-D;
end
firstframes_off = min(max(0,round(resultsmovie_params.firstframes*nframes)),nframes-1);
firstframes_off(resultsmovie_params.firstframes < 0) = nan;
middleframes_off = round(resultsmovie_params.middleframes*nframes);
middleframes_off(resultsmovie_params.middleframes < 0) = nan;
endframes_off = round(resultsmovie_params.endframes*nframes);
endframes_off(resultsmovie_params.endframes < 0) = nan;
idx = ~isnan(middleframes_off);
firstframes_off(idx) = ...
  min(nframes-1,max(0,middleframes_off(idx) - ceil(resultsmovie_params.nframes(idx)/2)));
idx = ~isnan(endframes_off);
firstframes_off(idx) = ...
  min(nframes-1,max(0,endframes_off(idx) - resultsmovie_params.nframes(idx)));
endframes_off = firstframes_off + resultsmovie_params.nframes - 1;


firstframes = start_frame + firstframes_off;

%% option to not specify nzoomr, nzoomc

s=sprintf('Setting parameters...\n');
write_log(logfid,experiment,s)

[readframe,~,fid] = get_readframe_fcn(moviefile);
im = readframe(1);
[nr,nc,~] = size(im);
if ischar(resultsmovie_params.nzoomr) || ischar(resultsmovie_params.nzoomc),
    
  if isnumeric(resultsmovie_params.nzoomr),
    nzoomr = resultsmovie_params.nzoomr;
    nzoomc = round(nflies/nzoomr);
  elseif isnumeric(resultsmovie_params.nzoomc),
    nzoomc = resultsmovie_params.nzoomc;
    nzoomr = round(nflies/nzoomc);
  else
    nzoomr = ceil(sqrt(nflies));
    nzoomc = round(nflies/nzoomr);
  end
  resultsmovie_params.nzoomr = nzoomr;
  resultsmovie_params.nzoomc = nzoomc;
  
  if iscell(resultsmovie_params.figpos),  
    
    rowszoom = floor(nr/nzoomr);
    imsize = [nr,nc+rowszoom*nzoomc];
    figpos = str2double(resultsmovie_params.figpos);
    if isnan(figpos(3)),
      figpos(3) = figpos(4)*imsize(2)/imsize(1);
    elseif isnan(figpos(4)),
      figpos(4) = figpos(3)*imsize(1)/imsize(2);
    end
    resultsmovie_params.figpos = figpos;
    
    if fid > 1,
      fclose(fid);
    end
  end  
end

boxradius=round(0.5*(floor(nr/resultsmovie_params.nzoomr)/resultsmovie_params.scalefactor)-1);

%% choose colors for each fly

s=sprintf('Choosing colors for each fly...\n');
write_log(logfid,experiment,s)

colors = jet(nflies)*.8;

% alone flies go in the middle
isalone = false(1,nflies);
maxroi = max([trx.roi]);
for roii = 1:maxroi,
  idx = [trx.roi] == roii;
  if nnz(idx) == 1,
    isalone(idx) = true;
  end
end

nalone = nnz(isalone);
npairs = (nflies - nalone)/2;

colorsp1 = colors(1:npairs,:);
colorsalone = colors(npairs+1:npairs+nalone,:);
colorsp2 = colors(npairs+nalone+1:end,:);

ip = 1;
ialone = 1;
for roii = 1:maxroi,
  idx = find([trx.roi] == roii);
  if nnz(idx) == 0,
    continue;
  elseif numel(idx) == 1,
    colors(idx,:) = colorsalone(ialone,:);
    ialone = ialone+1;
  else
    colors(idx(1),:) = colorsp1(ip,:);
    colors(idx(2),:) = colorsp2(ip,:);
    ip = ip+1;
  end
end

%% create movie

s=sprintf('Calling make_ctrax_results_movie...\n');
write_log(logfid,experiment,s)

if ~DEBUG && exist(avifile,'file'),
  try
    delete(avifile);
  catch ME,
    s=sprintf('Could not remove avi file %s:\n%s\n',avifile,ME.message);
    write_log(logfid,experiment,s)
  end
end

[succeeded,~,~,height,width]= ...
  make_ctrax_result_movie_GUI('moviename',moviefile,'trxname',trxfile,'aviname',avifile,...
  'nzoomr',resultsmovie_params.nzoomr,'nzoomc',resultsmovie_params.nzoomc,...
  'boxradius',boxradius,'taillength',resultsmovie_params.taillength,...
  'fps',resultsmovie_params.fps,...
  'maxnframes',resultsmovie_params.nframes,...
  'firstframes',firstframes,...
  'figpos',resultsmovie_params.figpos,...
  'movietitle',basename,...
  'compression','none',...
  'useVideoWriter',false,...
  'titletext',false,...
  'avifileTempDataFile',[avifile,'-temp'],...
  'dynamicflyselection',true,...
  'doshowsex',true,...
  'colors',colors);
if getappdata(0,'iscancel') || getappdata(0,'isskip')
    resultsmoviedata = [];
    return
end

if ishandle(1),
  close(1);
end

if ~succeeded,
  error('Failed to create raw avi %s',avifile);
end

%% create subtitle file

s=sprintf('Creating subtitle file...\n');
write_log(logfid,experiment,s)

subtitlefile = fullfile(out.folder,'subtitles.srt');
fid = fopen(subtitlefile,'w');
dt = [0,resultsmovie_params.nframes];
ts = cumsum(dt);
for i = 1:numel(dt)-1,
  s=sprintf('%d\n',i);
  write_log(logfid,experiment,s)
  s=sprintf('%s --> %s\n',...
    datestr(ts(i)/resultsmovie_params.fps/(3600*24),'HH:MM:SS,FFF'),...
    datestr((ts(i+1)-1)/resultsmovie_params.fps/(3600*24),'HH:MM:SS,FFF'));
  write_log(logfid,experiment,s)
  s=sprintf('%s, fr %d-%d\n\n',basename,...
    firstframes_off(i)+1,...
    endframes_off(i)+1);
  write_log(logfid,experiment,s)
end
fclose(fid);

%% compress

s=sprintf('Compressing to xvid avi file...\n');
write_log(logfid,experiment,s)

tmpfile = [xvidfile,'.tmp'];
newheight = 4*ceil(height/4);
newwidth = 4*ceil(width/4);
% subtitles are upside down, so encode with subtitles and flip, then flip
% again
cmd = sprintf('mencoder %s -o %s -ovc xvid -xvidencopts fixed_quant=4 -vf scale=%d:%d,flip -sub %s -subfont-text-scale 2 -msglevel all=2',...
  avifile,tmpfile,newwidth,newheight,subtitlefile);
status = system(cmd);
if status ~= 0,
  s=sprintf('*****\n');
  write_log(1,experiment,s)
  warning('Failed to compress avi to %s',xvidfile);
  s=sprintf('Need to run:\n');
  write_log(1,experiment,s)
  s=sprintf('%s\n',cmd);
  write_log(1,experiment,s)
  cmd2 = sprintf('mencoder %s -o %s -ovc xvid -xvidencopts fixed_quant=4 -vf flip -msglevel all=2\n',...
    tmpfile,xvidfile);
  s=sprintf('then\n');
  write_log(1,experiment,s)
  write_log(1,experiment,cmd2)  
  s=sprintf('then delete %s %s %s\n',tmpfile,avifile,subtitlefile);
  write_log(1,experiment,s)
  s=sprintf('*****\n');
  write_log(1,experiment,s)
else
  cmd = sprintf('mencoder %s -o %s -ovc xvid -xvidencopts fixed_quant=4 -vf flip -msglevel all=2\n',...
    tmpfile,xvidfile);
  status = system(cmd);
  if status ~= 0,
    s=sprintf('*****\n');
    write_log(1,experiment,s)
    warning('Failed to add subtitles to %s',xvidfile);
    s=sprintf('Need to run:\n');
    write_log(1,experiment,s)
    write_log(1,experiment,cmd)
    s=sprintf('then delete %s %s %s\n',tmpfile,avifile,subtitlefile);
    write_log(1,experiment,s)
    s=sprintf('*****\n');
    write_log(1,experiment,s)
  else
    delete(tmpfile);
    delete(avifile);
    delete(subtitlefile);
  end
end

%% save info to mat file

resultsmoviedata.resultsmovie_params = resultsmovie_params;
resultsmoviedata.firstframes = firstframes;

filename = fullfile(out.folder,cbparams.dataloc.resultsmoviedatamat.filestr);
s=sprintf('Saving info to mat file %s...\n',filename);
write_log(logfid,experiment,s)

if exist(filename,'file'),
  delete(filename);
end
save(filename,'-struct','resultsmoviedata');

%% close log

s=sprintf('Finished running CourtshipBowlMakeResultsMovie at %s for experiment %s.\n',datestr(now,'yyyymmddTHHMMSS'),experiment);
write_log(logfid,experiment,s)

if logfid > 1,
  fclose(logfid);
end

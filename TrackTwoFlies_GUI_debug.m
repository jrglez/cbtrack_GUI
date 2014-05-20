function trackdata = TrackTwoFlies_GUI_debug(handles,moviefile,bgmed,roidata,params,varargin)
global ISPAUSE
trackdata=getappdata(0,'trackdata');

version = '0.1.1';
timestamp = datestr(now,TimestampFormat);

experiment=getappdata(0,'experiment');
out=getappdata(0,'out');
cbparams=getappdata(0,'cbparams');
[restart] = myparse(varargin,'restart',''); 

dorestart = false;
if ~isempty(restart) && ~isempty(trackdata)
  restartstage = trackdata.stage; 
  dorestart = true;
else
    restartstage = '';
end

logfid=open_log('track_log',getappdata(0,'cbparams'),out.folder);

SetBackgroundTypes;
flycolors = {'r','b'};
stages = {'maintracking','reformat','chooseorientations','trackwings1','assignids','chooseorientations2','trackwings2'};

%% open movie

fprintf(logfid,'Opening movie...\n');
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile);

%% initialize

nrois = roidata.nrois;
nframes_track = min(params.lastframetrack,nframes)-params.firstframetrack+1;

if ~dorestart && any([~ISPAUSE,~isfield(trackdata,'trxx')]),
  fprintf(logfid,'Allocating...\n');
  trackdata = struct;
  trxx = nan(2,nrois,nframes_track);
  trxy = nan(2,nrois,nframes_track);
  trxa = nan(2,nrois,nframes_track);
  trxb = nan(2,nrois,nframes_track);
  trxtheta = nan(2,nrois,nframes_track);
  trxarea = nan(2,nrois,nframes_track);
  istouching = nan(nrois,nframes_track);
  gmm_isbadprior = nan(nrois,nframes_track);
  trxpriors=nan(2,nrois,nframes_track);
  
  pred = struct;
  pred.mix = gmm(2,2,'full');
  pred.x = nan(2,1);
  pred.y = nan(2,1);
  pred.theta = nan(2,1);
  pred.area = nan(2,1);
  pred.isfirstframe = true;
  pred = repmat(pred,[1,nrois]);
  
  trxcurr = struct;
  trxcurr.x = nan(2,1);
  trxcurr.y = nan(2,1);
  trxcurr.a = nan(2,1);
  trxcurr.b = nan(2,1);
  trxcurr.theta = nan(2,1);
  trxcurr.area = nan(2,1);
  trxcurr.istouching = nan;
  trxcurr.gmm_isbadprior = nan;
  trxcurr.priors=nan(1,2);
  trxcurr = repmat(trxcurr,[1,roidata.nrois]);
  handles.hell = nan(2,nrois);
  handles.htrx = nan(2,nrois);
  handles.him = nan;
elseif ISPAUSE || dorestart
    trxx = trackdata.trxx;
    trxy = trackdata.trxy;
    trxa = trackdata.trxa;
    trxb = trackdata.trxb;
    trxtheta = trackdata.trxtheta;
    trxarea = trackdata.trxarea;
    istouching = trackdata.istouching;
    gmm_isbadprior = trackdata.gmm_isbadprior;
    pred=trackdata.pred;
    trxcurr=trackdata.trxcurr;  
end
trackdata.tracktwoflies_version = version;
trackdata.tracktwoflies_timestamp = timestamp;

%% loop over frames

stage = 'maintracking'; 

if ~dorestart || find(strcmp(stage,stages)) >= find(strcmp(restartstage,stages)),

    if all([dorestart, strcmp(stage,restartstage)]) || all([ISPAUSE,isfield(trackdata,'t')])
      startframe = trackdata.t; 
    else
      startframe = params.firstframetrack;
    end
    ISPAUSE=false;

    fprintf(logfid,'Starting main tracking from frame %i at %s...\n',startframe,datestr(now,'yyyymmddTHHMMSS'));
    if ~params.DEBUG
      hwait=waitbar(0,{['Experiment ',experiment];['Tracking: frame ',num2str(startframe),'(0 of ',num2str(nframes_track),')']},'CreateCancelBtn','setappdata(0,''cancel_hwait'',1)');
    end
    for t = startframe:min(params.lastframetrack,nframes),
      if ISPAUSE
          fprintf(logfid,'Main tracking paused at frame %i at %s...\n',t,datestr(now,'yyyymmddTHHMMSS')); %#ok<UNRCH>
          break; 
      end
      iframe = t - params.firstframetrack + 1;

      if mod(iframe,1000) == 0,
        fprintf(logfid,'Frame %d / %d\n',iframe,nframes_track);
      end

      % read in frame
      im = readframe(t);

      % subtract off background
      switch params.bgmode,
        case DARKBKGD,
          dbkgd = imsubtract(im,bgmed);
        case LIGHTBKGD,
          dbkgd = imsubtract(bgmed,im);
        case OTHERBKGD,
          dbkgd = imabsdiff(im,bgmed);
      end

      % threshold
      isfore = dbkgd >= params.bgthresh;

      % track this frame
      trxprev = trxcurr;
      % waitbar(t/min(params.lastframetrack,nframes),hwait, ['Tracking frame ',num2str(t),' of ', num2str(min(params.lastframetrack,nframes))]);
      [trxcurr,pred] = TrackTwoFliesOneFrame_GUI(dbkgd,isfore,pred,trxprev,roidata,params);

      trxx(:,:,iframe) = cat(2,trxcurr.x);
      trxy(:,:,iframe) = cat(2,trxcurr.y);
      trxa(:,:,iframe) = cat(2,trxcurr.a);
      trxb(:,:,iframe) = cat(2,trxcurr.b);
      trxtheta(:,:,iframe) = cat(2,trxcurr.theta);
      trxarea(:,:,iframe) = cat(2,trxcurr.area);
      istouching(:,iframe) = cat(1,trxcurr.istouching);
      gmm_isbadprior(:,iframe) = cat(1,trxcurr.gmm_isbadprior);
      trxpriors(:,:,iframe)=cat(1,trxcurr.priors)';
      % plot

      if params.DEBUG,
         hold on
        set(handles.video_img,'CData',im);
        isnewplot = false;
        title(num2str(t));

        for roii = 1:roidata.nrois,

          roibb = roidata.roibbs(roii,:);
          offx = roibb(1)-1;
          offy = roibb(3)-1;

          for i = 1:2,
            if isnewplot || ~ishandle(handles.hell(i,roii)),
              handles.hell(i,roii) = drawellipse(trxx(i,roii,iframe)+offx,trxy(i,roii,iframe)+offy,trxtheta(i,roii,iframe),trxa(i,roii,iframe),trxb(i,roii,iframe),[flycolors{i},'-']);
            else
              updateellipse(handles.hell(i,roii),trxx(i,roii,iframe)+offx,trxy(i,roii,iframe)+offy,trxtheta(i,roii,iframe),trxa(i,roii,iframe),trxb(i,roii,iframe));
            end
            if isnewplot || ~ishandle(handles.htrx(i,roii)),
              handles.htrx(i,roii) = plot(squeeze(trxx(i,roii,max(iframe-30,1):iframe)+offx),squeeze(trxy(i,roii,max(iframe-30,1):iframe)+offy),[flycolors{i},'.-']);
            else
              set(handles.htrx(i,roii),'XData',squeeze(trxx(i,roii,max(iframe-30,1):iframe)+offx),...
                'YData',squeeze(trxy(i,roii,max(iframe-30,1):iframe)+offy));
            end
          end
        end
      set(handles.text_info,'String',{['Experiment ',experiment];['Tracking: frame ',num2str(t),' (',num2str(iframe),' of ',num2str(nframes_track),', ',num2str(iframe*100/nframes_track,'%.1f'),'%).']})  
      else
        waitbar(iframe/nframes_track,hwait,{['Experiment ',experiment];['Tracking: frame ',num2str(t),' (',num2str(iframe),' of ',num2str(nframes_track),')']});  
      end    

      if params.DEBUG || mod(t,1) == 0,
        drawnow;
      end
      
      if mod(iframe,5000) == 0,
            trackdata.t=t;
            trackdata.trxx=trxx; 
            trackdata.trxy=trxy;
            trackdata.trxa=trxa;
            trackdata.trxb=trxb;
            trackdata.trxtheta=trxtheta;
            trackdata.trxarea=trxarea;
            trackdata.istouching=istouching;
            trackdata.gmm_isbadprior=gmm_isbadprior;
            trackdata.pred=pred;
            trackdata.trxcurr=trxcurr; 
            trackdata.trxpriors=trxpriors;
            trackdata.headerinfo=headerinfo;
            trackdata.stage=stage;
            if cbparams.track.dosave
                save(out.temp_full,'trackdata','-append')
            end
            fprintf(logfid,'Saving temporary file after %i frames at %s...\n',iframe,datestr(now,'yyyymmddTHHMMSS'));
      end
      setappdata(0,'t',t);
    end
    if exist('hwait','var') && ishandle(hwait)
        delete(hwait)
    end
    trackdata.t=t-(t~=min(params.lastframetrack,nframes));

    trackdata.trxx=trxx; 
    trackdata.trxy=trxy;
    trackdata.trxa=trxa;
    trackdata.trxb=trxb;
    trackdata.trxtheta=trxtheta;
    trackdata.trxarea=trxarea;
    trackdata.istouching=istouching;
    trackdata.gmm_isbadprior=gmm_isbadprior;
    trackdata.pred=pred;
    trackdata.trxcurr=trxcurr; 
    trackdata.trxpriors=trxpriors;
    trackdata.headerinfo=headerinfo;
    trackdata.stage=stage;
    if cbparams.track.dosave
        save(out.temp_full,'trackdata','-append')
    end
end

%% clean up

% fprintf(logfid,'Clean up...\n');
if params.DEBUG
    guidata(handles.cbtrackGUI_ROI,handles)
end

if fid > 1,
  try
    fclose(fid);
  catch ME,
    warning('Could not close movie: %s',getReport(ME));
  end
end
if logfid > 1,
  fclose(logfid);
end


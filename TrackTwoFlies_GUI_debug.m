function trackdata = TrackTwoFlies_GUI_debug(handles,moviefile,bgmed,roidata,params,varargin)
global ISPAUSE
trackdata=getappdata(0,'trackdata');


version = '0.1.1';
timestamp = datestr(now,TimestampFormat);

tmpfilename = sprintf('TmpResultsTrackTwoFlies_%s.mat',datestr(now,TimestampFormat));
[restart,tmpfilename] = myparse(varargin,'restart','','tmpfilename',tmpfilename); %[restart,tmpfilename,logfid] = myparse(varargin,'restart','','tmpfilename',tmpfilename,'logfid',1);

dorestart = false;
if ~isempty(restart),
  fprintf('Loading temporary results from file %s...\n',restart);
  load(restart);
  restartstage = stage; %#ok<NODEF>
  dorestart = true;
else
    restartstage = '';
end
% fprintf(logfid,'TrackTwoFlies temporary results saved to file %s\n',tmpfilename);

SetBackgroundTypes;
flycolors = {'r','b'};
stages = {'maintracking','chooseorientations','trackwings1','assignids','chooseorientations2','trackwings2'};

%% open movie

% fprintf(logfid,'Opening movie...\n');
[readframe,nframes,fid,headerinfo] = get_readframe_fcn(moviefile);

%% initialize

nrois = roidata.nrois;
nframes_track = min(params.lastframetrack,nframes)-params.firstframetrack+1;

if ~dorestart && any([~ISPAUSE,~isfield(trackdata,'trxx')]),
%   fprhsvntf(logfid,'Allocating...\n');
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
elseif ISPAUSE
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

    % fprintf(logfid,'Main tracking...\n');
    % hwait=waitbar(0,['Tracking frame 0 of ', num2str(min(params.lastframetrack,nframes))]);
    for t = startframe:min(params.lastframetrack,nframes),
      if ISPAUSE
          break; %#ok<UNRCH>
      end
      iframe = t - params.firstframetrack + 1;

      if mod(iframe,1000) == 0,
    %     fprintf(logfid,'Frame %d / %d\n',iframe,nframes_track);
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
      params.DEBUG=1;
      if params.DEBUG,

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
      set(handles.text_info,'String',['Tracking: frame ',num2str(iframe),' of ',num2str(min(params.lastframetrack,nframes)),' (',num2str(iframe*100/min(params.lastframetrack,nframes),'%.1f'),'%).'])  
      end

      if params.DEBUG || mod(t,1) == 0,
        drawnow;
      end

      if mod(iframe,5000) == 0,
        save(tmpfilename,'trxx','trxy','trxa','trxb','trxtheta','trxarea','istouching','gmm_isbadprior','pred','trxcurr','t','params','moviefile','bgmed','roidata','stage');
      end
      track=get(handles.pushbutton_start,'UserData');
      track.t=t;
      set(handles.pushbutton_start,'Userdata',track);
    end
    trackdata.t=t-1;
    %close(hwait)

    save(tmpfilename,'trxx','trxy','trxa','trxb','trxtheta','trxarea','istouching','gmm_isbadprior','pred','trxcurr','t','params','moviefile','bgmed','roidata','stage');
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
end

    %% clean up

    % fprintf(logfid,'Clean up...\n');
    guidata(handles.cbtrackGUI_ROI,handles)

    if fid > 1,
      try
        fclose(fid);
      catch ME,
        warning('Could not close movie: %s',getReport(ME));
      end
    end

    if exist(tmpfilename,'file'),
      try
        delete(tmpfilename);
      catch ME,
        warning('Could not delete tmp file: %s',getReport(ME));
      end
    end

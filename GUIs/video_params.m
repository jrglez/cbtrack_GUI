function varargout = video_params(varargin)
% VIDEO_PARAMS MATLAB code for video_params.fig
%      VIDEO_PARAMS, by itself, creates a new VIDEO_PARAMS or raises the existing
%      singleton*.
%
%      H = VIDEO_PARAMS returns the handle to a new VIDEO_PARAMS or the handle to
%      the existing singleton*.
%
%      VIDEO_PARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEO_PARAMS.M with the given input arguments.
%
%      VIDEO_PARAMS('Property','Value',...) creates a new VIDEO_PARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before video_params_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to video_params_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help video_params

% Last Modified by GUIDE v2.5 16-Jun-2014 16:45:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @video_params_OpeningFcn, ...
                   'gui_OutputFcn',  @video_params_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before video_params is made visible.
function video_params_OpeningFcn(hObject, eventdata, handles, varargin)
xmar0=20;
xmar1=245;
xmar2=20;
ymar0=50;
ymar1=60;
ymar2=100;

moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
BG=getappdata(0,'BG');
roidata=getappdata(0,'roidata');

nflies_per_roi=roidata.nflies_per_roi;

%%% Detect flies
f=cbparams.track.firstframetrack;
[readframe] = get_readframe_fcn(moviefile);
[im,dbkgd]=compute_dbkgd(readframe,1,1,cbparams.track,BG.bgmed,roidata.inrois_all);
im=im{1};
dbkgd=dbkgd{1};
[~,~,~,trx] = ChangeParams_GUI(readframe(1),BG.bgmed,dbkgd,roidata,nflies_per_roi,cbparams.detect_rois,cbparams.track);
trx2=struct('x',[],'y',[],'a',[],'b',[],'theta',[]);
trx2=repmat(trx2,[sum(nflies_per_roi),1]);
k=1;
for iroi = 1:size(trx,1),
    for fly=1:nflies_per_roi(iroi)
        trx2(k).x = trx{iroi}.x(fly);
        trx2(k).y = trx{iroi}.y(fly);
        trx2(k).a = trx{iroi}.a(fly)/2;
        trx2(k).b = trx{iroi}.b(fly)/2;
        trx2(k).theta = trx{iroi}.theta(fly);           
        k=k+1;
    end
end
trx=trx2;
nflies=length(trx);

%%% Setup video
scr_size=get(0,'ScreenSize');
scrw=scr_size(3);
scrh=scr_size(4);
maxaxesw=scrw-2*xmar0-xmar1-xmar2;
maxaxesh=scrh-2*ymar0-ymar1-ymar2;
[imh,imw]=size(im);

movie_params=cbparams.results_movie;
nzoomc=movie_params.nzoomc;
nzoomr=movie_params.nzoomr;
if ~isnumeric(nzoomr) || isempty(nzoomr) || ~isnumeric(nzoomc) || isempty(nzoomc),    
  if isnumeric(nzoomr) && ~isempty(nzoomr),
    nzoomc = round(nflies/nzoomr);
  elseif isnumeric(nzoomc) && ~isempty(nzoomc),
    nzoomr = round(nflies/nzoomc);
  else
    nzoomr = ceil(sqrt(nflies));
    nzoomc = round(nflies/nzoomr);
  end
end
nzoom=nzoomr*nzoomc;
figpos=movie_params.figpos;
if ~isnumeric(figpos) || isempty(figpos),  
    if nzoomr~=0
        rowszoom = floor(imh/nzoomr);
    else
        rowszoom = 0;
    end
    figpos = [1,1,imw+rowszoom*nzoomc,imh];
end
set_vidw=figpos(3);
set_vidh=figpos(4);
if nzoomr~=0
    rowszoom = floor(imh/nzoomr);
else
    rowszoom = 0;
end
vidw=imw+nzoomc*rowszoom;
vidh=imh;
axesw=set_vidw;
axesh=set_vidh;
if axesw>maxaxesw || axesh>maxaxesh
    rescw=maxaxesw/axesw;
    resch=maxaxesh/axesh;
    resc=min(rescw,resch);
else
    resc=1;
end
axesw=axesw*resc;
axesh=axesh*resc;
axesx=xmar1;
axesy=ymar1+(maxaxesh-axesh)/2;
guiw=axesw+xmar1+xmar2;
guih=maxaxesh+ymar1+ymar2;
guix=xmar0;
guiy=ymar0;
vidscale.position=[guix,guiy,guiw,guih];
maxaxesw=axesw;
maxaxesh=axesh;

set(hObject,'Units','pixels','Position',[guix,guiy,guiw,guih])
handles.axes_vid=axes('Parent',hObject,'Units','pixels');
hold on
handles.vid_img=imagesc(im,'Parent',handles.axes_vid);
axis(handles.axes_vid,[0.5,vidw+0.5,0.5,vidh+0.5]);
colormap('gray')

debugdata.vis=9; debugdata.DEBUG=0; debugdata.track=0; debugdata.vid=1; 
[~,trx]=TrackWingsSingle_GUI(trx,BG.bgmed,roidata.inrois_all,cbparams.wingtrack,readframe(f),debugdata);
doplotwings = cbparams.track.dotrackwings && all(isfield(trx,{'xwingl','ywingl','xwingr','ywingr'}));
scalefactor = movie_params.scalefactor;

max_a=max([trx.a]);
max_b=max([trx.b]);
max_scalefactor = rowszoom/(4*sqrt(max_a^2+max_b^2)-1);
scalefactor=min(max_scalefactor,scalefactor);
boxradius = round(0.5*(rowszoom/scalefactor)-1);
zoomflies=1:nzoom;
colors=jet(nflies);
if nflies<nzoom
    zoomflies(nflies+1:end)=nan;    
end
zoomflies=reshape(zoomflies,[nzoomr,nzoomc]);
% corners of zoom boxes in plotted image coords
if nzoom~=0
    x0 = imw+(0:nzoomc-1)*rowszoom+1;
    y0 = (0:nzoomr-1)*rowszoom+1;
    x1 = x0 + rowszoom - 1;
    y1 = y0 + rowszoom - 1;
else
    x0 = imw;
    y0 = 1;
    x1 = x0;
    y1 = y0 + imh - 1;
end

handles.himzoom=nan(nzoomr,nzoomc);
handles.hzoomwing=nan(nzoomr,nzoomc);
handles.hzoom=nan(nzoomr,nzoomc);
handles.htextzoom=nan(nzoomr,nzoomc);
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            handles.himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings,
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                handles.hzoomwing(i,j) = plot(xwing,ywing,'.-','color',colors(fly,:));
            end
            handles.hzoom(i,j) = drawflyo(x,y,theta,a,b);
            handles.htextzoom(i,j) = text((x0(j)+x1(j))/2,.95*y0(i)+.05*y1(i),s,...
                'color',colors(fly,:),'horizontalalignment','center',...
                'verticalalignment','bottom','fontweight','bold','Clipping','on');
            set(handles.hzoom(i,j),'color',colors(fly,:));
        end
    end
end
set(handles.axes_vid,'Xtick',[],'Ytick',[])
set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh],'Color',[204/255 204/255 204/255])
axis(handles.axes_vid,'equal');


% Plot unzoomed flies
for fly = 1:nflies,
  handles.htri(fly) = drawflyo(trx(fly),1);
  set(handles.htri(fly),'color',colors(fly,:));
  if doplotwings,
    xwing = [trx(fly).xwingl,trx(fly).x,trx(fly).xwingr];
    ywing = [trx(fly).ywingl,trx(fly).y,trx(fly).ywingr];
    handles.hwing(fly) = plot(xwing,ywing,'.-','color',colors(fly,:));
  end
end


%%% Create uiobjects
handles.text_resc=uicontrol('Style','text','Units','Pixels',...
    'Position',[xmar1,guih-ymar2,axesw,ymar2/2],'FontUnits','Pixels',...
    'FontSize',18,'HorizontalAlignment','center');
if resc<1
    resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc); 
else
    resc_s={''};
end  
set(handles.text_resc,'String',resc_s);

handles.panel_set=uipanel('Units','pixels','Title','Video Parameters',...
    'Position',[10,ymar1,xmar1-20,maxaxesh+6],'FontUnits','pixels','FontSize',12);
handles.panel_end=uipanel('Units','pixels','Position',[(guiw-250)/2,10,250,40],...
    'FontUnits','pixels','FontSize',14);

uiend_name={'pushbutton_cancel';'pushbutton_accept'};
uiend_style={'pushbutton';'pushbutton'};
uiend_string={'Cancel';'Accept'};
uiend_x=[21;140];
uiend_y=[3;3];
uiend_w=[90;90];
uiend_h=[34;34];
uiend_pos=[uiend_x uiend_y uiend_w uiend_h];
uiend_alignment={'center','center'};
uiend_enable={'on';'on'};
uiend_callback={@pushbutton_cancel_Callback;@pushbutton_accept_Callback;};
for i=1:numel(uiend_name)
    handles.(uiend_name{i})=uicontrol('Parent',handles.panel_end,...
        'Style',uiend_style{i},'Units','pixels','String',uiend_string{i},...
        'HorizontalAlignment',uiend_alignment{i},'Position',uiend_pos(i,:),...
        'FontUnits','pixels','FontSize',14,'Enable',uiend_enable{i},...
        'Callback',uiend_callback{i});
end

uiset_name={'checkbox_dovideo';'text_FPS';'edit_FPS';'checkbox_nzoom';...
    'text_nzoom';'text_nr';'edit_nr';'text_nc';'edit_nc';'text_zoom';...
    'slider_zoom';'edit_zoom';'text_tailL';'edit_tailL';'text_nframes';...
    'text_nframesI';'edit_nframesI';'text_nframesM';'edit_nframesM';...
    'text_nframesF';'edit_nframesF';'text_size';'text_vidw';'edit_vidw';...
    'text_vidh';'edit_vidh';'manual';'manual_start';'manual_back';...
    'manual_cancel'};
uiset_style={'checkbox';'text';'edit';'checkbox';'text';'text';'edit';'text';...
    'edit';'text';'slider';'edit';'text';'edit';'text';'text';'edit';'text';...
    'edit';'text';'edit';'text';'text';'edit';'text';'edit';...
    'text';'pushbutton';'pushbutton';'pushbutton'};
uiset_string={'Make resutls video';'Frames per second';num2str(movie_params.fps);...
    'Zoom Flies';'Number of zoomed flies';'Rows';num2str(nzoomr);...
    'Columns';num2str(nzoomc);'Zoom';'';num2str(scalefactor,'%.2f');...
    'Tail lenght';num2str(movie_params.taillength);...
    'Number of frames';'Initial';num2str(movie_params.nframes(1));...
    'Middle';num2str(movie_params.nframes(2));'End';num2str(movie_params.nframes(3));...
    'Video size';'Width';num2str(set_vidw);'Height';num2str(set_vidh);...
    'Manual fly selection';'Start';'Back';'Cancel'};
uiset_value={movie_params.dovideo;[];[];1;[];[];[];[];[];[];scalefactor;[];[];...
    [];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[]};
uiset_x=[15;25;175;15;25;30;55;130;155;25;25;175;25;175;25;30;30;95;95;160;...
    160;25;30;55;130;155;25;25;90;155];
uiset_y=guih-ymar2-[35;70;65;110;145;165;185;165;185;230;255;225;295;290;...
    330;350;370;350;370;350;370;415;435;455;435;455;500;530;530;530];
if uiset_y(1)-uiset_y(end)>maxaxesh-50
    uiset_y_new=uiset_y*(axesh-50)/(uiset_y(1)-uiset_y(end)); uiset_y=uiset_y_new+uiset_y(1)-uiset_y_new(1);
end
uiset_w=[175;150;50;175;175;100;50;100;50;100;200;50;100;50;150;50;50;50;50;...
    50;50;150;100;50;100;50;150;65;65;65];
uiset_h=[25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;...
    25;25;25;25;25;35;35;35];
uiset_pos=[uiset_x uiset_y uiset_w uiset_h];
uiset_alignment={'left','left','center','left','left','center','center','center',...
    'center','left','center','center','left','center','left',...
    'center','center','center','center','center','center','left','center',...
    'center','center','center','left','center','center','center','center'};
uiset_fs=repmat(14,[numel(uiset_name),1]); uiset_fs(1)=16;
uiset_BG=repmat([0.929 0.929 0.929],[numel(uiset_name),1]); uiset_BG(strcmp(uiset_style,'edit'),:)=1;
if movie_params.dovideo
    uiset_enable={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';...
        'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';...
        'on';'off';'off';'off';'off'};
else
    uiset_enable={'on';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';...
        'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';...
        'off';'off';'off';'off';'off';'off';'off';'off'};
end
uiset_callback={@checkbox_dovideo_Callback;@text_FPS_Callback;...
    @edit_FPS_Callback;@checkbox_nzoom_Callback; @text_zoom_Callback;...
    @text_nr_Callback;@reset_nzoom;@text_nc_Callback;...
    @reset_nzoom;@text_zoom_Callback;@slider_zoom_Callback;...
    @edit_zoom_Callback;@text_tailL_Callback;@edit_tailL_Callback;...
    @text_nframes_Callback;@text_nframesI_Callback;@edit_nframesI_Callback;...
    @text_nframesM_Callback;@edit_nframesM_Callback;...
    @text_nframesF_Callback;@edit_nframesF_Callback;...
    @text_size_Callback;@text_vidw_Callback;@edit_vidw_Callback;...
    @text_vidh_Callback;@edit_vidh_Callback;@text_manual;...
    @pushbutton_manual_start;@pushbutton_manual_back;@pushbutton_manual_candcel};
for i=1:numel(uiset_style)
    handles.(uiset_name{i})=uicontrol('Style',uiset_style{i},'Units','pixels',...
    'String',uiset_string{i},'Value',uiset_value{i},...
    'HorizontalAlignment',uiset_alignment{i},'Position',uiset_pos(i,:),...
    'FontUnits','pixels','FontSize',uiset_fs(i),'Enable',uiset_enable{i},...
    'BackgroundColor',uiset_BG(i,:),'Callback',uiset_callback{i});
end

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

if nzoom~=0
    set(handles.slider_zoom,'Min',1e-6,'Max',max_scalefactor+1.1e-6)
else
    set(handles.checkbox_nzoom,'Value',false)
    checkbox_nzoom_Callback(handles.checkbox_nzoom, eventdata);
end
fcn_slider_zoom= get(handles.slider_zoom,'Callback');
hlisten_frame=addlistener(handles.slider_zoom,'ContinuousValueChange',fcn_slider_zoom); %#ok<NASGU>

movie_params.scalefactor=scalefactor;
movie_params.nzoomr=nzoomr;
movie_params.nzoomc=nzoomc;
movie_params.figpos=figpos;
vid.maxaxesw=maxaxesw;
vid.maxaxesh=maxaxesh;
vid.trx=trx;
vid.zoomflies=zoomflies;
vid.rowszoom=rowszoom;
vid.boxradius=boxradius;
vid.colors=colors;
vid.im=im;
vid.mar=[xmar0,ymar0;xmar1,ymar1;xmar2,ymar2];
vid.x0=x0;
vid.y0=y0;
vid.doplotwings=doplotwings;
set(handles.panel_set,'UserData',movie_params);
set(handles.axes_vid,'UserData',vid);
set(handles.figure1,'UserData',vidscale);

function varargout = video_params_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function figure1_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>


function slider_zoom_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

scalefactor=get(handles.slider_zoom,'Value');
set(handles.edit_zoom,'String',num2str(scalefactor,'%.2f'))
nzoomc=movie_params.nzoomc;
nzoomr=movie_params.nzoomr;
rowszoom=vid.rowszoom;
boxradius = round(0.5*(rowszoom/scalefactor)-1);
if isnan(boxradius) || isinf(boxradius) || boxradius==0 || isnan(scalefactor) || isinf(scalefactor) || scalefactor==0
    set(handles.checkbox_nzoom,'Value',0)
    checkbox_nzoom_Callback(handles.checkbox_nzoom, eventdata)
    return
end

trx=vid.trx;
zoomflies=vid.zoomflies;
colors=vid.colors;
im=vid.im;
x0=vid.x0;
y0=vid.y0;
doplotwings=vid.doplotwings;

hvis=get(get(handles.axes_vid,'Parent'),'HandleVisibility');
set(get(handles.axes_vid,'Parent'),'HandleVisibility','on')
hold on
% corners of zoom boxes in plotted image coords
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            set(handles.himzoom(i,j),'cdata',repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings 
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                set(handles.hzoomwing(i,j),'XData',xwing,'YData',ywing,'Color',colors(fly,:));
            end
            updatefly(handles.hzoom(i,j),x,y,theta,a,b);
            set(handles.htextzoom(i,j),'string',s,'color',colors(fly,:));
        else
            handles.himzoom(i,j)=nan;
            handles.hzoomwing(i,j)=nan;
            handles.hzoom(i,j)=nan;
            handles.htextzoom(i,j)=nan;
        end
    end
end
set(get(handles.axes_vid,'Parent'),'HandleVisibility',hvis)

set(handles.panel_set,'UserData',movie_params);

function edit_zoom_Callback(hObject, eventdata)
handles=guidata(hObject);
scalefactor=str2double(get(hObject,'String'));
set(handles.slider_zoom,'Value',scalefactor);
slider_zoom_Callback(handles.slider_zoom, eventdata);


function edit_vidw_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

xmar1=vid.mar(2,1);
ymar1=vid.mar(2,2);

set_vidw=str2double(get(hObject,'String'));
set_vidh=movie_params.figpos(4);
maxaxesw=vid.maxaxesw;
maxaxesh=vid.maxaxesh;
axesw=set_vidw;
axesh=set_vidh;
if axesw>maxaxesw || axesh>maxaxesh
    rescw=maxaxesw/axesw;
    resch=maxaxesh/axesh;
    resc=min(rescw,resch);
else
    resc=1;
end
axesw=axesw*resc;
axesh=axesh*resc;
axesx=xmar1;
axesy=ymar1+(maxaxesh-axesh)/2;

set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh]);
axis(handles.axes_vid,'equal');
set(hObject,'String',num2str(set_vidw,'%i'))
if resc<1
    resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc); 
else
    resc_s={''};
end  
set(handles.text_resc,'String',resc_s);



function edit_vidh_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

xmar1=vid.mar(2,1);
ymar1=vid.mar(2,2);

set_vidw=movie_params.figpos(3);
set_vidh=str2double(get(hObject,'String'));
maxaxesw=vid.maxaxesw;
maxaxesh=vid.maxaxesh;
axesw=set_vidw;
axesh=set_vidh;
if axesw>maxaxesw || axesh>maxaxesh
    rescw=maxaxesw/axesw;
    resch=maxaxesh/axesh;
    resc=min(rescw,resch);
else
    resc=1;
end
axesw=axesw*resc;
axesh=axesh*resc;
axesx=xmar1;
axesy=ymar1+(maxaxesh-axesh)/2;

set(handles.figure1,'Position',[guix,guiy,guiw,guih]);
set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh]);
axis(handles.axes_vid,'equal');
set(hObject,'String',num2str(set_vidh,'%i'))
if resc<1
    resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc); 
else
    resc_s={''};
end  
set(handles.text_resc,'String',resc_s);



function checkbox_dovideo_Callback(hObject, eventdata)
handles=guidata(hObject);
uiset_name={'checkbox_dovideo';'text_FPS';'edit_FPS';'text_nzoom';'text_nr';...
    'edit_nr';'text_nc';'edit_nc';'text_zoom';'slider_zoom';'edit_zoom';...
    'text_tailL';'edit_tailL';'text_nframes';'text_nframesI';...
    'edit_nframesI';'text_nframesM';'edit_nframesM';'text_nframesF';...
    'edit_nframesF';'text_size';'text_vidw';'edit_vidw';'text_vidh';'edit_vidh';};
if get(hObject,'Value')
    for i=2:numel(uiset_name)
        set(handles.(uiset_name{i}),'Enable','on')
    end
else
    for i=2:numel(uiset_name)
        set(handles.(uiset_name{i}),'Enable','off')
    end
end
        
function pushbutton_cancel_Callback(hObject, eventdata)
handles=guidata(hObject);
delete(handles.figure1)

function pushbutton_accept_Callback(hObject, eventdata)
handles=guidata(hObject);
cbparams=getappdata(0,'cbparams');
movie_params=get(handles.panel_set,'UserData');

movie_params.dovideo=get(handles.checkbox_dovideo,'Value');
movie_params.nzoomr=str2double(get(handles.edit_nr,'String'));
movie_params.nzoomc=str2double(get(handles.edit_nc,'String'));
movie_params.scalefator=str2double(get(handles.edit_zoom,'String'));
movie_params.fps=str2double(get(handles.edit_FPS,'String'));
movie_params.taillength=str2double(get(handles.edit_tailL,'String'));
movie_params.nframes=[str2double(get(handles.edit_nframesI,'String')),str2double(get(handles.edit_nframesM,'String')),str2double(get(handles.edit_nframesF,'String'))];
movie_params.figpos=[1,1,str2double(get(handles.edit_vidw,'String')),str2double(get(handles.edit_vidh,'String'))];

cbparams.results_movie=movie_params;
setappdata(0,'cbparams',cbparams);

delete(handles.figure1)


function edit_FPS_Callback(hObject, eventdata)


function edit_tailL_Callback(hObject, eventdata)


function edit_nframesI_Callback(hObject, eventdata)


function edit_nframesM_Callback(hObject, eventdata)


function edit_nframesF_Callback(hObject, eventdata)


function figure1_ResizeFcn(hObject, eventdata, handles)
handles=guidata(hObject);
if isfield(handles,'axes_vid')
    movie_params=get(handles.panel_set,'UserData');
    vidscale=get(handles.figure1,'UserData');
    vidscale=GUIresize(handles,hObject,vidscale);

    figpos=movie_params.figpos;
    position=get(handles.axes_vid,'Position');
    if figpos(3)>position(3) || figpos(4)>position(4)
        rescw=position(3)/figpos(3);
        resch=position(4)/figpos(4);
        resc=min(rescw,resch);
        resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc);
    else
        pos_panel=get(handles.panel_set,'Position');
        axesx=position(1);
        axesy=pos_panel(2)+(pos_panel(4)-figpos(4))/2;
        axesw=figpos(3);
        axesh=figpos(4);
        set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh])
        resc_s={''};
    end
    set(handles.text_resc,'String',resc_s);
    
    vid=get(handles.axes_vid,'UserData');
    axespos=get(handles.axes_vid,'Position');
    vid.maxaxesw=axespos(3);
    vid.maxaxesh=axespos(4);
    set(handles.axes_vid,'UserData',vid);
    
    vidscale.position=get(handles.figure1,'Position');
    set(handles.figure1,'UserData',vidscale);
end


function checkbox_nzoom_Callback(hObject, eventdata)
handles=guidata(hObject);
if get(hObject,'Value')
    movie_params=get(handles.panel_set,'UserData');
    if movie_params.nzoomr==0
        movie_params.nzoomr=1;
    end
    if movie_params.nzoomc==0
        movie_params.nzoomc=1;
    end
    if movie_params.scalefactor==0
        movie_params.scalefactor=1;
    end
    set(handles.text_nzoom,'Enable','on')
    set(handles.text_nr,'Enable','on')
    set(handles.edit_nr,'Enable','on','String',num2str(movie_params.nzoomr))
    set(handles.text_nc,'Enable','on')
    set(handles.edit_nc,'Enable','on','String',num2str(movie_params.nzoomc))
    set(handles.text_zoom,'Enable','on')
    set(handles.slider_zoom,'Enable','on','Value',movie_params.nzoomr)
    set(handles.edit_zoom,'Enable','on','String',num2str(movie_params.scalefactor))
    reset_nzoom(hObject, eventdata)
else
    set(handles.text_nzoom,'Enable','off')
    set(handles.text_nr,'Enable','off')
    set(handles.edit_nr,'Enable','off','String','0')
    set(handles.text_nc,'Enable','off')
    set(handles.edit_nc,'Enable','off','String','0')
    set(handles.text_zoom,'Enable','off')
    set(handles.slider_zoom,'Enable','off')
    set(handles.edit_zoom,'Enable','off','String','')
    
    vid=get(handles.axes_vid,'UserData');

    if ~isempty(vid)
        delete(handles.himzoom(ishandle(handles.himzoom)))
        handles.himzoom=[];
        delete(handles.htextzoom(ishandle(handles.htextzoom)))
        handles.htextzoom=[];
        if vid.doplotwings,
            delete(handles.hzoomwing(ishandle(handles.hzoomwing)));
            handles.hzoomwing=[];
            delete(handles.hzoom(ishandle(handles.hzoom)));
            handles.hzoom=[];
        end
        im=vid.im;
        [imh,imw]=size(im);
        axis(handles.axes_vid,[0.5,imw+0.5,0.5,imh+0.5]);
        axis(handles.axes_vid,'equal');

        guidata(hObject, handles);

        vid.zoomflies=0;
        vid.rowszoom=0;
        vid.boxradius=0;
        vid.vidpos=[1,1,imw,imh];
        vid.x0=[];
        vid.y0=[];
        set(handles.axes_vid,'UserData',vid);
    end
    %%% aqui. cuando uncheck, borrar los zooms. Despues, si nr o nc==0, que
    %%% hacer?
end
    
    
function reset_nzoom(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

im=vid.im;
[imh,imw]=size(im);

nzoomr=round(str2double(get(handles.edit_nr,'String')));
set(handles.edit_nr,'String',num2str(nzoomr,'%i'))
nzoomc=round(str2double(get(handles.edit_nc,'String')));
set(handles.edit_nc,'String',num2str(nzoomc,'%i'))
nzoom=nzoomr*nzoomc;
scalefactor = str2double(get(handles.edit_zoom,'String'));
if nzoom==0 || isnan(nzoom) || isinf(nzoom) || scalefactor==0 || isnan(scalefactor) || isinf(scalefactor)
    set(handles.checkbox_nzoom,'Value',0)
    checkbox_nzoom_Callback(handles.checkbox_nzoom, eventdata)
    return
end
rowszoom=floor(imh/nzoomr);
vidw=imw+nzoomc*rowszoom;
vidh=imh;

axis(handles.axes_vid,[0.5,vidw+0.5,0.5,vidh+0.5]);

trx=vid.trx;
doplotwings = vid.doplotwings;
max_a=max([trx.a]);
max_b=max([trx.b]);
max_scalefactor = rowszoom/(4*sqrt(max_a^2+max_b^2)-1);
scalefactor=min(max_scalefactor,scalefactor);
boxradius = round(0.5*(rowszoom/scalefactor)-1);
nflies=length(trx);
zoomflies=1:nzoom;
colors=jet(nflies);
if nflies<nzoom
    zoomflies(nflies+1:end)=nan;    
end
zoomflies=reshape(zoomflies,[nzoomr,nzoomc]);
delete(handles.himzoom(ishandle(handles.himzoom)))
handles.himzoom=[];
delete(handles.htextzoom(ishandle(handles.htextzoom)))
handles.htextzoom=[];
if doplotwings,
    delete(handles.hzoomwing(ishandle(handles.hzoomwing)));
    handles.hzoomwing=[];
    delete(handles.hzoom(ishandle(handles.hzoom)));
    handles.hzoom=[];
end
hold on

% corners of zoom boxes in plotted image coords
x0 = imw+(0:nzoomc-1)*rowszoom+1;
y0 = (0:nzoomr-1)*rowszoom+1;
x1 = x0 + rowszoom - 1;
y1 = y0 + rowszoom - 1;
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            handles.himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings,
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                handles.hzoomwing(i,j) = plot(xwing,ywing,'.-','color',colors(fly,:));
            end
            handles.hzoom(i,j) = drawflyo(x,y,theta,a,b);
            handles.htextzoom(i,j) = text((x0(j)+x1(j))/2,.80*y0(i)+.20*y1(i),s,...
                'color',colors(fly,:),'horizontalalignment','center',...
                'verticalalignment','bottom','fontweight','bold');
            set(handles.hzoom(i,j),'color',colors(fly,:));
        else
            handles.himzoom(i,j)=nan;
            handles.hzoomwing(i,j)=nan;
            handles.hzoom(i,j)=nan;
            handles.htextzoom(i,j)=nan;
        end        
    end
end
axis(handles.axes_vid,'equal');

set(handles.slider_zoom,'Max',max_scalefactor,'Value',scalefactor)
set(handles.edit_zoom,'String',num2str(scalefactor,'%.2f'))

guidata(hObject, handles);

movie_params.scalefactor=scalefactor;
movie_params.nzoomr=nzoomr;
movie_params.nzoomr=nzoomc;
vid.zoomflies=zoomflies;
vid.rowszoom=rowszoom;
vid.boxradius=boxradius;
vid.colors=colors;
vid.vidpos=[1,1,vidw,vidh];
vid.x0=x0;
vid.y0=y0;
set(handles.panel_set,'UserData',movie_params);
set(handles.axes_vid,'UserData',vid);
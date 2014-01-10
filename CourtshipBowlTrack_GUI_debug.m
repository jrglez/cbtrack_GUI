function CourtshipBowlTrack_GUI_debug(handles)
%% parse inputs
% ParseCourtshipBowlParams_GUI;
moviefile=getappdata(0,'moviefile');
cbparams = getappdata(0,'cbparams');
params=cbparams.track;

SetBackgroundTypes;
if ischar(params.bgmode) && isfield(bgtypes,params.bgmode),
  params.bgmode = bgtypes.(params.bgmode);
end
restart = getappdata(0,'restart');

if ~isfield(params,'DEBUG'),
  params.DEBUG = 0;
end
if params.dotrackwings || strcmp(params.assignidsby,'wingsize'),
  params.wingtracking_params = cbparams.wingtrack;
end

%% load background model
BG=getappdata(0,'BG');
bgmed=BG.bgmed;

%% load roi info
roidata=getappdata(0,'roidata');

%% main function

trackdata = TrackTwoFlies_GUI_debug(handles,moviefile,bgmed,roidata,params,'restart',restart);
setappdata(0,'trackdata',trackdata)


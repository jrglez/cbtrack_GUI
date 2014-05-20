function clear_partial(iframe)
cbparams=getappdata(0,'cbparams');
roidata=getappdata(0,'roidata');
params=cbparams.track;
trackdata=getappdata(0,'trackdata');
t = iframe + cbparams.track.firstframetrack - 1;
trackdata.t=t;
trackdata.trxx(:,:,iframe+1:end)=nan; %#ok<*NASGU>
trackdata.trxy(:,:,iframe+1:end)=nan;
trackdata.trxa(:,:,iframe+1:end)=nan;
trackdata.trxb(:,:,iframe+1:end)=nan;
trackdata.trxtheta(:,:,iframe+1:end)=nan;
trackdata.trxarea(:,:,iframe+1:end)=nan;
trackdata.istouching(:,iframe+1:end)=nan;
trackdata.gmm_isbadprior(:,iframe+1:end)=nan;
trackdata.trxpriors(:,:,iframe+1:end)=nan;
trxcurr=trackdata.trxcurr;
trxprev=trackdata.trxcurr;
pred=trackdata.pred;
nrois=size(trackdata.trxx,2);
for i=1:nrois
    trxcurr(i).x=trackdata.trxx(:,i,iframe);
    trxcurr(i).y=trackdata.trxy(:,i,iframe);
    trxcurr(i).a=trackdata.trxa(:,i,iframe);
    trxcurr(i).b=trackdata.trxb(:,i,iframe);
    trxcurr(i).area=trackdata.trxarea(:,i,iframe);
    trxcurr(i).istouching=trackdata.istouching(i,iframe);
    trxcurr(i).gmm_isbadprior=trackdata.gmm_isbadprior(i,iframe);
    trxprev(i).x=trackdata.trxx(:,i,iframe-1);
    trxprev(i).y=trackdata.trxy(:,i,iframe-1);
    trxprev(i).a=trackdata.trxa(:,i,iframe-1);
    trxprev(i).b=trackdata.trxb(:,i,iframe-1);
    trxprev(i).area=trackdata.trxarea(:,i,iframe-1);
    pred(i).area = trxcurr.area;
    pred(i).x = (2-params.err_dampen_pos)*trxcurr(i).x - (1-params.err_dampen_pos)*trxprev(i).x;
    pred(i).y = (2-params.err_dampen_pos)*trxcurr(i).y - (1-params.err_dampen_pos)*trxprev(i).y;
    dtheta = modrange(trxcurr(i).theta-trxprev(i).theta,-pi/2,pi/2);
    pred(i).theta = trxcurr(i).theta+(1-params.err_dampen_theta)*dtheta;
    pred(i).mix.priors = (1-params.err_dampen_priors)*trackdata.trxpriors(:,i,iframe) + params.err_dampen_priors*.5;
    % set centres, covars to predicted positions
    pred(i).mix.centres = [pred(i).x,pred(i).y];
    pred(i).mix.covars = axes2cov(trxcurr(i).a,trxcurr(i).b,pred(i).theta);

    if iframe==1
        pred.isfirstframe=0;
    end    
end
trackdata.trxcurr=trxcurr;
trackdata.pred=pred;
setappdata(0,'trackdata',trackdata);



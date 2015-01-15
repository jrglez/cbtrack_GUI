function [frame_rs,dbkgd,isfore,cc_ind,flies_ind,trx] = ChangeParams_GUI(frame,roidata,nflies_per_roi,tracking_params,vign,H0,vis_plot)
% do background subtraction to count flies in each roi
BG = getappdata(0,'BG');
bgmed = BG.bgmed;

nrois = roidata.nrois;
areassample = cell(nrois,1);
isfore=[];
cc_ind=cell(nrois,1);
flies_ind=cell(nrois,1);
trx=cell(nrois,1);

trxcurr = struct;
trxcurr.x = nan(2,1);
trxcurr.y = nan(2,1);
trxcurr.a = nan(2,1);
trxcurr.b = nan(2,1);
trxcurr.theta = nan(2,1);
trxcurr.area = nan(2,1);
trxcurr.istouching = nan;
trxcurr.gmm_isbadprior = nan;
trxcurr = repmat(trxcurr,[1,nrois]);

% Subtract bg
if tracking_params.normalize
    im_class='double';
    normalize=bgmed;
else
    im_class=class(frame);
    normalize=ones(size(bgmed));
end

[frame_rs,dbkgd]=compute_dbkgd1(frame,tracking_params,bgmed,roidata.inrois_all,H0,im_class,vign,normalize);
if vis_plot>2
    % threshold
    isfore = dbkgd >= tracking_params.bgthresh;
    se_open=strel('disk',tracking_params.radius_open_body);
    isfore=imopen(isfore,se_open);
    
    if vis_plot>3
        for j = 1:nrois,
            if any(roidata.ignore==j),
                cc_ind{j} = [];
                flies_ind{j} = [];
                trx{j} = [];
                continue;
            end
            roibb = roidata.roibbs(j,:);
            roibb([1,3]) =  floor(roibb([1,3])/tracking_params.down_factor);
            roibb([2,4]) =  ceil(roibb([2,4])/tracking_params.down_factor);
            roibb(roibb==0)=1;
            isforebb = isfore(roibb(3):roibb(4),roibb(1):roibb(2));
            isforebb(~roidata.inrois{j}) = false;
            cc = bwconncomp(isforebb);
            areassample{j} = cellfun(@numel,cc.PixelIdxList);    
            isfly=[areassample{j}]>=tracking_params.minccarea;
            [y,x]=cellfun(@(x) ind2sub(size(isforebb),x),cc.PixelIdxList,'UniformOutpu',0);
            cc_ind{j}=cellfun(@(x,y) cat(2,x+roibb(1)-1,y+roibb(3)-1),x,y,'UniformOutpu',0);
            if vis_plot==5
                flies_ind{j}=cellfun(@(x,y) cat(2,x+roibb(1)-1,y+roibb(3)-1),x(isfly),y(isfly),'UniformOutpu',0);
            end

            if vis_plot==6
                dbkgdbb = double(dbkgd(roibb(3):roibb(4),roibb(1):roibb(2)));
                dbkgdbb(~roidata.inrois{j}) = 0;
                isforebb(~roidata.inrois{j}) = false;
                pred.isfirstframe=1;
                [trx{j},~] = TrackTwoFliesOneFrameOneROI_GUI(isforebb,dbkgdbb,pred,trxcurr(j),nflies_per_roi(j),tracking_params);
                trx{j}.x=trx{j}.x+roibb(1)-1;
                trx{j}.y=trx{j}.y+roibb(3)-1;
            end
        end
    end
end
  

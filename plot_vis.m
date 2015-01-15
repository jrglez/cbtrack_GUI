function plot_vis(handles,visdata)
switch visdata.plot
    case 1
        if isfield(visdata,'hell') 
            delete(visdata.hell(ishandle(visdata.hell)))
        end
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.frame_rs);
    case 2
        if isfield(visdata,'hell') 
            delete(visdata.hell(ishandle(visdata.hell)))
        end
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.dbkgd);
    case 3
        if isfield(visdata,'hell') 
            delete(visdata.hell(ishandle(visdata.hell)))
        end
        visdata.hell=[];
        im=double(visdata.frame_rs);
        im_r=im; im_r(visdata.isfore)=min(255,im_r(visdata.isfore)*1.5+89);
        im=repmat(im,[1,1,3]);
        im(:,:,1)=im_r;
        im=uint8(im);
        set(handles.BG_img,'CData',im);
    case 4
        if isfield(visdata,'hell') 
            delete(visdata.hell(ishandle(visdata.hell)))
        end
        visdata.hell=[];
        
        nROI=size(visdata.cc_ind,1);
        nc=size(visdata.frame_rs,2);
        nr=size(visdata.frame_rs,1);
        imtmp = repmat(double(visdata.frame_rs(:)),[1,3]);
        for i=1:nROI
            cc_ind=visdata.cc_ind{i};
            if ~isempty(cc_ind)
                ncc=length(cc_ind);
                colors_cc=hsv(ncc)*0.7;
                for k=1:ncc
                    idx=sub2ind([nr,nc],cc_ind{k}(:,2),cc_ind{k}(:,1));
                    imtmp(idx,:)=min(bsxfun(@plus,imtmp(idx,:)*3,255*colors_cc(k,:))/2,255);
                end
            end
        end
        imtmp = uint8(reshape(imtmp,[nr,nc,3]));
        set(handles.BG_img,'CData',imtmp);
    case 5
        if isfield(visdata,'hell') 
            delete(visdata.hell(ishandle(visdata.hell)))
        end
        visdata.hell=[];
        
        nROI=size(visdata.cc_ind,1);
        nc=size(visdata.frame_rs,2);
        nr=size(visdata.frame_rs,1);
        imtmp = repmat(double(visdata.frame_rs(:)),[1,3]);
        for i=1:nROI
            flies_ind=visdata.flies_ind{i};
            if ~isempty(flies_ind)
                ncc=length(flies_ind);
                colors_cc=hsv(ncc)*0.7;
                for k=1:ncc
                    idx=sub2ind([nr,nc],flies_ind{k}(:,2),flies_ind{k}(:,1));
                    imtmp(idx,:)=min(bsxfun(@plus,imtmp(idx,:)*3,255*colors_cc(k,:))/2,255);
                end
            end
        end
        imtmp = uint8(reshape(imtmp,[nr,nc,3]));
        set(handles.BG_img,'CData',imtmp);
    case 6
        if isfield(visdata,'hell') 
            delete(visdata.hell(ishandle(visdata.hell)))
        end
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.frame_rs);
        nROI=size(visdata.trx,1);
        l=0;
        hold(handles.axes_tracker,'on')
        for i=1:nROI
            trx=visdata.trx{i};
            if ~isempty(trx)
                nell=length(trx.x);
                colors_ell=hsv(nell)*0.7;
                for k=1:length(trx.x)
                    l=l+1;
                    visdata.hell(l) = drawellipse(trx.x(k),trx.y(k),trx.theta(k),trx.a(k),trx.b(k),'Color',colors_ell(k,:),'LineWidth',2);
                end
            end
        end
        hold(handles.axes_tracker,'off')
end
[nr,nc]=size(visdata.frame_rs);
axis(handles.axes_tracker,[0.5 nc 0.5 nr])
axis(handles.axes_tracker,'equal')

set(handles.popupmenu_vis,'UserData',visdata)
function plot_vis(handles,visdata,f)
switch visdata.plot
    case 1
        delete(visdata.hcc)
        visdata.hcc=[];
        delete(visdata.hflies)
        visdata.hflies=[];
        delete(visdata.hell)
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.frames{f});
        colormap('gray')
        delete(visdata.hcc)
    case 2
        delete(visdata.hcc)
        visdata.hcc=[];
        delete(visdata.hflies)
        visdata.hflies=[];
        delete(visdata.hell)
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.dbkgd{f});
        colormap('gray')
        delete(visdata.hcc)
    case 3
        delete(visdata.hcc)
        visdata.hcc=[];
        delete(visdata.hflies)
        visdata.hflies=[];
        delete(visdata.hell)
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.isfore{f});
        colormap('gray')
        delete(visdata.hcc)
    case 4
        delete(visdata.hcc)
        visdata.hcc=[];
        delete(visdata.hflies)
        visdata.hflies=[];
        delete(visdata.hell)
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.rois);
        colormap('light_gray')
        nROI=size(visdata.cc_ind,1);
        l=0;
        for i=1:nROI
            cc_ind=visdata.cc_ind{i,f};
            if ~isempty(cc_ind)
                ncc=length(cc_ind);
                colors_cc=hsv(ncc)*0.7;
                for k=1:ncc
                    l=l+1;
                    visdata.hcc(l)=plot(cc_ind{k}(:,1),cc_ind{k}(:,2),'.','Color',colors_cc(k,:));
                end
            end
        end
    case 5
        delete(visdata.hcc)
        visdata.hcc=[];
        delete(visdata.hflies)
        visdata.hflies=[];
        delete(visdata.hell)
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.rois);
        colormap('light_gray')
        nROI=size(visdata.flies_ind,1);
        l=0;
        for i=1:nROI
             flies_ind=visdata.flies_ind{i,f};
           if ~isempty(flies_ind)
                nflies=length(flies_ind);
                colors_flies=hsv(nflies)*0.7;
                for k=1:nflies
                    l=l+1;
                    visdata.hflies(l)=plot(flies_ind{k}(:,1),flies_ind{k}(:,2),'.','Color',colors_flies(k,:));
                end
            end
        end
    case 6
        delete(visdata.hcc)
        visdata.hcc=[];
        delete(visdata.hflies)
        visdata.hflies=[];
        delete(visdata.hell)
        visdata.hell=[];
        set(handles.BG_img,'CData',visdata.frames{f});
        colormap('gray')
        nROI=size(visdata.trx,1);
        l=0;
        for i=1:nROI
            trx=visdata.trx{i,f};
            if ~isempty(trx)
                nell=length(trx.x);
                colors_ell=hsv(nell)*0.7;
                for k=1:length(trx.x)
                    l=l+1;
                    visdata.hell(l) = drawellipse(trx.x(k),trx.y(k),trx.theta(k),trx.a(k),trx.b(k),'Color',colors_ell(k,:),'LineWidth',2);
                end
            end
        end
end
set(handles.popupmenu_vis,'UserData',visdata)
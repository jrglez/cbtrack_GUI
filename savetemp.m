function savetemp(savelist)
if strcmp(savelist,'all')
    savelist={'text_log','expdir','moviefile','experiment',...
        'analysis_protocol','P_stage','GUIscale', 'cbparams','BG',...
        'roidata','visdata','trackdata','debugdata'};
end
savelist2={'P_stage','cbparams'};
out=getappdata(0,'out');

scrSize=get(0,'screensize');
boxpos=[(scrSize(3)-500)/2,(scrSize(4)-150)/2,500,150];
hbox=figure('units','pixels','position',boxpos,'windowstyle','modal');
htext=uicontrol('style','text','BackgroundColor',[0.8 0.8 0.8],'FontUnits','pixels',...
    'FontSize',14,'units','pixels','position',[50 35 400 80],...
    'HorizontalAlignment','center','Parent',hbox);
s={['Experiment ', getappdata(0,'experiment')];'';'Saving temporary resulst'};
s=textwrap(s,htext);
set(htext,'String',s)

logfid=open_log('main_log');
s=sprintf('Saving temporary results to file %s...\n\n***\n',out.temp_full);
write_log(logfid,getappdata(0,'experiment'),s)
if logfid>2
    fclose(logfid);
end
for i=1:length(savelist)
    if isappdata(0,savelist{i})
        eval([savelist{i},'=getappdata(0,''',savelist{i},''');'])
        if i==1 && ~exist(out.temp_full,'file')
            save(out.temp_full,savelist{i})
        else
            save(out.temp_full,savelist{i},'-append')
        end            
    end
end
for i=1:length(savelist2)
    if isappdata(0,savelist2{i})
        eval([savelist2{i},'=getappdata(0,''',savelist2{i},''');'])
        save(out.temp_full,savelist2{i},'-append')
    end
end

if ishandle(hbox)
    delete(hbox)
end


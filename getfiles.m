function [expdirs,moviefile,exps,analysis_protocol,paramsfile,omitedexp_all]=getfiles(handles)
VidDirOrTxt=get(handles.uipanel_folder,'SelectedObject');
omitedexp_all=[];
if VidDirOrTxt==handles.radiobutton_Vid
    fullfilein=get(handles.edit_in,'String');
    [expdirs{1},moviefile{1},ext]=fileparts(fullfilein);
    exps{1}=splitdir(expdirs{1},'last');
    moviefile=strcat(moviefile{1},ext); moviefile={fullfile(expdirs{1},moviefile)};
    analysis_protocol=splitdir(expdirs{1},'last');
    paramsfile={fullfile(expdirs{1},'params.xml')};
elseif VidDirOrTxt==handles.radiobutton_Dir
    expdir=get(handles.edit_in,'String');
    content=dir(expdir);
    aredirs=[content.isdir];
    for i=1:numel(aredirs)
        aredirs(i)=aredirs(i)&&~strcmp(content(i).name(1),'.');
    end    
    exps={content(aredirs).name};

    movie_name=cell(1,numel(exps));
    filetypes={'.ufmf','.fmf','.sbfmf','.avi','.mp4','.mov','.mmf'};
    expdirs=fullfile(expdir,exps);
    success=true(1,numel(expdirs));
    for i=1:numel(expdirs)
        expcontent=(dir(expdirs{i}));        
        nmovies=0;
        for j=1:numel(expcontent)
            [~,ext]=splitext(expcontent(j).name);
            if any(strcmp(ext,filetypes))
                nmovies=nmovies+1;
                movie_name{i}=expcontent(j).name;
            end                    
        end
        if nmovies~=1
            success(i)=false;            
        end
    end
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[];
    expdirs(~success)=[];
    movie_name(~success)=[];
    if isempty(exps)
      exps = exps(:)'; % to match empty size of movie_name 
    end
    moviefile=fullfile(expdir,exps,movie_name);
    analysis_protocol = splitdir(expdir,'last');
    paramsfile=fullfile(expdir,'params.xml');
    if exist(paramsfile,'file')==2
        % Undocumented single-parameter-file option
        paramsfile={paramsfile};
    else
        paramsfile=fullfile(expdirs,'params.xml');
    end
elseif VidDirOrTxt==handles.radiobutton_Txt
    fullfiletxt=get(handles.edit_in,'String');
    [analysis_protocol,paramsfile,expdirs] = ReadGroupedExperimentList_queue(fullfiletxt);

    exps=cell(1,numel(expdirs));
    movie_name=cell(1,numel(expdirs));
    filetypes={'.ufmf','.fmf','.sbfmf','.avi','.mp4','.mov','.mmf'};
    success=true(1,numel(expdirs));
    for i=1:numel(expdirs)
        exps{i}=splitdir(expdirs{i},'last');
        expcontent=(dir(expdirs{i}));        
        nmovies=0;
        for j=1:numel(expcontent)
            [~,ext]=splitext(expcontent(j).name);
            if any(strcmp(ext,filetypes))
                nmovies=nmovies+1;
                movie_name{i}=expcontent(j).name;
            end                    
        end
        if nmovies~=1
            success(i)=false;         
        end
    end
    omitedexp=exps(~success);
    omitedexp_all=[omitedexp_all,omitedexp];
    exps(~success)=[];
    expdirs(~success)=[];
    movie_name(~success)=[];

    moviefile=fullfile(expdirs,movie_name);
end
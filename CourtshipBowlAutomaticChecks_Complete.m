function [success,msgs,iserror] = CourtshipBowlAutomaticChecks_Complete(expdir,varargin)

version = '0.1';
timestamp = datestr(now,TimestampFormat);

experiment = getappdata(0,'experiment');
analysis_protocol = getappdata(0,'analysis_protocol');
cbparams = getappdata(0,'cbparams');
check_params = cbparams.auto_checks_complete;


%% log file
logfid=open_log('automaticchecks_complete_log');
s=sprintf('\n\n***\nRunning CourtshipBowlAutomaticChecks_Complete version %s for experiment %s at %s\n',version,experiment,timestamp);
write_log(logfid,experiment,s)

try

    %% file names

    automatedchecksincomingfile = fullfile(expdir,cbparams.dataloc.automaticchecksincomingresults.filestr);
    roifile = fullfile(expdir,cbparams.dataloc.roidatamat.filestr);
    outfile = fullfile(expdir,cbparams.dataloc.automaticcheckscompleteresults.filestr);

    %% types of automated errors: order matters in this list

    % requied files and their categories
    files = fieldnames(cbparams.dataloc);
    isrequired = structfun(@(x) isstruct(x) && isfield(x,'essential') && (x.essential>=1),cbparams.dataloc);
    required_files = files(isrequired);
    file_categories = cell(size(required_files));
    for i = 1:numel(required_files),
      s = cbparams.dataloc.(required_files{i});
      if ~isstruct(s) && ~isfield(s,'type'),
        file_categories{i} = 'other';
      else
        file_categories{i} = s.type;
      end
    end
    % hard-code these because order matters
    unique_file_categories = ...
      {'data_capture'
      'detect_rois'
      'track'
      'compute_perframe_features'
      'results_movie'};

    % also all the per-frame feature mat files are required
    perframefns = cbparams.compute_perframe_features.perframefns;

    categories = [cellfun(@(x) ['missing_',x,'_files'],unique_file_categories,'UniformOutput',false)
      {'bad_number_of_rois'
      'bad_number_of_flies'
      'completed_checks_other'}];

    category2idx = struct;
    for i = 1:numel(categories),
      category2idx.(categories{i}) = i;
    end
    iserror = false(1,numel(categories));
    msgs = {};
    success = true;

    %% check number of rois and number of flies per roi

    roidata = load(roifile);
    if ~isfield(roidata,'nflies_per_roi'),
      msgs{end+1} = sprintf('Variable nflies_per_roi not stored in roi mat file %s',roifile);
      success = false;
      iserror(category2idx.bad_number_of_rois) = true;
    else

      % number or rois
      nrois = numel(roidata.nflies_per_roi);
      if nrois < check_params.min_nrois,
        msgs{end+1} = sprintf('Only %d < %d ROIs detected',nrois,check_params.min_nrois);
        success = false;
        iserror(category2idx.bad_number_of_rois) = true;
      end

      % number of rois with 2 flies
      nrois_2flies = nnz(roidata.nflies_per_roi==2);
      if nrois_2flies < check_params.min_nrois_2flies,
        msgs{end+1} = sprintf('Only %d < %d ROIs have 2 flies in them\n',nrois_2flies,check_params.min_nrois_2flies);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end
      if nrois_2flies > check_params.max_nrois_2flies,
        msgs{end+1} = sprintf('%d > %d ROIs have 2 flies in them\n',nrois_2flies,check_params.max_nrois_2flies);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end

      % number of rois with 1 fly
      nrois_1fly = nnz(roidata.nflies_per_roi==1);
      if nrois_1fly > check_params.max_nrois_1fly,
        msgs{end+1} = sprintf('%d > %d ROIs have 1 fly in them\n',nrois_1fly,check_params.max_nrois_1fly);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end
      if nrois_1fly < check_params.min_nrois_1fly,
        msgs{end+1} = sprintf('%d < %d ROIs have 1 fly in them\n',nrois_1fly,check_params.min_nrois_1fly);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end

      % number of rois with 0 flies
      nrois_0flies = nnz(roidata.nflies_per_roi==0);
      if nrois_0flies < check_params.min_nrois_0flies,
        msgs{end+1} = sprintf('Only %d < %d ROIs have 0 flies in them\n',nrois_0flies,check_params.min_nrois_0flies);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end
      if nrois_0flies > check_params.max_nrois_0flies,
        msgs{end+1} = sprintf('%d > %d ROIs have 0 flies in them\n',nrois_0flies,check_params.max_nrois_0flies);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end

      % number of rois with >2 flies
      nrois_moreflies = nnz(roidata.nflies_per_roi>2);
      if nrois_moreflies > check_params.max_nrois_moreflies,
        msgs{end+1} = sprintf('%d > %d ROIs have >2 in them\n',nrois_moreflies,check_params.max_nrois_moreflies);
        success = false;
        iserror(category2idx.bad_number_of_flies) = true;
      end

    end

    %% check for missing files

    for i = 1:numel(required_files),
      file = cbparams.dataloc.(required_files{i});
      if isfield(file,'searchstr'),
        fn = file.searchstr;
      else
        fn = file.filestr;
      end
      if any(fn == '*'),
        isfile = ~isempty(dir(fullfile(expdir,fn)));
      else
        isfile = exist(fullfile(expdir,fn),'file');
      end
      if ~isfile,
        msgs{end+1} = sprintf('Missing file %s',fn); %#ok<AGROW>
        success = false;
        category = sprintf('missing_%s_files',file.type);
        iserror(category2idx.(category)) = true;
      end
    end
    
    % check pff
    if cbparams.compute_perframe_features.dopff
        missing_perframe_fns = {};
        perframedir = fullfile(expdir,cbparams.dataloc.perframedir.filestr);
        for i = 1:numel(perframefns),
          if ~exist(fullfile(perframedir,[perframefns{i},'.mat']),'file'),
            missing_perframe_fns{end+1} = perframefns{i}; %#ok<AGROW>
          end
        end
        if ~isempty(missing_perframe_fns),
          msgs{end+1} = [sprintf('Missing %d per-frame feature mat files: ',numel(missing_perframe_fns)),...
            sprintf('%s ',missing_perframe_fns{:})];
          success = false;
          iserror(category2idx.missing_compute_perframe_features_files) = true;
        end
    end

    %% output results to file, merging with automatedchecks incoming

    if exist(automatedchecksincomingfile,'file'),
      automatedchecks_incoming = ReadParams(automatedchecksincomingfile);
    else
      automatedchecks_incoming = struct('automated_pf','U','notes_curation','');
    end
    
    fid = fopen(outfile,'w');
    if fid < 0,
      error('Could not open automatic checks results file %s for writing.',outfile);
    end
    if success && ~strcmpi(automatedchecks_incoming.automated_pf,'F'),
      fprintf(fid,'automated_pf,P\n');
    else
      fprintf(fid,'automated_pf,F\n');
      fprintf(fid,'notes_curation,');
      s = sprintf('%s\\n',msgs{:});
      s = s(1:end-2);
      if isfield(automatedchecks_incoming,'notes_curation') && ...
          ~isempty(automatedchecks_incoming.notes_curation),
        if isempty(s),
          s = automatedchecks_incoming.notes_curation;
        else
          s = [automatedchecks_incoming.notes_curation,'\n',s];
        end
      end
      fprintf(fid,'%s\n',s);
      if strcmpi(automatedchecks_incoming.automated_pf,'F'),
        if isfield(automatedchecks_incoming,'automated_pf_category') && ...
            ~isempty(automatedchecks_incoming.automated_pf_category),
          s = automatedchecks_incoming.automated_pf_category;
        else
          s = 'incoming_checks_unknown';
        end
      else
        i = find(iserror,1);
        if isempty(i),
          s = 'completed_checks_other';
        else
          s = categories{i};
        end
      end
      fprintf(fid,'automated_pf_category,%s\n',s);

    end
    % version info
    fprintf(fid,'cbautocheckscomplete_version,%s\n',version);
    fprintf(fid,'cbautocheckscomplete_timestamp,%s\n',timestamp);
    fprintf(fid,'analysis_protocol,%s\n',analysis_protocol);

    if fid>1,
      fclose(fid);
    end

catch ME,
   msgs{end+1} = ME.message;
   success = false;
end

%% print results to log file

s = {sprintf('success = %d\n',success)};

if isempty(msgs),
  s = [s;{sprintf('No error or warning messages.\n')}];
else
  s = [s;{sprintf('Warning/error messages:\n');...
  sprintf('%s\n',msgs{:})}];
end
s = [s;{sprintf('Finished running FlyBowlAutomaticChecks_Complete at %s.\n',datestr(now,'yyyymmddTHHMMSS'))}];
write_log(logfid,experiment,s)

if logfid > 1,
  fclose(logfid);
end

classdef DTrax
  
  properties (Constant)
    SUBDIRS = {...
      'compute_perframe_features'
      'filehandling'
      'GUIs'
      'misc'
      'netlab' 
      'user'};
    
    APPDATALIST = {'isnew','button','next','viewlog','h_log','expdir','experiment','moviefile','out',...
      'analysis_protocol','P_stage','cbparams','restart','GUIscale',...
      'startframe','endframe','BG','roidata','roidata_rs','visdata','vign','H0','debugdata_WT',...
      'pff_all','t','trackdata','iscancel','isskip','allow_stop','isstop'};
  end
  
  methods (Static)
    
    function setpath
      p = DTrax.getpath;
      addpath(p{:});
    end
    
    function rmpath
      p = DTrax.getpath;
      rmpath(p{:});
    end
    
    function p = getpath
      root = cbtrackroot;      
      p = [{root}; cellfun(@(x)fullfile(root,x),DTrax.SUBDIRS,'uni',0)];
    end
    
    function clearAppData
      adlist = DTrax.APPDATALIST;
      for ad=adlist,ad=ad{1}; %#ok<FXSET>
        if isappdata(0,ad)
          rmappdata(0,ad);
        end
      end
    end
    
  end
  
end
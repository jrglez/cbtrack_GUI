classdef CBTrackPath
  
  properties (Constant)
    SUBDIRS = {...
      'compute_perframe_features'
      'filehandling'
      'GUIs'
      'misc'
      'netlab'};
  end
  
  methods (Static)
    
    function setpath
      p = CBTrackPath.getpath;
      addpath(p{:});
    end
    
    function rmpath
      p = CBTrackPath.getpath;
      rmpath(p{:});
    end
    
    function p = getpath
      root = cbtrackroot;      
      p = [{root}; cellfun(@(x)fullfile(root,x),CBTrackPath.SUBDIRS,'uni',0)];
    end
    
  end
  
end
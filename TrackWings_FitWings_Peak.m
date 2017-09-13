function wingtrx = TrackWings_FitWings_Peak(dthetawing,params)
nbins = params.nbins_dthetawing;
if ~isempty(dthetawing)
    H = histc(dthetawing,params.edges_dthetawing);
    H = reshape(H,1,numel(H));
    H = [H(1:end-2),H(end-1)+H(end)];
    smoothH = conv(H,params.wing_frac_filter,'same');
    smoothfrac = conv(H/sum(H),params.wing_frac_filter,'same');
    H1 = smoothH; H1(round(nbins/2)+1:end) = 0;
    smoothfrac1 = H1/sum(H1);
    H2 = smoothH; H2(1:round(nbins/2)) = 0;
    smoothfrac2 = H2/sum(H2);
    
    locs = []; pks = [];
    if sum(H1) > params.min_single_wing_area,
      [pk1,loc1] = max(smoothfrac1);
      if pk1 >= params.wing_min_peak_threshold_frac,
          locs = [locs,loc1]; pks = [pks,pk1];
      end
    end
    
    if sum(H2) > params.min_single_wing_area,
      [pk2,loc2] = max(smoothfrac2);
      if pk2 >= params.wing_min_peak_threshold_frac,
          locs = [locs,loc2]; pks = [pks,pk2];
      end
    end
    
    if numel(locs) == 2 && diff(locs) < params.wing_min_peak_dist_bins
        locs = round(mean(locs));
    end

%     nwingpx = numel(dthetawing);
%     frac = histc(dthetawing,params.edges_dthetawing)/nwingpx;
%     frac = frac(:)';
%     frac = [frac(1:end-2),frac(end-1)+frac(end)];
%     smoothfrac = conv(frac,params.wing_frac_filter,'same');
%     %smoothfrac = imfilter(frac,params.wing_frac_filter);
%     % wings are at local maxima
% 
%     % this is much faster than calling the findpeaks function
%     locs = []; %pks = [];
%     if nwingpx > params.min_single_wing_area,
%       [pk,loc] = max(smoothfrac);
%       if pk >= params.wing_min_peak_threshold_frac,
%         locs(1) = loc; %pks(1) = pk;
%         isallowed = [true,smoothfrac(2:end)>smoothfrac(1:end-1)] & ...
%           [smoothfrac(1:end-1)>=smoothfrac(2:end),true];
%         isallowed(max(1,loc-params.wing_min_peak_dist_bins):min(params.nbins_dthetawing,loc+params.wing_min_peak_dist_bins)) = false;
%         [pk,loc] = max(smoothfrac(isallowed));
%         if pk >= params.wing_peak_min_frac,
%           idxallowed = find(isallowed);
%           locs(2) = idxallowed(loc);
%           %pks(2) = pk;
%         end
%       end
%     end

    % [pks,locs] = findpeaks(smoothfrac,'MinPeakHeight',params.wing_peak_min_frac,...
    %   'MinPeakDistance',params.wing_min_peak_dist_bins,...
    %   'Threshold',params.wing_min_peak_threshold_frac,...
    %   'NPeaks',2,...
    %   'SortStr','descend');

    % sub-bin precision
    if isempty(locs),
      wing_angles_curr = 0;
      npeaks = 0;
      area = 0;
      wing_trough_angle = 0;
%     elseif numel(locs) == 1,
%       wing_angles_curr = median(dthetawing);
%       npeaks = 1;
%       area = nwingpx;
%       wing_trough_angle = wing_angles_curr;
    else
      wing_angles_curr = params.centers_dthetawing(locs);
      npeaks = numel(locs); % npeaks = 2;

      for j = 1:numel(locs),
        subbin_x_curr = params.subbin_x+locs(j);
        subbin_x_curr(subbin_x_curr < 1 | subbin_x_curr > params.nbins_dthetawing) = [];
        ncurr = numel(subbin_x_curr);
        Xcurr = [ones(ncurr,1),  subbin_x_curr,  subbin_x_curr.^2];

        % frac = X*coeffs
        coeffs = Xcurr\smoothfrac(subbin_x_curr)';

        % max(c1 + c2*x + c3*x^2)
        % c2 + 2*c3*x = 0
        % x = -c2 / (2*c3)

        % make sure it is concave
        if coeffs(3) >= 0,
          continue;
        end

        maxx = -coeffs(2)/(2*coeffs(3));

        % make sure it is within range
        if abs(maxx-locs(j)) > 1 || maxx > params.nbins_dthetawing || maxx < 1,
          continue;
        end

        % interpolate
        wceil = maxx-floor(maxx);
        wing_angles_curr(j) = params.centers_dthetawing(floor(maxx))*(1-wceil) + wceil*params.centers_dthetawing(ceil(maxx));

      end

      if numel(locs) == 1
          area = sum(H);
          wing_trough_angle = wing_angles_curr;
      else
        % AL: assert(numel(locs)==2)?
        
        % can't have two wings on the same side of the body (It will never
        % happen since I have split the wings in two
        if sign(wing_angles_curr(1)) == sign(wing_angles_curr(2)) && ...
            min(abs(wing_angles_curr)) >= params.min_nonzero_wing_angle,
          wing_angles_curr(end) = []; % AL: why arbitrary rm?
          npeaks = 1;
          area = nwingpx;
          assert(false,'Should harderr on prev line; nwingpx undefined var.');
        else

          % find the trough between the two peaks
          minloc = min(locs);
          maxloc = max(locs);
          [~,troughloc] = min(smoothfrac(minloc:maxloc));
          troughloc = troughloc + minloc - 1;
          % find other locations with the same value
          loc1 = find(smoothfrac(minloc:troughloc)>smoothfrac(troughloc),1,'last');
          if isempty(loc1),
            loc1 = troughloc;
          else
            loc1 = loc1+minloc;
          end
          loc2 = find(smoothfrac(troughloc:maxloc)>smoothfrac(troughloc),1,'first');
          if isempty(loc2),
            loc2 = troughloc;
          else
            loc2 = loc2+troughloc-2;
          end
          troughloc = (loc1+loc2)/2;
          if mod(troughloc,1) > 0,
            area = sum(smoothfrac(1:troughloc-.5));
            wing_trough_angle = (params.centers_dthetawing(troughloc-.5)+params.centers_dthetawing(troughloc+.5))/2;
          else
            area = sum(smoothfrac(1:troughloc-1))+smoothfrac(troughloc)/2;
            wing_trough_angle = params.centers_dthetawing(troughloc);
          end
          area = [area,1-area]*sum(H);
          if all(area < params.min_single_wing_area),
            wing_angles_curr = 0;
            npeaks = 0;
            area = 0;
            wing_trough_angle = 0;
          elseif area(1) < params.min_single_wing_area,
            [~,removei] = min(wing_angles_curr);
            area(1) = [];
            wing_angles_curr(removei) = [];
            npeaks = 1;
          elseif area(2) < params.min_single_wing_area,
            [~,removei] = max(wing_angles_curr);
            area(2) = [];
            wing_angles_curr(removei) = [];
            npeaks = 1;
          end
        end
      end
    end
    wing_angles_curr = sort(wing_angles_curr);
    if numel(wing_angles_curr) == 1,
      % AL: overrides if numel(locs)==1 branch above
      if abs(wing_angles_curr) > params.min_nonzero_wing_angle,
        wing_trough_angle = 0;
        [wing_angles_curr] = sort([0,wing_angles_curr]);
        area = [sum(H1),sum(H2)];  
      else
        % AL ??? 
        % area is sum(H) above
        wing_angles_curr = repmat(wing_angles_curr,[1,2]);
        area = repmat(area,[1,2]); 
      end
    end
else
    wing_angles_curr=nan(1,2);
    npeaks=nan;
    area=nan(1,2);
    wing_trough_angle=nan;
end
wingtrx = struct('wing_anglel',[],...
  'wing_angler',[],...
  'nwingsdetected',[],...
  'wing_areal',[],...
  'wing_arear',[],...
  'wing_trough_angle',[]);

wingtrx.wing_anglel = wing_angles_curr(1);
wingtrx.wing_angler = wing_angles_curr(2);
wingtrx.nwingsdetected = npeaks;
wingtrx.wing_areal = area(1);
wingtrx.wing_arear = area(2);
wingtrx.wing_trough_angle = wing_trough_angle;
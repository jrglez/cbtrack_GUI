% [theta,s,combs] = choose_orientations3(theta,phi,sqrtWarea,weight_theta,weight_phi,weight_Warea)
%
% we will set the orientation to theta_t = phi_t + s_t * pi
% we want to choose s_t to minimize
% \sum_t cost(s_t|s_{t-1})
% cost(s_t|s_{t-1}) = [wtheta_t*d(\theta_t,\theta_{t-1}) +
%                      wphi(||v_t||^2)*d(\theta_t,angle(v_t))+
%                      walpha*d(\theta_t,alpha)]
%
% we will find the most likely states s_t using the recursion
% cost_t(s_t) = min_{s_{t-1}} { cost_{t-1}(s_{t-1}) + cost(s_t|s_{t-1})
%
% Inputs:
% theta: nflies x N matrix where thtea(fly,t) is the orientation of the fly at time t
% phi: nflies x N matrix where phi(fly,t) is the velocity direction   of the fly at time t
% sqrtWare: N x ncombs matrix where sqrtWare(t,:) is the sqrt sum of the 
% area of the wings at time t for the different orientation combinations.
% weight_theta: nflies x N matrix where weight_theta(fly,t) is the weight of the
% change in orientation term at time t
% weight_phi: nflies x N matrix where weight_phi(fly,t) is the weight of the
% velocity direction term at time t
% weight_Warea: N x ncombs matrix where weight_Warea(t,:) is the weight
% of the wing area at time t for the different orientation combinations.
%
% Outputs:
% theta: nflies X N
% s: N x 1 col index into combs
% combs: nflies X ncombs, array of 1/2s where 1 indicates theta unchanged
% and 2 indicates theta flipped
%
function [theta,s,combs] = choose_orientations3(theta,phi,sqrtWarea,weight_theta,weight_phi,weight_Warea)
% Aqui: No esta bien porque arrastro el coste de las alas de un frame a
% otro y se va sumando. 
[nflies,N] = size(theta);

% posible orientation combinations
combs = dec2bin(0:2^nflies-1,nflies)-'0'+1; combs=combs';
ncombs = size(combs,2);

sqrtWarea = sqrtWarea(:,1:ncombs);
weight_Warea = weight_Warea(:,1:ncombs);

% allocate space for storing the optimal path
stateprev = zeros(N,ncombs);
s = nan(N,1);

% allocate space for computing costs
tmpcost = zeros(1,ncombs);
costprevnew = zeros(1,ncombs);

% initialize first frame
costprev = zeros(1,ncombs);

% compute iteratively
for t = 2:N,
  costWareaprev=-sum(sqrtWarea(t-1,:).*weight_Warea(t-1,:),1);
  % compute for both possible states
  for scurr = 1:ncombs,
    % try both previous states
    thetacurr = theta(:,t) + (combs(:,scurr)-1)*pi;
    
    for sprev = 1:ncombs,
      
      thetaprev = theta(:,t-1) + (combs(:,sprev)-1)*pi;
      costcurr = sum(weight_theta(:,t).*angledist(thetaprev,thetacurr) + ...
        weight_phi(:,t).*angledist(thetacurr,phi(:,t)),1);
      tmpcost(sprev) = costprev(sprev) + costcurr;
      
    end
    
    % choose the minimum
    sprev = argmin(tmpcost+costWareaprev);
    
    % set pointer for path
    stateprev(t-1,scurr) = sprev;
    
    % set cost
    costprevnew(scurr) = tmpcost(sprev);
    
  end
  
  % copy over
  costprev = costprevnew;
end

% choose the best last state
s(end) = argmin(costprev-sum(sqrtWarea(end,:).*weight_Warea(end,:),1));

theta(:,end) = modrange(theta(:,end)+(combs(:,s(end))-1)*pi,-pi,pi);

% choose the best states
for t = N-1:-1:1,
  s(t) = stateprev(t,s(t+1));
  theta(:,t) = modrange(theta(:,t)+(combs(:,s(t))-1)*pi,-pi,pi);
end

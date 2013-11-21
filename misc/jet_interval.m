function colors=jet_interval(a,b,n)
N=256;
intervals=floor(linspace(1,N,b)); intervals(1)=0;
interval=floor(linspace(intervals(a),intervals(a+1),n);

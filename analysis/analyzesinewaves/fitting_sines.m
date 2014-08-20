test_data = data_hold(4).filter_out;
ntp =size(test_data, 1);
t = (1:ntp)/fs;
freq = 10; 
x = t';
y = test_data;
%y=sin(2*pi*freq*x+pi/4);
LB = [-inf, -inf, -pi];
UB = [inf, inf, pi];
%LB = [-inf, -inf, -inf];
%UB = [inf, inf, inf];
%bestcoeffs=fminsearchbnd(@sinfun,[0 0 0],LB,UB,[],x,y,freq);
bestcoeffs=fminsearch(@sinfun,[0 0 0],[],x,y,freq);
yfit=bestcoeffs(1)*sin(2*pi*freq*x+bestcoeffs(3)) +  bestcoeffs(2);
%Now compare y with yfit
plot(x,y,x,yfit);


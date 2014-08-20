function [sin_data, phase, gain, score] = fitdata(data, frequency, initial_cond, fs)
%FITDATA finds the values of the phase and the gain for a single sinusoidal
%signal, it uses fminsearch to do this, given the data and the value of the
%ideal frequency.
%----
%Input:
%----
%data: data to do the fitting
%frequency: Ideal frequency
%initial_cond: Initial conditions for the  [Gain, Offset, Phase]
% Y_fun = a .* sin(2*pi*freq*X+c)+b;
%fs: sampling frequency
%----
%output:
%----
%sin_data: fitted sinusoidal of the data
%phase: value of the phase
%gain: vlaue of the gain
%score: score of the optimization
ntp =size(data, 1);%get the time points
t = (1:ntp)/fs;
freq = frequency; 
x = t';
y = data;
a = initial_cond(1);
b = initial_cond(2);
c = initial_cond(3);
[bestcoeffs fval] = fminsearch(@sinfun,[a,b,c],[],x,y,frequency);%calculate the optimization
count = 1;
yfit=bestcoeffs(1)*sin(2*pi*freq*x+bestcoeffs(3)) +  bestcoeffs(2);%get the ideal data
sin_data = yfit;
phase = bestcoeffs(3);%set the phase
gain = bestcoeffs(1);%set the gain
score = fval;
end
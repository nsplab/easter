function [sin_data, phase, gain, score, phase_out] = fitdataevolved(data, frequency, initial_cond, fs)
%create the optimization
ntp =length(data);
t = (1:ntp)/fs;
freq = frequency; 
x = t';
y = data;
a = initial_cond(1);
b = initial_cond(2);
c = initial_cond(3);
%[bestcoeffs fval] = fminsearch(@sinfun,[a,b,c],[],x,y,frequency);
count = 1;
for phase = 0:0.01:2*pi
    scorei = sinfunphase(phase,[a,b], x,y,frequency);
    score(count)=scorei;
    phasen(count) = phase;
    count = count + 1;
end
c=phasen(find(score==min(score)));
yfit=a*sin(2*pi*freq*x+c) +  b;
%yfit=bestcoeffs(1)*sin(2*pi*freq*x+bestcoeffs(3)) +  bestcoeffs(2);
sin_data = yfit;
phase = c;
gain = a;
%phase = bestcoeffs(3);
%gain = bestcoeffs(1);
phase_out = phasen;
score = score;
end
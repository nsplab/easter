% get_filters.m
%
% This function returns a list of the requested filters.
%
% Arguments:
%   fs: sampling frequency
%   use_hpf: use highpass filter
%   use_lpf: use lowpass filter
%   use_nf_60: use 60 Hz notch filter
%   use_nf_120: use 120 Hz notch filter
%   use_nf_180: use 180 Hz notch filter
%
% Output:
%   filters: cell array of requested filters

function [ filters ] = get_filters(fs, use_hpf, use_lpf, use_nf_60, use_nf_120, use_nf_180)

filters = {};

if (nargin >= 2) && use_hpf
    hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);
    hpf = design(hp, 'butter');
    filters = {filters{:}, hpf};
end

if (nargin >= 3) && use_lpf
    lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(220.0),(256.0),1,90,fs);
    lpf = design(lp, 'butter');
    filters = {filters{:}, lpf};
end

if (nargin >= 4) && use_nf_60
    n60 = fdesign.notch('N,F0,BW,Ap',6,60,20,2,fs);
    nf60 = design(n60);    
    filters = {filters{:}, nf60};
end

if (nargin >= 5) && use_nf_120
    n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);
    nf120 = design(n120);    
    filters = {filters{:}, nf120};
end

if (nargin >= 6) && use_nf_180
    n180 = fdesign.notch('N,F0,Q,Ap',6,180,10,1,fs);
    nf180 = design(n180);    
    filters = {filters{:}, nf180};
end

end


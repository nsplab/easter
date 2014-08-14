function [ filters ] = get_filters(fs, use_hpf, use_lpf, use_nf_60, use_nf_120, use_nf_180)
%GET_FILTERS  Returns a list of the requsted filters.
%
% FILTERS = GET_FILTERS(FS, USE_HPF, USE_LPF, USE_NF_60, USE_NF_120, USE_NF_180)
%
% Parameters:
%
%   FS is the sampling frequency.
%
%   USE_HPF is a boolean indicating if the highpass filter is needed.
%   USE_LPF is a boolean indicating if the lowpass filter is needed.
%   USE_NF_60 is a boolean indicating if the 60 Hz notch filter is needed.
%   USE_NF_120 is a boolean indicating if the 120 Hz notch filter is needed.
%   USE_NF_180 is a boolean indicating if the 180 Hz notch filter is needed.
%
% Output:
%
%   FILTERS is a cell array of requested filters.

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


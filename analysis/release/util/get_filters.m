function [ filters ] = get_filters(fs, use_hpf, use_lpf, use_nf_60, use_nf_120, use_nf_180)

filters = {};

if (use_hpf)
    hp = fdesign.highpass('Fst,Fp,Ast,Ap',(2.0),(10.0),90,1,fs);             %highpass filter; passband 90 Hz, stopband 105 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
    hpf = design(hp, 'butter');
    filters = {filters{:}, hpf};
end

if (use_lpf)
    lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(220.0),(256.0),1,90,fs);             %lowpass filter; passband 300 Hz, stopband 350 Hz, 1dB passband ripple, 90 dB stopband attenuation, sampling frequency fs, butterworth 
    lpf = design(lp, 'butter');
    filters = {filters{:}, lpf};
end

if (use_nf_60)
    n60 = fdesign.notch('N,F0,BW,Ap',6,60,20,2,fs); % wider notch filter at 60 (from about 51 to 71 Hz)
    nf60 = design(n60);    
    filters = {filters{:}, nf60};
end

if (use_nf_60)
    n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);                           %set parameters for 120 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
    nf120 = design(n120);    
    filters = {filters{:}, nf120};
end

if (use_nf_60)
    n180 = fdesign.notch('N,F0,Q,Ap',6,180,10,1,fs);                           %set parameters for 180 Hz notch filter (N - filter order, F0 - center frequency, Q - quality factor, Ap - passband ripple (decibels)
    nf180 = design(n180);    
    filters = {filters{:}, nf180};
end

end


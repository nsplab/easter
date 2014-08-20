function filt_data = filter_data(data, frequency, band, fs)
%FILTER_DATA filters a given data set, given a base frequency and a desired
%band,a s well as the sampling frequency
%----
%input:
%----
%data: a data array that we wish to filter
%frequency: Frequency value to be filtered in the dataset
%band: size of the band that we wish to use to do the filtering
%fs: sampling frequency
%----
%Output:
%----
%filt_data: filtered data
Ap = 1;%values of the ripples 
Ast = 10;%Ast/Ap is the ratio of the ripples, the larger it is, the better the filtering, but also generates greater transients
if frequency < 5 %lower frequencies have a bad time using bandpass filters, soi we use low pass filters
    %Use a low pass filter
    %disp('Using Low pass');
    Fplp = frequency + band/2;%low pass cutoff
    Fstlp = Fplp*1.8; %low pass dampened
    lp = fdesign.lowpass('Fp,Fst,Ap,Ast',Fplp ,Fstlp ,Ap, Ast, fs);
    lpf = design(lp, 'butter');
    filt_data = filtfilt(lpf.sosMatrix,lpf.ScaleValues,data);
else
    %disp('Using band pass');
    f1bp = frequency - band/2;%start f the band
    f2bp = frequency + band/2;%end of the band
    f1st = 0.5*f1bp;%dampen of the start
    f2st = 1.5*f2bp;%dampen of the end
    scale = 1.5;
    while f2st >fs/2%is the value is too high, we decrease the band
        scale = scale-0.1;
        f2st = scale*f2bp;
    end
    bp = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',f1st,f1bp,f2bp,f2st,Ast,Ap,Ast, fs);
    bpf = design(bp,'butter');
    filt_data = filtfilt(bpf.sosMatrix, bpf.ScaleValues, data);
end
end
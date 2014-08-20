test_index = 2;
test_data = double(data_cell(test_index).data(1000:end-1000));
out_data = double((data_cell(test_index).dataout(1000:end-1000)));
fs = 19200;
nyqfs = fs/2;
N = 2;
F0 = 1/nyqfs;
BW = 10/nyqfs;
Q = 10;
Ap = 1;
Ast = 90;
f1bp = 0.5;
f2bp = 4;
Fphp = 1; %high pass cutoff
Fsthp = 0.01; %high pass dampened
Fplp = 2; %low pass cutoff
Fstlp = 6; %low pass dampened
%h=fdesign.lowpass('Fp,Fst,Ap,Ast',Fp,Fst,1,60);
%[a b] = iirpeak(F0, BW)
bp = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fsthp,f1bp,f2bp,Fstlp,Ast,Ap,Ast, fs);
Ap
bpf = design(bp,'butter');
ybp = filtfilt(bpf.sosMatrix, bpf.ScaleValues, test_data);
yobp = filtfilt(bpf.sosMatrix, bpf.ScaleValues, out_data);

%hp = fdesign.highpass('Fst,Fp,Ast,Ap',Fsthp, Fphp, Ast, Ap, fs);
%hpf = design(hp, 'butter');
lp = fdesign.lowpass('Fp,Fst,Ap,Ast',Fplp ,Fstlp ,Ap, Ast, fs);
lpf = design(lp, 'butter');
ylp = filtfilt(lpf.sosMatrix,lpf.ScaleValues,test_data);
% y = filtfilt(hpf.sosMatrix,hpf.ScaleValues,yy);
% y1 = filter(hpf,test_data);
% y1 = filter(lpf,y1);
yolp = filtfilt(lpf.sosMatrix,lpf.ScaleValues,out_data);
% yo = filtfilt(hpf.sosMatrix,hpf.ScaleValues,yyo);
% yo1 = filter(hpf,out_data);
% yo1 = filter(lpf,yo1);

%h=fdesign.notch('N,F0,Q,Ap',N,F0,Q,Ap);
%d=design(h); %Lowpass FIR filter
%y=filtfilt(b,a,test_data); %zero-phase filtering
%y1=filter(b,a,test_data); %conventional filtering
subplot(211);
plot([y]);
title('Filtered Waveforms');
legend('Zero-phase Filtering');
subplot(212);
plot(test_data);
title('Original Waveform');
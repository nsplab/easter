% ask the user to select the data file
%run('../loaddata.m');

% sampling rate
fs = decimated_sampling_rate_in_Hz;
windlengthSeconds = 8;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.45;%windlength * 0.25;
noverlap = windlength * noverlapPercent;

n60 = fdesign.notch('N,F0,Q,Ap',6,60,10,1,fs);
n120 = fdesign.notch('N,F0,Q,Ap',6,120,10,1,fs);
nf60 = design(n60);
nf120 = design(n120);

%{
lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(80.0),(90.0),1,90,fs);
lpf = design(lp, 'butter');

hp = fdesign.highpass('Fst,Fp,Ast,Ap',(10.0),(20.0),90,1,fs);
hpf = design(hp, 'butter');
%}



% seconds of data to be discarded from the beginning of the data
% as usualy there are some artifact at the beginning discarding 2 or 3
% seconds of the data is suggested
cutSeconds = 3;
cutLength = fs * cutSeconds;

% choose the colormap for the plots
%CM = colorcube(12);

% the titles in the legend
legends = [];

% number of tapers in used in the multi-taper method
% larger number of tapers reduces variance of PSD estimation while
% descreses frequency resolution
numberOfTapers = 100;
NW = numberOfTapers / 2;

dataname = 'Cardiac';

% get the name of the data set
%tmp = regexp(pathname, '/\d+-\w+/', 'match');
%if size(tmp,1) ~= 0
 %   dataname = tmp{1}(2:end-1);
%end

% draw the figure with white background and full screen
fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% channels on scalp
%scalpCh = [5];

% choose the colormap for the plots
CM = colorcube(size(data,1)+1);
%CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00')];
%CM = [hex2dec('58'),hex2dec('e0'), hex2dec('00'); hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0')];
%CM = CM/400;


% compute PSD of all channels and plot the PSD + 95% confidence intervals
%{
for i=1:size(data,1)
    i
    %[pxx, f, pxxc] = pmtm(data{i,2}(cutLength:end-cutLength), NW, length(data{i,2})-cutLength*2, fs, 'ConfidenceLevel', 0.95);
    [pxx, f, pxxc] = pwelch(data{i,2}, (windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    
    nump = 8000;    
    f = f(1:nump);
    pxx = pxx(1:nump);
    pxxc = pxxc(1:nump);

    legends(end+1) = plot(f, log10(pxx),'color',CM(i,:),'linewidth',2);
    %plot(f,log10(pxxc),'color',CM(i,:),'linewidth',1);
end

% add the legend
legend(legends, data{:,1})

% put a tick every 10 Hz
%tmp = get(gca,'xlim');
%set(gca,'XTick',[0:10:tmp(2)]);

% set labels and grid
xlabel('frequency (Hz)');
ylabel('${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
tmp = title(['PSD: ' dataname  '_' filename ' |  window length (secs)=' int2str(windlengthSeconds) '  overlap=' num2str(noverlapPercent)]);
set(tmp,'interpreter','none');
grid on
grid minor
ylim([-4 12]);

% save the figure in file
myaa([3 3], [dataname '_' filename '_psd.png']);

n60 = fdesign.notch('N,F0,Q,Ap',6,60.0,10,1, fs);
nf60 = design(n60);

n120 = fdesign.notch('N,F0,Q,Ap',6,120.0,10,1, fs);
nf120 = design(n120);


hold off
% draw the figure with white background and full screen
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on


x_lines = [0.5274, 2.413, 4.317, 6.2, 8.082, 9.979, 11.87, 13.75, 15.65, 17.54, 19.43, 21.32, 23.2, 25.09, 26.99, 28.88, ];
y_limits = [-10000; 10000];
y_grid = repmat(y_limits, 1, numel(x_lines));
x_grid = [x_lines; x_lines];
plot(x_grid, y_grid, ':', 'color', [0.9,0.5,0.5]/2,'linewidth',3); 
set(gca, 'XTick', x_lines);

%}

% the titles in the legend
legends = [];

time_axis = (0:length(data_decimated{1,2})-1)/fs;

for k=1:size(data_decimated,1)
    k
    %{
    notch60DataLPF = filtfilt(nf60.sosMatrix,nf60.ScaleValues,data{k,2});
    notch60DataHPF = filtfilt(nf60.sosMatrix,nf60.ScaleValues,notch60DataLPF);
    %}

    notch60Data = filtfilt(nf60.sosMatrix,nf60.ScaleValues,data_decimated{k,2});
    %notch60Data = filtfilt(nf60.sosMatrix,nf60.ScaleValues,notch60DataHPF);
    notch60Notch120Data = filtfilt(nf120.sosMatrix,nf120.ScaleValues,notch60Data);
    %time_axis = (-fs:length(notch60Notch120Data)-1-fs)/fs;
    %legends(end+1) = plot(time_axis, detrend(notch60Notch120Data),'color',CM(i,:),'linewidth',2);
    %legends(end+1) = plot(decimate(time_axis,20), decimate(detrend(notch60Notch120Data),20),'color',CM(i,:),'linewidth',2);
    legends(end+1) = plot((time_axis), (detrend(notch60Notch120Data)),'color',CM(k,:),'linewidth',2);
    %legends(end+1) = plot(decimate(time_axis,20), decimate((notch60Notch120Data),20)/1000,'color',CM(i,:),'linewidth',2);
    %plot(f,log10(pxxc),'color',CM(i,:),'linewidth',1);
end

% add the legend
legend(legends, data_decimated{:,1})
%legend(legends, {'right arm','precordial', 'nose', 'endo'}, 'Location', 'NorthOutside', 'Orientation' , 'horizontal');


% put a tick every 10 Hz
%tmp = get(gca,'xlim');
%set(gca,'XTick',[0:10:tmp(2)]);

% set labels and grid
xlabel('time (seconds)');
ylabel('$\mu V$','Interpreter','LaTex');
%tmp = title(['Signal: ' dataname '_' filename]);
%set(tmp,'interpreter','none');
axis tight

hold off

tmp = title(['Cardiac: '  allData{1}(i)]);
%tmp = title(['Cardiac: '  a{i,1}]);
%tmp = title(['Cardiac: '  filename]);
set(tmp,'interpreter','none');

saveas(fgh, [S{i} '.fig']);

%grid on
%grid minor
%ylim([-4 12]);

% save the figure in file
%myaa([3 3], [dataname '_' filename 'signal_.png']);


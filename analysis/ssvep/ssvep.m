% sampling rate
fs = 9600;
windlengthSeconds = 2;
windlength = windlengthSeconds * fs;
noverlapPercent = 0.45;%windlength * 0.25;
noverlap = windlength * noverlapPercent;

% ask the user to select the data file
%run('../loaddata.m');

fid = fopen([pathname filename], 'r');
digitalinCh = 65;
fseek(fid, 4*(digitalinCh-1), 'bof');
dataColumn = fread(fid, Inf, 'single', 4*64);
time_axis = (0:length(dataColumn)-1)*1.0/fs;
figure;plot(time_axis,dataColumn);

tmp = (dataColumn>0);
t1 = diff(tmp);
t2 = find(t1==1);
t3 = find(t1==-1);

if isempty(t3)
    t3 = length(dataColumn);
end

cutSecondsBegining = 10;
cutSecondsEnd = 15;

cutLengthB = t2; %fs * cutSecondsBegining;
cutLengthE = t3; %fs * cutSecondsEnd;


% choose the colormap for the plots
CM = colorcube(size(data,1)+1);
%CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00')];
%CM = CM/256;

%scalpCh = [8,4,6,7];

% the titles in the legend
legends = [];


dataname = 'SSVEP';

% draw the figure with white background and full screen
fgh = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% compute PSD of all channels and plot the PSD + 95% confidence intervals
for ii=1:size(data,1)
    ii
    [pxx, f] = pwelch(data{ii,2}((1+cutLengthB):(cutLengthE)), (windlength), noverlap, windlength, fs);
    if (windlength < cutLengthB)
        [pxxC, fC] = pwelch(data{ii,2}((1):(cutLengthB+1)), (windlength), noverlap, windlength, fs);
    else
        [pxxC, fC] = pwelch(data{ii,2}((1+cutLengthE):end), (windlength), noverlap, windlength, fs);
    end
    %[pxx, f, pxxc] = pwelch(dataExp{scalpCh(i),2}((1+cutLengthB):(end-(cutLengthE))), (windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    %[pxxC, fC, pxxcC] = pwelch(dataCtr{scalpCh(i),2}((1+cutLengthB):(end-(cutLengthE))), (windlength), noverlap, windlength, fs, 'ConfidenceLevel', 0.95);
    
    %{
    nump = 10000;    
    f = f(1:nump);
    fC = fC(1:nump);
    pxx = pxx(1:nump);
    pxxC = pxxC(1:nump);
    %}

    diffPow = log10(pxx) - log10(pxxC);
    %diffPower(diffPower<0) = 0.00001;
    
    subplot(3,1,1);hold on;
    legends(end+1) = plot(f, log10(pxx),'color',CM(ii,:),'linewidth',3);
    axis tight
    subplot(3,1,2);hold on;
    plot(fC, log10(pxxC),'color',CM(ii,:),'linewidth',3);
    axis tight
    subplot(3,1,3);hold on;
    plot(f, diffPow,'color',CM(ii,:),'linewidth',3);
    axis tight
    
end

tmpCmt = allData{1}(i);
subplot(3,1,1);hold on;
if ~isempty(strfind(tmpCmt{1}(9:25), '10'))
    for h=1:floor(f(end)/9.8000)
        plot([(h*9.8000) (h*9.8000)], ylim,'b--','linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '40'))
    for h=1:floor(f(end)/40.8333)
        plot([(h*40.8333) (h*40.8333)], ylim,'b--','linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '50'))
    for h=1:floor(f(end)/54.4444)
        plot([(h*54.4444) (h*54.4444)], ylim,'b--','linewidth',1)
    end
end

subplot(3,1,2);hold on;
if ~isempty(strfind(tmpCmt{1}(9:25), '10'))
    for h=1:floor(f(end)/9.8000)
        plot([(h*9.8000) (h*9.8000)], ylim,'b--','linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '40'))
    for h=1:floor(f(end)/40.8333)
        plot([(h*40.8333) (h*40.8333)], ylim,'b--','linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '50'))
    for h=1:floor(f(end)/54.4444)
        plot([(h*54.4444) (h*54.4444)], ylim,'b--','linewidth',1)
    end
end

subplot(3,1,3);hold on;
if ~isempty(strfind(tmpCmt{1}(9:25), '10'))
    for h=1:floor(f(end)/9.8000)
        plot([(h*9.8000) (h*9.8000)], ylim,'b--','linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '40'))
    for h=1:floor(f(end)/40.8333)
        plot([(h*40.8333) (h*40.8333)], ylim,'b--','linewidth',1)
    end
end
if ~isempty(strfind(tmpCmt{1}(9:25), '50'))
    for h=1:floor(f(end)/54.4444)
        plot([(h*54.4444) (h*54.4444)], ylim,'b--','linewidth',1)
    end
end

% add the legend
subplot(3,1,1);
legend(legends, data{:,1})
 
%legend(legends, {'left eye','right eye', 'middle head', 'back head'});

% put a tick every 10 Hz
%tmp = get(gca,'xlim');
%set(gca,'XTick',[0:10:tmp(2)]);

% set labels and grid
subplot(3,1,1);
xlabel('frequency (Hz)');
ylabel('experiment: ${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
%tmp = title(['Experiment PSD: ' dataname  '_' filename ' |  window length (secs)=' int2str(windlengthSeconds) '  overlap=' num2str(noverlapPercent)]);
%set(tmp,'interpreter','none');
%grid on
%grid minor
%ylim([-7 6]);

subplot(3,1,2);
xlabel('frequency (Hz)');
ylabel('baseline: ${log}_{10} (\mu V^2/{Hz})$','Interpreter','LaTex');
set(gca, 'TickDir', 'out')

subplot(3,1,3);
xlabel('frequency (Hz)');
ylabel('${log}_{10} (\mu V^2/{Hz} $exp$) - {log}_{10} (\mu V^2/{Hz} $base$)$','Interpreter','LaTex');
set(gca, 'TickDir', 'out')

subplot(3,1,1);
tmp = title(['SSVEP: '  allData{1}(i)]);
set(tmp,'interpreter','none');
set(gca, 'TickDir', 'out')

%saveas(fgh, ['matlab_data/' S{i} '.fig']);


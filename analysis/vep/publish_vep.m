lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(300.0),(350.0),1,90,fs);
lpf = design(lp, 'butter');

positive = floor(0.6 * fs);
negative = floor(0.1 * fs) - 1;
total = positive + negative + 1;

%//////////////////////////////////
% Look for LED ON and OFF transitions based on digital input channel (65)
%//////////////////////////////////

diff_cleanDigitalIn = diff(cleanDigitalIn);                                %compute any edges in the digital trace
event_index_LED_ON = find(diff_cleanDigitalIn==LED_ON_edge);               %find the edges that correspond to LED turning on
event_index_LED_OFF = find(diff_cleanDigitalIn==LED_OFF_edge);             %find the edges that correspond to LED turning off


set(0,'defaultAxesFontName', 'Arial');
set(0,'defaultaxesfontSize',20);

% draw the figure with white background and full screen
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% the titles in the legend
legends = [];

CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00'); hex2dec('00'),hex2dec('00'),hex2dec('00')];
CM = CM/256;

scalpCh = [8,4,6,7,2];

for ii=1:length(scalpCh)
    ii
    
    chData = data{scalpCh(ii),2};

    %highPassed = filtfilt(hpf.sosMatrix,hpf.ScaleValues,chData);
    bandPassed = filtfilt(lpf.sosMatrix,lpf.ScaleValues,chData);

    m = [];

    for jj=2:length(t2)-1,
         %m(end+1, 1:total) = bandPassed((t2(i)-negative):(t2(i)+positive)) - bandPassedEar((t2(i)-negative):(t2(i)+positive));
        m(end+1, 1:total) = detrend(bandPassed((event_index_LED_ON(jj)-negative):(event_index_LED_ON(jj)+positive)));
    end
     
    t = (-negative:positive)/fs*1000;
    am = mean(m);
    %am = trimmean(m,20);
    
    confMean = bootci(800, @mean, m);
    %confMean = confMean + [am; am];
    
    px=[t, fliplr(t)];
    py = [ confMean(1,:),  fliplr(confMean(2,:))];
    patch(px,py,1,'FaceColor',CM(ii,:),'EdgeColor','none');
    
    legends(end+1) = plot(t, am,'color',CM(ii,:),'linewidth',3);
    alpha(.2);
    %[legends(end+1), tmp]= boundedline(t, am, confMean, 'cmap', CM,'linewidth',3);
    
    %[legends(end+1), tmp]= boundedline(t, am, confMean','cmap',CM,'linewidth',3);
    
    
end

grid on

% add the legend
legend(legends, {'left eye','right eye', 'middle head', 'back head', 'endo'});

xlabel('time (ms)');
ylabel('$\mu V$','Interpreter','LaTex');

ylim([-15 20]);

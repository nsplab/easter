lp = fdesign.lowpass('Fp,Fst,Ap,Ast',(300.0),(350.0),1,90,fs);
lpf = design(lp, 'butter');

positive = floor(0.6 * fs);
negative = floor(0.1 * fs) - 1;
total = positive + negative + 1;


set(0,'defaultAxesFontName', 'Arial');
set(0,'defaultaxesfontSize',20);

% draw the figure with white background and full screen
figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);
hold on

% the titles in the legend
legends = [];

CM = [hex2dec('e9'), hex2dec('00'), hex2dec('3a'); hex2dec('ff'), hex2dec('ba'),hex2dec('00'); hex2dec('18'),hex2dec('26'),hex2dec('b0'); hex2dec('58'),hex2dec('e0'), hex2dec('00')];
CM = CM/256;

scalpCh = [8,4,6,7];

for i=1:length(scalpCh)
    i
    
    chData = data{scalpCh(i),2};

    %highPassed = filtfilt(hpf.sosMatrix,hpf.ScaleValues,chData);
    bandPassed = filtfilt(lpf.sosMatrix,lpf.ScaleValues,chData);

    m = [];

    for j=2:length(t2)-1,
         %m(end+1, 1:total) = bandPassed((t2(i)-negative):(t2(i)+positive)) - bandPassedEar((t2(i)-negative):(t2(i)+positive));
        m(end+1, 1:total) = detrend(bandPassed((t2(j)-negative):(t2(j)+positive)));
    end
     
    t = (-negative:positive)/fs*1000;
    am = mean(m);
    %am = trimmean(m,20);
    
    confMean = bootci(800, @mean, m);
    %confMean = confMean + [am; am];
    
    px=[t, fliplr(t)];
    py = [ confMean(1,:),  fliplr(confMean(2,:))];
    patch(px,py,1,'FaceColor',CM(i,:),'EdgeColor','none');
    
    legends(end+1) = plot(t, am,'color',CM(i,:),'linewidth',3);
    alpha(.2);
    %[legends(end+1), tmp]= boundedline(t, am, confMean, 'cmap', CM,'linewidth',3);
    
    %[legends(end+1), tmp]= boundedline(t, am, confMean','cmap',CM,'linewidth',3);
    
    
end

grid on

% add the legend
legend(legends, {'left eye','right eye', 'middle head', 'back head'});

xlabel('time (ms)');
ylabel('$\mu V$','Interpreter','LaTex');

ylim([-15 20]);

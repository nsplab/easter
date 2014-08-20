%plot the results of the getdelays script
%is mostly code to format the p[lot
figure %cretaes a figure
subplot(2,1,1)
semilogx(freq_ar, phasen, 'LineWidth', 4)%plots the phase difference
title('Phase difference of the input vs the output signals (Ph_{out}-Ph_{in})')
ylabel('Phase (degrees)')
xlabel('Frequency (Hz)')
ax1 =axis;
set(gca, 'fontsize', 18)
set(gca, 'box', 'off');
subplot(2,1,2)
semilogx(freq_ar, gain_arr, 'LineWidth', 4)%plots the ggain
set(gca, 'fontsize', 18)
set(gca, 'box', 'off');
title('Gain Ratio of the Signals (Vo/Vin)')
ylabel('Gain (unitless)')
xlabel('Frequency (Hz)')
ax=axis;
axis([ax1(1) ax1(2) 0 1])
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));

figure
subplot(2,1,1)
p1 = semilogx(freq_ar,rad2deg([data_hold(:).phase_in]), 'r', 'LineWidth', 4);
hold on
p2 = semilogx(freq_ar,rad2deg([data_hold(:).phase_out]), 'b', 'LineWidth', 4);
title('Phase of the input vs the output signals (Ph_{in},Ph_{out})')
legend([p1,p2], 'Phase Input', 'Phase Output')
ylabel('Phase (degrees)')
xlabel('Frequency (Hz)')
set(gca, 'fontsize', 18)
set(gca, 'box', 'off');
subplot(2,1,2)
title('Gain of the input and output signals')
p1 = semilogx(freq_ar, abs([data_hold(:).gain_in]), 'r','LineWidth', 4);
hold on
p2 = semilogx(freq_ar, abs([data_hold(:).gain_out]), 'b', 'LineWidth', 4);
ylabel('Normalized Volts')
xlabel('Frequency(Hz)')
set(gca, 'fontsize', 18)
set(gca, 'box', 'off');
title('Gain Ratio of the Signals (Vo/Vin)')
ylabel('Gain')
xlabel('Frequency')
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
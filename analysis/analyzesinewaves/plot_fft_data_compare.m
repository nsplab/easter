function plot_fft_data_compare(data1, data2, voltage, freq)
fs = 19200;
%index_plot = 1;
subplot(2,1,1)
p1 = plot_fft(data1, fs, 'k');
title(['Input signal for' voltage ' and ' num2str(freq) 'Hz'])
set(gca, 'fontsize', 18)
ax_t = axis;
axis([ax_t(1), 100, ax_t(3),ax_t(4)])
subplot(2,1,2)
p2 = plot_fft(data2, fs, 'b');
ax_t2 = axis;
axis([ax_t2(1), 100, ax_t2(3),ax_t2(4)])
title(['Output signal for' voltage ' and ' num2str(freq) 'Hz'])
set(gca, 'fontsize', 18)
subplot(2,1,1)
axis([ax_t2(1), 100, ax_t2(3),ax_t2(4)])
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
end
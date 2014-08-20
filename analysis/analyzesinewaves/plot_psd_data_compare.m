function plot_psd_data_compare(data1, data2, title_1, title_2)
fs = 19200;
%index_plot = 1;
%subplot(2,1,1)
p1 = plot_psd(data1, fs, 'k');
title(['Comparison between original and resampled psd'])
set(gca, 'fontsize', 18)
hold on
ax_t = axis;
axis([ax_t(1), fs/2, ax_t(3),ax_t(4)])
%subplot(2,1,2)
p2 = plot_psd(data2, fs*4, 'b');
axis([ax_t(1), fs/2, ax_t(3),ax_t(4)])

%p3 = plot_psd(data3, fs, 'r');
%axis([ax_t(1), 100, ax_t(3),ax_t(4)])
legend([p1, p2], title_1, title_2)
title(['Comparison'])
set(gca, 'fontsize', 18)
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
end
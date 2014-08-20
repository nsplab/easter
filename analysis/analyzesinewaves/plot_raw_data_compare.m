function plot_raw_data_compare(data1, data2, title_1, title_2)
fs = 19200;
ntp = size(data1,1)
time1 = (1:ntp)/fs;
ntp = size(data2,1)
time2 = (1:ntp)/(fs);
%index_plot = 1;
plot(time1, data1, 'r', 'LineWidth', 6)
hold on
plot(time2, data2, 'b', 'LineWidth', 6)
title(['Comparison between original and optimized signal'])
xlabel('Time (seconds)')
ylabel('uVolts')
set(gca, 'fontsize', 18)
legend(title_1, title_2)
set(gca, 'fontsize', 18)
figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',24,'fontWeight','bold', 'color', [0,0,0])
set(gcf, 'color', [1,1,1])
set(gcf,'renderer', 'zbuffer');
set(gcf, 'Position', get(0,'Screensize'));
end
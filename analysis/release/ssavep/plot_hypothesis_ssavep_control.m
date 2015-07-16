clear;
close all;

% Figure window size
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

%% Create the figure

% make the figure with white background, with fixed size (in pixels) and invisible
%fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'on');
% make axes with correct margins
axes('units', 'pixel', 'position', [margins margins width height]);
hold on; % Allow all channels to be shown
box on;



% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();

f_harmonic = 0:0.001:1;

for i = 1:size(CM, 1)
  ratio_harmonic = spline([0 0.25 0.5 0.75 1], [0 0 0 0 0], f_harmonic);
  ratio_harmonic = ratio_harmonic + i * 0.02;
  ratio_harmonic = 10 .^ ratio_harmonic;
  plot(f_harmonic, ratio_harmonic,'color',CM(i,:),'linewidth',5);
end

xrange = [0 1];
xlim(xrange);
yrange = [1e-1 1e3];
ylim(yrange);
set(gca, 'yscale', 'log');


name = 'ssavep_hypothesis_control';
% Constant for font size
font_size = 20;

%% Figure with labels
% set ticks on axes
xticks = [0 0.25 0.5 0.75 1];
yticks = [1e-1 1e0 1e1 1e2 1e3];
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
% label axes
xlabel('Frequency (kHz)');
ylabel('p_{exp} / p_{rest}');
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') ./ [1 (yrange(2) / yrange(1)) ^ 0.05 1]);
ylabh = get(gca,'YLabel');
set(ylabh,'Position',get(ylabh,'Position') - [0.10 * diff(xrange) 0 0]);

% set size of tick labels
set(gca,'FontSize',font_size);
%set size of labels
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
% fake white title to keep size of figures same when using pdfcrop (with ylabel vs. without y label)
title('|', 'color', 'white', 'fontsize', font_size);

% Save labelled version of figure
saveas(fgh, ['figures/' name '_labelled.fig']);
plot2svg(['figures/' name '_labelled.svg'], fgh, 'png');
save2pdf(['figures/' name '_labelled.pdf'], fgh, 150);

%% Figure with no labels
% Remove labels on ticks for x axis
set(gca, 'XTickLabel', {});
set(gca, 'XTick', [0]);
set(gca, 'XTickLabel', {0});

% Remove labels on ticks for y axis
set(gca, 'YTickLabel', {});
a = 0.65;
b = -1.20;
c = 0.03;
d = 0.15;
e = 0.05;
f = 0.1;
patch(([a a a+d a+d a+d+f a+d a+d] + 0.5) * 2 / 3, 10 .^ (2 * [b b+c b+c b+c+e b+c/2 b-e b] + 1), 'k', 'clipping', 'off');
% Set text color to white
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
% remove label for y axis
ylabel('');
xl = xlabel('Frequency');
ylabel('');
set(xl,'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);

% Save unlabelled version of figure
saveas(fgh, ['figures/' name '.fig']);
plot2svg(['figures/' name '.svg'], fgh, 'png');
save2pdf(['figures/' name '.pdf'], fgh, 150);


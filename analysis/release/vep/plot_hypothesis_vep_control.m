clear;
close all;

for onoff = {'on', 'off'}

% Figure window size
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels

% Axes for figure
%xrange = [-preEventPlot_sec, postEventPlot_sec] * 1000; % x-axis limits for figure
%yrange = [-26 26];                                      % y-axis limits for figure
%xticks = [-50, 0, 50, 100];                             % tick marks on x-axis
%yticks = [-26, -13, 0, 13, 26];                         % tick marks on y-axis
yrange = [-1 1];
xrange = [-0.5 1];                                      % y-axis limits for figure
yticks = [-1, -0.5, 0, 0.5, 1];                             % tick marks on x-axis
xticks = [-0.5, 0, 0.5, 1];                         % tick marks on y-axis

% Figure formatting
font_size = 20; % font size of figure labels
dig_height = 0.7;   % fraction of vertical space for digital in to occupy

% make the figure with white background, with fixed size (in pixels) and invisible
%fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'off');
fgh = figure('Color',[1 1 1],'units','pixels','position',[0 0 (width + 2 * margins) (height + 2 * margins)], 'visible', 'on');
% make axes with correct margins
axes('units', 'pixel', 'position', [margins margins width height]);
hold on; % Allow all channels to be shown


time_axis = xrange(1):0.001:xrange(2);
cleanDigitalIn = (time_axis >= 0);

digitalInDataPlot = cleanDigitalIn;
digitalInDataPlot = dig_height * digitalInDataPlot * abs(yrange(2) - yrange(1));
digitalInDataPlot = digitalInDataPlot + yrange(1) + (1 - dig_height) / 2 * abs(yrange(2) - yrange(1));
if (strcmp(onoff, 'off'))
  digitalInDataPlot = -digitalInDataPlot;
end

% digital in plotted in black
plot(time_axis, digitalInDataPlot, 'k', 'linewidth', 3);

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();

for i = 1:size(CM, 1)
  chData_trial_averaged = 0 * time_axis;
  chData_trial_averaged = chData_trial_averaged + 0.5 * ((time_axis - 0.020) >= 0) .* exp(-500 * max(0, (time_axis - 0.020)));
  chData_trial_averaged = chData_trial_averaged - 0.5 * ((time_axis - 0.025) >= 0) .* exp(-500 * max(0, (time_axis - 0.025)));
  chData_trial_averaged = chData_trial_averaged + i * 0.02;
  plot(time_axis, chData_trial_averaged,'color',CM(i,:),'linewidth',4);
end



% Use fixed axes and ticks for axes
xlim(xrange);
ylim(yrange);

% Display full box around figures
box on;


%% Figure with labels
name = 'vep_hypothesis_control';
if (strcmp(onoff, 'off'))
  name = [name '_off'];
end

% set ticks on axes
set(gca, 'XTick', xticks);
set(gca, 'YTick', yticks);
% label axes
xlabel('Time (ms)');
ylabel('$\mu V$','Interpreter','LaTex');
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') - [0 0.015 0]);
ylabh = get(gca,'YLabel');
set(ylabh,'Position',get(ylabh,'Position') - [0.070 0 0]);

% set size of tick labels
set(gca,'FontSize',font_size);
%set size of labels
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);
% fake white title to keep size of figures same when using pdfcrop (with ylabel vs. without y label)
title('|', 'color', 'white', 'fontsize', font_size);

% Save labelled version of figure
saveas(fgh, ['figures/' name '_labelled.fig']);
plot2svg(['figures/' name '_labelled.svg'], fgh, 'png');

%% Figure with no labels
% Remove labels on ticks for x axis
set(gca, 'XTickLabel', {});
set(gca, 'XTick', [0]);
set(gca, 'XTickLabel', {0});
a = 0.65;
b = -1.20;
c = 0.03;
d = 0.15;
e = 0.05;
f = 0.1;
patch([a a a+d a+d a+d+f a+d a+d], [b b+c b+c b+c+e b+c/2 b-e b], 'k', 'clipping', 'off');
% Remove labels on ticks for y axis
set(gca, 'YTickLabel', {});
% Set text color to white
set(findall(fgh,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [1 1 1]);
% remove label for y axis
ylabel('');
xl = xlabel('Time');
ylabel('');
set(xl,'fontSize',font_size,'fontWeight','normal', 'color', [0 0 0]);

% Save unlabelled version of figure
saveas(fgh, ['figures/' name '.fig']);
plot2svg(['figures/' name '.svg'], fgh, 'png');

end


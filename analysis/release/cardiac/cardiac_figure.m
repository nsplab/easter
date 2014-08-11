% cardiac_figure.m
%
% This function generates the figures for the cardiac artifact cleaning.

function [] = cardiac_figure()

% Use subject 1 vep at mid-basilar for plot
subject_ID = 'subject1';
experiment = 'vep';
index = 3;

%% Constants
[ maxNumberOfChannels, digitalInCh, original_sampling_rate_in_Hz, channelNames, gtechGND, earth ] = subject_information(subject_ID);
[ channelToPlot, CM ] = plot_settings();

%% Filters
filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);
cardiac_filters = get_filters(original_sampling_rate_in_Hz, true, false, false, false, false);

[ pathname, pathname_comments ] = get_pathname(subject_ID, experiment)

[ files, comments ] = get_information(pathname, pathname_comments, experiment);

name = files{index};

%% Load data
[ data, cleanDigitalIn ] = load_data([pathname name], maxNumberOfChannels, digitalInCh, channelNames);

cardiacData = data{strcmp(data, 'Bottom Precordial'), 2};
cardiacData = run_filters(cardiacData, cardiac_filters);

% draw the figure with white background and fixed size (in pixels)
width = 275;   % width of figure (just plot itself, not labels)
height = 225;  % height of figure (just plot itself, not labels)
margins = 100; % extra space for labels
position = [0 0 (width + 2 * margins) (height + 2 * margins)];

% Open invisible screen for figure
f_start = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f_end = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f1 = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f2 = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f3 = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f4 = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;
f5 = figure('Color',[1 1 1],'units','pixels','position',position, 'visible', 'off'); axes('units', 'pixel', 'position', [margins margins width height]); box on;

interval = [10 11];
time = interval(1)*9600:interval(2)*9600;
time_axis = (time - time(1)) / 9600 * 1000;

%figure(f4);
set(0, 'CurrentFigure', f4);
plot([0 0], [-200 200], 'color', 'black', 'linewidth', 2);

%figure(f5);
set(0, 'CurrentFigure', f5);
plot([0 0], [-200 200], 'color', 'black', 'linewidth', 2);

set(0, 'CurrentFigure', f_start);
hold on;
plot(time_axis, 0.20 * cardiacData(time), 'LineWidth', 2, 'Color', 'black');

set(0, 'CurrentFigure', f_end);
hold on;
plot(time_axis, 0.20 * cardiacData(time), 'LineWidth', 2, 'Color', 'black');

cardiac_removal(0.20 * cardiacData, cardiacData, name, 'black', f1, f2, f3, f4, f5);

for ii=1:length(channelToPlot)
    fprintf('ii: %d, %d\n', ii, channelToPlot(ii));

    chData = data{channelToPlot(ii),2};

    % Apply filters
    chData = run_filters(chData, filters);

    set(0, 'CurrentFigure', f_start);
    plot(time_axis, chData(time), 'LineWidth', 2, 'Color', CM(ii, :));

    chData = cardiac_removal(chData, cardiacData, name, CM(ii, :), f1, f2, f3, f4, f5);
    %chData = cardiac_removal(chData, cardiacData);

    set(0, 'CurrentFigure', f_end);
    plot(time_axis, chData(time), 'LineWidth', 2, 'Color', CM(ii, :));

end

%saveas(f1, ['matlab_data/' name '_' int2str(channel) '_r_peak.fig']);
saveas(f1, ['matlab_data/' name '_r_peak.fig']);

%saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
%save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f2, 1200);
saveas(f2, ['matlab_data/' name '_dt.fig']);
save2pdf(['matlab_data/' name '_dt.pdf'], f2, 150);

%saveas(f1, ['matlab_data/' name '_' int2str(channel) '_dt.fig']);
%save2pdf(['matlab_data/' name '_' int2str(channel) '_dt.pdf'], f3, 1200);
saveas(f3, ['matlab_data/' name '_dt.fig']);
save2pdf(['matlab_data/' name '_dt.pdf'], f3, 150);

%save2pdf(['matlab_data/' name '_' int2str(channel) '_cardiac.pdf'], f4, 1200);
%save2pdf(['matlab_data/' name '_cardiac.pdf'], f4, 1200);
plot2svg(['matlab_data/' name '_cardiac.svg'], f4, 'png')


%save2pdf(['matlab_data/' name '_' int2str(channel) '_cardiac_all.pdf'], f3, 1200);
save2pdf(['matlab_data/' name '_cardiac_all.pdf'], f5, 150);

font_size = 20;

set(0, 'CurrentFigure', f_start);
xlabel('Time (ms)');
ylabel('$\mu V$', 'interpreter', 'LaTeX');
set(gca,'YTick',[-200,-100,0,100,200]);
xlim(time_axis([1, end]));
ylim([-200, 200]);
set(findall(f_start,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0,0,0]);
set(gca,'FontSize',font_size);


set(0, 'CurrentFigure', f_end);
xlabel('Time (ms)');
ylabel('$\mu V$', 'interpreter', 'LaTeX');
set(gca,'YTick',[-200,-100,0,100,200]);
xlim(time_axis([1, end]));
ylim([-200, 200]);
set(findall(f_end,'type','text'),'fontSize',font_size,'fontWeight','normal', 'color', [0,0,0]);
set(gca,'FontSize',font_size);

save2pdf(['matlab_data/' name '_start.pdf'], f_start, 150);
save2pdf(['matlab_data/' name '_end.pdf'], f_end, 150);


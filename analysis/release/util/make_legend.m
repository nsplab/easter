function [ f ] = make_legend(include_cardiac)
%MAKE_LEGEND  Creates and saves a figure with the legend.
%
%   [ F ] = MAKE_LEGEND(INCLUDE_CARDIAC)
%
% Parameters:
%
%   INCLUDE_CARDIAC is a boolean variable that indicated whether or not the
%   cardiac channel should be included in the legend. This variable is
%   optional and defaults to false.
%
% Output:
%
%   F is the figure handle of the figure with the legend.
%
% The figure is saved as legend.pdf and legend.svg in the directory figures.

% Constants
linewidth = 2;
fontsize = 10;

% Create figure
f = figure;
hold on;

% Get plotting information
[ channelToPlot, CM ] = plot_settings();
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information('subject1');

% Plot garbage to have something for the legend
legends = [];
for i = 1:numel(channelToPlot)
  legends = [legends plot(0, 0, 'Color', CM(i, :), 'linewidth', linewidth)];
end
if (nargin >= 1) && include_cardiac
    legends = [legends plot(0, 0, 'Color', 'black', 'linewidth', linewidth)];
end

% make the legend
if (nargin >= 1) && include_cardiac
    legend(legends, {channelNames{channelToPlot}, 'Cardiac'}, 'fontsize', fontsize);
else
    legend(legends, channelNames(channelToPlot), 'fontsize', fontsize);
end

% Remove everything not needed for the legend
axis off;
set(legends, 'visible', 'off');
set(gca, 'visible', 'off');

% Save figure
save2pdf('figures/legend.pdf', f, 1200);
plot2svg('figures/legend.svg', f, 'png');

end


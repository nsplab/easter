function [ f ] = make_legend(index)
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
CM( 1, :) =         [1.0 0.0 0.0];
CM( 2, :) = lighten([1.0 0.0 0.0], 0.25);
CM( 3, :) = lighten([1.0 0.0 0.0], 0.5);

CM( 7, :) =         [0.0 1.0 0.0];
CM( 8, :) = lighten([0.0 1.0 0.0], 0.25);
CM( 9, :) = lighten([0.0 1.0 0.0], 0.5);

CM( 4, :) =         [0.0 0.0 0.0];
CM( 5, :) = lighten([0.0 0.0 0.0], 0.25);
CM( 6, :) = lighten([0.0 0.0 0.0], 0.5);

CM(10, :) =         [0.0 0.0 1.0];
CM(11, :) = lighten([0.0 0.0 1.0], 0.25);
CM(12, :) = lighten([0.0 0.0 1.0], 0.5);

  %CMs = {CMi, lighten(CMi, 0.25), lighten(CMi, 0.5), CMf, lighten(CMf, 0.25), lighten(CMf, 0.5)};
channelToPlot = 1:12;
if (index == 1)
    channelNames = {'12:08:22', '12:28:28', '12:31:02', '16:38:47', '16:54:15', '16:58:34'};
    % 9:51:31
    channelNames = {'',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '12:08:22',
                    '12:28:28',
                    '12:31:02',
                    '16:38:47',
                    '16:54:15',
                    '16:58:34'};
else
    channelNames = {'11:14:51', '11:31:23', '11:37:22', '15:48:24', '15:55:07', '15:57:52'};
end


% Plot garbage to have something for the legend
legends = [];
for i = 1:numel(channelToPlot)
  legends = [legends plot(0, 0, 'Color', CM(i, :), 'linewidth', linewidth)];
end

% make the legend
columnlegend(2, channelNames(channelToPlot), 'fontsize', fontsize, 'location', 'southwest');

% Remove everything not needed for the legend
axis off;
set(legends, 'visible', 'off');
set(gca, 'visible', 'off');

% Save figure
save2pdf('figures/legend_baseline.pdf', f, 1200);
plot2svg('figures/legend_baseline.svg', f, 'png');

end


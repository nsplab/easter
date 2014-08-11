% make_legend.m
%
% This function creates and saves the legend.
%
% Arguments:
%   None
%
% Output:
%   f: figure handle
%   Saves the legend as legend.pdf.

function [ f ] = make_legend()

    % Create figure
    f = figure;
    hold on;

    % Get plotting information
    [ channelToPlot, CM ] = plot_settings();
    [ channelNames, gtechGND, earth ] = subject_information('subject1');

    % Plot garbage to have something for the legend
    legends = [];
    for i = 1:numel(channelToPlot)
      legends = [legends plot(0, 0, 'Color', CM(i, :), 'linewidth', 2)];
    end
    legends = [legends plot(0, 0, 'Color', 'black', 'linewidth', 2)];

    % make the legend
    legend(legends, {channelNames{channelToPlot}, 'Cardiac'}, 'fontsize', 10);

    % Remove everything not needed for the legend
    axis off;
    set(legends, 'visible', 'off');
    set(gca, 'visible', 'off');

    % Save figure
    save2pdf('legend.pdf', f, 1200);

end


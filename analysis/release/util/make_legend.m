function [ f ] = make_legend()
  f = figure;
  hold on;

  [ channelToPlot, CM ] = plot_settings();

  [ channelNames, gtechGND, earth ] = rabbit_information('10rabbit_may_15_2014');


  legends = [];
  for i = 1:numel(channelToPlot)
    legends = [legends plot(0, 0, 'Color', CM(i, :), 'linewidth', 2)];
  end
  legends = [legends plot(0, 0, 'Color', 'black', 'linewidth', 2)];
  legend(legends, {channelNames{channelToPlot}, 'Cardiac'}, 'fontsize', 10);

  axis off;
  set(legends, 'visible', 'off');
  set(gca, 'visible', 'off');

  %save2pdf('legend.pdf', f, 1200);
  save2pdf('legend2.pdf', f, 1200);


end


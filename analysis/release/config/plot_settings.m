% plot_settings.m
%
% This function specifies which channels to plot and the colors to use for
% them.
%
% Arguments:
%   None.
%
% Output:
%   channelToPlot: list of channels to be plotted
%   CM: color matrix - colors for each channel in the plot

function [ channelToPlot, CM ] = plot_settings()

channelToPlot = [3,5,8,2]; 

CM = [hex2dec('ff'), hex2dec('ba'), hex2dec('00'); 
      hex2dec('40'), hex2dec('40'), hex2dec('ff'); 
      hex2dec('b0'), hex2dec('00'), hex2dec('b0'); 
      hex2dec('e9'), hex2dec('00'), hex2dec('3a')];
CM = CM / 256; 

end


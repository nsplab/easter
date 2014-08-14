function [ channelToPlot, CM ] = plot_settings()
%PLOT_SETTINGS  Specifies which channels to plot and colors for the channels.
%
%   [ CHANNELTOPLOT, CM ] = PLOT_SETTINGS()
%
% Parameters:
%
%   None.
%
% Output:
%
%   CHANNELTOPLOT is a list of the channels to be plotted.
%
%   CM is a color matrix. Each row corresponds to one of the channels, and
%   each of the columns corresponds to one of the RGB values.

channelToPlot = [3,5,8,2]; 

CM = [hex2dec('ff'), hex2dec('ba'), hex2dec('00'); 
      hex2dec('40'), hex2dec('40'), hex2dec('ff'); 
      hex2dec('b0'), hex2dec('00'), hex2dec('b0'); 
      hex2dec('e9'), hex2dec('00'), hex2dec('3a')];
CM = CM / 256; 

end


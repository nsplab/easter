function [] = generate_all()
%GENERATE_ALL  Generates all figures required for the paper figures.
%
% GENERATE_ALL()
%
% Parameters:
%
%   None.
%
% Output:
%
%   Figures saved to the directory figures.

addpath('cardiac');
addpath('config');
addpath('ssavep');
addpath('util');
addpath('vep');

if ~exist('figures', 'dir')
    mkdir(pwd(),  'figures');
end

make_legend();

plot_all_vep('subject1');
plot_all_vep('subject1', 2, [3], false);
plot_all_ssavep('ssaep', 'subject1');
plot_all_ssavep('ssvep', 'subject1');

plot_all_vep('subject2');
plot_all_ssavep('ssaep', 'subject2');
plot_all_ssavep('ssvep', 'subject2');

cardiac_figure('subject1', 'vep', 3, [10, 11]); % Use subject 1 vep at mid-basilar for plot

end


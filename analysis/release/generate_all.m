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

set(0,'defaultAxesFontName', 'SansSerif');
set(0,'defaultTextFontName', 'SansSerif');
set(0,'DefaultAxesFontSize', 20);
set(0,'DefaultTextFontSize', 20);

if ~exist('figures', 'dir')
    mkdir(pwd(),  'figures');
end

%make_legend(true);
%
%plot_hypothesis_vep();
%plot_hypothesis_vep_control();
%
%plot_hypothesis_ssaep();
%plot_hypothesis_ssavep_control();
%plot_hypothesis_ssvep();

%plot_all_vep('subject1', 1);
%plot_all_vep('subject1', 4);
%plot_all_vep('subject1', 5);
%plot_all_vep('subject1', 1, [3], false);
plot_all_ssavep('ssaep', 'subject1');
plot_all_ssavep('ssvep', 'subject1');

%plot_all_vep('subject2', 1);
%plot_all_vep('subject2', 4);
%plot_all_vep('subject2', 5);
plot_all_ssavep('ssaep', 'subject2');
plot_all_ssavep('ssvep', 'subject2');

%cardiac_figure('subject1', 'vep', 3, [10, 11]); % Use subject 1 vep at mid-basilar for plot

end


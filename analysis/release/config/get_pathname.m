% get_pathname.m
%
% Arguments:
%   subject_ID: string ('subject1' or 'subject2') for which subject to get
%               paths for
%   experiment: string ('vep', 'ssaep', 'ssvep') for which experiment to get
%               paths for

function [ pathname, pathname_comments ] = get_pathname(subject_ID, experiment)

% pathnames use lowercase 'vep', 'ssaep', 'ssvep'
experiment = lower(experiment);

% path for the data in easter binary format
pathname = ['data/' subject_ID '/' experiment '/'];
% file containing comments written on the experiment day to use as labels for the figure titles
pathname_comments = ['data/' subject_ID '/neuro_experiment_log.txt'];

end


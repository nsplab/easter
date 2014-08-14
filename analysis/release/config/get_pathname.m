function [ pathname, experiment_log ] = get_pathname(subject_ID, experiment)
%GET_PATHNAME Returns paths to binary data file directory and experiment logs.
%
%   [ PATHNAME, EXPERIMENT_LOG ] = GET_PATHNAME(SUBJECT_ID, EXPERIMENT) gives
%   the relevant paths for subject SUBJECT_ID for experiment EXPERIMENT. The
%   binary data files are contained in the directory PATHNAME, and the
%   experiment log file has the name EXPERIMENT_LOG.
%
% Parameters:
%
%   SUBJECT_ID is a string ('subject1' or 'subject2') of the name of the
%   subject. The available options are in the data directory.
%
%   EXPERIMENT is a string ('vep', 'ssaep', 'ssvep') of the experiment name.
%
% Output:
%
%   PATHNAME is the directory that contains the binary data files.
%
%   EXPERIMENT_LOG is the name of the experiment log for the experiment.

experiment = lower(experiment); % pathnames use lowercase (vep, ssaep, ssvep)

% path for the binary files
pathname = ['data/' subject_ID '/' experiment '/'];

% file containing comments written on the experiment day
experiment_log = ['data/' subject_ID '/neuro_experiment_log.txt'];

end


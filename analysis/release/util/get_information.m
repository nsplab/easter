% get_information.m
%
% Arguments:
%   pathname: directory that contains the data files
%   pathname_comments: experiment log file
%   experiment: string ('VEP', 'SSAEP', or 'SSVEP')
%
% Output:
%   files: list of data filenames
%   comments: list of relevant lines from experiment log

function [ files, comments ] = get_information(pathname, pathname_comments, experiment)

% experiment log uses capitalized 'VEP', 'SSAEP', 'SSVEP'
experiment = upper(experiment);

tmp = dir(pathname);       % get the list of data filenames for this particular type of evoked potential
files = {tmp(3:end).name}; % chop out the '.' and '..' filename entries that are in every directory

fid = fopen(pathname_comments);
if fid==-1 % if the vep.txt comments file doesn't exist, display an error message to the console and skip the textscan
    fprintf('Experiment log not found.\n');
    allData = []; % TODO: make this an assert?
else
    comments = textscan(fid,'%s','Delimiter','\n'); % read log file
    C = strfind(comments{1}, ['- ' experiment]);    % get rows for this experiment
    rows = find(~cellfun('isempty', C));            % grab just the relevant rows
    comments = comments{1}(rows);
    fclose(fid);
end

% check that the files and experiment log match
assert_match(files, comments);

end


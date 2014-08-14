function [ files, comments ] = get_information(pathname, pathname_comments, experiment)
%GET_INFORMATION  Returns a list of files and comments from experiment log.
%
% [ FILES, COMMENTS ] = GET_INFORMATION(PATHNAME, PATHNAME_COMMENTS, EXPERIMENT)
%
% Parameters:
%   PATHNAME is the directory that contains the data files.
%
%   PATHNAME_COMMENTS is the filename of the experiment log file.
%
%   EXPERIMENT is a string specifying the experiment (VEP, SSAEP, or SSVEP).
%
% Output:
%
%   FILES is a list of data filenames.
%
%   COMMENTS is a list of relevant lines from experiment log.


% experiment log uses capitalized 'VEP', 'SSAEP', 'SSVEP'
experiment = upper(experiment);

tmp = dir(pathname);       % get the list of data filenames for this particular type of evoked potential
files = {tmp(3:end).name}; % chop out the '.' and '..' filename entries that are in every directory

fid = fopen(pathname_comments);
assert(fid ~= -1) % check that the experiment log exist

comments = textscan(fid,'%s','Delimiter','\n'); % read log file
C = strfind(comments{1}, ['- ' experiment]);    % get rows for this experiment
rows = find(~cellfun('isempty', C));            % grab just the relevant rows
comments = comments{1}(rows);
fclose(fid);                                    % close file

% check that the files and experiment log match
assert_match(files, comments);

end


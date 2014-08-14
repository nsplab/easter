function [] = assert_match(files, comments)
%ASSERT_MATCH  Checks that the data files and experiment logs match.
%
% ASSERT_MATCH(FILES, COMMENTS)
%
% This function takes a list of the data files for an experiment and the
% relevant lines in the experiment log to verify that the two match. A match
% requires the two to have the same number of elements and to have the same
% hour, minute, and second.
%
% Parameters:
%
%   FILES is a list of data filenames.
%
%   COMMENTS is a list of relevant lines from experiment log.
%
% Output:
%
%   No return value.
%
%   Results in an assertion error if there is a problem with matching.


%% Check for matching experiment log and data files
assert(length(files) == length(comments)); % check that the experiment log and data files have the same number of VEP runs
for i = 1:length(files)
  % Hard coded parsing of file name
  files_day = files{i}(1:3);
  assert(strcmp(files{i}(4), '_'))
  files_date = files{i}(5:6);
  assert(strcmp(files{i}(7), '_'))
  files_month = files{i}(8:9);
  assert(strcmp(files{i}(10), '_'))
  files_month = files{i}(11:14);
  assert(strcmp(files{i}(15), '_'))
  files_hour = files{i}(16:17);
  assert(strcmp(files{i}(18), '_'))
  files_minute = files{i}(19:20);
  assert(strcmp(files{i}(21), '_'))
  files_second = files{i}(22:23);

  % Hard coded parsing of experiment log
  comment = comments{i};
  if comment(2) == ':'
      comment = ['0' comment]; % one digit hour - pad with extra 0
  end
  comment_hour = comment(1:2);
  assert(strcmp(comment(3), ':'))
  comment_minute = comment(4:5);
  assert(strcmp(comment(6), ':'))
  comment_second = comment(7:8);

  % Check for explicit match
  assert(strcmp(files_hour, comment_hour));
  assert(strcmp(files_minute, comment_minute));
  assert(strcmp(files_second, comment_second));
end

end


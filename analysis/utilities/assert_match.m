function [] = assert_match(S, allData)

%% Check for matching experiment log and data files
assert(length(S) == length(allData)); % check that the experiment log and data files have the same number of VEP runs
for i = 1:length(S)
  % Hard coded parsing of file name
  assert(strcmp(S{i}(1), '_'))
  S_day = S{i}(2:4);
  assert(strcmp(S{i}(5), '_'))
  S_date = S{i}(6:7);
  assert(strcmp(S{i}(8), '.'))
  S_month = S{i}(12:15);
  assert(strcmp(S{i}(16), '_'))
  S_hour = S{i}(17:18);
  assert(strcmp(S{i}(19:21), '%3A'))
  S_minute = S{i}(22:23);
  assert(strcmp(S{i}(24:26), '%3A'))
  S_second = S{i}(27:28);
  assert(strcmp(S{i}(29:35), '_ssvep_'))
  S_extra = S{i}(34:end);

  % Hard coded parsing of experiment log
  header = allData{i};
  if header(2) == ':'
      header = ['0' header]; % one digit hour - pad with extra 0
  end
  header_hour = header(1:2);
  assert(strcmp(header(3), ':'))
  header_minute = header(4:5);
  assert(strcmp(header(6), ':'))
  header_second = header(7:8);

  % Check for explicit match
  assert(strcmp(S_hour, header_hour));
  assert(strcmp(S_minute, header_minute));
  assert(strcmp(S_second, header_second));
end

end


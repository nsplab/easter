% opens a dialog box to select the file you want to load
% creates a cell array named 'data':
% 1st column: the name of the channel/electrode
% 2nd column: samples vector

digitalinCh = 65;

cd '../../../../data/easter/';

% select the binary data file
if (~exist('dontUseGUI')) || (~dontUseGUI)
    [filename, pathname] = uigetfile('*','Select the binary data file');
end

% open the binary data file
[pathname filename]
fid = fopen([pathname filename], 'r');

% if the info file exists read its content
fidInfo = fopen([pathname 'info.txt'], 'r');
if fidInfo > 0
    info = importdata([pathname 'info.txt']);
end

% prepare the data cell array
data = cell(0,2);

% maximum number of channels recorded
% set this to any number greater than the number of channels named in
% info.txt as the following code adds only the named channels to the data
% cell array
maxNumberOfChannels = 10;

for i=1:maxNumberOfChannels
    % read the i-th column of data / i-th channel
    fseek(fid, 4*(i-1), 'bof');
    dataColumn = fread(fid, Inf, 'single', 4*64);
    channelName = ['channel ' int2str(i)];
    % if the channel is named in info.txt append the name to the name cell
    if fidInfo > 0
        a = regexp(info,['channel ' int2str(i) ': (?<name>\w+[\ \w \/]*)'],'names');
        a(cellfun('isempty',a)) = [];
        if isempty(a)
            break;
        end
        channelName = [channelName ': ' a{1}.name];
    end
    data(end+1,1) = {channelName};
    data(end,2) = {dataColumn};
end

fseek(fid, 4*(digitalinCh-1), 'bof');
dataColumnDig = fread(fid, Inf, 'single', 4*64);
cleanDigitalIn = (dataColumnDig>0);

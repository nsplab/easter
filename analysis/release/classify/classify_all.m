function [ ] = classify_all()
addpath(genpath('..'));

file_experiment = '../data/subject1/vep/Thu_15_05_2014_11_57_42';
file_control    = '../data/subject1/vep/Thu_15_05_2014_12_15_47';
on_off = 'on';
control_type = 'live';
evaluate('../data/subject1/vep/Thu_15_05_2014_11_57_42', '../data/subject1/vep/Thu_15_05_2014_12_15_47', 'on', 'live')

file_experiment = '../data/subject1/vep/Thu_15_05_2014_11_57_42';
file_control = '../data/subject1/vep/Thu_15_05_2014_17_22_22';
on_off = 'on';
control_type = 'dead';
evaluate('../data/subject1/vep/Thu_15_05_2014_11_57_42', '../data/subject1/vep/Thu_15_05_2014_17_22_22', 'on', 'dead')
end


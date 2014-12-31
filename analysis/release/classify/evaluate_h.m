function [ accuracy, sensitivity, specificity ] = evaluate(experiment, control, subject_ID)

assert(numel(experiment) == numel(control));

accuracy = [];
sensitivity = [];
specificity = [];

%for i = 1:numel(experiment)
%  experiment{i} = experiment{i}(:, 1:10:end);
%  control{i} = control{i}(:, 1:10:end);
%end

%for num_trials_mean = 206%1:100
for num_trials_mean = 1:100
%for num_trials_mean = 1:2

  % preprocess - calculate mean
  exp_data = {};
  con_data = {};
  for i = 1:numel(experiment)
    several_trial_mean = nan(size(experiment{i}, 1) - num_trials_mean + 1, ...
                             size(experiment{i}, 2));
    for j = 0:(size(experiment{i}, 1) - num_trials_mean)
        several_trial_mean(j + 1, :) = mean(experiment{i}(j + (1:num_trials_mean), :), 1);
    end
    exp_data{i} = several_trial_mean;
  
    several_trial_mean = nan(size(control{i}, 1) - num_trials_mean + 1, ...
                             size(control{i}, 2));
    for j = 0:(size(control{i}, 1) - num_trials_mean)
        several_trial_mean(j + 1, :) = mean(control{i}(j + (1:num_trials_mean), :), 1);
    end
    con_data{i} = several_trial_mean;
  end

  %figure;
  %plot(exp_data{4}')

  experiment_train = false(size(exp_data{1}, 1), 1);
  experiment_test  = false(size(exp_data{1}, 1), 1);
  control_train    = false(size(con_data{1}, 1), 1);
  control_test     = false(size(con_data{1}, 1), 1);
  
  %experiment_train(1:50) = true;
  %experiment_test(51:end) = true;
  %control_train(1:50) = true;
  %control_test(51:end) = true;

  %experiment_train(1:50) = true;
  %experiment_test(51:100) = true;
  %control_train(1:50) = true;
  %control_test(51:100) = true;
  
  experiment_train(1:50) = true;
  experiment_test(end-49:end) = true;
  control_train(1:50) = true;
  control_test(end-49:end) = true;
  
  %experiment_train(1:floor(size(experiment{1}, 2) / 2)) = true;
  %experiment_test(ceil(size(experiment{1}, 2) / 2):end) = true;
  %control_train(1:floor(size(control{1}, 2) / 2)) = true;
  %control_test(ceil(size(control{1}, 2) / 2):end) = true;
  
  %experiment_train = true(size(exp_data{1}, 1), 1);
  %experiment_test  = true(size(exp_data{1}, 1), 1);
  %control_train    = true(size(con_data{1}, 1), 1);
  %control_test     = true(size(con_data{1}, 1), 1);
  
  % Train
  for i = 1:numel(exp_data)
    assert(all(size(exp_data{i}) == size(exp_data{1})));
  
    e_train{i} = exp_data{i}(experiment_train, :);
    c_train{i} = con_data{i}(control_train, :);
  end
  model = train(e_train, c_train);
  
  % Test
  for i = 1:numel(exp_data)
    %[v, d] = eig(model.experiment_cov{i})
    %[v, d] = eig(model.control_cov{i})
    assert(all(size(exp_data{i}) == size(exp_data{1})));
  
    e_test{i} = exp_data{i}(experiment_test, :);
    c_test{i} = con_data{i}(control_test, :);
  end
  
  [acc, sen, spec] = test(model, e_test, c_test);
  acc
  sen
  spec
  accuracy = [accuracy;
              acc];
  sensitivity = [sensitivity;
                 sen];
  specificity = [specificity
                 spec];
end


%% Preliminary information about plotting

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, experiment_log ] = get_pathname(subject_ID, 'vep');
[ files, comments ] = get_information(['../' pathname], ['../' experiment_log], 'vep');

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();

chName = channelNames(channelToPlot);
f = figure;
hold on;
for i = 1:numel(chName)
  plot(accuracy(:, i), 'Color', CM(i, :), 'LineWidth', 3);
end
legend(chName);
title('accuracy');
ylim([-0.05 1.05]);

f = figure;
hold on;
for i = 1:numel(chName)
  plot(sensitivity(:, i), 'Color', CM(i, :), 'LineWidth', 3);
end
legend(chName);
title('sensitivity');
ylim([-0.05 1.05]);

f = figure;
hold on;
for i = 1:numel(chName)
  plot(specificity(:, i), 'Color', CM(i, :), 'LineWidth', 3);
end
legend(chName);
title('specificity');
ylim([-0.05 1.05]);

end


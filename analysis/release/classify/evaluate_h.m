function [ accuracy, sensitivity, specificity ] = evaluate(experiment, control, subject_ID, digital_data, pre, post, control_type, decimate_rate)
experiment
control

assert(numel(experiment) == numel(control));

accuracy = [];
sensitivity = [];
specificity = [];

%% Preliminary information about plotting

% Information about recording 
[ numChannels, digitalCh, fs, channelNames, GND, earth ] = subject_information(subject_ID);

% Load names of data files and experiment log
[ pathname, experiment_log ] = get_pathname(subject_ID, 'vep');
[ files, comments ] = get_information(['../' pathname], ['../' experiment_log], 'vep');

fs = fs / decimate_rate;

% Get list of channels to plot and colors for each channel
[ channelToPlot, CM ] = plot_settings();

experiment = experiment([end, 1:(end-1)]);
control = control([end, 1:(end-1)]);
channelToPlot = channelToPlot([end, 1:(end-1)]);
CM = CM([end, 1:(end-1)], :);

chName = channelNames(channelToPlot);

%for i = 1:numel(experiment)
%  experiment{i} = experiment{i}(:, 1:10:end);
%  control{i} = control{i}(:, 1:10:end);
%end

%for num_trials_mean = 206%1:100
%for num_trials_mean = 1:100
%for num_trials_mean = 1:2
%for num_trials_mean = [1, 2, 5, 10, 50, 100]
for num_trials_mean = 1:10
%for num_trials_mean = 50
%for num_trials_mean = [1 5 10 50]

  % preprocess - calculate mean
  exp_data = {};
  con_data = {};
  for i = 1:numel(experiment)
    %several_trial_mean = nan(size(experiment{i}, 1) - num_trials_mean + 1, ...
    %                         size(experiment{i}, 2));
    several_trial_mean = [];
    %for j = 0:(size(experiment{i}, 1) - num_trials_mean)
    for j = 0:num_trials_mean:(size(experiment{i}, 1) - num_trials_mean)
        %several_trial_mean(j + 1, :) = mean(experiment{i}(j + (1:num_trials_mean), :), 1);
        several_trial_mean((j / num_trials_mean) + 1, :) = mean(experiment{i}(j + (1:num_trials_mean), :), 1);
    end
    exp_data{i} = several_trial_mean;
  
    %several_trial_mean = nan(size(control{i}, 1) - num_trials_mean + 1, ...
    %                         size(control{i}, 2));
    several_trial_mean = [];
    %for j = 0:(size(control{i}, 1) - num_trials_mean)
    for j = 0:num_trials_mean:(size(experiment{i}, 1) - num_trials_mean)
        %several_trial_mean(j + 1, :) = mean(control{i}(j + (1:num_trials_mean), :), 1);
        several_trial_mean((j / num_trials_mean) + 1, :) = mean(control{i}(j + (1:num_trials_mean), :), 1);
    end
    con_data{i} = several_trial_mean;
  end

  yl = [Inf, -Inf];
  for i = 1:numel(chName)
    yl = [min([min(min([exp_data{i}; con_data{i}])), yl(1)]),
          max([max(max([exp_data{i}; con_data{i}])), yl(2)])];
  end
  yl = [min([ yl(1), -yl(2)])
        max([-yl(1),  yl(2)])];

  N = size(exp_data{1}, 2);
  %f = figure;
  %hold on;
  %handle = [];
  %for i = 1:numel(chName)
  %  if (size(exp_data{i}, 1) > 10)
  %    h = plot(1000 * (1:N) / fs - pre, exp_data{i}(1:10, :)', 'Color', CM(i, :), 'LineWidth', 3);
  %  else
  %    h = plot(1000 * (1:N) / fs - pre, exp_data{i}', 'Color', CM(i, :), 'LineWidth', 3);
  %  end
  %  handle = [handle h(1)];
  %end
  %dig_height = 0.7;
  %h = plot(1000 * (1:N) / fs - pre, dig_height * digital_data{1}(1, :) * (yl(2) - yl(1)) + yl(1) + (1 - dig_height) / 2 * abs(yl(2) - yl(1)), 'Color', 'black', 'LineWidth', 3);
  %%legend(handle, chName);
  %xlim(1000 * [0 N / fs] - pre);
  %ylim(yl);
  %title(['Experiment (Mean of ' int2str(num_trials_mean) ')']);
  %xlabel('Time (ms)');
  %ylabel('Signal (\mu V)');
  %save2pdf(['experiment_' int2str(num_trials_mean) '.pdf'] , f, 150);

  %f = figure;
  %hold on;
  %handle = [];
  %for i = 1:numel(chName)
  %  if (size(con_data{i}, 1) > 10)
  %    h = plot(1000 * (1:N) / fs - pre, con_data{i}(1:10, :)', 'Color', CM(i, :), 'LineWidth', 3);
  %  else
  %    h = plot(1000 * (1:N) / fs - pre, con_data{i}', 'Color', CM(i, :), 'LineWidth', 3);
  %  end
  %  handle = [handle h(1)];
  %end
  %h = plot(1000 * (1:N) / fs - pre, dig_height * digital_data{1}(1, :) * (yl(2) - yl(1)) + yl(1) + (1 - dig_height) / 2 * abs(yl(2) - yl(1)), 'Color', 'black', 'LineWidth', 3);
  %%legend(handle, chName);
  %xlim(1000 * [0 N / fs] - pre);
  %ylim(yl);
  %title(['Control (Mean of ' int2str(num_trials_mean) ')']);
  %xlabel('Time (ms)');
  %ylabel('Signal (\mu V)');
  %save2pdf([control_type 'control_' int2str(num_trials_mean) '.pdf'] , f, 150);

  %continue;


  %figure;
  %plot(exp_data{4}')

  experiment_train = false(size(exp_data{1}, 1), 1);
  experiment_test  = false(size(exp_data{1}, 1), 1);
  control_train    = false(size(con_data{1}, 1), 1);
  control_test     = false(size(con_data{1}, 1), 1);

  %experiment_train = true(size(exp_data{1}, 1), 1);
  %experiment_test  = true(size(exp_data{1}, 1), 1);
  %control_train    = true(size(con_data{1}, 1), 1);
  %control_test     = true(size(con_data{1}, 1), 1);
  
  %experiment_train(1:50) = true;
  %experiment_test(51:end) = true;
  %control_train(1:50) = true;
  %control_test(51:end) = true;

  %experiment_train(1:50) = true;
  %experiment_test(51:100) = true;
  %control_train(1:50) = true;
  %control_test(51:100) = true;
  
  %experiment_train(1:50) = true;
  %experiment_test(end-49:end) = true;
  %control_train(1:50) = true;
  %control_test(end-49:end) = true;
  
  experiment_train(1:10) = true;
  experiment_test(11:end) = true;
  control_train(1:10) = true;
  control_test(11:end) = true;
  
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
  
    %e_train{i} = exp_data{i}(experiment_train, :);
    %c_train{i} = con_data{i}(control_train, :);
    e_train{i} = exp_data{i}(experiment_train, [190:250, 590:700]);
    c_train{i} = con_data{i}(control_train, [190:250, 590:700]);
  end
  model = train(e_train, c_train);
  
  % Test
  for i = 1:numel(exp_data)
    %[v, d] = eig(model.experiment_cov{i})
    %[v, d] = eig(model.control_cov{i})
    assert(all(size(exp_data{i}) == size(exp_data{1})));
  
    %e_test{i} = exp_data{i}(experiment_test, :);
    %c_test{i} = con_data{i}(control_test, :);
    e_test{i} = exp_data{i}(experiment_test, [190:250, 590:700]);
    c_test{i} = con_data{i}(control_test, [190:250, 590:700]);
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


f = figure;
hold on;
for i = 1:numel(chName)
  plot(accuracy(:, i), 'Color', CM(i, :), 'LineWidth', 3);
end
legend(chName, 'Location', 'best');
title('accuracy');
ylim([-0.05 1.05]);
save2pdf(['accuracy_' control_type '.pdf'] , f, 150);

f = figure;
hold on;
for i = 1:numel(chName)
  plot(sensitivity(:, i), 'Color', CM(i, :), 'LineWidth', 3);
end
legend(chName, 'Location', 'best');
title('sensitivity');
ylim([-0.05 1.05]);
save2pdf(['sensitivity_' control_type '.pdf'] , f, 150);

f = figure;
hold on;
for i = 1:numel(chName)
  plot(specificity(:, i), 'Color', CM(i, :), 'LineWidth', 3);
end
legend(chName, 'Location', 'best');
title('specificity');
ylim([-0.05 1.05]);
save2pdf(['specificity_' control_type '.pdf'] , f, 150);

end


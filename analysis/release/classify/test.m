function [ ] = test(file_experiment, file_control, on_off)

experiment = load_vep(file_experiment, on_off);
control = load_vep(file_control, on_off);

assert(numel(experiment) == numel(control));

experiment_train = false(size(experiment{1}, 2), 1);
experiment_test  = false(size(experiment{1}, 2), 1);
control_train    = false(size(control{1}, 2), 1);
control_test     = false(size(control{1}, 2), 1);

experiment_train(1:floor(size(experiment{1}, 2) / 2)) = true;
experiment_test(ceil(size(experiment{1}, 2) / 2):end) = true;
control_train(1:floor(size(control{1}, 2) / 2)) = true;
control_test(ceil(size(control{1}, 2) / 2):end) = true;

experiment_mean = cell(numel(experiment), 1);
experiment_cov = cell(numel(experiment), 1);
control_mean = cell(numel(control), 1);
control_cov = cell(numel(control), 1);

% preprocess - calculate mean
num_trials_mean = 10;
for i = 1:numel(experiment)
  several_trial_mean = nan(size(experiment{i}, 1) - num_trials_mean + 1, ...
                           size(experiment{i}, 2));
  size(several_trial_mean)
  for j = 0:(size(experiment{i}, 1) - num_trials_mean)
      several_trial_mean(j + 1, :) = mean(experiment{i}(j + (1:num_trials_mean), :), 1);
  end
  size(several_trial_mean)

  experiment{i} = several_trial_mean;
end

% Train
for i = 1:numel(experiment)
  assert(all(size(experiment{i}) == size(experiment{1})));

  experiment_mean{i} = mean(experiment{i}(experiment_train));
  experiment_cov{i} = cov(experiment{i}(experiment_train));
  control_mean{i} = mean(control{i}(control_train));
  control_cov{i} = cov(control{i}(control_train));
end

% Test
for i = 1:numel(experiment)
  assert(all(size(experiment{i}) == size(experiment{1})));

  num_correct = 0;

  experiment_data = experiment{i}(experiment_test);
  control_data = control{i}(control_test);
  data = [experiment_data;
          control_data];
  N = size(data, 1);
  isexp = false(N, 1);
  isexp(1:size(experiment_data, 1)) = true;

  for j = 1:size(data, 1)
    logp_exp = logmvnpdf(data(j, :), experiment_mean{i}, experiment_cov{i});
    logp_con = logmvnpdf(data(j, :), control_mean{i}, control_cov{i});
    guess = (logp_exp > logp_con);
    if (guess == isexp(j))
      num_correct = num_correct + 1;
    end
  end

  acc = num_correct / N

end

end


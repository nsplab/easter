function [ model ] = train(experiment, control)


experiment_mean = cell(numel(experiment), 1);
experiment_cov = cell(numel(experiment), 1);
control_mean = cell(numel(control), 1);
control_cov = cell(numel(control), 1);

for i = 1:numel(experiment)
  %experiment{i} = sort(experiment{i});
  %control{i} = sort(control{i});

  %experiment{i} = experiment{i}(round(0.025 * size(experiment{i}, 1)):round(0.975 * size(experiment{i}, 1)), :);
  %control{i} = control{i}(round(0.025 * size(control{i}, 1)):round(0.975 * size(control{i}, 1)), :);


  experiment_mean{i} = mean(experiment{i});
  experiment_cov{i} = cov(experiment{i});
  experiment_invcov{i} = inv(experiment_cov{i} + 0.1 * eye(size(experiment_cov{i})));
  experiment_logdetcov{i} = logdet(experiment_cov{i});

  control_mean{i} = mean(control{i});
  control_cov{i} = cov(control{i});
  control_invcov{i} = inv(control_cov{i} + 0.1 * eye(size(control_cov{i})));
  control_logdetcov{i} = logdet(control_cov{i});

  %X = [experiment{i}(:, 1:10:end);
  %     control{i}(:, 1:10:end)];
  X = [experiment{i};
       control{i}];
  N = size(X, 1);
  Y = false(N, 1);
  Y(1:size(experiment{1}, 1)) = true;
  %B{i} = glmfit(X, Y, 'binomial', 'link', 'logit', 'constant', 'off');
  %B{i} = regress(Y, X);
  %mean(Y == (X * B{i} > 0.5))

  linclass{i} = fitcdiscr(X, Y);
  linclass{i}
  %quadclass{i} = fitcdiscr(X, Y, 'discrimType','quadratic');
  %quadclass{i}
end

model.experiment_mean = experiment_mean;
model.experiment_cov  = experiment_cov;
model.experiment_invcov  = experiment_invcov;
model.experiment_logdetcov  = experiment_logdetcov;

model.control_mean    = control_mean;
model.control_cov     = control_cov;
model.control_invcov     = control_invcov;
model.control_logdetcov  = control_logdetcov;

%model.B = B;
model.linclass = linclass;
%model.quadclass = quadclass;

end


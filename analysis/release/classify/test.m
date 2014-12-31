function [ acc, sen, spec ] = test(model, experiment, control)

for i = 1:numel(experiment)
  num_correct = 0;
  
  data = [experiment{i};
          control{i}];
  N = size(data, 1);
  isexp = false(N, 1);
  isexp(1:size(experiment{1}, 1)) = true;

  sen_num = 0;
  sen_den = 0;

  spec_num = 0;
  spec_den = 0;

  for j = 1:size(data, 1)
    logp_exp = logmvnpdf(data(j, :), model.experiment_mean{i}, model.experiment_cov{i}, model.experiment_invcov{i}, model.experiment_logdetcov{i});
    logp_con = logmvnpdf(data(j, :), model.control_mean{i}, model.control_cov{i}, model.control_invcov{i}, model.control_logdetcov{i});
    %logp_exp = -sum((data(j, :) - model.experiment_mean{i}) .^ 2);
    %logp_con = -sum((data(j, :) - model.control_mean{i}) .^ 2);
    guess = (logp_exp > logp_con);
    if (guess == isexp(j))
      num_correct = num_correct + 1;
    end

    if (isexp(j))
      if (guess == isexp(j))
        sen_num = sen_num + 1;
      end
      sen_den = sen_den + 1;
    else
      if (guess == isexp(j))
        spec_num = spec_num + 1;
      end
      spec_den = spec_den + 1;
    end
  end
  
  acc(i) = num_correct / N;
  sen(i) = sen_num / sen_den;
  spec(i) = spec_num / spec_den;
  %sen_num
  %sen_den
  %spec_num
  %spec_den
end

end


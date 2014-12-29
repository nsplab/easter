function [ logp ] = logmvnpdf(x, mu, sigma)
k = numel(x);
logp = -k / 2 * log(2 * pi) ...
       -1 / 2 * log(det(sigma)) ...
       -1 / 2 * (x - mu) * inv(sigma) * (x - mu)';
end


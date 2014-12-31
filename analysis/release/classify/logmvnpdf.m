function [ logp ] = logmvnpdf(x, mu, sigma, invsigma, logdetsigma)
k = numel(x);
a = -k / 2 * log(2 * pi);
b = -1 / 2 * logdetsigma;
c = -1 / 2 * (x - mu) * invsigma * (x - mu)';
logp = a + b + c;
end


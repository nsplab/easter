function params=CleanParams(params,freqconv);
% function params=CleanParams(params,freqconv)
%   by Matt Nelson 07-03-20
%
% For use nlinfit with fitsine. Called by AddToSavedTransFxn.
%
if params(1)<0      %ensure a positive amplitude
    params(1)=-params(1);
    params(3)=params(3)+pi;
end
params(2)=params(2)/freqconv;   %convert frequency to Hz
while params(3)<0  params(3)=params(3)+2*pi;    end %These two lines put Ph between 0 and 2*pi
while params(3)>=2*pi  params(3)=params(3)-2*pi;   end

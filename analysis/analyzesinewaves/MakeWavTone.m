function y=MakeWavTone(sigfreq,d,fs,filepath)
% function y=MakeWavTone(sigfreq,d,fs,filepath)
%   by Matt Nelson 07-03-20
% 
% INPUTS
%   sigfreq     =  signal freq in Hz to produce a tone
%   d           = duration (sec)
%   fs          = sample frequency (Hz) for wav file created
%   filepath    = string of path wav file is saved to
%
%   This will generate a .wav file of a pure sine wave at the specified
%   frequency and sampling rate. This is intended for use in empirically 
%   determining the transfer function for a system used in neural
%   recordings if signal generators are not used, for use with
%   AddToSavedTransFxn.m and CorrectData.m.
 
% set general variables
if(nargin<4)|isempty(filepath)    filepath=pwd;   end
if(nargin<3)|isempty(fs)    fs=40000;   end
if(nargin<2)|isempty(d)    d=75;   end
if(nargin<1)|isempty(sigfreq)    sigfreq=0;   end
n = fs * d;  % number of samples
 
writeflag=true;
 
filename=['Tone' num2str(sigfreq) 'Hz' num2str(d) 'sec.wav'];
y=sin(sigfreq*2*pi*(1:n)/fs);    
 
y = .999*y/max(abs(y)); % -1 to 1 normalization
 
%WAVWRITE(Y,FS,NBITS,WAVEFILE)  -it assumes nbits= 16 if you only enter 3
%arguments
 
if writeflag
    disp(['writing file: ' filename ' to path: ' filepath])
    wavwrite(y,fs,[filepath filename]);
end
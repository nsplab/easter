function output = AddToSavedTransFxn(allsigs,f,Fs,filename,filepath)
% function AddToSavedTransFxn(allsigs,f,Fs,filename,filepath)
%   by Matt Nelson 07-03-20
%
% INPUTS
%   allsigs     = 2xN array with the signal recorded with the relevant 
%                 equipment down the first row, and the actual signal down
%                 the second row.
%   f           = Signal Freq (Hz)
%   Fs          = sampling frequency (Hz) for recording system
%   filename    = name of the .mat file in which the relevent empirically 
%                 determined transfer function is saved, with the .mat 
%                 extension typically excluded
%   filepath    = string of path where saved trans fxn is located
%
%   After collecting test data with a sine wave signal of known frequency
%   with a given equipment configuration, this wall save the phase and 
%   magnitude data in the complex variable Hw and the corresponding 
%   frequency of that measurment in HwFreqs In a sorted order based on all
%   the other frequencies already saved. Hw and HwFreqs are stored in the
%   given filename and filepath later for use with CorrectData.m
 
% set general variables
if(nargin<5)|isempty(filepath)    filepath=[pwd '\'];   end  %assumed '\' for Windows
if(nargin<4)|isempty(filename)    filename='DefaultTransFxn';   end
if(nargin<3)|isempty(Fs)    Fs=1000;   end
if(nargin<2)|isempty(f)    f=0;   end
if(nargin<1)|isempty(allsigs)    error('Need to input signals.');   end
 
nsigs=size(allsigs,1);
nsamps=size(allsigs,2);
output = 0; 
%Find amplitude and phase
if f~=0 %Try nlinfit w/ sine wave if frequency is input
    %set params for fitsine
    nfitcycles=50;
    freqconv=2*pi/Fs;   %multiply by this by freq in Hz to get radians per sample, divide by this to go back to Hz
    initF=f*freqconv;
    options=statset;
    options.MaxIter=1000;
    initPh=0;
    ResidFrac=.4;    
    
    nfitsamps=min([round(nfitcycles*2*pi/initF) nsamps]);
    X=(1:nfitsamps);
    for isig=1:nsigs
        initV=rms(allsigs(isig,1:nfitsamps))*2/sqrt(2);   %try to develop a good initial amplitude guess and hopefully help nlinfit converege faster
        [newparams(isig,:),r]=nlinfit(X,allsigs(isig,1:nfitsamps),@fitsine,[initV,initF,initPh,mean(allsigs(isig,1:nfitsamps))],options);
        disp(['finished nlinfitting for sig ' num2str(isig)])
 
        sinefit=rms(r)/rms(allsigs(isig,1:nfitsamps)) <= ResidFrac;        
        if ~sinefit 
            break;   
        else
            newparams(isig,:)=CleanParams(newparams(isig,:),freqconv);
            Amp(isig)=newparams(isig,1);
            Freq(isig)=newparams(isig,2);
            Ph(isig)=newparams(isig,3);
        end
    end
else    sinefit=0;  end     %If the frequency is not input to the function, you have to go with Hilbert estimate
 
if ~sinefit     %Try Hilbert estimate
    output = 1; %if the hilbert was used spit a 1
    disp(['sine fit did not work, getting Hilbert estimate'])
    [Amp,Freq,Ph]=getHilbVals(allsigs(:,1:nfitsamps),Fs,1);
else    disp(['sine fit worked']);   end
 
 
%Assign Hw value and record the frequency in a sorted order
curVal=Amp(1)/Amp(end)*exp(j*(Ph(1)-Ph(end))); %complex valued number
if f==0 curFreq=Freq(2);    else    curFreq=f;  end 
 
if exist([filepath filename '.mat'])==2
    load([filepath filename '.mat'])
    
    if any(HwFreqs==curFreq)    %This will overwrite a previously stored value for the current frequency if it exists
        curind=find(HwFreqs==curFreq);
        Hw(curind)=curVal;        
    else
        [HwFreqs,Inds]=sort([HwFreqs curFreq]);
        tmpHw=[Hw curVal];
        Hw=tmpHw(Inds);
    end
else
    Hw=curVal;
    HwFreqs=curFreq;
end
[filepath filename '.mat']
save([filepath filename '.mat'],'Hw','HwFreqs');
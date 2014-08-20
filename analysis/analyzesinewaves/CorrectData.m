function outdata=CorrectData(rawdata,Fs,filename,filepath,options)
% function outdata=CorrectData(rawdata,Fs,filename,filepath,options)
%   by Matt Nelson 07-03-20
%
% INPUTS
%   rawdata     = vector (or array) of raw signal(s) to be corrected given 
%                 that it was recording with equipment with the relevant 
%                 saved empirically determined transfer function
%   Fs          = sampling frequency (Hz) for recording system
%   filename    = name of the .mat file in which the relevent empirically 
%                 determined transfer function is saved, with the .mat 
%                 extension typically excluded
%   filepath    = string of path where saved trans fxn is located
%   options     = structure of the various options for the correction
%                   i.e. to change the value flatPh to 0 (it's default is 
%                   currently one) input the structure options with a field
%                   of flatPh, and flatPh will be set to whatever value 
%                   that field is. 
%
% OUTPUTS
%   outdata     = The corrected data in the same dimensions as rawdata
%
%   This will correct rawdata that was collected with equipment possessing
%   the transfer function that is saved under the given filename and
%   filepath in the variables Hw and HwFreqs. (see AddToSavedTransFxn.m)
%   This will work either through an inverse filter or a time-reversed 
%   filter applied to the data, with a few options that can be changed.
%
%   Please note that this program is in no way an optimized correction 
%   technique, just something very straightforward that worked well enough 
%   with our data.
%
%   The code assumes that rawdata, and the Hw and HwFreqs saved in the .mat
%   file are saved as row vectors, or with individual signals down each row
%   of rawdata. They are transposed to become so if they are not.
 
 
if(nargin<4)|isempty(filepath)    filepath=[pwd '\'];   end  %assumed '\' for Windows
if(nargin<3)|isempty(filename)    filename='DefaultTransFxn';   end
if(nargin<2)|isempty(Fs)    Fs=1000;   end
if(nargin<1)|isempty(rawdata)    error('Need to input raw data.');   end
 
if exist([filepath filename '.mat'])==2
    load([filepath filename '.mat'])        %This should load Hw and HwFreqs
else    error(['Couldn''t find file: ' filepath filename '.mat']);   end
 
%
if size(rawdata,1)>size(rawdata,2)    
    rawDatTrans=1;
    rawdata=rawdata'; 
else    rawDatTrans=0;      end
if size(Hw,1)>size(Hw,2)    Hw=Hw'; end
if size(HwFreqs,1)>size(HwFreqs,2)    HwFreqs=HwFreqs';   end
 
%%First specify default options
%General options
RevFilt=0;      %set to 1 to re-apply the filter in the reverse time order, which corrects the phase shifts and applies the amplitude effects of the filter a second time
                %set to 0 to apply the inverse filter which will undo both the phase and amplitude effects of the transfer function
                    %Note: but be careful of amplifying noise outside the transfer function cutoffs when doing this, and use magcap when doing this (see below)
usewin=0;       %apply a hann window to the raw data before applying it's fft.
ViewSigFFT=0;   %View the FFT of the raw data
ViewInterpSpec=1;   %View the interpolated spectrum of the saved transfer function, including any adjustments made to it per the options below
 
%Transfer function spectrum adjustment options
magcap=1;       %Will set the magnitude to a minimum value. This is important to do if RevFilt is set to 0.
minmag=.1;      %The minimum magnitude if magcap =1. If RevFilt = 0, you multiply the recorded the signal by the inverse of this
                    %In that case, to resolve sharper and sharper and waveforms (assuming a high cut filter exists) make this lower and lower, but beware of the effect of multiplying high frequency noise that this has
 
%Transfer function spectrum interpolation options
extrap=0;       %set to 1 to extrapolate for frequency points outside of gathered range;
                %set to 0 to set the magnitude equal to zero at the DC and Nyquist freqs, then interpolate from there
 
%%write over any default options given the input structure options
if(nargin>=5) && ~isempty(options) 
    fieldlist=fieldnames(options);
    for ifld=1:length(fieldlist)        
        if length(options.(fieldlist{ifld}))>1
            eval([fieldlist{ifld} '=[' num2str(options.(fieldlist{ifld})) '];']);
        else
            eval([fieldlist{ifld} '=' num2str(options.(fieldlist{ifld})) ';']);
        end
    end
end
 
% Other interpolation options not recommended to be changed
% Feel free to play with these interpolation options, but we found our defaults below to be considerably better
compinterp=0;       %set to 0 to interpolate phase and magnitude separately, set to 1 to interpolate as a complex number
loginterp=0;        %interpolates in log base 10 space
methods={'nearest', ... % - nearest neighbor interpolation
      'linear' ...  %  - linear interpolation
      'spline' ...  %  - piecewise cubic spline interpolation (SPLINE)
      'pchip' ...   %  - shape-preserving piecewise cubic interpolation
      'cubic'};     %  - same as 'pchip'
InterpMnum=4;       %which of the above methods you want to use to interpolate; i.e. 4 refers to pchip
 
%%%determine # of points in FFT
NFFT=length(rawdata);
NumUniquePts = ceil((NFFT+1)/2);
f = (0:NumUniquePts-1)*Fs/NFFT;
 
%%%make transfer fxn cover entire frequency range
tmpY=Hw;
tmpX=HwFreqs;
if ~extrap
    if tmpX(1)>0
        tmpY=[0.00001*exp(j*angle(tmpY(1))) tmpY];          
        tmpX=[0 tmpX];          %try keeeping angle the same as tmpY(1) and make mag 0.001 or something
    end    
    if tmpX(end)<f(end)
        tmpY=[tmpY 0.00001*exp(j*angle(tmpY(end)))];
        tmpX=[tmpX f(end)];
    end
end
 
%%%interpolate transfer fxn
%'extrap' is added whether extrap is 1 or 0, but if it's zero then this won't matter anyway as we won't be outside the limits
if compinterp
    if loginterp    
        Hwi = interp1(log10(tmpX),tmpY,log10(f),methods{InterpMnum},'extrap');
    else
        Hwi = interp1(tmpX,tmpY,f,methods{InterpMnum},'extrap');    
    end
else
    if loginterp
        if tmpX(1)==0   
            tmpX(1)=.001;   
        end
        f(1)=.001;
        tmpm = interp1(log10(tmpX),abs(tmpY),log10(f),methods{InterpMnum},'extrap');    
        
        tmpr = interp1(log10(tmpX),real(tmpY),log10(f),methods{InterpMnum},'extrap');
        tmpi = interp1(log10(tmpX),imag(tmpY),log10(f),methods{InterpMnum},'extrap');
        tmpph=angle(tmpr+tmpi*j);        %This seems to work best if you get the phase from interpolating the real and imag components, and the magnitude from interpolating the magnitude itself
    else
        tmpm = interp1(tmpX,abs(tmpY),f,methods{InterpMnum},'extrap');    
        
        tmpr = interp1(tmpX,real(tmpY),f,methods{InterpMnum},'extrap');
        tmpi = interp1(tmpX,imag(tmpY),f,methods{InterpMnum},'extrap');
        tmpph=angle(tmpr+tmpi*j);        %This seems to work best if you get the phase from interpolating the real and imag components, and the magnitude from interpolating the magnitude itself 
    end
    Hwi=tmpm.*exp(j*tmpph);
end
    
if ViewInterpSpec   
    tmpfilt=Hwi;    
end    %preserve this before adjustments fom magcap or flatPh for plotting spectrum
%%Apply spectrum adjustments
if magcap
    mininds=find(abs(Hwi)<minmag);
    Hwi(mininds)=minmag*exp(j*angle(Hwi(mininds))); %preserve the phase, but change the magnitudes, so we don't incraese the power too much at any frequency, which would lead to amplifiaction of noise                
end
 
if ViewInterpSpec
    PlotSpecRange=[.01,Fs/2]; %Hz
    plotinds=[find(f>=PlotSpecRange(1),1,'first') find(f<=PlotSpecRange(2),1,'last')];
 
    ny='ny';
    figure
    MAx=subplot(211);
    plot(f(plotinds(1):plotinds(2)),abs(tmpfilt(plotinds(1):plotinds(2))));    
        
    if magcap
        hold on
        plot(f(plotinds(1):plotinds(2)),abs(Hwi(plotinds(1):plotinds(2))),'r');
    end
    
    PhAx=subplot(212);
    plot(f(plotinds(1):plotinds(2)),angle(tmpfilt(plotinds(1):plotinds(2)))*180/pi);
      
    set(MAx,'XScale','log');
    set(PhAx,'XScale','log');
    
    axes(MAx)
    title(['Interp. Spec: ' methods{InterpMnum}  '; compinterp: ' ny(compinterp+1) '; loginterp: ' ny(loginterp+1) '; extrap: ' ny(extrap+1)])
end
 
 
%add the second part of the filter spectrum for a symmetric spectrum (from a real filter)
if ~rem(NFFT,2) % Here NFFT is even; therefore,Nyquist point is included.
    FHwi=[Hwi(1) Hwi(2:end-1) Hwi(end) conj(Hwi([length(Hwi)-1:-1:2]))]; %the complex conjugate will negate the phase for all frequencies above the Nyquist
else
    FHwi=[Hwi(1) Hwi(2:end) conj(Hwi([length(Hwi):-1:2]))]; %the complex conjugate will negate the phase for all frequencies above the Nyquist
end
 
%disp('In CorrectData... about to take ffts of rawdata')
nsigs=size(rawdata,1);
if usewin     rawdata=repmat(hann(length(rawdata),'periodic')',nsigs,1)  .* rawdata; end
if ViewSigFFT || ~RevFilt   sigfft=fft(rawdata,[],2);   end
 
if ViewSigFFT    
    f2=(0:NFFT-1)*Fs/NFFT;
    figure
    plot(f2(1:NumUniquePts),abs(sigfft(1:NumUniquePts)))
    title('rec sigfft')
end
 
%%%Apply correction
if RevFilt
    rawdata=fliplr(rawdata);
    outdata=fliplr(real(ifft( fft(rawdata,[],2) .* repmat(FHwi,nsigs,1),[],2 )));    
else
    outdata=real(ifft( sigfft ./ repmat(FHwi,nsigs,1),[],2 ));
end
 
if rawDatTrans      outdata=outdata';   end   
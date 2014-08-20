 function out=sinfunphase(phase, coeffs,X,Y,freq)
 c =  phase;
 a = coeffs(1);
 b = coeffs(2);
 Y_fun = a .* sin(2*pi*freq*X+c)+b;
 %DIFF = Y_fun - Y;
  if c>pi
     penalty = 10;
 else
     penalty = 0;
 end
 DIFF = Y_fun - Y; 
 %SQ_DIFF = abs(DIFF);
 SQ_DIFF = DIFF.^2 ;
 out = sqrt(mean(SQ_DIFF));%rms error
 %out = sum(SQ_DIFF);
 function out=sinfun(coeff,X,Y,freq)
 a = coeff(1);
 b = coeff(2);
 c = coeff(3);
 Y_fun = a .* sin(2*pi*freq*X+c)+b;
 if a<0
     penalty = 1000;
 else
     penalty = 0;
 end
 DIFF = Y_fun - Y; 
 SQ_DIFF = abs(DIFF);
 SQ_DIFF = DIFF.^2;
 out = sum(SQ_DIFF);
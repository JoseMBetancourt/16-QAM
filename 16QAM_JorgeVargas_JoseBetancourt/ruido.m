function [noise_signal] = ruido(signal, varianza_ruido)

   X = signal;
   
   sigma = varianza_ruido; 
   
   Z = sigma*randn(1 , length(X));

   Y = X + Z;
   
   noise_signal = Y;


end

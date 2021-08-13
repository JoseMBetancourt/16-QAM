function [signal_demod] = demodulacion(signal_mod , portadora, sobre_muestreo, num_simbolos)

    Y = signal_mod;
    fc = portadora;
    fs = sobre_muestreo;
    n = num_simbolos;
    
    Ts = 1/fs;
    
    t = 0 : Ts : Ts*(n-1);  
    
    Y_real = sqrt(2)*Y.*cos(2*pi*fc.*t);    
    Y_imag = -sqrt(2)*Y.*sin(2*pi*fc.*t);
    
    y = (Y_real + 1j*Y_imag)';
    
    signal_demod = y;

end

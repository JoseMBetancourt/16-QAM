function [modulada] = modulacion(signal , portadora, sobre_muestreo, num_simbolos)
    
    x = signal;
    fc = portadora;
    fs = sobre_muestreo;
    n = num_simbolos;
    
    Ts = 1/fs;
    
    t = 0 : Ts : Ts*(n-1);    

    X = sqrt(2)*(real(x).*cos(2*pi*fc.*t)-imag(x).*sin(2*pi*fc.*t));
    
    modulada = X;

end

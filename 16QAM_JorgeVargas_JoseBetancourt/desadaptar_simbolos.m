function [simbolos_desadaptados] = desadaptar_simbolos(signal, sobre_muestreo, Transiente)
    
    U = signal;
    fs = sobre_muestreo;
    T = Transiente;
    
    u = downsample(U,fs);    
    u = u(T+1:end-(T+2));
    
    simbolos_desadaptados = u;

end

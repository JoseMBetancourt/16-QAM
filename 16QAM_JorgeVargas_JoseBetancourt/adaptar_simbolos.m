function [simbolos_adaptados] = adaptar_simbolos(simbolos, sobre_muestreo, transiente)

    s = simbolos;
    fs = sobre_muestreo;
    T = transiente;
    
    %Se muestrea la Seceuncia de Simbolos
    s_adap = upsample(s', fs);
    %Se añaden ceros para compensar el transiente del pulso conformador
    s_adap = [s_adap zeros(1, 2*(T + 1)*fs)];
    
    simbolos_adaptados = s_adap;

end


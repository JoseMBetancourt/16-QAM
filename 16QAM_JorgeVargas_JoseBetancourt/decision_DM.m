function [simbolos_estimados] = decision_DM(simbolos_recibidos , constelacion)

    u = simbolos_recibidos;        
    
    s_est = u;
    
    distancias=zeros(1, numel(constelacion));

    for x = 1 : numel(s_est)
       for y = 1 : numel(constelacion)
           distancias(y) = sqrt((((real(s_est(x)))-(real(constelacion(y))))^2)+(((imag(s_est(x)))-(imag(constelacion(y))))^2));                       
       end
       [~,indice] = min(distancias);   
       s_est(x) = constelacion(indice);
    end
    
    simbolos_estimados = s_est;
    

end


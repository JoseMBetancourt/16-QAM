function [simbolos_estimados] = decision_MAP(simbolos_recibidos, constelacion, probabilidades , sigma)
    
    c = constelacion;    
    u = simbolos_recibidos;
    p = probabilidades;
    %g = 0.6527; 
    
    R=zeros(numel(u),1);
    s_est=zeros(numel(u),1);

    for y=1 : numel(u)

        for x=1 : 16  

            R(x) = p(x)*( 1 / ( sigma*sqrt(2*pi) ) ).*exp(( - ( sqrt((((real(u(y)))-(real(c(x))))^2)+(((imag(u(y)))-(imag(c(x))))^2)))^2 )/ (2*(sigma^2)) ) ;

        end

        [~,argR] = max(R);

         s_est(y)= c(argR);
         
    end
      
    simbolos_estimados = s_est;
    
end





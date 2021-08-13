function [distancia_minima] = distancia_minima(constelacion)

c = constelacion;

n = numel(c);
tamano = (n * (n - 1))/2;       %Cantidad de combinaciones posibles
distancias = zeros(tamano,1);
contador=0;

%Se recorren los simbolos de la constelacion calculando la distancia  entra cada uno de ellos
    for x = 1 : numel(c)-1

        for y = x+1 : numel(c)

            distancia = sqrt((((real(c(x)))-(real(c(y))))^2)+(((imag(c(x)))-(imag(c(y))))^2));        
            contador=contador+1;
            distancias(contador) = distancia;
            
        end
        
    end
   
    %Se identifica la menor distancia entre todas
    distancia_minima = min(distancias); 
    
end




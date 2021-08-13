function [s_m_trayecto] = multitrayecto(senial,Lineas)
    
    X=senial;
    desplazamiento_t  = 0; 
    porc_amplitud = 0.9;
    
    for x=1:Lineas
        c_desp  = round(rand*desplazamiento_t*numel(X));
        s_desp = [zeros(1, c_desp) X*(rand*porc_amplitud)];
        s_desp_l = s_desp(1:end-c_desp);
        X = X + s_desp_l;
    end   
    
    s_m_trayecto = X;
    
end
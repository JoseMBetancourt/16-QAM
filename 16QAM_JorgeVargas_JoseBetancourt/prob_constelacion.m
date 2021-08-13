function [probabilidades] = prob_constelacion(constelacion, bits_simbolo, Pr_0, Pr_1)
    
    c = constelacion;
    a = constelacion;
    
    L = bits_simbolo;
    
    c_d = c;
    
    
    c_d(a == c(1))  = 0;
    c_d(a == c(2))  = 1;
    c_d(a == c(3))  = 2;
    c_d(a == c(4))  = 3;

    c_d(a == c(5))  = 4;
    c_d(a == c(6))  = 5;
    c_d(a == c(7))  = 6;
    c_d(a == c(8))  = 7;

    c_d(a == c(9))  = 8;
    c_d(a == c(10)) = 9;
    c_d(a == c(11)) = 10;
    c_d(a == c(12)) = 11;

    c_d(a == c(13)) = 12;
    c_d(a == c(14)) = 13;
    c_d(a == c(15)) = 14;
    c_d(a == c(16)) = 15;

    c_d = real(c_d);
    
    c_o = de2bi(c_d,4,'left-msb');   
    
    for x = 1 : numel(c)
        for y = 1 : L
            
            if(c_o(x,y) == 0)
               c_p(x,y) = Pr_0;
            else
               c_p(x,y) = Pr_1;
            end            
            
        end
    end
    
    p = [];
    for x = 1 : numel(c)
        
        p = [ p ; prod(c_p(x,:))];

    end    
    
    probabilidades = p;    

end


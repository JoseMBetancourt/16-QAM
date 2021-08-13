function [bits] = demapeo(simbolos,constelacion, bits_simbolo)

    s = simbolos;
    L = bits_simbolo;
    c = constelacion;
    
    b_d(s ==  c(1))  = 0;
    b_d(s ==  c(2))  = 1;
    b_d(s ==  c(3))  = 2;
    b_d(s ==  c(4))  = 3;

    b_d(s ==  c(5))  = 4;
    b_d(s ==  c(6))  = 5;
    b_d(s ==  c(7))  = 6;
    b_d(s ==  c(8))  = 7;

    b_d(s ==  c(9))  = 8;
    b_d(s ==  c(10)) = 9;
    b_d(s ==  c(11)) = 10;
    b_d(s ==  c(12)) = 11;

    b_d(s ==  c(13)) = 12;
    b_d(s ==  c(14)) = 13;
    b_d(s ==  c(15)) = 14;
    b_d(s ==  c(16)) = 15;

    b_d = real(b_d);
    
    b_o = de2bi(b_d,L,'left-msb');
    
    b = reshape(b_o', 1, []);
    
    bits = b;

end

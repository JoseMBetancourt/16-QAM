function [bits_completos] = adaptar_bits(bits, multiplo)

    b = bits;
    L = multiplo;

    if mod( numel(b) , L ) ~= 0
        
        div = floor(numel(b) / L);
        b_c = [ b  zeros( 1 , (L*(div+1))-(numel(b)) ) ];
        bits_completos = b_c;
        
    else
        
        bits_completos=b;
        
    end
    
end

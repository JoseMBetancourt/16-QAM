function [simbolos] = mapeo_prop(bits_decimal,constelacion)

    simbolos = bits_decimal;
    
    simbolos(bits_decimal==0)  =  constelacion(1);
    simbolos(bits_decimal==1)  =  constelacion(2);
    simbolos(bits_decimal==2)  =  constelacion(3);
    simbolos(bits_decimal==3)  =  constelacion(4);

    simbolos(bits_decimal==4)  =  constelacion(5);
    simbolos(bits_decimal==5)  =  constelacion(6);
    simbolos(bits_decimal==6)  =  constelacion(7);
    simbolos(bits_decimal==7)  =  constelacion(8);

    simbolos(bits_decimal==8)  =  constelacion(9);
    simbolos(bits_decimal==9)  =  constelacion(10);
    simbolos(bits_decimal==10) =  constelacion(11);
    simbolos(bits_decimal==11) =  constelacion(12);

    simbolos(bits_decimal==12) =  constelacion(13);
    simbolos(bits_decimal==13) =  constelacion(14);
    simbolos(bits_decimal==14) =  constelacion(15);
    simbolos(bits_decimal==15) =  constelacion(16);

end


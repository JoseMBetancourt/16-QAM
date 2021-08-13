clc, clear, close all;
%
% Miembros del Equipo:
% 
% - Jose Miguel Betancourt Chaves
% - Jorge Andrés Vargas Cordoba
% 
% Tareas:                                           Porcentaje
% 
% - QAM Tradicional (Tx y Rx ideales sin canal)         100%
% - QAM Propuesto (Diseño constelación y el Tx)         100%
% - QAM Propuesto (Implementar Rx ideal)                100%
% - Canal (Efecto del Ruido y Multitrayecto)            100% 
% - Probabilidades y MAP                                100%

% =================== Parametros Iniciales Del Sistema ===================% 

M=16;                % Esquema QAM (4,16,64,256)
L=log2(M);           % Numero De Bits Por Simbolo

num_bits = 10000;     % Cantidad De Bits Del Mensaje
Pr_0 = 0.7;          % Probabilidad Ocurrencia Del 0
Pr_1 = 1-Pr_0;       % Probabilidad Ocurrencia Del 1

while true
    opcion = input(' [ 1 ] QAM Estandard\n [ 2 ] QAM Modificado\n\n Ingrese una opcion [1] o [2]:  ');
    if ((~isempty(opcion))&&((opcion==1)||(opcion==2)))
        break
    end
    clc
    warndlg('Ingresar una opcion valida')
end

% Se define la constelacion a Utilizar
switch opcion    
    case 1
        %Contelacion Tradicional
        const = [ -3 + 3j ; -3 + 1j ; -3 - 3j ; -3 - 1j ;  
                  -1 + 3j ; -1 + 1j ; -1 - 3j ; -1 - 1j ; 
                   3 + 3j ;  3 + 1j ;  3 - 3j ;  3 - 1j ;
                   1 + 3j ;  1 + 1j ;  1 - 3j ;  1 - 1j ];        
        
    case 2 
        %Constelacion Propuesta (Forma de Rombo)
        const = [ 0 - 1j ;  1 + 0j ;  0 + 1j ;  1 - 2j ;
                 -1 + 0j ; -1 - 2j ; -1 + 2j ;  0 + 3j ;
                  2 + 1j ;  1 + 2j ;  2 - 1j ;  3 - 0j ;
                 -2 - 1j ;  0 - 3j ; -2 + 1j ; -3 + 0j ];        
end

% ================== Caracteristicas de la constelación ==================%

%Vector de Probabilidades de Simbolo
Pr_s = prob_constelacion(const, L, Pr_0, Pr_1);

%Energía promedio de Simbolo
Es = 0;
for x=1:M
   Es = Es + ( abs(const(x,:) )^2 )*Pr_s(x);
end

%Energía promedio de Bit
Eb = Es / L;

%Entropia 
H = 0;
for x=1:M
   H = H - (Pr_s(x)*log2(Pr_s(x)));
end

%Distancia Minima de la constelación
dmin = distancia_minima(const);

%Ganancia de Codificación de la constelación
Gamma = (dmin^2) / (4*Eb);

% ============================= TRANSMISOR ============================== %

% =========================== FUENTE DE BITS ============================ %

% Se genera un mensaje aleatorio
b = randsrc( 1 , num_bits , [0 1 ; Pr_0 Pr_1] );

% Se agregan zeros al mensaje para que éste sea multiplo de'L'
b = adaptar_bits(b,L);

% =============================== MAPEO ================================= %

% Agrupamos los bits en filas de 'L' columnas
b_o = reshape ( b , L , numel(b)/L )';

% Convertimos cada fila de la matriz en un numero decimal
b_d = bi2de(b_o,'left-msb');

% Se generan los simbolos que representan el mensaje
s = mapeo_prop(b_d,const);

% =============================== FILTRO ================================ %

% Se muestrea la secuencia y añaden ceros para compensar el transiente T
T = 4;
fs = 8;
s_adap = adaptar_simbolos(s,fs,T);

% Diseño del pulso conformador (R: Roll-off T: Transiente)
R = 0.5;
p = rcosdesign(R, T, fs,'sqrt');

% Se filtra la señal
x = filter(p, 1, s_adap);

% ============================ MODULACIÓN =============================== %

n = numel(s_adap);
fc=2;

% Se obtiene la señal a transmitir
X = modulacion(x,fc,fs,n);

% ====================== CANAL AWGN Y MULTITRAYECTO ===================== %

No = (10)*Eb ;
EbNo = Eb/No ;

%Varianza ruido
sigma = sqrt(Es/(2*L*EbNo));

%Numero de trayectos
num_trayec = 10;

% Introducimos el efecto de multitrayecto a la señal
X = multitrayecto(X, num_trayec);

% Introducimos ruido AWGN a la señal
Y = ruido(X, sigma);

% ============================== RECEPTOR =============================== %
% ============================ DEMODULACION ============================= %

V = demodulacion(Y,fc,fs,n);

% =============================== FILTRO ================================ %

U = filter(p,1,V);

% ============================== MUESTREO =============================== %

u = desadaptar_simbolos(U,fs,T);

% ============================== DECISIÓN =============================== %

s_est = decision_DM(u, const);
s_est1 = decision_MAP(u, const, Pr_s, sigma);

% ============================== DE-MAPEO =============================== %

b_est = demapeo(s_est, const, L);
b_est1 = demapeo(s_est1, const, L);

% =========================== FIN DE LA TX ============================== %

% ============================ RESULTADOS =============================== %

fprintf(' \n ======= Resultados ======= \n\n');
switch opcion
    case 1
        fprintf(' Esquema %d: QAM Estandard \n\n', opcion);
    case 2
        fprintf(' Esquema %d: QAM Modificado \n\n', opcion);
end

fprintf(' Numero de bits generados: %d \n', numel(b));
fprintf(' Probabilidad del 0: %.2f \n', Pr_0);
fprintf(' Probabilidad del 1: %.2f \n', Pr_1);
fprintf(' Numero de bits errados MD: %d \n', biterr(b,b_est));
fprintf(' Numero de bits errados MAP: %d \n\n', biterr(b,b_est1));

fprintf(' Energia Prom de Bit: %.4f \n', Eb);
fprintf(' Energia Prom de Simb: %.4f \n', Es);
fprintf(' Distancia Minima: %.4f \n', dmin);
fprintf(' Ganancia de Codificación: %.4f dB\n', 10*log10(Gamma));
fprintf(' Entropia de Constelación: %.4f \n', H);

% ============================== GRAFICAS =============================== %
% ============================= GRAFICAS TX ============================= %

Ts = 1/fs;
t = 0: Ts : Ts*(n-1);

% DESCOMENTAR PARA VISUALIZAR EL PROCESO GRAFICO PASO A PASO

% figure,
% stem(b,'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Mensaje Binario'), axis([0 numel(b) -0.5 1.5]), grid on;
% %subplot(212), histogram(b,2), title('# De bits obtenidos');
% 
% figure, 
% plot(s,'o','MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',6),
% axis([-4 4 -4 4]),
% grid on,
% title('Constelacion Transmitida');
% 
% figure,
% subplot(211), stem(real(s),'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Simbolos Reales'), axis([0 numel(s) -4 4]), grid on;
% subplot(212), stem(imag(s),'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Simbolos Imaginarios'), axis([0 numel(s) -4 4]), grid on;
% 
% figure,
% subplot(211), stem(real(s_adap),'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Simbolos Reales'), axis([0 numel(s_adap) -4 4]), grid on;
% subplot(212), stem(imag(s_adap),'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Simbolos Imaginarios'), axis([0 numel(s_adap) -4 4]), grid on;
% 
% 
% 
% figure,
% subplot(211), plot(real(x),'-r','LineWidth',1), title('Forma De Onda x Real'), grid on;
% subplot(212), plot(imag(x),'-r','LineWidth',1), title('Forma De Onda x Imag'), grid on;
% 
% figure,
% plot(t,X,'-r'),title('Señal Transmitida'), grid on;
% 
% %============================= GRAFICAS RX ============================= %
% 
% figure,
% plot(t,Y,'-g'),title('Señal Recibida'),grid on;
% 
% figure,
% subplot(211), plot(real(V),'-g'), title('Forma De Onda V Real'), grid on;
% subplot(212), plot(imag(V),'-g'), title('Forma De Onda V Imag'), grid on;
% 
% figure,
% subplot(211), plot(real(U),'-g','LineWidth',1), title('Forma De Onda U Real'), grid on;
% subplot(212), plot(imag(U),'-g','LineWidth',1), title('Forma De Onda U Imag'), grid on;
% 
% figure,
% subplot(211), stem(real(u),'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Simbolos Real'), axis([0 numel(u) -4 4]), grid on;
% subplot(212), stem(imag(u),'o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3), title('Simbolos Imag'), axis([0 numel(u) -4 4]), grid on;
% 
% figure, plot(u,'o','MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',6),
% axis([-4 4 -4 4]),
% grid on,
% title('Constelacion Recibida');
% 
% figure, plot(s_est1,'o','MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',6),
% axis([-4 4 -4 4]),
% grid on,
% title('Constelacion Corregida');
% 
% figure, stem(b_est,'o','LineWidth',2,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3),
% axis([0 numel(b_est) -0.5 1.5]),
% grid on,
% title('Mensaje Binario Recibido MD');
% 
% figure, stem(b_est1,'o','LineWidth',2,'MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',3),
% axis([0 numel(b_est1) -0.5 1.5]),
% grid on,
% title('Mensaje Binario Recibido MAP');
% 
% % ============================= Comparacion ML y MAP ============================= %
% 
% txt1={'\fontsize{12}Criterio de MD',['Bits generados: ', num2str(numel(b))],['Bit errados: ', num2str(symerr(b,b_est))]};
% txt2={'\fontsize{12}Criterio de MAP',['Bits generados: ', num2str(numel(b))],['Bit errados: ', num2str(symerr(b,b_est1))]};
% figure,subplot(2,1,2), plot(u,'o','MarkerEdgeColor','black','MarkerFaceColor','blue','MarkerSize',6),axis([-4 4 -4 4]),grid on,title('Constelacion Recibida');
% subplot(2,2,1),text(0,0.5,txt1),set(gca,'visible','off');
% subplot(2,2,2),text(0,0.5,txt2),set(gca,'visible','off');





clc, clear, close all;

% =================== Parametros Iniciales Del Sistema ===================% 

M=16;                % Esquema QAM (4,16,64,256)
L=log2(M);           % Numero De Bits Por Simbolo

num_bits = 20;   % Cantidad De Bits Del Mensaje
Pr_0 = 0.7;          % Probabilidad Ocurrencia Del 0
Pr_1 = 1-Pr_0;       % Probabilidad Ocurrencia Del 1

%opcion = 1; %QAM Tradicional
opcion = 2; %QAM Propuzesto

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

%Iteramos varias veces el código variando EbNodB

EbNodB = 0 : 16 ;
BER = zeros(1, numel(EbNodB));

for i = 1 : 1 : numel(EbNodB)
    
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
X_1 = modulacion(x,fc,fs,n);

% ====================== CANAL AWGN Y MULTITRAYECTO ===================== %

EbNo = 10.^(EbNodB(i)./10);

%Varianza ruido
sigma = sqrt(Es/(2*L*EbNo));

%Numero de trayectos
num_trayec = 1;

% Introducimos el efecto de multitrayecto a la señal
X = multitrayecto(X_1, num_trayec);

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

% ========================== BIT ERROR RATE  ============================ %

BER(i) = biterr(b,b_est)/num_bits;
    
end

% ============================ GRAFICA BER  ============================= %

EbNo = 10.^(EbNodB./10);
BER_TEORICA = (4/log2(M))*qfunc(sqrt(3*EbNo*log2(M)/(M-1)));

semilogy(EbNodB, BER,'bo'),grid on, hold on;
semilogy(EbNodB, BER_TEORICA),grid on, hold on;
legend('BER 16QAM ROMBO','BER 16QAM TEORICA')
xlabel('EbNo[dB]');
ylabel('BER');



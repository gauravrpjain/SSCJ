clear all
clc
%% QPSK MODULATION%%
N = 10^2; % number of symbols
Es_N0_dB = [0:12]; % multiple Eb/N0 values

%% Spreading%%
B=1;
A= [8.344e-08- 9.955e-08i ,0+0i,2.204e-07+8.880e-08i,1.475e-07-7.140e07i,0+0i,1.381e-05+5.856e-06i,0+0i,0+0i,0+0i,0+0i,.775-.422i,3.253e-06+3.335e-05i,.0178-.148i,-.286- .232i,3.415e-06+8.611e-07i,.0059+.053i,-6.37296e-06+2.567e-06i,-.1258+.0254i,.0268-.0053i,3.685e-05+ 1.1206e-05i,0+0i,3.8899e-05-1.806e-05i,0+0i,0+0i,.1494-.1390i,3.196e-06+2.4832e-05i,.000212+.000149i,0+0i,5.2146e-06-1.3411e-05i,-.000147+.0004322i];

code=[1 1 1 1 1 0 0 0 1 1 0 1 1 1 0 1 0 1 0 0 0 0 1 0 0 1 0 1 1 0 0];
code= 2*code-1;
for k=1:length(Es_N0_dB)
ipQPSK1 = ((rand(1,N)>0.5)) + j*((rand(1,N)>0.5)); 
sQPSK1 =(2*ipQPSK1-(1+j))/sqrt(2);
spreadsignal= (sQPSK1/sqrt(31))'*code;

%%adding noise%%
for i= 1:N
     %Y(i,:)= filter( B,A, spreadsignal(i,:));
    noisesignal(i,:)=spreadsignal(i,:)+ (10^(-Es_N0_dB(k)/20))*(1/2)*(randn(1,31) + j*randn(1,31));
end

%%despreading%%
despreadsignal= (noisesignal * code')';
%despreadsignal= (Y * code')';

%%demodulation%%%
deQPSKr = real(despreadsignal)>0;
deQPSKi = imag(despreadsignal)>0;
nErrdeQPSK1(k) = size(find((real(sQPSK1)>0)- deQPSKr),2);
nErrdeQPSK2(k) = size(find((imag(sQPSK1)>0)- deQPSKi),2);
end

nErrdeQPSK= (nErrdeQPSK1/N + nErrdeQPSK2/N);
simSERdeQPSK= nErrdeQPSK/2;
figure(6)
semilogy(Es_N0_dB,simSERdeQPSK,'b');
axis([0 15 10^-5 1.5])
xlabel('Eb/No, dB')
ylabel('Bit Error Rate')
title('Bit error probability curve for QPSK')

%% channel %%




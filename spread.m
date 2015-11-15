clear
clc
G=15;  % Code length
%Generation of first m-sequence using generator polynomial [45]
sd1 =[1 0 1 1];             % Initial state of Shift register
PN1=[];                       % First m-sequence
for j=1:G        
    PN1=[PN1 sd1(1)];
    if sd1(1)==sd1(2)
        temp1=0;
    else temp1=1;
    end
    sd1(1)=sd1(2);
    sd1(2)=sd1(3);
    sd1(3)=sd1(4);
    sd1(4)=temp1;
end
figure(1);
subplot(3,1,1)
stem(PN1)
title('M-sequence');
hold on;
for i=1:1:3
    kd1(i) = PN1(i*5);
end
KD1=[];
for i=1:G
    KD1=[KD1 kd1(1)];
    temp=kd1(1);
    kd1(1)=kd1(2);
    kd1(2)=kd1(3);
    kd1(3)=temp;
end
for i=1:G
    if KD1(i)==PN1(i)
        ks(i)=0;
    else
        ks(i)=1;
    end
end
figure(1);
subplot(3,1,2)
stem(KD1);
subplot(3,1,3)
stem(ks)
title('Kasami-sequence');

SNR = -2:1:12;
data_length = 1e6;
data_inr = 2*(rand(1,data_length/2)>0.5)-1;
data_ini = 2*(rand(1,data_length/2)>0.5)-1;
data_in = data_inr+1i*data_ini;

spread_data = kron(data_in,ks);
k=1;
for SNR =-2:1:12
    SNR_lin = 10^(SNR/10);
    sig_ener = 2;
    noise_pow =sig_ener/SNR_lin;
    noiser =sqrt(noise_pow/2)*randn(1,15*data_length/2);
    noisei =sqrt(noise_pow/2)*randn(1,15*data_length/2);
    noise = noiser+1i*noisei;
    trans_data = noise+spread_data;

load('ch_coeff.mat');

trans_chan = filter(ch_coeff,1,trans_data);
[qpsk_equal,equal_coeff]=MMSE_eq(trans_chan,ch_coeff,noise_pow/2);
            
qpsk_equal=qpsk_equal(1:length(trans_data));



des_data = reshape(qpsk_equal,G,data_length/2);
final_data = ks*des_data;
rec_datar =real(final_data);
rec_datai = imag(final_data);
decoder = 2*(rec_datar>0)-1;
    decodei = 2*(rec_datai>0)-1;
    errr = sum(decoder~=data_inr);
    erri = sum(decodei~=data_ini);
    err = errr+erri;
    prob1(k) = err/(data_length);
    
    
    des_data_ch = reshape(trans_chan,G,data_length/2);
final_data_ch = ks*des_data_ch;
rec_datar_ch =real(final_data_ch);
rec_datai_ch = imag(final_data_ch);
decoder_ch = 2*(rec_datar_ch>0)-1;
    decodei_ch = 2*(rec_datai_ch>0)-1;
    errr = sum(decoder_ch~=data_inr);
    erri = sum(decodei_ch~=data_ini);
    err = errr+erri;
    prob1_ch(k) = err/(data_length);
    
    des_data_awgn = reshape(trans_data,G,data_length/2);
final_data_awgn = ks*des_data_awgn;
rec_datar_awgn =real(final_data_awgn);
rec_datai_awgn = imag(final_data_awgn);
decoder_awgn = 2*(rec_datar_awgn>0)-1;
    decodei_awgn = 2*(rec_datai_awgn>0)-1;
    errr = sum(decoder_awgn~=data_inr);
    erri = sum(decodei_awgn~=data_ini);
    err = errr+erri;
    prob1_awgn(k) = err/(data_length);
    
    k=k+1;
end

no_bits = 1e6;
SNR = -2:1:12;
SNR_lin = 10.^(SNR/10);
in_datar = 2*(rand(1,no_bits/2)>0.5)-1;
in_datai = 2*(rand(1,no_bits/2)>0.5)-1;
in_data = in_datar+1i*in_datai;
Eb = 1;
Es = 2*Eb;
for ii=1:1:length(SNR)
    noise_pow = Es/SNR_lin(ii);
    noiser = sqrt(noise_pow/2)*randn(1,no_bits/2);
    noisei = sqrt(noise_pow/2)*randn(1,no_bits/2);
    rec_datar = in_datar + noiser;
    rec_datai = in_datai + noisei; 
    decoder = 2*(rec_datar>0)-1;
    decodei = 2*(rec_datai>0)-1;
    errr = sum(decoder~=in_datar);
    erri = sum(decodei~=in_datai);
    err = errr+erri;
    prob1_wtspread(ii) = err/(no_bits);
end
SNR = -2:1:12;
figure(2);
semilogy(SNR,prob1);
grid on;  
hold on
semilogy(SNR,prob1_ch,'-mo')
hold on
semilogy(SNR,prob1_wtspread,'-k*')
hold on
semilogy(SNR,prob1_awgn,'-r*')
title('BER vs SNR');
xlabel('Signal to noise ratio');
ylabel('Bit error rate');   
grid on;


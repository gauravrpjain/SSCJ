function [eq_rec_signal,coeff_mmse] = MMSE_eq(rec_data,imp_res,sigma_sq)
% MMSE based equalization
% rec_data---> Received data from channel.
% imp_rec----> Impulse response of the channel
% sigma_sq---> Noise variance

Lc = length(imp_res);%length of impulse response
La = Lc+1;%order of the equalizer
L = La+Lc;
b = [imp_res(1) zeros(1,La)];
a = [imp_res zeros(1,La)];
Clow = toeplitz(a,b);
DEN = ctranspose(Clow)*Clow + sigma_sq*eye(La+1);
req = [zeros(1,(L-1)/2) 1 zeros(1,(L-1)/2)];
NUM = ctranspose(Clow)*req';
coeff_mmse = inv(DEN)*NUM;


eq_sig_mmse = conv(rec_data,coeff_mmse);

ov_all_ch = conv(imp_res,coeff_mmse);
[C,I] = max(ov_all_ch);
eq_sig_mmse = eq_sig_mmse(I:end-1)/C; % To compensate the delay introduced
                                  % by channel and equalizer.


eq_rec_signal = eq_sig_mmse;


%This shows an example of using a maximal length sequence  for system
%identification

m=13;%mls order

%plant properties
wn=1/10;%(rad/sample) natural frequency
zeta=0.05;%damping ratio
dt=1;%sampling rate

b_f=1*[1 2 1];%[z^0 z^-1 z^-2] system numerator
a_f=[4/(wn*dt)^2+4*zeta/(wn*dt)+1 -8/(wn*dt)^2+2   4/(wn*dt)^2-4*zeta/(wn*dt)+1];
%[z^0 z^-1 z^-2] system denominator
   

N=2^m-1;%period of sequence
%feedbacks=[nan hex2dec('3') hex2dec('5') hex2dec('9') hex2dec('12')...
%    hex2dec('21') hex2dec('41') hex2dec('8e') hex2dec('108') hex2dec('204')...
%    hex2dec('402') hex2dec('829') hex2dec('100D') hex2dec('2015')...
%    hex2dec('4001') hex2dec('8016')];
%maximal length lfsr feedback values from http://www.ece.cmu.edu/~koopman/lfsr/index.html
feedbacks=[nan 3 5 9 18 33 65 142 264 516 1026 2089 4109 8213 16385 32790];
%same as above for those without hex2dec


feedback=feedbacks(m);%select appropriate mls feedback

use_mex=false;%set to true if you have lfsr_mex working
if use_mex
    u=lfsr_mex(feedback,1,N,1)*2-1;%generate MLS
else
    u=lfsr(feedback,1,N,1)*2-1;%generate MLS
end

acorr=xcorr_fft(u,u);

figure(1)
plot(0:(N-1),acorr,'.-')
xlabel('lag')
ylabel('Autocorrelation of input')

%notice that the autocorrelation of the input mls sequence has a very large
%(N) peak at zero lag and is very small (-1) at all other values.

N_warmup=1;%run some samples to get the states right

u_tmp=repmat(u,1,1+N_warmup);
y=filter(b_f,a_f,u_tmp);
y(1:(N_warmup*N))=[];%discard warm-up

sigma_noise=.01;%add some Gaussian white noise
y=y+sigma_noise*randn(size(y));

y_imp=xcorr_fft(y,u)/N;%cross correlate input and output to get impulse response

y_imp_theor=impulse(tf(b_f,a_f,dt),0:(N-1))';%calculated impulse response from transfer function



figure(2)
h1=plot(y_imp);
hold on
h2=plot(y_imp_theor,'k');
hold off
xlabel('t (samples)')
ylabel('Impulse Response')
legend([h1 h2],'Measured','Theoretical')

%notice that there is a steady state error between the theoretical response
%and the calculated response due to the -1 autocorrelation at non-zero lags.
%This can be reduced by using a larger m (so larger N).

figure(3)
plot(y_imp-y_imp_theor)
xlabel('t (samples)')
ylabel('Error')

%we can then use this impulse response to get the frequency response. If
%there is undesired echo, you can window the impulse response to eliminate
%the echos to get a pseudo-anechoic response.
Y=fft(y_imp);
f=(0:(N-1))/N;

[Y_theo_mag Y_theo_phase w_theo]=bode(tf(b_f,a_f,dt));


figure(4)
h1=loglog(f(1:((N+1)/2)),abs(Y(1:((N+1)/2))));
hold on
h2=loglog(w_theo/pi/2,squeeze(Y_theo_mag),'k');
hold off
xlabel('f (wrt Nyquist)')
ylabel('Frequency Response')
legend([h1 h2],'Measured: mls','Theoretical')

%It is very important that we use a mls with a length (N) that is longer
%than the system's impulse response. Look what happens if we don't:

m2=8;%mls order
N2=2^m2-1;%period of sequence
feedback2=feedbacks(m2);%select appropriate mls feedback

if use_mex
    u2=lfsr_mex(feedback2,1,N2,1)*2-1;%generate MLS
else
    u2=lfsr(feedback2,1,N2,1)*2-1;%generate MLS
end

N_warmup2=3;%run some samples to get the states right

u_tmp2=repmat(u2,1,1+N_warmup2);
y2=filter(b_f,a_f,u_tmp2);
y2(1:(N_warmup2*N2))=[];%discard warm-up
y2=y2+sigma_noise*randn(size(y2));

y_imp2=xcorr_fft(y2,u2)/N2;%cross correlate input and output to get impulse response

figure(5)
h1=plot(y_imp);
hold on
h2=plot(y_imp2,'g');
h3=plot(y_imp_theor,'k');
hold off
xlabel('t (samples)')
ylabel('Impulse Response')
legend([h1 h2 h3],'Measured m=13','Measured m=8','Theoretical')


%
%Copyright (c) 2009, Travis Wiens
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without 
%modification, are permitted provided that the following conditions are 
%met:
%
%    * Redistributions of source code must retain the above copyright 
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright 
%      notice, this list of conditions and the following disclaimer in 
%      the documentation and/or other materials provided with the distribution
%      
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%POSSIBILITY OF SUCH DAMAGE.
%
% If you would like to request that this software be licensed under a less
% restrictive license (i.e. for commercial closed-source use) please
% contact Travis at travis.mlfx@nutaksas.com

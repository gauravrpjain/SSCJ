function [ K ] = kasami(m, feedback)

use_mex=false;%set to true if you have lfsr_mex working

if nargin<1
    m=16;
end

if mod(m,2)~=0
    error('m must be even')
end

N=2^m-1;%period of sequence

N_calc=2^(m/2);%number of sequences to calculate

%feedbacks=[nan hex2dec('3') hex2dec('5') hex2dec('9') hex2dec('12')...
%    hex2dec('21') hex2dec('41') hex2dec('8e') hex2dec('108') hex2dec('204')...
%    hex2dec('402') hex2dec('829') hex2dec('100D') hex2dec('2015')...
%    hex2dec('4001') hex2dec('8016')];
%maximal length lfsr feedback values from http://www.ece.cmu.edu/~koopman/lfsr/index.html
feedbacks=[nan 3 5 9 18 33 65 142 264 516 1026 2089 4109 8213 16385 32790 ];
%same as above for those without hex2dec

if nargin<2
    feedback=feedbacks(m);%select appropriate mls feedback
    %feedback = hex2dec('80000057');
end

f=1+2^(m/2);%sampler
if use_mex
    a=lfsr_mex(feedback,1,N,1)*2-1;%generate base MLS
    b=lfsr_mex(feedback,1,N,f)*2-1;
else
    a=lfsr(feedback,1,N,1)*2-1;%generate base MLS
    b=lfsr(feedback,1,N,f)*2-1;
end

K=zeros(N_calc,N);%allocate memory

K(1,:)=a;%first sequence is the first mls

for i=0:(N_calc-2)
    K(i+2,:)=xor(a==1,circshift(b,[0 i])==1)*2-1;%kasami sequences
end
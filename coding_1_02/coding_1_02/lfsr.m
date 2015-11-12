function [ y ] = lfsr( feedback, start, N_points, f_decimate )
%[ y ] = lfsr( feedback, start, N_points, f_decimate )
%Generate binary sequence from a 32-bit linear feedback shift register (LFSR).
%Inputs:
% feedback: feedback term (from feedback polynomial) which will be XORed
%   with LFSR. Examples for maximal length sequences can be found at
%   http://www.ece.cmu.edu/~koopman/lfsr/index.html (but note these values
%   must be converted from hex to decimal).
% start: starting value for lfsr state. 1 is usually good
% N_points: number of output points to generate
% f_decimate: resample sequence by this factor. 1 is unchanged, 2 takes
%   every second member, etc. Useful for Kasami sequences.
%Note that the mex file is approx 100 times faster.

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

if nargin<1
    feedback=142;%this would generate an 8-bit maximal length sequence
end
if nargin<2
    start=1;
end
if nargin<3
    N_points=1;
end
if nargin<4
    f_decimate=1;
end

lfsr_state=uint32(start);%get starting value. 
%Note that you may change this and every other uint32 to uint8, uint16 or 
%uint64, depending on your needs
y=zeros(1,N_points);%allocate output

for i=1:N_points
    y(i)=bitand(lfsr_state, uint32(1));%save lsb
    for j=1:f_decimate
        if bitand(lfsr_state, uint32(1))
            lfsr_state=bitxor(bitshift(lfsr_state,-1),uint32(feedback));
        else
            lfsr_state=bitshift(lfsr_state,-1);
        end
    end
end
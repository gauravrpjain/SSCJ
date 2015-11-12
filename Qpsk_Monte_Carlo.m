 E_o=1;
n=1e4;
code = [1 -1 1 1 -1 1 -1 1 1 1 1 -1 -1 -1 1 1] ;
k=1;

for snr=1:1:15 
    N_o(k)=E_o*10.^(-snr/10);
    Rand_message=mod(randi(4),4);
    switch Rand_message
        case 0
            x=-sqrt(E_o/2);
            y=-sqrt(E_o/2);
        case 1
            x=-sqrt(E_o/2);
            y=sqrt(E_o/2);
        case 2
            x=sqrt(E_o/2);
            y=-sqrt(E_o/2);
        case 3
            x=sqrt(E_o/2);
            y=sqrt(E_o/2);
    end

    Error_QPSK=0;
   	
	spread_x = x*code;
	spread_y = y*code;

    for i=1:n
        spread_signal_x = spread_x+(sqrt((N_o(k)/2))*randn());
        spread_signal_y=spread_y+(sqrt((N_o(k)/2))*randn());
        despread_x = spread_signal_x*transpose(code);
        despread_y = spread_signal_y*transpose(code);
	signal_x = (despread_x)/16;
	signal_y = (despread_y)/16;

        if((x>0)&&(signal_x<=0))
            Error_QPSK=Error_QPSK+1;
        elseif((x<0)&&(signal_x>0))
            Error_QPSK=Error_QPSK+1;
        end

        if((y>0)&&(signal_y<=0))
            Error_QPSK=Error_QPSK+1;
        elseif((y<0)&&(signal_y>0))
            Error_QPSK=Error_QPSK+1;
        end
    end
    

    Pe_QPSK(k)=Error_QPSK/(2*n);
    
        
    Error_BPSK=0;
    for i=1:n
        Rand_message=mod(randi(2),2);
        switch Rand_message
            case 0
                x=-sqrt(E_o);
            case 1
                x=sqrt(E_o);
        end
	
	spread_x = x*code;	

        spread_signal_x=spread_x+(sqrt((N_o(k)/2))*randn());
        despread_x = spread_signal_x*transpose(code);
    	signal_x = (despread_x)/16;


	if x>0
            if signal_x<=0
                Error_BPSK=Error_BPSK+1;
            end
        else 
            if signal_x>0
                Error_BPSK=Error_BPSK+1;
            end
        end
    end

    Pe_BPSK(k)=Error_BPSK/(n);
    k=k+1;   
end
t=1:1:15
figure;
semilogy(t,Pe_BPSK,'b',t,Pe_QPSK,'r-+');
grid on;
ylabel('Bit Error Rate');
xlabel('Snr(in db)');
legend('BPSK','QPSK','Location','northeast')






Eb=1;

k=1;
x=sqrt(Eb);
y=sqrt(Eb);

spread_x = x*code;
spread_y = y*code;
for snr=1:1:15 
    N_o_QPSK(k)=10.^(-snr/10);
    Error_QPSK=0;       
    for i=1:n

        spread_signal_x=spread_x+(sqrt(N_o_QPSK(k)/2)*randn());
        spread_signal_y=spread_y+(sqrt(N_o_QPSK(k)/2)*randn());
        
        despread_x = spread_signal_x*transpose(code);
        despread_y = spread_signal_y*transpose(code);
        signal_x = (despread_x)/16;
        signal_y = (despread_y)/16;

    if x>0
            if signal_x<=0
                Error_QPSK=Error_QPSK+1;
            end
        else 
            if signal_x>0
                Error_QPSK=Error_QPSK+1;
            end
        end
        if y>0
            if signal_y<=0
                Error_QPSK=Error_QPSK+1;
            end
        else 
            if signal_y>0
                Error_QPSK=Error_QPSK+1;
            end
        end
    end

    Pe_QPSK(k)=Error_QPSK/(2*n);
    k=k+1;
end


    

k=1;
for snr=1:1:15 
    N_o_BPSK(k)=10.^(-snr/10);
    Error_BPSK=0;
    for i=1:n
        Rand_message=mod(randi(100),2);
        switch Rand_message
            case 0
                x=-sqrt(Eb);
            case 1
                x=sqrt(Eb);
        end
        spread_x =x*code;
        
        spread_signal_x=spread_x+(sqrt((N_o_BPSK(k)/2))*randn());
        despread_x = spread_signal_x*transpose(code);
        
        signal_x = (despread_x)/16;
        
        if x>0
            if signal_x<=0
                Error_BPSK=Error_BPSK+1;
            end
        else 
            if signal_x>0
                Error_BPSK=Error_BPSK+1;
            end
        end
    end

    Pe_BPSK(k)=Error_BPSK/(n);
    k=k+1;   
end
t=1:1:15;
figure;
Pe_BPSK
Pe_QPSK

semilogy(t,Pe_BPSK,'b-',t,Pe_QPSK,'r-+');
grid on;
ylabel('Bit Error Rate');
xlabel('Eb/No(in db)');
legend('BPSK','QPSK','Location','northeast')

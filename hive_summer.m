%In progress
function [yres, yV, yP, yH, yR] = hive_summer(year,a,s,y,resIn,Vin,Pin,Hin,Rin,Xin)

    agemax = a;
    summerdays = s;
    yeardays = y;
    T = year;
    res = resIn;
    P = Pin;
    V = Vin;
    H = Hin;
    R = Rin;
    X = Xin;
    G = zeros(6,agemax);

    G(1,1:3)=1; G(2,4:8)=1; G(3,9:20)=1; G(4,21:32)=1;G(5,33:42)=1;G(6,42:agemax)=1;

          for t=(yeardays*T+1):(yeardays*T+summerdays) %sets the date, goes through all field season days
   
		     X = one_field_day(X,t,agemax);  % call to bees.m function, which outputs new state of hive
              
             %G is 6 x agemax, and X = [V,P,H,R,N]
		     res(1:6,t-yeardays*T)= G*X(5:end); %G*X(5:end); 
 
		     V(1,t-yeardays*T)= X(1);

		     P(1,t-yeardays*T) = X(2);
        
             H(1,t-yeardays*T) = X(3);
             % disp([t,X(3)]);

		     R(1,t-yeardays*T)= X(4);
 
          end %END OF LOOP THROUGH THIS SUMMER
    
	yres = res;
    
    yV = V;
    
    yP = P;
    
    yH = H;
    
    yR = R;
    
    return
    
end

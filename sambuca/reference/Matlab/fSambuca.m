
function calcspec = fSambuca(CHL,CDOM,TR,q,H,UQSubs, filtsum,wav, awater, aphy_star,d_wls,n_wls,filt)

% SIOP (spectral inputs 'awater' and
% 'aphy_star' are also SIOPs), as are the reference wavelengths noted further down...all these would eventually come from the
% LUT/database based on the user selection or geographical location of the
% data
% ***************************************************
X_ph_lambda0x = 0.00157747;
X_tr_lambda0x = 0.0225353;
Sc = 0.0168052;
Str = 0.00977262;
a_tr_lambda0tr = 0.00433;
Y = 0.878138;
lambda0cdom=550.00;
a_cdom_lambda0cdom = 1.0;

PI = pi;

% image acquistion paramters from image/spectra metadata
%********************************************************
theta_air=30; %solar zenith
offnad=10; % off nadir angle

%SUBSTRATES---only two in this case, which avoids the substrate loop. q is
%then just a continious variable as the others to be estimated.
r1=UQSubs(:,1);
r2=UQSubs(:,2);

% Semi analytical Lee/Sambuca forward model
% ************************************************************************

thetaw = (asin(1/1.333*sin(PI/180.00*(theta_air))));
thetao = (asin(1/1.333*sin(PI/180.00*(offnad))));

% The wave lengths hardcoded here (550.00 and 546.00) are reference
% wavelenghts thare are actually part of the user defined SIOP set
for i=1:d_wls
bbwater(i)= ( 0.00194/2.0 ) * ( ( 550.0/wav(i) )^4.32 );
acdom_star(i) = a_cdom_lambda0cdom * (exp(-Sc * (wav(i) - 550.00) ) );
atr_star(i) = a_tr_lambda0tr * (exp(-Str * (wav(i) - 550.00) ) ); 
bbph_star(i) = X_ph_lambda0x * ( (546.00/wav(i))^Y );
bbtr_star(i) = X_tr_lambda0x * ( (546.00/wav(i))^Y );
end

for i=1:d_wls
a(i) = awater(i) +  (CHL * aphy_star(i)) + (CDOM  * acdom_star(i)) + (TR * atr_star(i));
bb(i) =  bbwater(i) + (CHL * bbph_star(i)) + (TR * bbtr_star(i));
end


for i=1:d_wls
r(i) = (q * r1(i)) + ( (1-q) * r2(i) ); % Calculates total bottom reflecatnce from the two substrates and the proportion of q and (1-q)
u(i) = bb(i) / (a(i) + bb(i));
kappa(i) = a(i) + bb(i);
end


for i=1:d_wls
DuColumn(i) = 1.03 * (1.00 + (2.40 * u(i)) )^0.50; 
DuBottom(i) = 1.04 * (1.00 + (5.40 * u(i)) )^0.50;
end

for i=1:d_wls
rrsdp(i) = (0.084 + (0.17 * u(i)) ) * u(i) ;
Kd(i)=   kappa(i) * (1.00     / cos(thetaw)); 
Kuc(i)=  kappa(i) * (DuColumn(i) / cos(thetao));
Kub(i)=  kappa(i) * (DuBottom(i) / cos(thetao));
end

for i=1:d_wls
rrs(i) = rrsdp(i) * (1.00 - exp(-( (1.00/cos(thetaw)) + (DuColumn(i) / cos(thetao)) )* kappa(i) * H)) + ( (1.00/PI) * r(i) * exp(-( (1.00/cos(thetaw)) + (DuBottom(i) / cos(thetao)) )* kappa(i) * H)   );
end

bandsum(1:36)=0;
calc(1:551,1:36) = 0;

%----------------------------------------------------------------------------- 
% This is the application of the Sensor filter, turning the full spectrum
% modelled data into the spectral response (filt) of the sensor (in this
% case 551 1nm bands, to 36 bands). The synthetic sensor data I created for
% my tests is 36 bands each 10nm wide with a constant repsonse over those
% 10nm (see the shape of filt). A real sesnor will have more complex shape,
% but the concept is the same
for j=1:n_wls
	for i=1:d_wls
		calc(i,j) = rrs(i) * filt(i,j);
		bandsum(j) = bandsum(j)+ calc(i,j);
    end
end

% Filtsum is the area under each bands spectral reponse in filt, calculated
% as in my fortran version below and in the McMC matlab code. This whole process of spectral resampling is
% done using a native function in IDL, so I had to work out a way to do it
% here. It may not be the most effective or efficient, and i'm not sure it
% will work if the spectral filter (filt) is not normalised to 1 as it is
% here.
%filtsum(:) = 0
% do j=1,n_wls
% 	do i=1, d_wls
% 		filtsum(j) = filtsum(j)+ filt(i,j)  
% 	enddo
% enddo


for i=1:n_wls
 calcspec(i) = bandsum(i)/filtsum(i);
end
%--------------------------------------------------------------------------------


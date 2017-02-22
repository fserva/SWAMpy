%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a small toy example of the
% Metropolis-Hasting algorithm. A markov chain is
% used to sample using the Sambuca forward model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%clear all
%close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the Bounds For the 5 Shallow water paramters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_min(1)=0.01; %CHL
p_max(1)=0.22;
p_min(2)=0.0005; %CDOM
p_max(2)=0.015;
p_min(3)=0.2; %TR
p_max(3)=2.4;
p_min(4)=0; %Q
p_max(4)=1;
p_min(5)=0; %H
p_max(5)=17.4;

%make it close
% p_min(1)=0.12; %CHL
% p_max(1)=0.18;
% p_min(2)=0.001; %CDOM
% p_max(2)=0.007;
% p_min(3)=0.4; %TR
% p_max(3)=0.9;
% p_min(4)=0; %Q
% p_max(4)=0.5;
% p_min(5)=0; %H
% p_max(5)=17.4;

% Define the data value and noise and number of wls

dat=dataspec; % The input data spectra
sig=0.0005; % Noise per band (could be a spectral NeDR noise)
n_wls=36; % Number of wavelengths in the data
d_wls=551; % The full SAMBUCA spectra number of wavelengths at 1nm

%Prepare filtsum for forward modle based on sensor filter (prapred filter with wl
%tags removed

filtsum(1:n_wls)=0;
for j=1:n_wls
    for i=1:d_wls
        
        filtsum(j)= filtsum(j)+filt(i,j);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define an Random point for the initial model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For conveniance, the model is written
% with the vector p, (i.e. p(1)=x and p(2)=y)

p(1)=p_min(1) + rand *(p_max(1)-p_min(1));
p(2)=p_min(2) + rand *(p_max(2)-p_min(2));
p(3)=p_min(3) + rand *(p_max(3)-p_min(3));
p(4)=p_min(4) + rand *(p_max(4)-p_min(4));
p(5)=p_min(5) + rand *(p_max(5)-p_min(5));

% Call to the forward SAMBUCA model to generate data

model(1:n_wls)=fSambuca(p(1),p(2),p(3),p(4),p(5),UQSubs,filtsum,wav, awater, aphy_star,d_wls,n_wls,filt);


%Compute the likelihood/misfit of this first model
like=0;
for i=1:n_wls
    like = like + ((dat(i)-model(i))^2/(2*(sig^2)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define parameters for the algortihm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pert(1) = 0.01;  % sdt deviation for perturbation on CHL
pert(2) = 0.0002;  % sdt deviation for perturbation on CDOM
pert(3) = 0.03;  % sdt deviation for perturbation on TR
pert(4) = 0.02;  % sdt deviation for perturbation on Q
pert(5) = 0.13;  % sdt deviation for perturbation on H

burn_in = 15000;  % Lenght of the burn-in period
nsamples = 80000; % Total number of samples


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize some variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ARchl=[0,0]; % Number of proposed and accepted models fore for CHL
% ARcdom=[0,0]; % Number of proposed and accepted models fore for CDOM
% ARtr=[0,0]; % Number of proposed and accepted models fore for TR
% ARq=[0,0]; % Number of proposed and accepted models fore for Q
% ARh=[0,0]; % Number of proposed and accepted models fore for H

n=0; %number of post burn-in samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START THE MARKOV CHAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% p is the current point
% pp is the proposed point

for i=1:nsamples
    
    pp=p; % the proposed model equal the curent + a
    model_prop=model;
    %random perturbation
    
    % Randomly choose which parameter to perturb
    u=ceil(rand*5);%u is random number between made to 1 to 5 reflect the parameter
   
     
        pp(u)= p(u)+randn*pert(u); % Gaussian perturbation
        
        
    % compute new proposed model using SAMBUCA forward
   
    model_prop(1:n_wls)=fSambuca(pp(1),pp(2),pp(3),pp(4),pp(5),UQSubs,filtsum,wav, awater, aphy_star,d_wls,n_wls,filt);

        
    
    %Compute the likelihood of this proposed model
    like_prop=0;
    for j=1:n_wls
        like_prop = like_prop + ((dat(j)-model_prop(j))^2/(2*(sig^2)));
    end
    
    
    
    
    % Compute the prior of the proposed model
    % i.e. check if whithin bounds
    % (Note that the prior of the current model p
    % is obviously always within bounds)
    prior=1;
    if ((pp(u)>p_max(u))||(pp(u)<p_min(u)))
        prior=0;
    end
    
    % See if we accept the proposed model pp
    if prior ~= 0
        w=rand; %u is random number between 0 and 1
        if (log(w)<((-like_prop+like))) % if we accept
        
            p=pp;%update model params
            like=like_prop; %update likelihood value
            model=model_prop; %update modelled data
        end
    end
    %Collect models in the chain if bur-in period has passed
    if (i>burn_in)
        n=n+1;
        
        histox(n,1:5)=p(1:5); % For 1D distribution all 5 params

    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Show statistics of the chain every 15000 models
    if(mod(i,2000)==0)
        sample_number=i
        current_model_parameters=p
        current_like=like
%         Acc_Rate_x=100*ARx(2)/ARx(1)
%         Acc_Rate_y=100*ARy(2)/ARy(1)
        
    end
   
end % ends the Markov Chain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% subplot(2,1,1)
% plot(P(:,1),P(:,2),'.','MarkerSize',1);
% Title('Posterior distribution estimated form the algorithm')
% xlabel('x');
% ylabel('y');



%subplot(2,2,3)
hist(histox(:,1),100);
xlabel('probability for CHL value');
figure
hist(histox(:,2),100);
xlabel('probability for CDOM value');
figure
hist(histox(:,3),100);
xlabel('probability for TR value');
figure
hist(histox(:,4),100);
xlabel('probability for Q value');
figure
hist(histox(:,5),100);
xlabel('probability for H value');


% subplot(2,2,4)
% hist(histoy,100)
% xlabel('probability for y value');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS PART ONLY PLOTS THE likelihood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% figure
% 
% x=linspace(-4,4,100);
% y=linspace(-4,4,100);
% 
% [X,Y] = meshgrid(x,y);
% Z=fmodel(X,Y);
% surf(X,Y,Z);
% xlabel('x');
% ylabel('y');
% 
% Title('Posterior distribution')
% shading flat



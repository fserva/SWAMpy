%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test data generation script for the first Python implementation of the
% Sambuca forward model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clear all
% close all

load('Inputs.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the Bounds For the 5 Shallow water paramters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%chl_min=0.01; %CHL
%chl_max=0.22;
%cdom_min=0.0005; %CDOM
%cdom_max=0.015;
%tr_min=0.2; %TR
%tr_max=2.4;
%q_min=0; %Q
%q_max=1;
%h_min=0; %H
%h_max=17.4;

%make it close
chl_min=0.12; %CHL
chl_max=0.18;
cdom_min=0.001; %CDOM
cdom_max=0.007;
tr_min=0.4; %TR
tr_max=0.9;
q_min=0; %Q
q_max=0.5;
h_min=0; %H
h_max=17.4;

% Define the data value and noise and number of wls
n_wls=36; % Number of wavelengths in the data
d_wls=551; % The full SAMBUCA spectra number of wavelengths at 1nm

chl=chl_min + rand *(chl_max-chl_min);
cdom=cdom_min + rand *(cdom_max-cdom_min);
tr=tr_min + rand *(tr_max-tr_min);
q=q_min + rand *(q_max-q_min);
h=h_min + rand *(h_max-h_min);

% Call to the forward SAMBUCA model to generate data
modelled_spectra(1:d_wls)=fSambucaNativeResolution(chl,cdom,tr,q,h,UQSubs,wav, awater, aphy_star,d_wls);

substrate1 = UQSubs(:,1);
substrate2 = UQSubs(:,2);

save 'test.mat' UQSubs wav awater aphy_star d_wls n_wls chl cdom tr q h modelled_spectra substrate1 substrate2;

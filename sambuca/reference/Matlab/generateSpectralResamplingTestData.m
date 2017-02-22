%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test data generation script for spectral resampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

load('Inputs.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the Bounds For the 5 Shallow water paramters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% resample using Steve's code (from fSambuca.m)
bandsum(1:36)=0;
calc(1:551,1:36) = 0;

for j=1:n_wls
	for i=1:d_wls
		calc(i,j) = modelled_spectra(i) * filt(i,j);
		bandsum(j) = bandsum(j)+ calc(i,j);
    end
end

resampled_spectra(1:n_wls)=0;
for i=1:n_wls
    resampled_spectra(i) = bandsum(i)/filtsum(i);
end

save 'test_resample.mat' modelled_spectra resampled_spectra filt filtsum calc bandsum;

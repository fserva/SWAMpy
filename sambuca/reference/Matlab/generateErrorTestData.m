%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test data generation script for error closure tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

load('Inputs.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a modelled spectra
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
observed_spectra = reshape(data(1,2,:),[1,36]);
n_wls=36; % Number of wavelengths in the data
d_wls=551; % The full SAMBUCA spectra number of wavelengths at 1nm
num_bands=n_wls;
% generate some random noise
noiserrs(1:n_wls) = 0;
for i = 1:n_wls
    noiserrs(i) = 0.00045 + rand*(0.0001);
end

chl=chl_min + rand *(chl_max-chl_min);
cdom=cdom_min + rand *(cdom_max-cdom_min);
tr=tr_min + rand *(tr_max-tr_min);
q=q_min + rand *(q_max-q_min);
h=h_min + rand *(h_max-h_min);

% Call to the forward SAMBUCA model to generate data
modelled_spectra_native(1:d_wls)=fSambucaNativeResolution(chl,cdom,tr,q,h,UQSubs,wav, awater, aphy_star,d_wls);

% resample using Steve's code (from fSambuca.m)
bandsum(1:36)=0;
calc(1:551,1:36) = 0;

for j=1:n_wls
	for i=1:d_wls
		calc(i,j) = modelled_spectra_native(i) * filt(i,j);
		bandsum(j) = bandsum(j)+ calc(i,j);
    end
end

modelled_spectra(1:n_wls)=0;
for i=1:n_wls
    modelled_spectra(i) = bandsum(i)/filtsum(i);
end

% OK, I now have observed_spectra and modelled_spectra. So can now evaluate the error functions

% IDL code divides everything by Qwater before calculating the error. I don't have any values for
% Qwater so I am going to assume a scalar value of 1 for now.
%Qwater = 1.0; % ZZ(14)
%realrrs = SAMBUCA.imagespectra.image_spectrum  / Qwater
%noiserrs= SAMBUCA.imagespectra.Noise_spectrum / Qwater ;VB07 to fix after all the checks !
%rrs=SAMBUCA.imagespectra.closed_spectrum / Qwater

%LSQ =   ( (TOTAL (  (double(realrrs) - double(rrs))^2,/double )  ) ^0.5)
LSQ = sum((observed_spectra - modelled_spectra).^2)^0.5;

% toggle noise
use_noise = 1;
if use_noise
    observed_spectra_original = observed_spectra;
    modelled_spectra_original = modelled_spectra;
    modelled_spectra = modelled_spectra./noiserrs;
    observed_spectra = observed_spectra./noiserrs;
end

f_val = sum((observed_spectra - modelled_spectra).^2)^0.5 / sum(observed_spectra);
topline = sum(observed_spectra .* modelled_spectra);
botline1 = (sum(observed_spectra.^2))^0.5;
botline2 = (sum(modelled_spectra.^2))^0.5;

rat = 0;
if botline1 == 0 || botline2 == 0
    rat = 0;
else
    rat = topline / (botline1 * botline2);
end

if rat <= 1
    alpha_val = acos(rat);
else
    alpha_val = 100.0;
end

distance_lsq = LSQ;
distance_alpha = alpha_val;
distance_f = f_val;
distance_alpha_f = f_val * alpha_val;

error_a = alpha_val;
error_f = f_val;
error_af = f_val*(0.00000001+alpha_val);

%output results
if use_noise
    observed_spectra = observed_spectra_original;
    modelled_spectra = modelled_spectra_original;
    save 'test_error_noise.mat' observed_spectra modelled_spectra num_bands noiserrs error_a error_f error_af distance_lsq distance_alpha distance_f distance_alpha_f;
else
    save 'test_error_no_noise.mat' observed_spectra modelled_spectra num_bands noiserrs error_a error_f error_af distance_lsq distance_alpha distance_f distance_alpha_f;
end


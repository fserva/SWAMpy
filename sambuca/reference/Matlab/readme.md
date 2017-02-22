# Stephen's Matlab code readme
I’ve attached the Matlab code we spoke about. It is a very simple implementation, sampling the parameters of interest for one input spectra/pixel using a MCMC approach rather than optimisation. It doesn’t have all the bells and whistles of Sambuca as such, but it does break done a lot of elements of the process quite simply and might be of some use.

SinglePixSpecMCMC.m is the sampling algorithm, calling the forward model fSambuca.m.

Common elements include:

-	Defining exploration ranges for the parameters of interest 
-	Defining proposal scales for a change of parameter in the proposed new model
-	Using the sensor filter (filt) to modify the Sambuca forward model outputs at 1nm to the spectral characteristics of the input data (dat)
-	Calling the Sambuca forward model and comparing the modelled data  to the input data using a simple misfit function
-	Sampling or perturbing the model (in a Bayesian MCMC context, rather than optimisation in this case)

The SIOP inputs to the forward model are a combination of spectral inputs (awater, aphy_star) and values specified at the start of the fSambuca model. This is equivalent to hardcoding these values rather than drawing from a database.

Substrate inputs are the file of two spectra (UQsubs). This simple implementation of the model only has two substrates, so we avoid the extra combinatorial issue of multiple substrate combinations, and can just sample and perturb the proportions (Q) of each. 

A constant noise value (sig) is used for each band in the misfit/error evaluation; in Sambuca proper we would use a spectra with a specific noise value for each band.

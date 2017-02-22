clear all
% load the exact values used by the Python tests
load('forwardModelTestValues.mat')
% warmup
fSambucaNativeResolution(chl,cdom,tr,q,h,UQSubs,wav, awater, aphy_star,d_wls);
fSambucaNativeResolution(chl,cdom,tr,q,h,UQSubs,wav, awater, aphy_star,d_wls);
tic
for i=1:30000,
    % the python test does not assign the returned value to anything, so to be fair
    % we don't assign it here either
    fSambucaNativeResolution(chl,cdom,tr,q,h,UQSubs,wav, awater, aphy_star,d_wls);
end
toc

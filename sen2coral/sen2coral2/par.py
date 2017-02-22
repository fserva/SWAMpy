# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 16:40:29 2017

@author: Marco
"""
from collections import namedtuple
from pkg_resources import resource_filename
from os.path import join
import os.path
import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt
import rasterio
from itertools import combinations
import time
import multiprocessing as mp
import sys
import sambuca as sb
#from sambuca_obs import sam_obs
#from sambuca_par import sam_par




def sam_par():
    if __name__=='sen2coral2.par':
        p_min = sb.FreeParameters(
            chl=0.01,               # Concentration of chlorophyll (algal organic particulates)
            cdom=0.0005,            # Concentration of coloured dissolved organic particulates
            nap=0.2,                # Concentration of non-algal particulates
            depth=0.1,              # Water column depth
            substrate_fraction=0)   # relative proportion of substrate1 and substrate2
        
        
        #p_max = sen.FreeParameters(
        #    chl=0.22, 
        #    cdom=0.015, 
        #    nap=2.4,
        #    depth=17.4,
        #    substrate_fraction=1)
        p_max = sb.FreeParameters(
            chl=0.16, 
            cdom=0.01, 
            nap=1.5,
            depth=7,
            substrate_fraction=1)
        
        #Create some initial parameters, one random and one as the mid point of each parameter range:
             
        pmin = np.array(p_min)
        pmax = np.array(p_max)
        num_params = len(pmin)
        p0_rand = np.random.random(num_params) * (pmax - pmin) + pmin
        p0_mid = (pmax - pmin) / 2
        
        print('p0_rand: ', p0_rand)
        print('p0_mid: ', p0_mid)
        
        
        # repackage p_min and p_max into the tuple of (min,max) pairs expected by our objective function,
        # and by the minimisation methods that support bounds
        p_bounds = tuple(zip(p_min, p_max))
        print('p_bounds', p_bounds)
        return p0_rand, p0_mid, num_params,pmin, pmax, p_bounds
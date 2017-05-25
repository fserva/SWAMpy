# -*- coding: utf-8 -*-
"""
Created on Wed Feb  8 16:29:20 2017

@author: Marco
"""

# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 16:40:29 2017

@author: Marco
"""
#from collections import namedtuple
#from pkg_resources import resource_filename
from os.path import join
#import os.path
import numpy as np
#import numpy.ma as ma
#import matplotlib.pyplot as plt
#import rasterio
#from itertools import combinations
#import time
#import multiprocessing as mp
#import sys
import sambuca as sb
import sambuca_core as sbc
#from sambuca_obs import sam_obs
#from sambuca_par import sam_par




def sam_par(base_path):
    if __name__=='sambuca_input_parameters':
        
        
        
        # Select three substrates to be used from full libraries in input_data/substrates folder
        substrate_path = join(base_path, 'substrates')
#        substrate1_name = 'cnr_lsi:sand'
#        substrate2_name = 'cnr_lsi:coral'
#        substrate3_name = 'cnr_lsi:seagrass'
        substrate1_name = 'hi_3:sand'
        substrate2_name = 'hi_3:Acropora'
        substrate3_name = 'hi_3:Turf Algae'
        #substrate4_name = 'moreton_bay_speclib:brown algae'
        #substrate5_name = 'moreton_bay_speclib:green algae'
        #substrate_names= ( substrate1_name, substrate2_name)
        substrate_names= ( substrate1_name, substrate2_name, substrate3_name)
        #substrate_names= ( substrate1_name, substrate2_name, substrate3_name, substrate4_name)
        #substrate_names= ( substrate1_name, substrate2_name, substrate3_name, substrate4_name, substrate5_name)
        
        aphy_star_path = join(base_path, 'siop/aphy_star_hiop.csv')
        aphy_star_name = 'aphy_star_hiop:aph'
        
        awater_path = join(base_path, 'siop/aw_350_900_lw2002_1nm.csv')
        awater_name = 'aw_350_900_lw2002_1nm:a_water'
        
        all_substrates = sbc.load_all_spectral_libraries(substrate_path)
        substrates = []
        for substrate_name in substrate_names:
            substrates.append(all_substrates[substrate_name])
        # load all filters from the given directory

        
        aphy_star = sbc.load_spectral_library(aphy_star_path)[aphy_star_name]
        awater = sbc.load_spectral_library(awater_path)[awater_name]
        
        
        p_min = sb.FreeParameters(
            chl=0.01,               # Concentration of chlorophyll (algal organic particulates)
            cdom=0.0005,            # Concentration of coloured dissolved organic particulates
            nap=0.2,                # Concentration of non-algal particulates
            depth=0.1,              # Water column depth
            sub1_frac=0,
            sub2_frac=0,
            sub3_frac=0)   
        
        
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
            depth=15,
            sub1_frac=1.3,
            sub2_frac=1.3,
            sub3_frac=1.3) 
       
        
        
        # repackage p_min and p_max into the tuple of (min,max) pairs expected by our objective function,
        # and by the minimisation methods that support bounds
        p_bounds = tuple(zip(p_min, p_max))
        #print('p_bounds', p_bounds)
        
        siop = {'a_water': awater, 'a_ph_star': aphy_star, 'substrates': substrates, 'substrate_names': substrate_names, 'a_cdom_slope': 0.0168052, 'a_nap_slope': 0.00977262, 'bb_ph_slope': 0.878138,
                 'bb_nap_slope': None, 'lambda0cdom': 550.0, 'lambda0nap': 550.0, 'lambda0x': 546.00, 'x_ph_lambda0x': 0.00157747, 'x_nap_lambda0x': 0.0225353, 'a_cdom_lambda0cdom': 1.0,
                  'a_nap_lambda0nap': 0.00433, 'bb_lambda_ref': 550, 'water_refractive_index': 1.33784, 'p_min': p_min, 'p_max': p_max, 'p_bounds': p_bounds}
        #print (siop)
        envmeta = {'theta_air': 60.0, 'off_nadir': 0.0, 'q_factor': np.pi}
        
        
                  
      
        
        return siop, envmeta
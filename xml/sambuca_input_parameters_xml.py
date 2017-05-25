# -*- coding: utf-8 -*-
"""
Created on Mon Feb 20 14:03:32 2017

@author: Marco
"""

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
import xmltodict



def sam_par(xml_path):
    if __name__=='sambuca_input_parameters_xml':
        #we read and parse the .xml file chosen by the user
        xml=open('swampy_s2.xml', 'rb')
        my_dict=xmltodict.parse(xml.read())
        
        
        # now we export the siop and the meta variables from .xml file
        # a0 are the wlens, a1 the spectra of a_water
        a0=my_dict['root']['siop']['a_water']['item'][0]['item']
        a1=my_dict['root']['siop']['a_water']['item'][1]['item']
        #we map the strings into float
        a0m=np.array(list(map(float, a0)))
        a1m=np.array(list(map(float, a1)))
        #we create the tuple
        awater=tuple([a0m, a1m])
        
        #same steps for aphy_star
        ap0=my_dict['root']['siop']['a_ph_star']['item'][0]['item']
        ap1=my_dict['root']['siop']['a_ph_star']['item'][1]['item']
        ap0m=np.array(list(map(float, ap0)))
        ap1m=np.array(list(map(float, ap1)))
        aphy_star=tuple([ap0m, ap1m])
        
        #same steps for the first subtrate
        sw1=my_dict['root']['siop']['substrates']['item'][0]['item'][0]['item']
        ss1=my_dict['root']['siop']['substrates']['item'][0]['item'][1]['item']
        sw1m=np.array(list(map(float, sw1)))
        ss1m=np.array(list(map(float, ss1)))
        sub_1=tuple([sw1m,ss1m])
        #same steps for the second subtrate
        sw2=my_dict['root']['siop']['substrates']['item'][1]['item'][0]['item']
        ss2=my_dict['root']['siop']['substrates']['item'][1]['item'][1]['item']
        sw2m=np.array(list(map(float, sw2)))
        ss2m=np.array(list(map(float, ss2)))
        sub_2=tuple([sw2m,ss2m])
        #same steps for the third subtrate
        sw3=my_dict['root']['siop']['substrates']['item'][2]['item'][0]['item']
        ss3=my_dict['root']['siop']['substrates']['item'][2]['item'][1]['item']
        sw3m=np.array(list(map(float, sw3)))
        ss3m=np.array(list(map(float, ss3)))
        sub_3=tuple([sw3m,ss3m])
        #we create a list with the three substrates
        substrates=[sub_1, sub_2, sub_3]
        #we create the lists with the parameters values
        p_min_list=list(map(float,my_dict['root']['siop']['p_min']['item']))
        p_max_list=list(map(float,my_dict['root']['siop']['p_max']['item']))
        
        # the values of the free_parameters are taken for the lists created from the .xml file
        p_min = sb.FreeParameters(
            chl=p_min_list[0],               # Concentration of chlorophyll (algal organic particulates)
            cdom=p_min_list[1],            # Concentration of coloured dissolved organic particulates
            nap=p_min_list[2],                # Concentration of non-algal particulates
            depth=p_min_list[3],              # Water column depth
            sub1_frac=p_min_list[4],
            sub2_frac=p_min_list[5],
            sub3_frac=p_min_list[6])   
        
        

        p_max = sb.FreeParameters(
            chl=p_max_list[0], 
            cdom=p_max_list[1], 
            nap=p_max_list[2],
            depth=p_max_list[3],
            sub1_frac=p_max_list[4],
            sub2_frac=p_max_list[5],
            sub3_frac=p_max_list[6]) 
       
        #we initialize bb_nap_slope
        bb_nap_slope=None
        #if in the .xml bb_nap_slop is not None, we allocate the value in the variable
        if type(my_dict['root']['siop']['bb_nap_slope'])==str:
            bb_nap_slope=float(my_dict['root']['siop']['bb_nap_slope'])
        
        # repackage p_min and p_max into the tuple of (min,max) pairs expected by our objective function,
        # and by the minimisation methods that support bounds
        p_bounds = tuple(zip(p_min, p_max))
        #we allocate the constant values from the .xml files
        siop = {'a_water': awater, 'a_ph_star': aphy_star, 'substrates': substrates, 'substrate_names': my_dict['root']['siop']['substrate_names']['item'], 'a_cdom_slope': float(my_dict['root']['siop']['a_cdom_slope']),\
                'a_nap_slope': float(my_dict['root']['siop']['a_nap_slope']),\
                'bb_ph_slope': float(my_dict['root']['siop']['bb_ph_slope']),\
                'bb_nap_slope': bb_nap_slope,\
                'lambda0cdom': float(my_dict['root']['siop']['lambda0cdom']),\
                'lambda0nap': float(my_dict['root']['siop']['lambda0nap']),\
                'lambda0x': float(my_dict['root']['siop']['lambda0x']),\
                'x_ph_lambda0x': float(my_dict['root']['siop']['x_ph_lambda0x']),\
                'x_nap_lambda0x': float(my_dict['root']['siop']['x_nap_lambda0x']),\
                'a_cdom_lambda0cdom': float(my_dict['root']['siop']['a_cdom_lambda0cdom']),\
                'a_nap_lambda0nap': float(my_dict['root']['siop']['a_nap_lambda0nap']),\
                'bb_lambda_ref': float(my_dict['root']['siop']['bb_lambda_ref']),\
                'water_refractive_index': float(my_dict['root']['siop']['water_refractive_index']),\
                'p_min': p_min, 'p_max': p_max, 'p_bounds': p_bounds}
        #we allocate the constant values from the .xml files
        envmeta = {'theta_air': float(my_dict['root']['envmeta']['theta_air']),\
                   'off_nadir': float(my_dict['root']['envmeta']['off_nadir']), 'q_factor': np.pi}
        
        
                  
      
        
        return siop, envmeta
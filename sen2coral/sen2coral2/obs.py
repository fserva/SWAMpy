# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 16:40:19 2017

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
import rasterio
import sambuca as sb
import sambuca_core as sbc

def sam_obs():
    if __name__=='sen2coral2.obs':
        print (os.path.isfile('bioopti_data\\..\\sambuca\\reference\\wl_alos_data\\inputs\\WL_ALOS_R_0_sub120.img'))
        
        
        base_path = 'bioopti_data\\'
        
        observed_rrs_base_path = base_path + '..\\sambuca\\reference\\wl_alos_data\\inputs\\'
        observed_rrs_raster_path = join(observed_rrs_base_path, 'WL_ALOS_R_0_sub120.img')
        
        sensor_filter_path = join(base_path, 'sensor_filters')
        sensor_filter_name = 'ALOS'
        
        substrate_path = join(base_path, 'Substrates')
        substrate1_name = 'moreton_bay_speclib:white Sand'
        substrate2_name = 'moreton_bay_speclib:brown Mud'
        substrate3_name = 'moreton_bay_speclib:Syringodium isoetifolium'
        substrate4_name = 'moreton_bay_speclib:brown algae'
        substrate5_name = 'moreton_bay_speclib:green algae'
        #substrate_names= ( substrate1_name, substrate2_name)
        #substrate_names= ( substrate1_name, substrate2_name, substrate3_name)
        #substrate_names= ( substrate1_name, substrate2_name, substrate3_name, substrate4_name)
        substrate_names= ( substrate1_name, substrate2_name, substrate3_name, substrate4_name, substrate5_name)
        
        aphy_star_path = join(base_path, 'SIOP/WL08_aphy_1nm.hdr')
        aphy_star_name = 'wl08_aphy_1nm:WL08_aphy_star_mean_correct.csv:C2'
        
        awater_path = join(base_path, 'SIOP/aw_350_900_lw2002_1nm.csv')
        awater_name = 'aw_350_900_lw2002_1nm:a_water'
        
        nedr_path = join(observed_rrs_base_path, 'WL_ALOS_NEDR_0_4bands.hdr')
        
        sensor_filter_path = join(base_path, 'sensor_filters')
        sensor_filter_name = 'ALOS'
        observed_rrs_width = 0
        observed_rrs_height = 0
        observed_rrs = None
        
        with rasterio.drivers():
            with rasterio.open(observed_rrs_raster_path) as src:
                print('Observed rrs file: ', observed_rrs_raster_path)
                print('Width, height: ', src.width, src.height)
                print('crs: ', src.crs)
                print('affine: ', src.affine)
                print('num bands: ', src.count)
                print('band indicies: ', src.indexes)
                
                observed_rrs_width = src.width
                observed_rrs_height = src.height
                observed_rrs = src.read()
                
        all_substrates = sbc.load_all_spectral_libraries(substrate_path)
        substrates = []
        for substrate_name in substrate_names:
            substrates.append(all_substrates[substrate_name])
        # load all filters from the given directory
        sensor_filters = sbc.load_sensor_filters(sensor_filter_path)
        
        # We don't need to do this, but it lets us see the name of all loaded filters
        sensor_filters.keys()
        
        
        # retrieve the specified filter
        sensor_filter = sensor_filters[sensor_filter_name]
        
        
        #Plot the sensor filter:
        #plot_items.clear()  #Python 3.3 and later only
        aphy_star = sbc.load_spectral_library(aphy_star_path)[aphy_star_name]
        awater = sbc.load_spectral_library(awater_path)[awater_name]
        nedr = sbc.load_spectral_library(nedr_path, validate=False)['wl_alos_nedr_0_4bands:33']
        nedr
        
        wavelengths = sbc.spectra_find_common_wavelengths(awater, aphy_star, *substrates)
        print('Common wavelength range: {0} - {1}'.format(min(wavelengths), max(wavelengths)))
        
        #Use the common wavelengths to mask the inputs:
        awater = sbc.spectra_apply_wavelength_mask(awater, wavelengths)
        aphy_star = sbc.spectra_apply_wavelength_mask(aphy_star, wavelengths)
        for i, substrate in enumerate(substrates):
            substrates[i] = sbc.spectra_apply_wavelength_mask(substrate, wavelengths)
            
        print('awater: min: {0}  max: {1}'.format(min(awater[0]), max(awater[0])))
        print('aphy_star: min: {0}  max: {1}'.format(min(aphy_star[0]), max(aphy_star[0])))
        for substrate_name, substrate in zip(substrate_names, substrates):
            print('{0}: min: {1}  max: {2}'.format(substrate_name, min(substrate[0]), max(substrate[0])))
        
        
        """Truncate the sensor filter to match the common wavelength range
        It remains to be seen whether this is the best approach, but it works for this demo. An alternative approach would be to truncate the entire band for any band that falls outside the common wavelength range.
        If this approach, or something based on it, is valid, then this should be moved into a sambuca_core function with appropriate unit tests."""
        
        filter_mask = (sensor_filter[0] >= wavelengths.min()) & (sensor_filter[0] <= wavelengths.max())
        sensor_filter = sensor_filter[0][filter_mask], sensor_filter[1][:,filter_mask]
        xstart = 0
        xend = 10
        xspan = xend - xstart
        ystart = 0
        yend = 120
        print ('CIAO ', xstart)
        num_pixels = xspan * (yend - ystart)
        assert xend <= observed_rrs_width
        assert yend <= observed_rrs_height
        fixed_parameters = sb.create_fixed_parameter_set(
                wavelengths=wavelengths,
                a_water=awater,
                a_ph_star=aphy_star,
                substrates=substrates,
                )
        result_recorder = sb.ArrayResultWriter(
            observed_rrs_width,
            observed_rrs_height,
            sensor_filter,  
            nedr,
            fixed_parameters)
        objective = sb.SciPyObjective(sensor_filter, fixed_parameters, error_function=sb.distance_f, nedr=nedr)
         
        return wavelengths, observed_rrs, observed_rrs_width, observed_rrs_height, awater,  aphy_star, substrates, nedr, sensor_filter, xstart, xend, ystart, yend, num_pixels, fixed_parameters, result_recorder, objective
    
    

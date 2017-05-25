# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 16:40:19 2017

@author: Marco
"""

from os.path import join
import os.path
import rasterio
import sambuca as sb
import sambuca_core as sbc
#import nibabel as nib
#import snappy
import numpy as np
def sam_obs(base_path, Rrs = False):
    if __name__=='sambuca_input_rrs':
        #print (os.path.isfile('bioopti_data\\..\\sambuca\\reference\\wl_alos_data\\inputs\\WL_ALOS_R_0_sub120.img'))
        
        
        #base_path = 'C:\\Users\\PCUSER\\sambuca_project\\input_data\\'
        
        observed_rrs_base_path = base_path + 'image\\'
        observed_rrs_raster_path = join(observed_rrs_base_path, 'TorresLS8Sub_3bands.img')
        observed_rrs_filename='TorresLS8Sub_3bands.img'
        sensor_filter_path = join(base_path, 'sensor_filters')
        sensor_filter_name = 'LS8BGR'
        #nedr_path = join(base_path + 'nedr\\', 'ls8n.csv')
        nedr_path = join(base_path + 'nedr\\', 'ls8noise3B.hdr')
       # nedr_path = join(base_path, 'nedr/s2testc5.csv')
       
        
        
      
        observed_rrs_width = 0
        observed_rrs_height = 0
        observed_rrs = None
        
        with rasterio.Env():
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
                
                crs=src.crs
                affine=src.affine
                count=src.count
                indexes=src.indexes
        
        sensor_filters = sbc.load_sensor_filters(sensor_filter_path)
        # retrieve the specified filter
        sensor_filter = sensor_filters[sensor_filter_name]
        
        #SPECIFY NEDR values e.g lib:bandname or for csv file:columheader
        nedr = sbc.load_spectral_library(nedr_path, validate=False)['ls8noise3b:25']
        #nedr = sbc.load_spectral_library(nedr_path, validate=False)['s2testc5:rrs']
        
       
         
        # Select subset of Bands e.g. 5 S2 bands
        print(observed_rrs.shape)
        #observed_rrs = observed_rrs[0:3,:,:]
        print(observed_rrs.shape)
        
        #***************************************************************
        
        
        # If Above surface remote sensing reflectance (Rrs) tag is true, convert to 
        # below surface (rrs) after Lee et al. (1999)
        
        if Rrs == True:
            observed_rrs = (2*observed_rrs)/((3*observed_rrs)+1)

        #print(observed_rrs[:,20,30])
        #print(nedr)
        
        
        
        image_info={'observed_rrs_width':observed_rrs_width, 'observed_rrs_height':observed_rrs_height, 'crs':crs,
                    'affine':affine, 'count':count, 'indexes':indexes, 'nedr': nedr, 'sensor_filter':sensor_filter,
                    'base_path': base_path, 'observed_rrs_filename':observed_rrs_filename}
        
        
        
        return observed_rrs, image_info 
        #return observed_rrs, observed_rrs_width, observed_rrs_height,  nedr, sensor_filter, xstart, xend, ystart, yend, num_pixels, base_path, observed_rrs_filename
        


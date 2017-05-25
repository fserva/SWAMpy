# -*- coding: utf-8 -*-
"""
Created on Mon Feb 20 14:03:02 2017

@author: Marco
"""

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
import xmltodict

def sam_obs(rrs_path, xml_path, Rrs = False):
    if __name__=='sambuca_input_rrs_xml':
        #we read and parse the .xml file chosen by the user
        xml=open('swampy_s2.xml', 'rb')
        my_dict=xmltodict.parse(xml.read())
        #we take the filename from the path chosen by the user
        observed_rrs_filename=rrs_path.split('\\')[len(rrs_path.split('\\'))-1]


        
        
        
      
        observed_rrs_width = 0
        observed_rrs_height = 0
        observed_rrs = None
        
        with rasterio.Env():
            with rasterio.open(rrs_path) as src:
                print('Observed rrs file: ', rrs_path)
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
 
        
        
        # Select subset of Bands e.g. 5 S2 bands
        observed_rrs = observed_rrs[0:5,:,:]
        print(observed_rrs.shape)
        
        #we read the nedr from .xml file
        #in the nedrw we have the central wavelenghts and in the nedrs the values of the nedr
        nedrw=my_dict['root']['image_info']['nedr']['item'][0]['item']
        nedrs=my_dict['root']['image_info']['nedr']['item'][1]['item']
        #we map strings into float
        nedrw_m=np.array(list(map(float, nedrw)))
        nedrs_m=np.array(list(map(float, nedrs)))
        #we create the tuple for nedr
        nedr=tuple([nedrw_m, nedrs_m])
        #nw is the nunmber of central wavelenghts
        nw=len(nedrw)

        
        #in sfw we have the wlens of the sesnsor filters
        sfw=my_dict['root']['image_info']['sensor_filter']['item'][0]['item']
        #in sf_dict we have the spectra of the filters
        sf_dict=my_dict['root']['image_info']['sensor_filter']['item'][1]['item']
        sf=[] #intialize the list for the sensor spectra
        #we append to this list the spectra, mapping strings into float
        for i in range(nw):
            sf.append(np.array(list(map(float,sf_dict[i]['item']))))
        sfs=np.array(sf) #the array with the filters spectra
            
        sfwm=np.array(list(map(float, sfw)))
        sfs=np.array(sf)
        #we create the tuple for the sensor filter
        sensor_filter=tuple([sfwm, sfs])
        

        #***************************************************************
        
        
        # If Above surface remote sensing reflectance (Rrs) tag is true, convert to 
        # below surface (rrs) after Lee et al. (1999)
        
        if Rrs == True:
            observed_rrs = (2*observed_rrs)/((3*observed_rrs)+1)

        print(observed_rrs[:,20,30])
        #print(nedr)
        
        
        image_info={'observed_rrs_width':observed_rrs_width, 'observed_rrs_height':observed_rrs_height, 'crs':crs,
                    'affine':affine, 'count':count, 'indexes':indexes, 'nedr': nedr, 'sensor_filter':sensor_filter,
                    'observed_rrs_filename':observed_rrs_filename}
        
        
        
        return observed_rrs, image_info 
        #return observed_rrs, observed_rrs_width, observed_rrs_height,  nedr, sensor_filter, xstart, xend, ystart, yend, num_pixels, base_path, observed_rrs_filename
        


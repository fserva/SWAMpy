# -*- coding: utf-8 -*-
"""
Created on Mon Feb 20 14:02:16 2017

@author: Marco
"""

import numpy as np
import sys

#import Marcos script modules and set up path to these

sys.path.append('C:\\Progetti\\sambuca_project\\sen2coral')

import sambuca_input_rrs_xml
import sambuca_input_parameters_xml
import sambuca_preparation
import sambuca_calculations
import sambuca_outputs
import define_outputs
import create_xml


# set some controls on numpy formatting
# 5 decimal places, suppress scientific notation
np.set_printoptions(precision=5, suppress=True)
import sambuca as sb
import sambuca_core as sbc
# Main statement needed if exporting to .py script. 
if __name__=='__main__':
        rrs_path = input('rrs path: ')
        xml_path= input('xml path: ' )
        [observed_rrs, image_info]=sambuca_input_rrs_xml.sam_obs(rrs_path, xml_path, Rrs = True)
        [siop, envmeta]=sambuca_input_parameters_xml.sam_par(xml_path)
        [wavelengths, siop, image_info, fixed_parameters, result_recorder, objective]=sambuca_preparation.sam_prep(siop, envmeta, 
                                                                                                           image_info)
        #create_xml.create_xml(siop, envmeta, image_info)
        [result_recorder, coordinates, num_pixels]=sambuca_calculations.sam_com(observed_rrs, objective, siop,
                                                                        result_recorder, image_info, shallow = True)
        define_outputs.output_suite(result_recorder, image_info, coordinates)
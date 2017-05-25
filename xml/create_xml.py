# -*- coding: utf-8 -*-
"""
Created on Mon Feb 20 12:43:30 2017

@author: Marco
"""

import xmltodict
import dicttoxml

def create_xml(siop, envmeta, image_info):
    swampy_dict={'siop': siop, 'envmeta':envmeta, 'image_info': image_info}
    out_file = open("swampy_s2.xml","wb")
    my_xml=dicttoxml.dicttoxml(swampy_dict ,  attr_type=False )
    out_file.write(my_xml)
    out_file.close()
        
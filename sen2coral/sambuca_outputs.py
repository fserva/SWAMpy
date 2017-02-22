# -*- coding: utf-8 -*-
"""
Created on Fri Feb  3 10:39:37 2017

@author: Marco/Paul Ryan/Steve Sagar
"""
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma
from itertools import combinations
import os
import rasterio

def writeout(file, data, affine, crs, dtype=None, transpose=None, fill=None):
    """
    Write out single or multi-band raster data as a GeoTiff file.
    Masked arrays automatically get a fill value applied to masked areas.
    
    Attributes:
        file(str): name of file to write data out to
        data(ndarray or MaskedArray): data to write out to file should be dimensioned
            [x,y] or [n,x,y], or optionally if not in this order use transpose (see below)
        affine(affine): transformation mapping from the pixel space to the geographic space
        crs(dict): Coordinate reference system
        dtype(type, optional): type to convert to
        transpose(list, optional): the new order of the axes of the input data
        fill(number, optional): value to fill the masked areas of masked arrays
    """
    
    # fill the masked areas with a value to signify no data
    if type(data) is ma.core.MaskedArray:
        if fill is None:
            fill = -999
        data = ma.filled(data,fill)
    elif type(data) is np.ndarray:
        fill = None

    # transpose the data if needed
    if transpose != None:
        data = np.transpose(data,transpose)    
    
    # if data only has two dimensions add a third for the dummy band
    if data.ndim == 2:
        data = np.expand_dims(data,0)
        
    # set the number of bands
    count = data.shape[0]
    
    # set x,y dimensions
    x = data.shape[2]
    y = data.shape[1]
    
    # set data type
    if dtype == None:
        dtype = type(data[0,0,0])
    else:
        data = data.astype(dtype=dtype)

    if fill == None:
        with rasterio.open(file,'w',driver='GTiff',width=x,height=y,count=count,dtype=dtype,transform=affine,crs=crs) as dst:
            dst.write(data)
    else:
        if np.isfinite(fill):
            with rasterio.open(file,'w',driver='GTiff',width=x,height=y,count=count,dtype=dtype,transform=affine,crs=crs,nodata=fill) as dst:
                dst.write(data)
        else:
            with rasterio.open(file,'w',driver='GTiff',width=x,height=y,count=count,dtype=dtype,transform=affine,crs=crs) as dst:
                dst.write(data)

def sam_out(result_recorder, xstart, xend, ystart, yend, substrate_names, substrates, objective, observed_rrs, observed_rrs_filename):
    [xstart,xend,ystart,yend]=coordinate
    
    [xs, xe, ys, ye]=[str(xstart), str(xend), str(ystart), str(yend)]
    lenst=len(observed_rrs_filename)
    observed_rrs_filename_s=observed_rrs_filename[0:lenst-4]
    if os.path.isdir('C:\Progetti\sambuca_project\Figures\\'+observed_rrs_filename_s+'_'+xs+xe+'_'+ys+ye)==True:
        img_path='C:\Progetti\sambuca_project\Figures\\'+observed_rrs_filename_s+'_'+xs+xe+'_'+ys+ye
        print (os.path.isdir('C:\Progetti\sambuca_project\Figures\\'+observed_rrs_filename_s+'_'+xs+xe+'_'+ys+ye))
    else:
        os.mkdir('C:\Progetti\sambuca_project\Figures\\'+observed_rrs_filename_s+'_'+xs+xe+'_'+ys+ye)
        print (xs,xe)
        img_path='C:\Progetti\sambuca_project\Figures\\'+observed_rrs_filename_s+'_'+xs+xe+'_'+ys+ye
        print (os.path.isdir('C:\Progetti\sambuca_project\Figures\\'+observed_rrs_filename_s+'_'+xs+xe+'_'+ys+ye))
        
 
    skip_mask = (result_recorder.success < 1)
    chl = ma.masked_array(result_recorder.chl,mask=skip_mask)
    
    
    cdom = ma.masked_array(result_recorder.cdom,mask=skip_mask)

    
    nap = ma.masked_array(result_recorder.nap,mask=skip_mask)

    depth = ma.masked_array(result_recorder.depth,mask=skip_mask)

    
    substrate_fraction = ma.masked_array(result_recorder.substrate_fraction,mask=skip_mask)

    
    nit = ma.masked_array(result_recorder.nit,mask=skip_mask)
    plt.imshow(nit[xstart:xend,ystart:yend]);
    plt.title('number of iterations')
    img = plt.colorbar()
    plt.savefig(img_path+"\\nit.png")
    plt.close()
    
    
    
    u, inv = np.unique(result_recorder.nit[xstart:xend,ystart:yend], return_inverse=True)
    n = np.bincount(inv)
    print("bins: ",u)
    print("count: ",n)
    
    
    
    img = plt.hist(result_recorder.nit[xstart:xend,ystart:yend].flatten(), bins=256, fc='k', ec='k')
    plt.title('number of iterations histogram')
    plt.savefig(img_path+"\\hist.png")
    
    img = plt.hist(result_recorder.nit[xstart:xend,ystart:yend].flatten(), bins=256, fc='k', ec='k', range=[-10,60])
    plt.show()
    plt.close()
    
    plt.imshow(result_recorder.success[xstart:xend,ystart:yend]);
    img = plt.colorbar()
    plt.title('succesfull iterations')
    plt.savefig(img_path+"\\success.png")
    plt.close()
    

    u, inv = np.unique(result_recorder.success, return_inverse=True)
    n = np.bincount(inv)
    print("bins: ",u)
    print("count: ",n)
    
    plt.imshow(chl[xstart:xend,ystart:yend]);
    img = plt.colorbar(label='mg/m3')
    plt.title('Chl concentration')
    plt.savefig(img_path+"\\chl.png")
    plt.close()
    
    plt.imshow(cdom[xstart:xend,ystart:yend]);
    img = plt.colorbar()
    plt.title('CDOM concentration')
    plt.savefig(img_path+"\\cdom.png")
    plt.close()
    
    plt.imshow(nap[xstart:xend,ystart:yend]);
    img = plt.colorbar()
    plt.title('NAP concentration')
    plt.savefig(img_path+"\\nap.png")
    plt.close()
    
    plt.imshow(depth[xstart:xend,ystart:yend], interpolation='nearest');
    img = plt.colorbar()
    plt.title('depth')
    plt.savefig(img_path+"\\depth.png")
    plt.close()
    
    plt.imshow(substrate_fraction[xstart:xend,ystart:yend]);
    img = plt.colorbar()
    plt.title('substrate fraction')
    plt.savefig(img_path+"\\sub_frac.png")
    plt.close()
    
    plt.imshow(result_recorder.substrate_pair[xstart:xend,ystart:yend]);
    img = plt.colorbar()
    plt.title('substrate pair')
    plt.savefig(img_path+"\\sub_pair.png")
    plt.close()
    
    for i,substrate_pair in enumerate(combinations(substrate_names,2)):
        print('Index={0}, substrate pair={1}'.format(i,substrate_pair))
        
    substrate_combo=0
    subsused2=np.array(objective._fixed_parameters.substrate_combinations[substrate_combo])
    masked_substrate_fraction = ma.masked_array(substrate_fraction[xstart:xend,ystart:yend],mask=(result_recorder.substrate_pair[xstart:xend,ystart:yend]!=substrate_combo))
    plt.imshow(masked_substrate_fraction)
    img = plt.colorbar()
    title_obj=plt.title('Substrate 1={0}, Substrate 2={1}'.format(substrate_names[subsused2[0]],substrate_names[subsused2[1]]))
    plt.savefig(img_path+"\\mask_sub_frac.png")
    plt.close()
    
    error_f = ma.masked_array(result_recorder.error_f,mask=skip_mask)
    plt.imshow(error_f[xstart:xend,ystart:yend], interpolation='nearest');
    img = plt.colorbar()
    plt.title('error f')
    plt.savefig(img_path+"\\errof.png")
    plt.close()
    
    plt.imshow(result_recorder.closed_rrs[xstart:xend,ystart:yend,0]);
    img = plt.colorbar()
    plt.title('closed rrs 0')
    plt.savefig(img_path+"\\closed0.png")
    plt.close()
    
    plt.imshow(result_recorder.closed_rrs[xstart:xend,ystart:yend,1]);
    img = plt.colorbar()
    plt.title('closed rrs 1')
    plt.savefig(img_path+"\\closed1.png")
    plt.close()
    
    plt.imshow(result_recorder.closed_rrs[xstart:xend,ystart:yend,2]);
    img = plt.colorbar()
    plt.title('closed rrs 2')
    plt.savefig(img_path+"\\closed2.png")
    plt.close()
    
    plt.imshow(result_recorder.closed_rrs[xstart:xend,ystart:yend,3]);
    img = plt.colorbar()
    plt.title('closed rrs 3')
    plt.savefig(img_path+"\\closed3.png")
    plt.close()
    
    rgbimg=np.zeros((120,120,3), 'uint8')
    rgbimg[..., 0] = (result_recorder.closed_rrs[:,:,2])*1024
    rgbimg[..., 1] = (result_recorder.closed_rrs[:,:,1])*1024
    rgbimg[..., 2] = (result_recorder.closed_rrs[:,:,0])*1024
    rgbobs=np.zeros((120,120,3), 'uint8')
    rgbobs[..., 0] = (observed_rrs[2,:,:])*1024
    rgbobs[..., 1] = (observed_rrs[1,:,:])*1024
    rgbobs[..., 2] = (observed_rrs[0,:,:])*1024
    
    img = plt.imshow(rgbimg[xstart:xend,ystart:yend,:])
    plt.title('rgbimg')
    plt.savefig(img_path+"\\rgbimg.png")
    plt.close()
    
    img = plt.imshow(rgbobs[xstart:xend,ystart:yend,:])
    plt.title('rgbobs')
    plt.savefig(img_path+"\\rgbobs.png")
    plt.close()
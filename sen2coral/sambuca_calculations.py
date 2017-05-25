# -*- coding: utf-8 -*-
"""
Created on Wed Feb  1 11:44:45 2017

@author: Marco
"""
import sambuca as sb

import time
import multiprocessing as mp
import numpy as np




def sam_com( observed_rrs, objective, siop, result_recorder, image_info, shallow = False):
    #pool = mp.Pool(processes=10)
    pool = None #for serial processing of substrates
    n = 0
    skip_count = 0
    
    #Define a region to process in the image input
    
    #*****Observed data is in band, row(height, x), column(width, y)******
    xstart =0
    xend = image_info['observed_rrs_height']
    xspan = xend - xstart
    ystart = 0
    yend = image_info['observed_rrs_width']
    coordinates=[xstart, xend, ystart, yend]
    num_pixels = xspan * (yend - ystart)
    assert xend <= image_info['observed_rrs_height']
    assert yend <= image_info['observed_rrs_width']
    
    
    # set current starting points as the midpoints of the parameters   
    #p0 = (np.array(siop['p_max'])+np.array(siop['p_min']))/2
    p0 = np.array(siop['p_min'])+((np.array(siop['p_max'])+np.array(siop['p_min']))/4)
    t0 = time.time()
    
    # set some relaxed abundance constraints (RASC) after Petit et. al.(2017)******
    
    low_relax = 0.7
    high_relax = 1.3
    
    cons=({'type':'ineq','fun':lambda x:high_relax -(x[4]+x[5]+x[6])},
          {'type':'ineq','fun':lambda x:(x[4]+x[5]+x[6])- low_relax})
    
    #******************************************************************************
    # Return to sum to one constraint
    
    #cons=({'type':'eq','fun':lambda x:1-(x[4]+x[5]+x[6])})
    
    #******************************************************************************
    
    for x in range(xstart, xend):
        for y in range(ystart, yend):
            print ([x,y])
            obs_rrs = observed_rrs[:,x,y]
            
            # Quick and dirty check because we are not masking out the no-data pixels
            if not np.allclose(obs_rrs, 0):
                
                # we need to set the observed rrs for this pixel into the objective, as there is no
                # direct way to get the scipy.minimise function to do it (although there are other ways
                # such as using a closure)
    
                #print("sono qui")
                result = sb.minimize(
                            objective,
                            p0,
                            method='SLSQP',
                            bounds=siop['p_bounds'],
                            constraints=cons,
                            options={'disp':False, 'maxiter':5000},
                            obs_rrs=obs_rrs)
                   
                #%time result = minimize(objective, p0, method='SLSQP', bounds=p_bounds, options={'disp':False, 'maxiter':500})
    
                # todo: check if the minimiser converged!
                
                # we need to repack the parameter tuple used by scipy.minimize into the sambuca.FreeParameter tuple
                # expected by the pixel result handlers. As the p0 tuple was generated from a FreeParameter tuple in the 
                # first place, we know that the order of the values match, so we can simply unpack the result tuple into 
                # the FreeParameters constructor.
                #print(result.nit,result.success,*result['x'])
                result_recorder(x, y, obs_rrs, parameters=sb.FreeParameters(*result.x), nit=result.nit, success=result.success)
                #result_recorder(x, y, obs_rrs, parameters=sb.FreeParameters(*result['x']))
                
                # ******GO SHALLOW*****retrieves shallow as possible while SDI remains below 1
                if shallow == True:
                    #parameters=sb.FreeParameters(*result.x)
                    while result_recorder.sdi[x,y] < 1:
                        result.x[3] = result.x[3] - 0.2
                        result_recorder(x, y, obs_rrs, parameters=sb.FreeParameters(*result.x), nit=result.nit, success=result.success)
                        
                        
            else:
                skip_count += 1
                #skip_count_widget.value = 'Pixels skipped (bad input spectra): {0}'.format(skip_count)
            
            # update the progress bar
            n += 1
            #text_widget.value = 'x: {0}  y: {1}  n: {2}'.format(x, y, n)
            #percentage_widget.value = 'Percentage complete: {0}%'.format(int(100*n/(num_pixels)))
            #progress_bar.value = n
    if pool != None:
        pool.close()
    
    t1 = time.time()
    print("Total execution time: {0:.1f} seconds".format(t1-t0))
    print("Average time per pixel: {0:.3f} seconds".format((t1-t0)/n))
    return result_recorder, coordinates, num_pixels
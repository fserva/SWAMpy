;---------------------
@SAMBUCA_2009
pro query_envi_generic, fname=fname, input_info=input_info
;
; query ENVI for all the needed info,
; and store them in the image_info structure

 ;envi_select,title="select input file",fid=fid, /no_dims,/no_spec
; get all the fids
       fids = envi_get_file_ids()

       ;print, fids
       fid=-1L
        if (fids[0] ne -1) then begin
         for i = 0, n_elements(fids) - 1 do begin
          envi_file_query, fids[i], fname = fid_fname
          if fid_fname eq  fname  then   fid= fids[i]
         endfor
       endif
       ;print, fid
        if fid le 0 then envi_open_file, fname,r_fid=fid

       envi_file_query, fid, fname=fname, file_type=file_type

       case  file_type of
       ; 0: ENVI standard image, 4: ENVI library
         0 : query_envi_image, fname=fname, image_info=input_info
         4 : query_envi_library, fname=fname,lib_info=input_info
         else: begin
         result=widget_message("MUST BE ENVI Standard image or SPECTRAL LIBRARY", /error)
         return
         end
       endcase


end
pro query_envi_image, fname=fname, image_info=image_info
;
; query ENVI for all the needed info,
; and store them in the image_info structure

 ;envi_select,title="select input file",fid=fid, /no_dims,/no_spec
; get all the fids
       fids = envi_get_file_ids()
       ;print, fids
       fid=-1L
        if (fids[0] ne -1) then begin
         for i = 0, n_elements(fids) - 1 do begin
          envi_file_query, fids[i], fname = fid_fname
          if fid_fname eq  fname  then   fid= fids[i]
         endfor
       endif
       ;print, fid
        if fid le 0 then envi_open_file, fname,r_fid=fid

      class_names=""
        envi_file_query, fid,ns=ns, nl=nl, nb=nb, wl=wl, $
                  fwhm=fwhm, bnames=bnames,data_type=data_type ,$
                  descrip=descrip, fname=fname, interleave=interleave,$
                  spec_names=spec_names,file_type=file_type,$
                  num_classes=num_classes,  class_names=class_names, $
                  lookup=lookup

       dims=[0,0,ns-1,0,nl-1]
       pos=uindgen(nb)

       inherit_spatial = envi_set_inheritance(fid, dims, pos, /spatial)

        tile_id = envi_init_tile(fid, pos, num_tiles=num_tiles, $
           interleave= interleave)

        image_info={fid: fid, nl:nl, ns:ns, nb:nb,$
                  wl:wl, fwhm:fwhm, bnames:bnames, data_type:data_type,$
                  descrip:descrip,fname:fname, interleave:interleave,$
                  pos:pos, dims:dims,$
                  inherit_spatial:inherit_spatial,$
                  in_memory:0b,$
                  num_classes:num_classes,  class_names:class_names, $
                  lookup:lookup,$
                  num_tiles:num_tiles, $
                  file_type:file_type,$
                  tile_id:tile_id  }

end
pro restore_envi_library, fname=fname, lib=lib
; select the envi image,
; query ENVI for all the needed info,
; and store them in the image_info structure
;
; get all the fids
       fids = envi_get_file_ids()
       ;print, fids
       fid=-1L
        if (fids[0] ne -1) then begin
         for i = 0, n_elements(fids) - 1 do begin
          envi_file_query, fids[i], fname = fid_fname
          if fid_fname eq  fname  then   fid= fids[i]
         endfor
       endif
       ;print, fid
        if fid le 0 then envi_open_file, fname,r_fid=fid


      ; envi_select,title="select input file",fid=my_fid,pos=pos,dims=dims ;, /no_dims,/no_spec


        envi_file_query, fid,ns=ns, nl=nl, nb=nb, wl=wl, $
                  fwhm=fwhm, bnames=bnames,data_type=data_type ,$
                  descrip=descrip, fname=fname, interleave=interleave,$
                  spec_names=spec_names,file_type=file_type

         pos=uintarr(nb) & dims= [-1,0,ns-1,0,nl-1]
        if file_type ne 4 then begin
          result=widget_message("MUST BE SPECTRAL LIBRARY", /error)
         return
         end

       tile=envi_get_data(fid=fid, pos=pos, dims=dims)
       spectra=float(transpose(tile))


        lib={fid: fid, nl:nl, ns:ns, nb:nb,$
                 spectra:spectra,spec_names:spec_names,$
                  wl:wl, fwhm:fwhm, bnames:bnames, data_type:data_type,$
                  descrip:descrip,fname:fname, interleave:interleave,$
                  pos:pos, dims:dims  }

end
pro query_envi_library, fname=fname, lib_info=lib_info
; select the envi image,
; query ENVI for all the needed info,
; and store them in the image_info structure
;
; get all the fids
       fids = envi_get_file_ids()
       ;print, fids
       fid=-1L
        if (fids[0] ne -1) then begin
         for i = 0, n_elements(fids) - 1 do begin
          envi_file_query, fids[i], fname = fid_fname
          if fid_fname eq  fname  then   fid= fids[i]
         endfor
       endif
       ;print, fid
        if fid le 0 then envi_open_file, fname,r_fid=fid

        if fid le 0 then begin
          result=widget_message("file not found", /error)
         return
         end
        envi_file_query, fid,ns=ns, nl=nl, nb=nb, wl=wl, $
                  fwhm=fwhm, bnames=bnames,data_type=data_type ,$
                  descrip=descrip, fname=fname, interleave=interleave,$
                  spec_names=spec_names,file_type=file_type

         pos=uintarr(nb) & dims= [-1,0,ns-1,0,nl-1]
        if file_type ne 4 then begin
          result=widget_message("MUST BE SPECTRAL LIBRARY", /error)
         return
         end


        lib_info={fid: fid, nl:nl, ns:ns, nb:nb,$
                 spec_names:spec_names,$
                  wl:wl, fwhm:fwhm, bnames:bnames, data_type:data_type,$
                  descrip:descrip,fname:fname, interleave:interleave,$
                  file_type:file_type,$
                  pos:pos, dims:dims  }

end
function machine_name
    if !version.os_family eq 'Windows' then begin
       spawn,"set",dos_set
       for i=0, n_elements(dos_set) -1 do begin
       aaa= strsplit(dos_set[i],'=',/extract)
       if  aaa[0] eq "COMPUTERNAME" then $
         return,aaa[1]
       endfor
    endif

return, "unix"
end
;********************************************
pro SAMBUCA_2009_name_state, pstate=pstate

;help,*pstate,/struc
;help,(*pstate).files,/struc

;print_debug=(*pstate).flag.print_debug


aphy_star_name=(*pstate).flag_str.aphy_name
;=============================

Hmax=(*pstate).values.H_max
deltaz=(*pstate).values.delta_z

;=============================
rundeep_str = (*pstate).flag.rundeep?  "OD" : "OS"
H_str= (*pstate).flag.get_z ? "HZ" +string(deltaz,format='(i0)') : "H"+string(Hmax,format='(i0)')
filt_str = (*pstate).flag.run_1nm ? "F1nm" : "F"+(*pstate).flag_str.sensor_name
noise_str = (*pstate).flag.use_noise ? "Non" :"Noff"
go_shallow_str = (*pstate).flag.go_shallow ? "SHon" : "SHoff"
TR_str=  (*pstate).flag.run_TR ? "TRonly" : ""


conc_name =(*pstate).flag_str.conc_name
libname=(*pstate).flag_str.sublib
ERROR_TYPE= (*pstate).flag_str.error_type

(*pstate).runname=strjoin(["",filt_str,H_str,ERROR_TYPE,noise_str,libname,conc_name,TR_str,rundeep_str,go_shallow_str],"_")

widget_control, (*pstate).bases.wstatus, set_value=(*pstate).runname

end
;-
pro SAMBUCA_2009_save_state, pstate=pstate
    SAMBUCA_2009_name_state, pstate=pstate
    state= *pstate
    save, state, filename=(*pstate).files.home_path+"RUN_database"+path_sep()+(*pstate).runname+".sav",/compress
end
;-
function SAMBUCA_2009_pre, pstate=pstate

;Simulates subsurface Lu/ED spectra by running the SAMBUCA model FORward while varying input parameters,
; (such as water optical propterties, bottom substrate mixtures and depth) and adding random 1%
; reflectance (R(0-)) noise. SAMBUCA is then run bacKWARDs in order to test retrieveal
; of the input parameters. The calculations are all performed with spectra interpolated to one nanometers,
; altough the final evaluation of the spectral fit is done after applying a given sensor's response function
; to the modelled spectra.

common SAMBUCA_share, SAMBUCA
common graph_flags, do_graph1
;===========================
if KEYWORD_SET(pstate) then  begin
help,*pstate,/struc
endif else begin
return, -1
endelse
;=============================
;restore flags form the state
rundeep=(*pstate).flag.rundeep
go_shallow=(*pstate).flag.go_shallow
run_TR=(*pstate).flag.run_TR
get_z=(*pstate).flag.get_z
print_debug=(*pstate).flag.print_debug
do_graph1=(*pstate).flag.do_graph1
;
;=============================
; build the runname and save the state
SAMBUCA_2009_save_state, pstate=pstate


;=============================


;select path_input according to OS and machinename


                    home_path=(*pstate).files.home_path
                    path_input=home_path


;=============================

conc_name =(*pstate).flag_str.conc_name
restore,home_path+"Input_siops"+path_sep()+"SAMBUCA_SIOP_"+conc_name+".sav"

inputspectra_fname=home_path+"Input_spectra"+path_sep()+"SAMBUCA_inputspectra_350_900_1nm.lib"
aphy_star_name="aphy_star_"+(*pstate).flag_str.aphy_name
;this parameter file has to match the bandset of the imagery

restore_envi_library, fname=inputspectra_fname, lib=inputspectra

; move these variable into the common
bands = inputspectra.wl
awater = inputspectra.spectra[0,*]
;find index for aphy_star
i_aphy= where (inputspectra.spec_names eq aphy_star_name)
 if total (i_aphy) ne -1  then $
    aphy_star=inputspectra.spectra[i_aphy,*] $
 else begin $
    print, aphy_star_name + "not found in "+ inputspectra_fname
    return, -1
 endelse

;;quickfix for aphystar for MB
;restore, filename=path_input+"samba_params_MB_RC_CASI.dat";
;a01 = samba_params.(2)(0,*)         ;empirical coefficients for water abs parameterisation
;wav1 = samba_params.(1)(0,*)        ;wavelength intervals
;aphy_star= INTERPOL( a01, wav1, inputspectra.wl )




input_params={theta_air:(*pstate).values.theta_air,lambda0cdom:input_siop.lambda0cdom,$
              lambda0tr:input_siop.lambda0tr,lambda0x:input_siop.lambda0x}

;;VB07
;sensor_name=(*pstate).flag_str.sensor_name
;
;
;filter_fname="Sensor_Filters\SAMBUCA_FILTER_"+sensor_name+"_350_900_1nm.lib"
;restore_envi_library, fname=home_path+filter_fname, lib=filter
;
;nm_filter_function = transpose(filter.spectra)
;sum_filter=total(nm_filter_function,1)
;for i= 0,n_elements(sum_filter)-1 do $
; if sum_filter[i] ne 0 then   nm_filter_function[*,i]=nm_filter_function[*,i]/sum_filter[i]
;
;
;ERROR_TYPE= (*pstate).flag_str.error_type
;run_1nm=(*pstate).flag.run_1nm
;use_noise=(*pstate).flag.use_noise
;
;;vb07
;print, sensor_name
;case sensor_name of
;    "QB":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:2],$ ; quickfix qb only 3 bands:
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;
;     "CASI":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:27],$ ; quickfix CASI 28 bands
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;     "Hymap06":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:22],$ ; quickfix hymap 23 bands
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;     "ALOS":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:2],$ ; quickfix ALOS only 3 bands:
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;
;     ;"Hyp"
;    ;"MERIS"
;    else: distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function,$
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;
;    endcase
;    help, distances,/struc


;=============================================
;OPENING INPUT /SUBSTRATE SPECTRA


;this parameter file has to match the bandset of the imagery
libname=(*pstate).flag_str.sublib


idx=where(STRMATCH( (*pstate).flag_str.lib_codes, (*pstate).flag_str.sublib) eq 1)

subs_fname=home_path+"Substrate_library"+path_sep()+(*pstate).flag_str.lib_names[idx]+".lib"
;       Case libname of
;       "s12" : subs_fname=path_input+"ACWS__12spectra_HYP_490_740.lib"
;       "s12_noZ" : subs_fname=path_input+"ACWS__12spectra_noZostera_HYP_490_740.lib"
;       "clean" : subs_fname=path_input+"CS_clean_HYP_490_740.lib";
;       "epi" : subs_fname=path_input+"CS_epi_HYP_490_740.lib"
;       "PosSand" : subs_fname=path_input+"CS_PosSand_HYP_490_740.lib"
;       "PosSands" : subs_fname=path_input+"CS_PosSands_HYP_490_740.lib"
;       "mb_s10" : subs_fname=path_input+"MB_10subs_CASI04.lib"
;       "mb_s11" : subs_fname=path_input+"MB_11subs_CASI04.lib"
;       "mb_SM": subs_fname=path_input+"MB_SAND+MUDsubs_CASI04.lib"
;       "mb_SM1nm": subs_fname=path_input+"MB_SAND+MUDsubs_1nm.lib"
;        "UQ02":subs_fname=path_input+"Substrate_library\UQ02_massive_sand.lib"
;        "LC_s5":subs_fname=path_input+"Substrate_library\Lake_Conj_subst5.lib"
;        "LC_s6":subs_fname=path_input+"Substrate_library\Lake_Conj_subst6.lib"
;        else: return, -1
;       endcase


restore_envi_library, fname=subs_fname, lib=all_subs


n_spectra = all_subs.nl
;print, n_spectra
spectra_names=all_subs.spec_names
n_wavs_subslib = all_subs.ns

Zrange_fname=home_path+"Substrate_library"+path_sep()+(*pstate).flag_str.lib_names[idx]+$
         "DEPTH_RANGE.csv"

if file_test(Zrange_fname) then begin

template={ VERSION:1., DATASTART:0, DELIMITER :44, MISSINGVALUE:!VALUES.F_NAN  , $
   COMMENTSYMBOL:'#',  FIELDCOUNT:5,    FIELDTYPES :[4L,4L,7L,7L,7L],$
   FIELDNAMES :["zmin","zmax","spectra_name","data_source","species"],$
   FIELDLOCATIONS:[0L,2L,4L,30L,39L],$
   FIELDGROUPS:[0L,1L,2L,3L,4L]}

data=READ_ASCII(Zrange_fname , COMMENT_SYMBOL='#',DELIMITER=',',template=Template)
if n_elements(data.zmin) ne n_spectra then begin
        result=widget_message("MUST BE SPECTRAL LIBRARY", /error)
       return, -1
endif
       subs_Z=fltarr(2,n_spectra) ; substrate depth range
       Subs_Z[0,*]=data.zmin
       Subs_Z[1,*]=data.zmax

endif else begin
       subs_Z=fltarr(2,n_spectra) ; substrate depth range
       Subs_Z[0,*]=0.  ; all
       Subs_Z[1,*]=(*pstate).values.H_max ; all
endelse




subs_Z=subs_z - (*pstate).values.tidal_offset


;=================================
;DEFINING PARAMETERS

if rundeep then begin


;   SET OF FIXED PARAMETERS:
;----------------------------
Fin = [ 'none',  $
       ;    'CHL',              $
     ;'CDOM',           $
     ;  'TR'   ,    $
        'Str', $
          'X_ph_lambda0x',   $
        'X_tr_lambda0x',  $
        'Sc', $
       'a_tr_lambda0tr' ,$
          'q1',  $
           'Y' , $
         'q2',  $
          'q3',  $
         'H',  $
          'Q'   ]


;SET OF PARAMETERS TO BE INVERTED:
;--------------------------------
Zin= [   'CHL' ,  $
       ;  'Str', $
        'CDOM', $
        'TR']
       ;    'Y' , $
        ;  'q1' ,$ ; ]
       ;  'q2',  $
       ;   'q3',  $
         ; 'H'  ] ;,$
         ; 'Q' ,  $
      ;  'X_ph_lambda0x',    $
       ;'X_tr_lambda0x',    $
      ; 'Sc' ,$
      ; 'a_tr_lambda0tr' ]

endif else begin


;   SET OF FIXED PARAMETERS:
;----------------------------
Fin = [ 'none',  $
       ;    'CHL',              $
     ;'CDOM',           $
     ;  'TR'   ,    $
        'Str', $
          'X_ph_lambda0x',   $
        'X_tr_lambda0x',  $
        'Sc', $
       'a_tr_lambda0tr' ,$
        ;  'q1',  $
           'Y' , $
         'q2',  $
          'q3',  $
        ; 'H',  $
          'Q'   ]


;SET OF PARAMETERS TO BE INVERTED:
;--------------------------------
Zin= [   'CHL' ,  $
       ;  'Str', $
        'CDOM', $
        'TR', $
       ;    'Y' , $
          'q1' ,$ ; ]
       ;  'q2',  $
       ;   'q3',  $
          'H'  ] ;,$
         ; 'Q' ,  $
      ;  'X_ph_lambda0x',    $
       ;'X_tr_lambda0x',    $
      ; 'Sc' ,$
      ; 'a_tr_lambda0tr']



end

if run_TR then begin

;   SET OF FIXED PARAMETERS:
;----------------------------
Fin = [ 'none',  $
           'CHL',              $
     'CDOM',           $
     ;  'TR'   ,    $
        'Str', $
          'X_ph_lambda0x',   $
        'X_tr_lambda0x',  $
        'Sc', $
       'a_tr_lambda0tr' ,$
        ;  'q1',  $
           'Y' , $
         'q2',  $
          'q3',  $
        ; 'H',  $
          'Q'   ]


;SET OF PARAMETERS TO BE INVERTED:
;--------------------------------
Zin= [  'TR', $
       ; 'CHL' ,  $
       ;  'Str', $
       ; 'CDOM', $
        ;'TR', $
       ;    'Y' , $
          'q1' ,$ ; ]
       ;  'q2',  $
       ;   'q3',  $
          'H'  ] ;,$
         ; 'Q' ,  $
      ;  'X_ph_lambda0x',    $
       ;'X_tr_lambda0x',    $
      ; 'Sc' ,$
      ; 'a_tr_lambda0tr']
end

;common opti_params,F,Zi,Fi

opti_params={Fin:Fin, Zin:Zin,$
         F:fltarr(n_elements(Fin)),Fi:fltarr(n_elements(Fin)),Zi:fltarr(n_elements(Zin))}



;============================
; select the input file
;
restore_envi_library,  fname=(*(*pstate).files.p_noise_info).fname,lib=Noise
print, "Noise library: "+ Noise.fname



if get_z then begin
; select the depth file

       envi_select,title="select depth file",fid=fid, /no_dims,/no_spec
       envi_file_query, fid, fname=Zfname, file_type=file_type
       print, fid
       if fid ge 0 then begin
       case  file_type of
       ; 0: ENVI standard image, 4: ENVI library
         0 : begin
             query_envi_image, fname=Zfname, image_info=Z_info

             end
         4 : query_envi_library, fname=Zfname,lib=Z_info
         else: result=widget_message("MUST BE ENVI Standard image or SPECTRAL LIBRARY", /error)
       endcase
       endif else begin
       result=widget_message("NO ENVI Standard image or SPECTRAL LIBRARY selected", /error)
       return, -1
       endelse
;check for size of bathy vs spectra
    if ( (*(*pstate).files.p_input_info).ns-z_info.ns) * $
       ( (*(*pstate).files.p_input_info).nl-z_info.nl) ne 0 then begin
       print, "check for size of image vs bathy"
       print, image_info.ns,z_info.ns
       print, image_info.nl,z_info.nl
       return,0
    endif
(*pstate).files.p_Z_info=ptr_new(Z_info)

endif

; adjust ns & nl
       case  (*(*pstate).files.p_input_info).file_type of
       ; 0: ENVI standard image, 4: ENVI library
         0 : begin
             ns=(*(*pstate).files.p_input_info).ns
             nl=(*(*pstate).files.p_input_info).nl
             ;n_wavs_input=image_info.nb & wavs_input = pos
             wavs_input=where((*(*pstate).files.p_input_info).wl gt 400. and $
                              (*(*pstate).files.p_input_info).wl lt 800., n_wavs_input )
             num_tiles=(*(*pstate).files.p_input_info).num_tiles
             end
         4 : begin
            ;ns=lib.nl
            ns=1+(*(*pstate).files.p_input_info).dims[4]-(*(*pstate).files.p_input_info).dims[3]
            ;n_wavs_input=lib.ns  & wavs_input= uindgen(nb) ;???
            wavs_input=where((*(*pstate).files.p_input_info).wl gt 400. and $
                        (*(*pstate).files.p_input_info).wl lt 800., n_wavs_input )
            num_tiles=1
             end
        endcase

print, "wavs_input",n_wavs_input, min(wavs_input),max(wavs_input)
    ;   if n_wavs_subslib ne n_wavs_input then begin
    ;   print, ns,n_wavs_subslib, n_wavs_input
    ;   return
    ;   endif

n_wavs=n_wavs_input

; VB07 move spectra to Common
 Noise_spectrum=(*pstate).values.image_scale*noise.spectra[wavs_input]

 imagespectra={Noise_spectrum:Noise_spectrum,image_spectrum:Noise_spectrum,$
           closed_spectrum:Noise_spectrum,closed_deep_spectrum:Noise_spectrum,$
           unmixed_mixel:Noise_spectrum,water_corrected_mixel:Noise_spectrum,$
           Kd:Noise_spectrum,Kub:Noise_spectrum,Kuc:Noise_spectrum,$
           SubsDet:Noise_spectrum,SDI:0l}



help,imagespectra,/struc


sensor_name=(*pstate).flag_str.sensor_name


filter_fname="Sensor_Filters"+path_sep()+"SAMBUCA_FILTER_"+sensor_name+"_350_900_1nm.lib"
restore_envi_library, fname=home_path+filter_fname, lib=filter

nm_filter_function = transpose(filter.spectra)
sum_filter=total(nm_filter_function,1)
for i= 0,n_elements(sum_filter)-1 do $
 if sum_filter[i] ne 0 then   nm_filter_function[*,i]=nm_filter_function[*,i]/sum_filter[i]

nm_filter_original = nm_filter_function
nm_filter_function=nm_filter_function[*,[wavs_input]]
SAVE, nm_filter_original, nm_filter_function, wavs_input, sum_filter, FILENAME='sensor_filter_band_count_adjustment.sav'


ERROR_TYPE= (*pstate).flag_str.error_type
run_1nm=(*pstate).flag.run_1nm
use_noise=(*pstate).flag.use_noise

distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function,$ :
          distance_alpha:0. , distance_f:0.,distance_LSQ:0., distance_alpha_f:0.,$
          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}

;vb07
;print, sensor_name
;case sensor_name of
;    "QB":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:2],$ ; quickfix qb only 3 bands:
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;
;     "CASI":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:27],$ ; quickfix CASI 28 bands
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;     "Hymap06":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:22],$ ; quickfix hymap 23 bands
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;     "ALOS":distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function[*,0:2],$ ; quickfix ALOS only 3 bands:
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;
;     ;"Hyp"
;    ;"MERIS"
;    else: distances ={dist_wl_index:fltarr(5),nm_filter_function:nm_filter_function,$
;          distance_alpha:0. , distance_f:0., distance_alpha_f:0.,$
;          ERROR_TYPE:ERROR_TYPE, run_1nm:run_1nm, use_noise:use_noise}
;
;    endcase
    help, distances,/struc



;;VB07
;;interpolate spectra from library to band set in 'samba_params'

if run_1nm then begin
    bands=inputspectra.wl
    ; these 3 lines are redundant if spectral library is at 1 nm  !!!
    my_refs=fltarr(n_spectra,inputspectra.ns)
    for ii=0,n_spectra -1 do my_refs[ii,*]= INTERPOL( all_subs.spectra[ii,*], all_subs.wl, bands )
    help, my_refs
endif else begin
; run at sensor bandset
    case  (*(*pstate).files.p_input_info).file_type of
           ; 0: ENVI standard image, 4: ENVI library
             0 : bands=(*(*pstate).files.p_input_info).wl[wavs_input]; quickfix
             4 : bands=(*(*pstate).files.p_input_info).wl[wavs_input]
    endcase

    awater=INTERPOL( awater, inputspectra.wl, bands )
    aphy_star=INTERPOL( aphy_star, inputspectra.wl, bands )

    ;my_refs=fltarr(n_spectra,image_info.nb)
    ;my_refs=fltarr(n_spectra,n_elements(bands)); quickfix

    ;for ii=0,n_spectra -1 do my_refs[ii,*]= INTERPOL( all_subs.spectra[ii,*], all_subs.wl, bands )

    ;or this way ???
    ; these 3 lines are redundant if spectral library is at 1 nm  !!!
    my_refs_1nm=fltarr(n_spectra,inputspectra.ns)
    for ii=0,n_spectra -1 do my_refs_1nm[ii,*]= INTERPOL( all_subs.spectra[ii,*], all_subs.wl, inputspectra.wl )
    print, total(abs(my_refs_1nm)-abs(all_subs.spectra))

    my_refs=my_refs_1nm #nm_filter_function
    if print_debug then help, my_refs
    my_refs=my_refs[*,wavs_input]
    ;  if print_debug   then plot, bands,transpose( my_refs)
    if print_debug then    print, my_refs
endelse


; VB07 move spectra to Common
;SAMBUCA will be run at the bandset containes in input_spectra.wl
a_star=[[reform(awater)],reform(aphy_star),reform(aphy_star),reform(aphy_star)]
help, a_star
input_spectra=   { wl:       bands,$
               awater:   reform(awater), $
               bbwater:   reform(awater), $
               aphy_star:   reform(aphy_star), $
          acdom_star : reform(aphy_star), $
          atr_star : reform(aphy_star), $
          bbph_star : reform(aphy_star), $
          bbtr_star : reform(aphy_star), $
               calculate_siops:1b,$
               substrateR:  reform(my_refs[0,*]) }
help, input_spectra,/struc

subs_names=[spectra_names,"NOT labelled"]
print, subs_names

; VB07 move spectra to Common
inputR= {n_spectra:n_spectra,subs_Z:subs_Z,spectra:my_refs, names:subs_names,  index:uintarr(2)}


 ;VB09:WGOSW


wls=(*(*pstate).files.p_input_info).wl


wl_abb_out=[440,550]
n_inv_wls_abb=n_elements(wl_abb_out)
i_wls_abb_out=intarr(n_inv_wls_abb)
for is=0,n_inv_wls_abb-1 do begin
     mindiffw=min(abs(wls - wl_abb_out[is]) ,min_idx)
     if mindiffw le 10. then  i_wls_abb_out[is]= min_idx
end
    ;if print_debug then
       print,  " wls for a & bb output" ,wl_abb_out
    ;if print_debug then
        print,  " wls for a & bb output" ,wls[i_wls_abb_out]

 WGOSW={wl440:i_wls_abb_out[0],wl555:i_wls_abb_out[1],a440:0.,bb555:0., Rbot555:0., Z:0.,   LSQ:0.}


SAMBUCA={distances:distances, opti_params:opti_params,input_params:input_params,$
       imagespectra:imagespectra,input_spectra:input_spectra,inputR:inputR,$
       input_siop:input_siop,WGOSW:WGOSW}
return, 1
end
;******************************************************
pro SAMBUCA_wid_noise_file, pstate=pstate
(*pstate).files.noise_fname=(*pstate).files.home_path+"NEDR" +path_sep()+$
          (*pstate).flag_str.nedr_name +".lib"
       query_envi_library, fname=(*pstate).files.noise_fname,lib_info=noise_info
          ; check for number of spectra
     if noise_info.nl ne 1 then begin
           result=widget_message("Noise library must have ONLY one spectrum!", /error)
          return
         endif


       tile=envi_get_data(fid=noise_info.fid, pos=noise_info.pos, dims=noise_info.dims)
       spectra=float(transpose(tile))

idx=where(spectra gt 0.000001, count_pos)
print, count_pos, noise_info.ns
     if count_pos lt noise_info.ns then begin
           result=widget_message("Noise spectrum  must have ONLY positive values in all bands!", /error)
          return
         endif

      ; Update pstate
      (*pstate).files.p_noise_info = ptr_new(noise_info)
      (*pstate).check_done[1]=1

end
;******************************************************
pro SAMBUCA_wid_input_file, pstate=pstate

if file_test((*pstate).files.input_fname) then begin
       query_envi_generic, fname=(*pstate).files.input_fname,input_info=input_info

           ; check for BSQ
     if input_info.file_type eq 0 and  input_info.interleave eq 0 then begin
           result=widget_message("IMAGE MUST BE BIP or BIL", /error)
          return
         endif

      ; Update text button
      widget_control, (*pstate).bases.infile_name, xsize = strlen(input_info.fname)+2
      widget_control, (*pstate).bases.infile_name, set_value = input_info.fname

      ; Update pstate
      (*pstate).files.p_input_info = ptr_new(input_info)
       (*pstate).check_done[0]=1
       endif else begin
             widget_control, (*pstate).bases.infile_name, xsize = 2
      widget_control, (*pstate).bases.infile_name, set_value = ""

             (*pstate).files.p_input_info = ptr_new()
              (*pstate).check_done[0]=0
   endelse
end
;******************************************************
pro SAMBUCA_modify_SIOP_ev, event


   widget_control, event.top, get_uvalue=pstate

   widget_control, event.id, get_uvalue=current
;help, event,/struc
;help,current

case current of

'conc':begin
    conc_name=(*pstate).bases.conc_names(widget_info( (*pstate).bases.conc ,/droplist_select))
    restore,(*pstate).home_path+"Input_siops"+path_sep()+"SAMBUCA_SIOP_"+conc_name+".sav"
    names=tag_names(input_siop)
    for i =0,N_TAGS(input_siop)-1 do begin
        (*pstate).siop_values[i]=input_siop.(i)
        widget_control,(*pstate).bases.siop_bases[i], set_value=input_siop.(i)
    end
     widget_control, event.top, set_uvalue=pstate
    end
"siops": begin
       ii_siop=where (widget_info(event.id,find_by_uname=widget_info(event.id,/uname)) eq $
                          (*pstate).bases.siop_bases)
     widget_control,event.id, get_value =val
       ;print,widget_info(event.id,/uname),val
        (*pstate).siop_values[ii_siop[0]]=val
    widget_control, event.top, set_uvalue=pstate

 end
'SIOP_OK':  begin
         widget_control, event.top,/destroy
         ptr_free, pstate
         heap_gc
         end
'SIOP_save': begin
         if (*pstate).new_name ne "" then begin
      conc_name=(*pstate).bases.conc_names(widget_info( (*pstate).bases.conc ,/droplist_select))
        restore,(*pstate).home_path+"Input_siops"+path_sep()+"SAMBUCA_SIOP_"+conc_name+".sav"
        for i =0,N_TAGS(input_siop)-1 do begin
           input_siop.(i)=(*pstate).siop_values[i]

       end
        save,input_siop,filename=(*pstate).home_path+"Input_siops"+path_sep()+"SAMBUCA_SIOP_"+(*pstate).new_name+".sav"



         widget_control, event.top,/destroy
         endif else result=DIALOG_message("New siop name MISSING !" ,/error)
         end
"siop_name": begin
     widget_control,event.id, get_value =val
    (*pstate).new_name=val
         end
else:print, current
endcase
;input_siop

end

;**************************************************************************
pro SAMBUCA_modify_SIOP_wid, pstate=pstate

file_list=file_search((*pstate).files.home_path+"Input_siops","*.sav")
if n_elements(file_list) ne 0 then begin
    ;the filename look like: "SAMBUCA_SIOP_CS.sav" or SAMBUCA_SIOP_HI_lagoon.sav
    conc_names=strarr( n_elements(file_list))
        for i=0,  n_elements(file_list)-1 do begin
        name_bits=strsplit(file_basename(file_list[i]),"_.",/extract)
        conc_names[i]=strjoin(name_bits[2:n_elements(name_bits)-2],"_")
        endfor
endif

restore,(*pstate).files.home_path+"Input_siops"+path_sep()+"SAMBUCA_SIOP_"+conc_names[0]+".sav"
siop_names=tag_names(input_siop)
siop_bases=lonarr(n_elements(siop_names))
siop_values=fltarr(n_elements(siop_names))

for i =0,N_TAGS(input_siop)-1 do siop_values[i]=input_siop.(i)

    tlb=widget_base(/column, mbar=menu, TITLE="SAMBUCA SIOP input GUI")
           base1 = widget_base(tlb, /column, /align_center)
         conc = Widget_Droplist(base1, Uvalue='conc',  $
            SCR_XSIZE=123 ,SCR_YSIZE=24 ,VALUE=conc_names)

       for i =0,N_TAGS(input_siop)-1 do $
        ;siop_bases[i] = cw_field( base1,uvalue="siops", Uname=siop_names[i] ,/floating , /RETURN_EVENTS, $
        siop_bases[i] = cw_field( base1,uvalue="siops", Uname=siop_names[i] ,/floating, /all_events, $
         Title=siop_names[i])

       low_base = widget_base(tlb, /row, /align_center)

       rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'SIOP_OK', value = $
          'OK')

        rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'SIOP_save', value = $
          'Save  SIOP set')
           ;siop_name = cw_field( low_base,uvalue="siop_name", /string , /RETURN_EVENTS, $
           siop_name = cw_field( low_base,uvalue="siop_name", /string , /all_EVENTS, $
         Title="New Siop name")

SIOP_state={bases:{conc:conc,conc_names:conc_names,siop_bases:siop_bases},$
         home_path:(*pstate).files.home_path, $
         new_name:"",$
            siop_values:siop_values,siop_names:siop_names}
         psiop_state=ptr_new(SIOP_state,/no_copy)
          ; show widgets on screen
    widget_control, tlb, /realize
    widget_control, tlb, set_uvalue=psiop_state,/REALIZE,/NO_COPY
        xmanager, "pippo",tlb, event_handler="SAMBUCA_modify_SIOP_ev";, /no_block


end
;**************************************************************************

pro log_state, pstate=pstate
        help, (*pstate) ,/structures, output=log_string
        ;print,  log_string, format='(a)'
        printf, (*pstate).ev_log_fid, log_string, format='(a)'
end
;
pro close_log,pstate=pstate
        log_state, pstate=pstate
       printf, (*pstate).ev_log_fid, SYSTIME()
end
;**************************************************************************
pro sambuca_ev,event

   widget_control, event.top, get_uvalue=pstate

   widget_control, event.id, get_uvalue=current
;help, event,/struc
;help,current

case current of
"OK": begin
       if ARRAY_EQUAL((*pstate).check_done,1B) then begin
          ;ptr_free, pstate
          rst=SAMBUCA_2009_pre(pstate=pstate)
            widget_control, event.top,/destroy
          if rst ne -1 then SAMBUCA_plot_SIOP,pstate=pstate
          if rst ne -1 then SAMBUCA_2009,pstate=pstate
          endif else result=DIALOG_message("SOMETHING MISSING ! :"+STRING((*pstate).check_done,format='(i0)') , /error)
      end
"Cancel": begin
          widget_control, event.top,/destroy
          ptr_free, pstate
          heap_gc
          return
          end
"save":begin
       if ARRAY_EQUAL((*pstate).check_done,1B) then begin
          SAMBUCA_2009_save_state,pstate=pstate
          endif else result=DIALOG_message("SOMETHING MISSING ! :"+STRING((*pstate).check_done,format='(i0)') , /error)
       end
"retrieve": begin
         file=dialog_pickfile(path=(*pstate).files.home_path+"RUN_database"+path_sep(),filter="*.sav",/fix_filter,/must_exist)
         if file ne '' then begin
         restore,file,/verbose
         help, state,/struc
         ;state.bases =(*pstate).bases
         ;state.flag_str=(*pstate).flag_str
         (*pstate).files=state.files
         SAMBUCA_wid_input_file, pstate=pstate

         (*pstate).flag_str.nedr_name= state.flag_str.nedr_name

          SAMBUCA_wid_noise_file, pstate=pstate

         (*pstate).flag_str.sensor_name=state.flag_str.sensor_name
         (*pstate).flag_str.conc_name=state.flag_str.conc_name
         (*pstate).flag_str.aphy_name=state.flag_str.aphy_name
         (*pstate).flag_str.sublib=state.flag_str.sublib
         (*pstate).flag_str.error_type=state.flag_str.error_type

         ;help, state.flag_str,/struc
         widget_control,(*pstate).bases.sensor, $
            SET_DROPLIST_SELECT= where (strcmp((*pstate).flag_str.sensor_names, state.flag_str.sensor_name) eq 1)
         widget_control,(*pstate).bases.conc, $
            SET_DROPLIST_SELECT= where (strcmp((*pstate).flag_str.conc_names, state.flag_str.conc_name) eq 1)
         widget_control,(*pstate).bases.aphy, $
            SET_DROPLIST_SELECT= where (strcmp((*pstate).flag_str.aphy_names, state.flag_str.aphy_name) eq 1)
         widget_control,(*pstate).bases.sublib, $
            SET_DROPLIST_SELECT= where (strcmp((*pstate).flag_str.lib_codes, state.flag_str.sublib) eq 1)
         widget_control,(*pstate).bases.error, $
            SET_DROPLIST_SELECT= where (strcmp((*pstate).flag_str.error_types, state.flag_str.error_type) eq 1)
         widget_control,(*pstate).bases.nedr_name,$
            SET_DROPLIST_SELECT= where (strcmp((*pstate).flag_str.nedr_names, state.flag_str.nedr_name) eq 1)



         (*pstate).values=state.values

        widget_control, (*pstate).bases.H_max, set_value =  (*pstate).values.H_max
        widget_control, (*pstate).bases.delta_z, set_value =(*pstate).values.delta_z
        widget_control, (*pstate).bases.image_scale, set_value =  (*pstate).values.image_scale
        widget_control, (*pstate).bases.theta_air, set_value =(*pstate).values.theta_air
        widget_control, (*pstate).bases.tidal_offset, set_value = (*pstate).values.tidal_offset


       (*pstate).flag=state.flag
       flag_values=uintarr(N_TAGS(state.flag))
       for i =0,N_TAGS(state.flag)-1 do flag_values[i]=state.flag.(i)
       widget_control, (*pstate).bases.flag_buttons, set_value =flag_values

       (*pstate).output=state.output
       output_values=uintarr(N_TAGS(state.output))
      for i =0,N_TAGS(state.output)-1 do output_values[i]=state.output.(i)
       widget_control, (*pstate).bases.output_buttons, set_value =output_values

       (*pstate).check_done=make_array(n_elements((*pstate).check_done),value=1B,/BYTE)
        SAMBUCA_2009_name_state, pstate=pstate
          widget_control, event.top, set_uvalue=pstate

         endif
            end

"SIOP":begin
       if ARRAY_EQUAL((*pstate).check_done,1B) then begin
          ;ptr_free, pstate
          rst=SAMBUCA_2009_pre(pstate=pstate)
          SAMBUCA_plot_SIOP,pstate=pstate
          endif else result=DIALOG_message("SOMETHING MISSING ! :"+STRING((*pstate).check_done,format='(i0)') , /error)
      end
"SIOP_modify": begin
          SAMBUCA_modify_SIOP_wid, pstate=pstate
                    file_list=file_search((*pstate).files.home_path+"Input_siops","*.sav")
          if n_elements(file_list) ne 0 then begin
              ;the filename look like: "SAMBUCA_SIOP_CS.sav" or SAMBUCA_SIOP_HI_lagoon.sav
              conc_names=strarr( n_elements(file_list))
                  for i=0,  n_elements(file_list)-1 do begin
                  name_bits=strsplit(file_basename(file_list[i]),"_.",/extract)
                  conc_names[i]=strjoin(name_bits[2:n_elements(name_bits)-2],"_")
                  endfor
              endif
       widget_control,(*pstate).bases.conc, set_value=conc_names

end
"flags":  begin
          tag=where(strcmp(event.value,tag_names((*pstate).flag),/FOLD_CASE))
          (*pstate).flag.(tag)=event.select
          widget_control, event.top, set_uvalue=pstate
           if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate

          end
"output":  begin
          tag=where(strcmp(event.value,tag_names((*pstate).output),/FOLD_CASE))
          (*pstate).output.(tag)=event.select
          widget_control, event.top, set_uvalue=pstate
          if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate

          end

;droplists
"sensor": begin
        (*pstate).flag_str.sensor_name=$
            (*pstate).flag_str.sensor_names(widget_info( (*pstate).bases.sensor ,/droplist_select))
        (*pstate).check_done[2]=1
         if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
       end
"conc": begin
       widget_control,(*pstate).bases.conc, get_value=conc_names
        (*pstate).flag_str.conc_name=$
            conc_names(widget_info( (*pstate).bases.conc ,/droplist_select))
              (*pstate).check_done[3]=1
              if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
       end
"aphy": begin
        (*pstate).flag_str.aphy_name=$
            (*pstate).flag_str.aphy_names(widget_info( (*pstate).bases.aphy ,/droplist_select))
              (*pstate).check_done[4]=1
              if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
       end
"sublib": begin
        (*pstate).flag_str.sublib= $
            (*pstate).flag_str.lib_codes(widget_info( (*pstate).bases.sublib ,/droplist_select))
              (*pstate).check_done[5]=1
              if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end
"error": begin
        (*pstate).flag_str.error_type= $
          (*pstate).flag_str.error_types(widget_info( (*pstate).bases.error ,/droplist_select))
              (*pstate).check_done[6]=1
              if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end
;values
"H_max":begin
        widget_control, (*pstate).bases.H_max, get_value =val
        (*pstate).values.H_max=val
        if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end
 "delta_z":begin
        widget_control, (*pstate).bases.delta_z, get_value =val
        (*pstate).values.delta_z=val
        if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end
  "image_scale":begin
        widget_control, (*pstate).bases.image_scale, get_value =val
        (*pstate).values.image_scale=val
        if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end
   "theta_air":begin
        widget_control, (*pstate).bases.theta_air, get_value =val
        (*pstate).values.theta_air=val
        if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end
  "tidal_offset":begin
        widget_control, (*pstate).bases.tidal_offset, get_value =val
        (*pstate).values.tidal_offset=val
        if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        end



 "select_infile": begin
    log_state, pstate=pstate
       envi_select,title="select input file",fid=fid, /no_dims,/no_spec
       envi_file_query, fid, fname=fname, file_type=file_type
       if fid ge 0 then begin
        (*pstate).files.input_fname = fname
       SAMBUCA_wid_input_file, pstate=pstate
      endif
    if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
    end
'noise_name':  begin
     (*pstate).flag_str.nedr_name= $
          (*pstate).flag_str.nedr_names(widget_info( (*pstate).bases.nedr_name ,/droplist_select))
       SAMBUCA_wid_noise_file, pstate=pstate
        if ARRAY_EQUAL((*pstate).check_done,1B) then SAMBUCA_2009_name_state, pstate=pstate
        (*pstate).check_done[6]=1

                 end
else: print, current
endcase
end

;--------------------------------------------------------------
pro sambuca_2009_wid,ev

;case machine_name() of
;    "CLW-3733G1S-BU":  home_path="C:\SAMBA\input2007\" ; VB
;    "CORAL-BU":  home_path="C:\work_in_progress\SAMBA\input2007\" ; VB
;    "OMNIVIEW-BU": home_path="C:\IDL_TOOLS\SAMBUCA\input2007\" ; JA
;    "CLW-71FQG1S-BU": home_path= "C:\IDL_TOOLS\SAMBUCA\input2007\" ; Ele
;    "ELIBOT-BU": home_path= "C:\IDL_TOOLS\SAMBUCA\input2007\" ; Hannelie
;    "POWERAPP5-WRON": home_path= "W:\IDL_TOOLS\SAMBUCA\input2007\" ;
;
;    'unix': begin
;        home_path="/cfs02/bra372/SAMBUCA/input2007/"
;            end
;    else: begin
;         print, "home_path TO FIX";home_path="C:\SAMBA\input2007\"
;           return
;            end
;endcase
home_path= "C:\Users\col52j\sambuca\reference\IDL\" ;

 openw, ev_log_fid,"sambuca_wid.evlog", /get_lun,/append

printf,ev_log_fid,"SAMBUCA"
printf, ev_log_fid,"widget event log"
printf, ev_log_fid,SYSTIME()




flag={use_deepwater_mask:1b,$
       ;rundeep=1b,$
       rundeep:0,$
       go_shallow:1,$
       ;go_shallow=0b ,$
       ;run_TR=1b,$ ; run only TR, q1 & H
       run_TR:0b,$
       get_z:0,$
       run_1nm:1b,$
       print_debug:0b,$
       use_noise:1b,$
       do_graph1:0};,$


flag_values=uintarr(N_TAGS(flag))
for i =0,N_TAGS(flag)-1 do flag_values[i]=flag.(i)


output={depth_concs:1b,$
distances:1b,$
iter:1b,$
subs:1b,$
closed_spectra:1b,$
closed_deep_spectra:0b,$
diff_deep_spectra:0b,$
diff_spectra:1b,$
UNmixel_spectra:1b,$
WCmixel_spectra:1b,$
SubsDet_spectra:1b,$
Kd:1b, Kub:0b,Kuc:0b}

output_values=uintarr(N_TAGS(output))
for i =0,N_TAGS(output)-1 do output_values[i]=output.(i)




;populate lists:

file_list=file_search(home_path+"Sensor_Filters","*.lib")
if n_elements(file_list) ne 0 then begin
    ;the filename look like: "SAMBUCA_FILTER_QB_350_900_1nm.lib"
    sensor_names=strarr( n_elements(file_list))
        for i=0,  n_elements(file_list)-1 do begin
        name_bits=strsplit(file_basename(file_list[i]),"_",/extract)
        sensor_names[i]=name_bits[2]
        endfor
endif

file_list=file_search(home_path+"Input_siops","*.sav")
if n_elements(file_list) ne 0 then begin
    ;the filename look like: "SAMBUCA_SIOP_CS.sav" or SAMBUCA_SIOP_HI_lagoon.sav
    conc_names=strarr( n_elements(file_list))
        for i=0,  n_elements(file_list)-1 do begin
        name_bits=strsplit(file_basename(file_list[i]),"_.",/extract)
        conc_names[i]=strjoin(name_bits[2:n_elements(name_bits)-2],"_")
        endfor
endif
file_list=file_search(home_path+"NEDR","*.lib")
if n_elements(file_list) ne 0 then begin
    NEDR_names=strarr( n_elements(file_list))
        for i=0,  n_elements(file_list)-1 do begin
        NEDR_names[i]=file_basename(file_list[i],".lib")
        endfor
        print, NEDR_names
endif


inputspectra_fname=home_path+"Input_spectra"+path_sep()+"SAMBUCA_inputspectra_350_900_1nm.lib"
restore_envi_library, fname=inputspectra_fname, lib=inputspectra
i_aphy= where (strcmp(inputspectra.spec_names, "aphy_star",9) eq 1)
if total(i_aphy) ne -1 then begin
aphy_names=inputspectra.spec_names[i_aphy]
;the spectra name look like: aphy_star_CS or aphy_star_MB_RC04
        for i=0,  n_elements(aphy_names)-1 do begin
        name_bits=strsplit(aphy_names[i],"_.",/extract)
        aphy_names[i]=strjoin(name_bits[2:n_elements(name_bits)-1],"_")
        endfor

print, aphy_names
endif


Substrate_index_fname=home_path+"Substrate_library"+path_sep()+"Substrate_index.csv"

template={ VERSION:1., DATASTART:0, DELIMITER :44, MISSINGVALUE:!VALUES.F_NAN  , $
   COMMENTSYMBOL:'#',  FIELDCOUNT:2,    FIELDTYPES :[7L,7L],$
   FIELDNAMES :["code","filename"],FIELDLOCATIONS:[0L,4L],$
   FIELDGROUPS:[0L,1L]}

data=READ_ASCII( Substrate_index_fname , COMMENT_SYMBOL='#',DELIMITER=',',template=Template)
;help,data,/struc
lib_names=data.filename
lib_codes=data.code

;lib_names=["s12","mb_s10","mb_s11","mb_SM", "mb_SM1nm",$
;;      "s12_noZ","clean","epi","PosSand","PosSands",$
;;lib_names=[ $
;         "UQ02","LC_s5","LC_s6"]
ERROR_TYPEs=["af","f","a"]

flag_str= {sublib:"",sensor_name:"",conc_name:"",aphy_name:"",ERROR_TYPE:"",nedr_name:"",$
sensor_names:sensor_names,conc_names:conc_names,aphy_names:aphy_names, nedr_names:nedr_names,$
lib_codes:lib_codes,lib_names:lib_names,ERROR_TYPEs:ERROR_TYPEs}


    ; create widget hierarchy
    tlb=widget_base(/column, TITLE="SAMBUCA input GUI")
       wrow1=widget_base(tlb,/row)
       select_infile = Widget_Button(wrow1, Uvalue='select_infile'  $
                ,/ALIGN_center ,SCR_YSIZE=30 , VALUE='Select  input file')

       infile_name = Widget_text(wrow1, Uvalue='infile_name' ,FRAME=1,  $
            SCR_XSIZE=200 ,SCR_YSIZE=24 ,/ALIGN_center ,VALUE='')

       wrow2=widget_base(tlb,/row)
;       select_noise = Widget_Button(wrow2, Uvalue='select_noise'  $
;                ,/ALIGN_center ,SCR_YSIZE=30 , VALUE='Select noise file')
;       noise_name = Widget_text(wrow2, Uvalue='noise_name' ,FRAME=1,  $
;            SCR_XSIZE=200 ,SCR_YSIZE=24 ,/ALIGN_center ,VALUE='')


         rst = Widget_Label(wrow2,  /ALIGN_CENTER  ,VALUE='Noise Equivalent R(0-)')
        nedr_name = Widget_Droplist(wrow2, Uvalue='noise_name',  $
         SCR_XSIZE=250 ,SCR_YSIZE=24 ,VALUE=nedr_names)


        wrowb=widget_base(tlb,/row)
;        flag_buttons=cw_bgroup(wrowb,flag_longnames,/NonEXCLUSIVE,$
        flag_buttons=cw_bgroup(wrowb,tag_names(flag),/NonEXCLUSIVE,$
                               button_uvalue=tag_names(flag), column=3, $
                               set_value=flag_values,uvalue="flags");,/LABEL_top=flag_string)

        wrow3=widget_base(tlb,/row)
        wrow3_1=widget_base(wrow3,/col,/frame)
         rst = Widget_Label(wrow3_1,  /ALIGN_CENTER  ,VALUE='Sensor')
        sensor = Widget_Droplist(wrow3_1, Uvalue='sensor',  $
            SCR_XSIZE=123 ,SCR_YSIZE=24 ,VALUE=sensor_names)
         wrow3_2=widget_base(wrow3,/col,/frame)
         rst = Widget_Label(wrow3_2,  /ALIGN_CENTER  ,VALUE='Conc set ')
         conc = Widget_Droplist(wrow3_2, Uvalue='conc',  $
            SCR_XSIZE=123 ,SCR_YSIZE=24 ,VALUE=conc_names)
          wrow3_2b=widget_base(wrow3,/col,/frame)
         rst = Widget_Label(wrow3_2b,  /ALIGN_CENTER  ,VALUE='a_star_phy')
        aphy = Widget_Droplist(wrow3_2b, Uvalue='aphy',  $
         SCR_XSIZE=123 ,SCR_YSIZE=24 ,VALUE=aphy_names)
          wrow3_3=widget_base(wrow3,/col,/frame)
         rst = Widget_Label(wrow3_3,  /ALIGN_CENTER  ,VALUE='Substrate library')
        sublib = Widget_Droplist(wrow3_3, Uvalue='sublib',  $
         SCR_XSIZE=123 ,SCR_YSIZE=24 ,VALUE=lib_codes)
          wrow3_4=widget_base(wrow3,/col,/frame)
         rst = Widget_Label(wrow3_4,  /ALIGN_CENTER  ,VALUE='Error Type')
      error = Widget_Droplist(wrow3_4, Uvalue='error',  $
         SCR_XSIZE=123 ,SCR_YSIZE=24 ,VALUE=ERROR_TYPEs)

        wrow4=widget_base(tlb,/row)
        values={H_max:25.,delta_z:1.,image_scale:1.,tidal_offset:0.,theta_air:45.}
        H_max = cw_field( wrow4, Uvalue='H_max' ,/floating , /RETURN_EVENTS, $
         value=values.H_max,Title='H max ',/column,XSIZE=10)
        delta_z = cw_field( wrow4, Uvalue='delta_z' ,/floating , /RETURN_EVENTS, $
           value=values.delta_z,Title='delta_z ',/column,XSIZE=10)
        image_scale = cw_field( wrow4, Uvalue='image_scale' ,/floating , /RETURN_EVENTS, $
         value=values.image_scale,Title='image_scale ',/column,XSIZE=10)
        tidal_offset = cw_field( wrow4, Uvalue='tidal_offset' ,/floating , /RETURN_EVENTS, $
           value=values.tidal_offset,Title='tidal_offset ',/column,XSIZE=10)
        theta_air = cw_field( wrow4, Uvalue='theta_air' ,/floating , /RETURN_EVENTS, $
         value=values.theta_air,Title='theta_air ',/column,XSIZE=10)
        wrowc=widget_base(tlb,/row)

;        flag_buttons=cw_bgroup(wrowb,flag_longnames,/NonEXCLUSIVE,$
        output_buttons=cw_bgroup(wrowc,tag_names(output),/NonEXCLUSIVE,$
                               button_uvalue=tag_names(output), column=4, $
                               set_value=output_values,uvalue="output");,/LABEL_top=flag_string)


       low_base = widget_base(tlb, /row, /align_center)

       rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'OK', value = $
          'OK')
       rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'Cancel', value = $
          'Cancel')
       rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'SIOP', value = $
          'Plot SIOP')
       rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'SIOP_modify', value = $
          'Modify SIOP set')

        rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'save', value = $
          'Save session')
       rst = widget_button(low_base, /ALIGN_CENTER, uvalue = 'retrieve', value = $
          'retrieve session')
    wrowd=widget_base(tlb,/row)
        wstatus=cw_field(wrowd,title="RUNNAME: ",/noedit,/string, uvalue="label_Status", xsize=60)

          ; show widgets on screen
    widget_control, tlb, /realize

bases={infile_name:infile_name,nedr_name:nedr_name,wstatus:wstatus,$
       sensor:sensor,conc:conc,aphy:aphy,sublib:sublib,error:error,$
       image_scale:image_scale,flag_buttons:flag_buttons,output_buttons:output_buttons,$
       tidal_offset:tidal_offset,theta_air:theta_air,$
       H_max:H_max,delta_z:delta_z}

files={home_path:home_path,p_input_info:ptr_new(),p_noise_info:ptr_new(),p_Z_info:ptr_new(),input_fname:"",noise_fname:""}
    ; state structure for persistent info
   state={ev_log_fid:ev_log_fid, flag:flag,flag_str:flag_str,output:output,$
    values:values,files:files,bases:bases,check_done:bytarr(7),$
    runname:""}
    ; store pointer to state structure in tlb
    pstate=ptr_new(state,/no_copy)
    log_state, pstate=pstate
    widget_control, tlb, set_uvalue=pstate,/REALIZE,/NO_COPY


    ; enter event loop ...
    xmanager, "pippo",tlb, event_handler="sambuca_ev", /no_block

end


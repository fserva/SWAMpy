;-
@amoeba_clw7
;-
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

function DO_whole_guacamole, pstate=pstate, zzzz=zzzz
    common SAMBUCA_share, SAMBUCA

    ;********************************
    Hmax=(*pstate).values.H_max
    deltaz=(*pstate).values.delta_z
    tidal_offset=(*pstate).values.tidal_offset
    get_z=(*pstate).flag.get_z
    ;*************************************

    ;Data structure that contains all parameters for 14 possible variables
    whole_guacamole = { name: strarr(15),  $
                        value: fltarr(15), $
                        pupper: fltarr(15),$
                        start: fltarr(15), $
                        plower: fltarr(15),$
                        scale: fltarr(15) }
    ;'scale' defines size of 'step' that amoeba takes when first varying variable
    ;as a first rule of thumb, start with one order of magnitude less than
    ;'pupper' - amoeba will still search for solution at several more
    ;decimal places than value  of scale. e.g. pupper = 2.0,
    ;scale = 0.1, and answer retrieved can be to fifth decimal.
    ;too low scale value can result in amoeba getting stuck in nearby local
    ;minima without properly exploring parameter space, large 'scale' is
    ;unnecessary, particularly if answer is more or less known, ie starting
    ;point close to 'answer'.

    ;'scale' and 'start' settings can have dramatic effects on
    ;amoeba result! highly recommend exploring these effects every
    ;time a new dataset is used.

    ;PARAMETERS TO BE OPTIMISED WITH INITIAL VALUES:
    whole_guacamole.name(0) = 'none'         ; dummy variable for Fi incase all 14 are to be inverted
    whole_guacamole.value(0) = 0.0
    whole_guacamole.pupper(0)= 0.0
    whole_guacamole.start(0)  = 0.0
    whole_guacamole.plower(0) = 0.0
    whole_guacamole.scale(0) = 0.0

    whole_guacamole.name(1) = 'CHL'
    whole_guacamole.value(1) = SAMBUCA.input_siop.CHL
    whole_guacamole.start(1)  =SAMBUCA.input_siop.CHL
    whole_guacamole.scale(1) = 0.1
    whole_guacamole.pupper(1)=  SAMBUCA.input_siop.CHL_upper
    whole_guacamole.plower(1) = SAMBUCA.input_siop.CHL_lower

    whole_guacamole.name(2) = 'CDOM'
    whole_guacamole.value(2) = SAMBUCA.input_siop.CDOM
    whole_guacamole.start(2)  = SAMBUCA.input_siop.CDOM
    whole_guacamole.scale(2) = 0.1
    whole_guacamole.pupper(2)= SAMBUCA.input_siop.CDOM_upper
    whole_guacamole.plower(2) = SAMBUCA.input_siop.CDOM_lower

    whole_guacamole.name(3) = 'TR'
    whole_guacamole.value(3) = SAMBUCA.input_siop.TR
    whole_guacamole.start(3)  = SAMBUCA.input_siop.TR
    whole_guacamole.scale(3) = 0.1
    whole_guacamole.pupper(3)=  SAMBUCA.input_siop.TR_upper
    whole_guacamole.plower(3) = SAMBUCA.input_siop.TR_lower

    whole_guacamole.name(4) = 'X_ph_lambda0x'
    whole_guacamole.value(4) = SAMBUCA.input_siop.X_ph_lambda0x
    whole_guacamole.pupper(4)= 0.005
    whole_guacamole.start(4)  = 0.005
    whole_guacamole.plower(4) = 0.00005
    whole_guacamole.scale(4) = 0.001

    whole_guacamole.name(5) = 'X_tr_lambda0x'
    whole_guacamole.value(5) = SAMBUCA.input_siop.X_tr_lambda0x
    whole_guacamole.pupper(5)= 0.05
    whole_guacamole.start(5)  = 0.05
    whole_guacamole.plower(5) = 0.00005
    whole_guacamole.scale(5) = 0.01

    whole_guacamole.name(6) = 'Sc'
    whole_guacamole.value(6) = SAMBUCA.input_siop.Sc
    whole_guacamole.pupper(6)= .021
    whole_guacamole.start(6)  = 0.016
    whole_guacamole.plower(6) = 0.012
    whole_guacamole.scale(6) = 0.001

    whole_guacamole.name(7) = 'Str'
    whole_guacamole.value(7) = SAMBUCA.input_siop.Str
    whole_guacamole.pupper(7)= 0.012
    whole_guacamole.start(7)  = 0.008
    whole_guacamole.plower(7) = 0.004
    whole_guacamole.scale(7) = 0.001

    whole_guacamole.name(8) = 'a_tr_lambda0tr'
    whole_guacamole.value(8) = SAMBUCA.input_siop.a_tr_lambda0tr
    whole_guacamole.pupper(8)= 3.5
    whole_guacamole.start(8)  = 0.2
    whole_guacamole.plower(8) = 0.001
    whole_guacamole.scale(8) = 0.001

    whole_guacamole.name(9) = 'Y'
    whole_guacamole.value(9) = SAMBUCA.input_siop.Y
    whole_guacamole.pupper(9)= 1.0
    whole_guacamole.start(9)  = 0.1
    whole_guacamole.plower(9) = 0.001
    whole_guacamole.scale(9) = 0.01

    whole_guacamole.name(10) = 'q1'
    whole_guacamole.value(10) = SAMBUCA.input_siop.q1
    whole_guacamole.pupper(10)= 1.0
    whole_guacamole.start(10)  =  SAMBUCA.input_siop.q1
    whole_guacamole.plower(10) = 0.01
    whole_guacamole.scale(10) = 0.1

    whole_guacamole.name(11) = 'q2'
    whole_guacamole.value(11) = SAMBUCA.input_siop.q2
    whole_guacamole.pupper(11)= 1.0
    whole_guacamole.start(11)  = SAMBUCA.input_siop.q2
    whole_guacamole.plower(11) = 0.01
    whole_guacamole.scale(11) = 0.1

    whole_guacamole.name(12) = 'q3'
    whole_guacamole.value(12) = SAMBUCA.input_siop.q3
    whole_guacamole.pupper(12)= 1.0
    whole_guacamole.start(12)  = 0.5
    whole_guacamole.plower(12) = 0.01
    whole_guacamole.scale(12) = 0.1

    if get_Z then begin
        if finite(zzzz) then begin
            zzz=zzzz
            whole_guacamole.name(13) = 'H'
            whole_guacamole.value(13) = zzz
            whole_guacamole.pupper(13)= zzz+deltaz
            whole_guacamole.start(13)  = zzz
            whole_guacamole.plower(13) = zzz-deltaz
            whole_guacamole.scale(13) = 1.00
        endif;finite(zzzz)
    endif else begin; getZ=0
        whole_guacamole.name(13) = 'H'
        whole_guacamole.value(13) = SAMBUCA.input_siop.H
        whole_guacamole.pupper(13)= Hmax + tidal_offset;
        whole_guacamole.start(13)  = 2.00
        whole_guacamole.plower(13) = 0.10
        whole_guacamole.scale(13) = 1.0
    endelse; getZ

    whole_guacamole.name(14) = 'Q'
    whole_guacamole.value(14) = SAMBUCA.input_siop.Qwater
    whole_guacamole.pupper(14)= 5.01
    whole_guacamole.start(14)  = SAMBUCA.input_siop.Qwater
    whole_guacamole.plower(14) = 2.99
    whole_guacamole.scale(14) = 0.1

    ;check for incosistencies in whole_guacamole
    for ig = 1, n_elements(whole_guacamole.pupper)-1 do $
        if whole_guacamole.plower[ig] ge whole_guacamole.pupper[ig] then begin
            print, "Incosistency in whole_guacamole: RETURNING -1"
            print, "Plower >= Pupper :",ig, whole_guacamole.name[ig], whole_guacamole.plower[ig],whole_guacamole.pupper[ig]
            return,-1
        endif

    RETURN,whole_guacamole
END


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
            if fid_fname eq fname then fid= fids[i]
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


function SAMBUCA_SA_V12_fwdVB, ZZ, input_spectra, input_params

    wav = input_spectra.wl
    aw = input_spectra.awater
    ;bbw = input_spectra.bbwater
    n_wls = n_elements(wav)

    ;==============
    theta_air=input_params.theta_air
    thetaw = (ASIN(1/1.333*SIN(!PI/180.00*(theta_air))))  ;subsurface solar zenith angle in radians
    thetao = 0.00                                       ;subsurface viewing angle in radians

    ;=======================
    ;PARAMETERS TO BE OPTIMISED WITH INITIAL VALUES:
    ;none  = ZZ(0)      ;dummy parameter incase nothing is to be fixed!
    CHL  = ZZ(1)              ;concentration of cholorphyl
    CDOM  = ZZ(2)             ; concentration of cdom
    TR =    ZZ(3)           ;concentration of tripton
    X_ph_lambda0x = ZZ(4)      ;specific backscatter of chlorophyl at lambda0x
    X_tr_lambda0x = ZZ(5)      ;specific backscatter of tripton at lambda0x
    Sc = ZZ(6)            ; slope of cdom absorption
    Str = ZZ(7)               ; slope of tr absorption
    a_tr_lambda0tr = ZZ(8)
    Y = ZZ(9)
    q1 = ZZ(10)
    q2 = ZZ(11)
    q3 = ZZ(12)
    H = ZZ(13)
    Qwater = ZZ(14)

    if input_spectra.calculate_siops then begin
        ;=========================
        ;SIOPS
        input_spectra.bbwater= ( 0.00194/2.0 ) * ( ( 550.0/wav )^4.32 ) ; Mobely 1994, eq

        lambda0cdom=input_params.lambda0cdom
        a_cdom_lambda0cdom = 1.0

        input_spectra.acdom_star = a_cdom_lambda0cdom * (exp(-Sc * (wav - input_params.lambda0cdom) ) ) ; abs. coeff for CDOM, where a_cdom_550 = 1
        input_spectra.atr_star = a_tr_lambda0tr * (exp(-Str * (wav - input_params.lambda0tr) ) )   ; abs coeff og tripton, where a_tr_550 = sample dependent

        ;---------scatter--------bb = bbw + bbchl + bbtr
        input_spectra.bbph_star = X_ph_lambda0x * ( (input_params.lambda0x/wav)^Y )  ;backscatter due to phytoplankton
        input_spectra.bbtr_star = X_tr_lambda0x * ( (input_params.lambda0x/wav)^Y )      ;backscatter due to tripton
        input_spectra.calculate_siops=0b
    endif

    a =  input_spectra.awater +  CHL * input_spectra.aphy_star + $
        CDOM  * input_spectra.acdom_star + TR * input_spectra.atr_star
    bb =  input_spectra.bbwater + CHL * input_spectra.bbph_star + $
        TR * input_spectra.bbtr_star
   
    ;-------bottom reflectance--------

    ;r = (q1 * r1) + ( (1-q1)*r2 )     ;proportion of 1st (and second which equals 1-q1 ) end member spectra
    r=input_spectra.substrateR

    ;================
    ;SA MODEL:

    u = bb / (a + bb)
    kappa = a + bb

    DuColumn = 1.03 * (1.00 + (2.40 * u) )^0.50  ; opt. path elongation for scatterd photons from column
    DuBottom = 1.04 * (1.00 + (5.40 * u) )^0.50  ; opt. path elongation for scatterd photons from bottom

    rrsdp = (0.084 + (0.17 * u) ) * u   ; remote sensing reflectance for opt deep water

    Kd=   kappa * (1.00     / cos(thetaw))
    Kuc=  kappa * (DuColumn / cos(thetao))
    Kub=  kappa * (DuBottom / cos(thetao))

    ;rrs = rrsdp * (1.00 - exp(-(Kd+Kuc) * H)) + ( (1.00/!DPI) * r * exp(- ( Kd+Kub)* H)   )
    rrs = rrsdp * (1.00 - exp(-( (1.00/cos(thetaw)) + (DuColumn / cos(thetao)) )* kappa * H)) + ( (1.00/!DPI) * r * exp(-( (1.00/cos(thetaw)) + (DuBottom / cos(thetao)) )* kappa * H)   )

    ;rrs = rrsdp * (1.00 - exp(-(Kd+Kuc) * H)) + ( (1.00/!DPI) * r * exp(- ( Kd+Kub)* H)   )

    closed_spectrum=  rrs * Qwater ; VB
    closed_deep_spectrum=  rrsdp * Qwater ; VB

    RETURN, {wl:input_spectra.wl,substrateR:input_spectra.substrateR,$
        input_spectra:input_spectra,$
        a:a,bb:bb,$
        ;a_star: [input_spectra.awater, [input_spectra.aphy_star], [acdom_star], [atr_star]],$
        ;bb_star: [input_spectra.bbwater,[bbph_star], [bbcdom_star],[ bbtr_star]],$
        R0:closed_spectrum,$
        R0dp:closed_deep_spectrum,$
        rrs:rrs,$
        rrsdp:rrsdp,$
        kd:Kd,$
        Kuc:Kuc,$
        Kub:Kub }
end
;****************************************************************

function sub5_SAMBUCA_SA_V12, Z
    common SAMBUCA_share, SAMBUCA

    ;prepare parameter values for forward run
    ZZ=fltarr(15)

    ZZ(SAMBUCA.opti_params.Zi)=Z       ;parameters to be optimised as passed from SAMBA via AMOEBA
    ZZ(SAMBUCA.opti_params.Fi)=SAMBUCA.opti_params.F       ;fixed parameters as passed from SAMBA in the common

    ; check if SIOPs are constant
    ; TODO !!!!
    ;X_ph_lambda0x = ZZ(4)      ;specific backscatter of chlorophyl at lambda0x
    ;X_tr_lambda0x = ZZ(5)      ;specific backscatter of tripton at lambda0x
    ;Sc = ZZ(6)            ; slope of cdom absorption
    ;Str = ZZ(7)               ; slope of tr absorption
    ;a_tr_lambda0tr = ZZ(8)

    ;prepare refelctance of the substrate  for forward run
    ;inputR= {spectra=all_subs.spectra, names:subs_names,  index:uintarr[2]}
    ;              inputR.index=[rr,rrr]

    index1 = SAMBUCA.inputR.index[0]
    index2 = SAMBUCA.inputR.index[1]
    r1 = SAMBUCA.inputR.spectra[SAMBUCA.inputR.index[0],*]
    r2 = SAMBUCA.inputR.spectra[SAMBUCA.inputR.index[1],*]
    q1 = ZZ(10)

    substrateR = (q1 * r1) + ( (1-q1)*r2 )     ;proportion of 1st (and second which equals 1-q1 ) end member spectra

    SAMBUCA.input_spectra.substrateR= substrateR

    ; run forward model
    spectra = SAMBUCA_SA_V12_fwdVB ( ZZ, SAMBUCA.input_spectra,SAMBUCA.input_params)
    ;help, spectra,/struc
    ;spectra = {wl:input_spectra.wl,$
    ;   R0:closed_spectrum,R0dp:closed_deep_spectrum,kd:Kd,Kuc:Kuc,Kub:Kub }
    SAMBUCA.input_spectra=spectra.input_spectra
    
    SAVE, /ALL, FILENAME = 'forward_model_test_data.sav'

    ; sensor filter test data
    filter = SAMBUCA.distances.nm_filter_function
    input_spectra = spectra.rrs
    output_spectra = spectra.rrs # SAMBUCA.distances.nm_filter_function
    SAVE, filter, input_spectra, output_spectra, FILENAME='sensor_filter_test_data.sav'

    ; move to the common output spectra
    if SAMBUCA.distances.run_1nm then begin
        SAMBUCA.imagespectra.closed_spectrum=spectra.R0 # SAMBUCA.distances.nm_filter_function
        SAMBUCA.imagespectra.closed_deep_spectrum=spectra.R0dp # SAMBUCA.distances.nm_filter_function
        SAMBUCA.imagespectra.Kd=spectra.Kd  # SAMBUCA.distances.nm_filter_function
        SAMBUCA.imagespectra.Kub=spectra.Kub  # SAMBUCA.distances.nm_filter_function
        SAMBUCA.imagespectra.Kuc=spectra.Kuc  # SAMBUCA.distances.nm_filter_function
    endif else begin
        SAMBUCA.imagespectra.closed_spectrum=spectra.R0
        SAMBUCA.imagespectra.closed_deep_spectrum=spectra.R0dp
        SAMBUCA.imagespectra.kd=spectra.kd
        SAMBUCA.imagespectra.kub=spectra.kub
        SAMBUCA.imagespectra.kuc=spectra.kuc
    endelse

    ; evaluate error function
    Qwater = ZZ(14)

    realrrs = SAMBUCA.imagespectra.image_spectrum  / Qwater
    noiserrs= SAMBUCA.imagespectra.Noise_spectrum / Qwater ;VB07 to fix after all the checks !
    rrs=SAMBUCA.imagespectra.closed_spectrum / Qwater

    ;print, rrs,realrrs

    ;ERROR FUNCTION TO BE OPTIMISED
    ;LSQ as in as in equation 1 of Mobley 2005 AO:i.e. without using Noise
    LSQ =   ( (TOTAL (  (double(realrrs) - double(rrs))^2,/double )  ) ^0.5)
    
    ;for test data generation, we need to copy these so they can be saved before the noise scaling,
    ;otherwise my unit tests fail and I spend a long time looking at the Python code getting confused :(
    realrrs_prediv = realrrs
    rrs_prediv = rrs
  
    if SAMBUCA.distances.use_noise then begin
        rrs=rrs/noiserrs
        realrrs=realrrs/noiserrs
    endif

    ;print, rrs,realrrs
    F_val =   ( (TOTAL (  (double(realrrs) - double(rrs))^2,/double )  ) ^0.5) / (TOTAL(double(realrrs)) )

    ;alpha
    Topline=TOTAL(double(realrrs)*double(rrs))
    Botline1=SQRT(TOTAL(double(realrrs)^2))
    Botline2=SQRT(TOTAL(double(rrs)^2))
    
    rat_denom = Botline1 * Botline2
    if rat_denom lt 1e-9 then begin
      rat_denom = 1e-9
    endif
    
    rat = Topline / rat_denom
    if rat lt 0 then begin
      rat = 0.0
    endif
    if rat gt 1.0 then begin
      rat = 1.0
    endif
    
    alpha_val = ACOS(rat)
    ;alpha_val=ACOS(Topline/(Botline1*Botline2))

;    if Botline1 eq 0 or Botline2 eq 0 then begin
;        rat=0.0
;    endif else begin
;        rat=Topline/(Botline1*Botline2)
;    endelse
;
;    if rat le 1 then begin
;        alpha_val=ACOS(rat)
;    endif else begin
;        alpha_val=100.0
;    endelse

    ;print,alpha_val,rat,Topline,Botline1,Botline2

    ;move the distance values to the common
    SAMBUCA.distances.distance_LSQ = LSQ
    SAMBUCA.distances.distance_alpha = alpha_val & SAMBUCA.distances.distance_f=F_val & SAMBUCA.distances.distance_alpha_f = F_val*alpha_val

    ;Daniel - saving test data for the Python error function unit tests
    error_a = alpha_val
    error_f = f_val
    error_af = f_val * alpha_val
    realrrs = realrrs_prediv
    rrs = rrs_prediv
    
    if rat lt 1.0 then begin
      if SAMBUCA.distances.use_noise then begin
        SAVE, realrrs, noiserrs, rrs, LSQ, error_a, error_f, error_af, FILENAME='noise_error_data.sav'
      endif else begin
        SAVE, realrrs, noiserrs, rrs, LSQ, error_a, error_f, error_af, FILENAME='no_noise_error_data.sav'
      endelse
    endif
    
    case SAMBUCA.distances.ERROR_TYPE of
        "a":  error = alpha_val
        "f":  error = f_val
        "af": error = F_val*(0.00000001+alpha_val)
    endcase
    ;print, LSQ,F_val,alpha_val,F_val*alpha_val,F_val*(0.00000001+alpha_val)

    ; retrieve Substrate detectability
    SubsDet_spectral=(abs((spectra.R0-spectra.R0dp)/SAMBUCA.imagespectra.Noise_spectrum))
    ;idx=where(closed_deep_diff_quanta)
    SAMBUCA.imagespectra.SDI =uint(max(SubsDet_spectral))
    SAMBUCA.imagespectra.subsdet=SubsDet_spectral

    ;retrieve the "water corrected" mixel
    ;r = (realrrs - rrsdp * (1.00 - exp(-(Kd+Kuc) * H)) ) /( (1.00/!DPI)  * exp(- ( Kd+Kub)* H)   )
    ; and  move to the two mixel spectra to the  common output spectra
    H = ZZ(13)
    water_corrected_mixel=  $
        ( (spectra.R0  / Qwater) - (spectra.R0dp/Qwater) * (1.00 - exp(-(spectra.Kd+spectra.Kuc) * H)) ) /( (1.00/!DPI)  * exp(- ( spectra.Kd+spectra.Kub)* H)   )

    ;WCmask=  water_corrected_mixel *0
    ;idx=where(SubsDet_spectral)
    ;if idx[0] ne -1 then WCmask[idx]=1
    ;water_corrected_mixel=water_corrected_mixel*WCmask

    if SAMBUCA.distances.run_1nm then begin
        SAMBUCA.imagespectra.water_corrected_mixel=water_corrected_mixel # SAMBUCA.distances.nm_filter_function
        SAMBUCA.imagespectra.unmixed_mixel=substrateR# SAMBUCA.distances.nm_filter_function
    endif else begin
        SAMBUCA.imagespectra.water_corrected_mixel=water_corrected_mixel
        SAMBUCA.imagespectra.unmixed_mixel=substrateR
    endelse

    ;VB09:WGOSW
    if SAMBUCA.distances.run_1nm then begin
        IOP_a=spectra.a # SAMBUCA.distances.nm_filter_function
        IOP_bb=spectra.bb # SAMBUCA.distances.nm_filter_function
    endif else begin
        IOP_a=spectra.a
        IOP_bb=spectra.bb
    endelse

    ;WGOSW={wl440:i_wls_abb_out[0],wl555:i_wls_abb_out[1],a440:0.,bb555:0.,    Rbot555:0.,    Z:0.,  LSQ:0.}
    SAMBUCA.WGOSW.a440=IOP_a[SAMBUCA.WGOSW.wl440]
    SAMBUCA.WGOSW.bb555=IOP_bb[SAMBUCA.WGOSW.wl555]
    SAMBUCA.WGOSW.Rbot555=SAMBUCA.imagespectra.unmixed_mixel[SAMBUCA.WGOSW.wl555]
    SAMBUCA.WGOSW.Z=H
    SAMBUCA.WGOSW.LSQ=LSQ

  RETURN, error
end

;=================================
pro SAMBUCA_plot_SIOP,pstate=pstate
    common SAMBUCA_share, SAMBUCA

    ;SAMBUCA.inputR.index=[0,1]

    ;DEFINING PARAMETERS
    if (*pstate).flag.get_z then $
        whole_guacamole=DO_whole_guacamole(pstate=pstate,zzzz=2.) $
    else $
        whole_guacamole=DO_whole_guacamole(pstate=pstate)

    ;hard-coded to 15 parameters
    ;appears to be determining indicies for the fixed (Fi) and free (Zi) parameters
    for cc=0, 14 do begin
        for ccc= 0, (n_elements(SAMBUCA.opti_params.Zin))- 1  do begin
            if [SAMBUCA.opti_params.Zin[ccc] EQ whole_guacamole.name[cc] ] then $
                SAMBUCA.opti_params.Zi[ccc] = cc
            if [ SAMBUCA.opti_params.Zin[ccc] EQ 'CHL' ] then chl_no = ccc
            if [ SAMBUCA.opti_params.Zin[ccc] EQ 'CDOM' ] then cdom_no = ccc
            if [ SAMBUCA.opti_params.Zin[ccc] EQ 'TR' ] then tr_no = ccc
            if [ SAMBUCA.opti_params.Zin[ccc] EQ 'q1' ] then q1_no = ccc
            if [ SAMBUCA.opti_params.Zin[ccc] EQ 'H' ] then H_no = ccc
        endfor

        for cccc = 0, (n_elements(SAMBUCA.opti_params.Fin)) - 1 do begin
            if [ SAMBUCA.opti_params.Fin[cccc] EQ whole_guacamole.name(cc) ] then SAMBUCA.opti_params.Fi[cccc] = cc
        endfor
    endfor

    ; VB07 update opti_params to Common
    SAMBUCA.opti_params.F=whole_guacamole.value[SAMBUCA.opti_params.Fi]

    Z = whole_guacamole.value[SAMBUCA.opti_params.Zi]
    ;help,rst,/struc

    a = [[SAMBUCA.input_spectra.awater],$
        [SAMBUCA.input_spectra.aphy_star],$
        [SAMBUCA.input_spectra.acdom_star],$
        [ SAMBUCA.input_spectra.atr_star],$
        [SAMBUCA.input_spectra.bbwater],$
        [SAMBUCA.input_spectra.bbph_star],$
        [SAMBUCA.input_spectra.bbtr_star]]
    ;help,a

    names=["awater ",   "aphy_star", "acdom_star" , "atr_star",$
        "bbwater" , "bbph_star" , "bbtr_star"]

    envi_plot_data,SAMBUCA.input_spectra.wl,a,plot_names=names

    return
end
;-
;**************************************************************************


pro SAMBUCA_2009, pstate=pstate
;Simulates subsurface Lu/ED spectra by running the SAMBUCA model FORward while varying input parameters,
; (such as water optical propterties, bottom substrate mixtures and depth) and adding random 1%
; reflectance (R(0-)) noise. SAMBUCA is then run bacKWARDs in order to test retrieveal
; of the input parameters. The calculations are all performed with spectra interpolated to one nanometers,
; altough the final evaluation of the spectral fit is done after applying a given sensor's response function
; to the modelled spectra.

    if ~ KEYWORD_SET(pstate) then begin
        print, "No pstate"
        return
    endif

    common SAMBUCA_share, SAMBUCA
    
    print_debug = 1

    ;===========================
    report_title="multi_SAMBUCA_2007"

    tic=systime(1)
    n_iter=0UL
    n_pixel_run=0UL
    n_pixel_conv=0UL
    ;**************************************************************************
    image_scale=(*pstate).values.image_scale
    Hmax=(*pstate).values.H_max
    deltaz=(*pstate).values.delta_z
    tidal_offset=(*pstate).values.tidal_offset
    ;**************************************************************************
    rundeep=(*pstate).flag.rundeep
    go_shallow=(*pstate).flag.go_shallow
    run_TR=(*pstate).flag.run_TR
    get_z=(*pstate).flag.get_z
    run_1nm=(*pstate).flag.run_1nm
    print_debug=(*pstate).flag.print_debug
    use_noise=(*pstate).flag.use_noise
    do_graph1=(*pstate).flag.do_graph1

    ;**************************************************************************
    ;get hold of the files from the state
    file_type= (*(*pstate).files.p_input_info).file_type
    case  file_type of
        ; 0: ENVI standard image, 4: ENVI library
        0 : image_info = (*(*pstate).files.p_input_info)
        4 : restore_envi_library,  fname=(*(*pstate).files.p_input_info).fname,lib=lib
    endcase

    image_scale=(*pstate).values.image_scale

    ; adjust ns & nl
    case  file_type of
        ; 0: ENVI standard image, 4: ENVI library
        0 : begin
            ns=image_info.ns
            nl=image_info.nl
            ;n_wavs_input=image_info.nb & wavs_input = pos
            wavs_input=where(image_info.wl gt 400. and image_info.wl lt 800., n_wavs_input )
            num_tiles=Image_info.num_tiles
            n_wavs=n_wavs_input
            out_wls=image_info.wl[wavs_input]
        end
        4 : begin
            ns=1+lib.dims[4]-lib.dims[3]
            ;n_wavs_input=lib.ns  & wavs_input= uindgen(nb) ;???
            wavs_input=where(lib.wl gt 400. and lib.wl lt 800., n_wavs_input )
            num_tiles=1
            n_wavs=n_wavs_input
            out_wls=lib.wl[wavs_input]
        end
    endcase

;; start the envi_report_init
;
;       case  file_type of
;       ; 0: ENVI standard image, 4: ENVI library
;         0 : envi_report_init, [Image_info.fname,(*(*pstate).files.p_noise_info).fname,$
;                        (*pstate).flag_str.sublib], base=base,title=report_title
;         4 : envi_report_init, [lib.fname,(*(*pstate).files.p_noise_info).fname, $
;                        (*pstate).flag_str.sublib], base=base,title=report_title
;       endcase


    ;=====================
    ; OPENING OUTPUT FILES
    case  file_type of
        ;0:ENVI standard image, 4: ENVI library
        0 : begin
            if STRPOS(Image_info.fname, '.') ne -1 then $
                dot=STRPOS(Image_info.fname, '.',/REVERSE_SEARCH) else $
                dot=STRLEN(Image_info.fname)-1
            out_name=strmid(Image_info.fname, 0,dot)
            extension=".img"
        end
        4 : begin
            if STRPOS(lib.fname, '.') ne -1 then $
                dot=STRPOS(lib.fname, '.',/REVERSE_SEARCH) else $
                dot=STRLEN(lib.fname)-1
            out_name=strmid(lib.fname, 0,dot)
            extension=".lib"
        end
    endcase

    runname=(*pstate).runname

    ;(*pstate).output.Kd
    ;(*pstate).output.Kub
    ;(*pstate).output.Kuc

    if (*pstate).output.depth_concs then out_name_ZCA=out_name+runname+'_depth_concs'+extension
    if (*pstate).output.distances  then out_name_dist=out_name+runname+'_distances'+extension
    if (*pstate).output.iter then out_name_iter=out_name+runname+'_iter'+extension
    if (*pstate).output.subs then out_name_subs=out_name+runname+'_subs'+extension
    if (*pstate).output.closed_spectra then out_name_R0=out_name+runname+'_closed_spectra'+extension
    if (*pstate).output.closed_deep_spectra then out_name_R0dp=out_name+runname+'_closed_deep_spectra'+extension
    if (*pstate).output.diff_deep_spectra  then out_name_R0dp_diff=out_name+runname+'_diff_deep_spectra'+extension
    if (*pstate).output.diff_spectra  then out_name_diff=out_name+runname+'_diff_spectra'+extension
    if (*pstate).output.UNmixel_spectra then out_name_unmix=out_name+runname+'_UNmixel_spectra'+extension
    if (*pstate).output.WCmixel_spectra then out_name_WCmix=out_name+runname+'_WCmixel_spectra'+extension
    if (*pstate).output.Kd then out_name_Kd=out_name+runname+'_Kd_spectra'+extension
    if (*pstate).output.Kub then out_name_Kub=out_name+runname+'_Kub_spectra'+extension
    if (*pstate).output.Kub then out_name_Kuc=out_name+runname+'_Kuc_spectra'+extension
    if (*pstate).output.SubsDet_spectra then out_name_SubsDet=out_name+runname+'_SubsDet_spectra'+extension
    if (*pstate).output.depth_concs then openw,out_ZCA,out_name_ZCA,/get_lun
    if (*pstate).output.distances  then openw,out_dist,out_name_dist,/get_lun
    if (*pstate).output.iter then openw,out_iter,out_name_iter,/get_lun
    if (*pstate).output.subs then openw,out_subs,out_name_subs,/get_lun
    if (*pstate).output.closed_spectra then openw,out_R0,out_name_R0,/get_lun
    if (*pstate).output.closed_deep_spectra then openw,out_R0dp,out_name_R0dp,/get_lun
    if (*pstate).output.diff_deep_spectra  then openw,out_R0dp_diff,out_name_R0dp_diff,/get_lun
    if (*pstate).output.diff_spectra  then openw,out_diff,out_name_diff,/get_lun
    if (*pstate).output.UNmixel_spectra then openw,out_unmix,out_name_unmix,/get_lun
    if (*pstate).output.WCmixel_spectra then openw,out_wcmix,out_name_wcmix,/get_lun
    if (*pstate).output.SubsDet_spectra then openw,out_SubsDet,out_name_SubsDet,/get_lun
    if (*pstate).output.Kd then openw,out_kd,out_name_kd,/get_lun
    if (*pstate).output.Kub then openw,out_kub,out_name_kub,/get_lun
    if (*pstate).output.Kuc then openw,out_kuc,out_name_kuc,/get_lun

    ;VB09
    out_name_WGOSW=out_name+runname+'_WGOSW'+extension
    openw,out_WGOSW,out_name_WGOSW,/get_lun

    if print_debug then journal, out_name+runname+'print_debug.txt'
    if print_debug then print,systime(0)

    ;-------------------------
    ;common imagespectra, image_spectrum, Noise_spectrum, closed_spectrum, closed_deep_spectrum
    ;common distances, dist_wl_index, distance_alpha , distance_f, distance_alpha_f

    ;READING IMAGE
    for i_tile=0L, num_tiles-1 do begin                       ; tile loop

        ; output arrays
        depth_t = fltarr(ns)
        fval_t = fltarr(ns)
        P_t = fltarr(ns)
        G_t = fltarr(ns)
        Tr_t = fltarr(ns)
        subs_t = fltarr(ns,SAMBUCA.inputR.n_spectra+1)
        SDI = fltarr(ns)
        dist_t=fltarr(ns,3)
        ;VB09:WGOSW
        WGOSW=fltarr(ns,5)

        n_iteration_spectrum=lonarr(ns)
        spectrum_time=fltarr(ns)

        closed_R0 = fltarr(ns,n_wavs) ; VB
        closed_R0dp = fltarr(ns,n_wavs) ; VB
        closed_deep_diff= fltarr(ns,n_wavs) ; VB
        closed_diff= fltarr(ns,n_wavs) ; VB
        WC_mixel= fltarr(ns,n_wavs) ; VB
        UN_mixel= fltarr(ns,n_wavs) ; VB
        SubsDet=fltarr(ns,n_wavs)
        Kd=fltarr(ns,n_wavs)
        Kub=fltarr(ns,n_wavs)
        Kuc=fltarr(ns,n_wavs)

        case  file_type of
        ; 0: ENVI standard image, 4: ENVI library
            0 : begin
                ;envi_report_stat, base,i_tile,num_tiles
                data_tile = envi_get_tile( image_info.tile_id, i_tile)
                case image_info.interleave of
                    0:  result=widget_message("IMAGE MUST BE BIL or BIP", /error)
                    1:  L_rs_t=float(data_tile) ; BIL: data_tile(ns,nb)
                    2:  L_rs_t=float(transpose(data_tile)) ; BIP: data_tile(nb,ns)
                endcase
                L_rs_t=image_scale*L_rs_t[*,wavs_input]
            end
            4 : begin
                L_rs_t=image_scale*lib.spectra[*,wavs_input]
            end
        endcase

        if get_Z then begin
            zfile_type= (*(*pstate).files.p_Z_info).file_type
            help, (*(*pstate).files.p_Z_info),/struc
            case  file_type of
                ; 0: ENVI standard image, 4: ENVI library
                0 :ZZZZZ= envi_get_data(fid=(*(*pstate).files.p_Z_info).fid,dims=[-1,0, ns-1,i_tile,i_tile],pos=0)
                4 : ZZZZZ= envi_get_data(fid=(*(*pstate).files.p_Z_info).fid,dims=[-1,0, ns-1,i_tile,i_tile],pos=0)
            endcase
            help, ZZZZZ
        endif

        tic_line=systime(1)
        for n = 0L,(ns-1) do begin ; pixel loop
        ;for n = 0,(1) do begin ; pixel loop
            if print_debug then print,systime(0)
            if print_debug then print,string([ i_tile,n, systime(1)-tic_line])

            case  file_type of
                ; 0: ENVI standard image, 4: ENVI library
                0 : begin
                    ;if print_debug then print,i_tile,n
                end
                4 : begin
                    envi_report_stat, base,n,ns
                end
            endcase

            min_amoeba = [0.0, 0.0, 0.0, 0.0, 0.0]
            min_fval = 2
            amoeba_converged=0b
            amoeba = 1.00
            min_ref1 = '******'
            min_ref2 = '******'
            min_rrr = 100
            min_rr = 100
            image_spectrum = L_rs_t[n,*]
            SAMBUCA.imagespectra.image_spectrum=image_spectrum
            start_spectrum_time=systime(1)

            ; check for '0' pixel
            if (total(image_spectrum) lt 0.00001) then begin
                depth_t[n] = 0.00
                fval_t[n] = .000
                P_t[n] = 0.00
                G_t[n] = 0.00
                Tr_t[n] = 0.00
                SDI[n]=0
                dist_t[n,*]=0.00 ;VB
            endif else begin ; pixel not zero proceed with inversion!
                n_pixel_run=n_pixel_run+1
                ; start iteration control variables
                n_iteration_spectrum[n]=0L

                ;if print_debug then print,i_tile,n , n_pixel_run

                ;==================================graph1
                do_graph1=(*pstate).flag.do_graph1
                if do_graph1 then begin
                    tlb=widget_base(column=1, title='Spectral matching through minimisation  ', mbar=bar)
                    draw=widget_draw(tlb, graphics_level=1, xsize=400, ysize=300)   ;graph for ping_SA minimisation
                    base1=widget_base(tlb, /row)
                    widget_control, tlb, /realize
                    widget_control, draw, get_value=winindex1
                    set_plot, 'win'
                    wset, winindex1
                    ;device, decomposed=0
                    ;loadct, 12
                endif
                ;======================================

                ;common input_reflectance, ref1, ref2              ; loop for input substrate spectra
                for rr = 0,SAMBUCA.inputR.n_spectra-1 do begin            ;n_spectra-1
                    for rrr = rr+1,SAMBUCA.inputR.n_spectra-1 do begin    ; n_spectra-2
                        ; VB07 update ref indexes to Common
                        SAMBUCA.inputR.index=[rr,rrr]

                        if print_debug then print,SAMBUCA.inputR.names[SAMBUCA.inputR.index]
                        ;======================================

                        ;DEFINING PARAMETERS
                        if get_Z then $
                            whole_guacamole=DO_whole_guacamole(pstate=pstate, zzzz=zzzzz[n]) else $
                            whole_guacamole=DO_whole_guacamole(pstate=pstate)

                        for cc=0, 14 do begin
                            for ccc= 0, (n_elements(SAMBUCA.opti_params.Zin))- 1  do begin
                                if [SAMBUCA.opti_params.Zin[ccc] EQ whole_guacamole.name[cc]] then SAMBUCA.opti_params.Zi[ccc] = cc
                                if [SAMBUCA.opti_params.Zin[ccc] EQ 'CHL'] then chl_no = ccc
                                if [SAMBUCA.opti_params.Zin[ccc] EQ 'CDOM'] then cdom_no = ccc
                                if [SAMBUCA.opti_params.Zin[ccc] EQ 'TR'] then tr_no = ccc
                                if [SAMBUCA.opti_params.Zin[ccc] EQ 'q1'] then q1_no = ccc
                                if [SAMBUCA.opti_params.Zin[ccc] EQ 'H'] then H_no = ccc
                            endfor

                            for cccc = 0, (n_elements(SAMBUCA.opti_params.Fin)) - 1 do begin
                                if [SAMBUCA.opti_params.Fin[cccc] EQ whole_guacamole.name(cc)] then SAMBUCA.opti_params.Fi[cccc] = cc
                            endfor
                        endfor

                        ; VB07 update opti_params to Common
                        SAMBUCA.opti_params.F=whole_guacamole.value[SAMBUCA.opti_params.Fi]

                        ; common opti_trajec is shared with the amoeba routine
                        common opti_trajec, trajec,ntry,Pupper,Plower

                        ; setting the depth range as a function of the substrates
                        ; the depth range is the intersection of the ranges of the two substrates
                        zmin=MAX([whole_guacamole.plower(13),SAMBUCA.InputR.Subs_Z[0,RR],SAMBUCA.InputR.Subs_Z[0,RRr]])
                        zmax=Min([whole_guacamole.pupper(13),SAMBUCA.InputR.Subs_Z[1,RR],SAMBUCA.InputR.Subs_Z[1,RRr]])

                        whole_guacamole.plower[13]=zmin
                        whole_guacamole.pupper[13]=zmax

                        Pupper = whole_guacamole.pupper[SAMBUCA.opti_params.Zi]
                        Plower = whole_guacamole.plower[SAMBUCA.opti_params.Zi]
                        p_start = whole_guacamole.start[SAMBUCA.opti_params.Zi]
                        p_scale = whole_guacamole.scale[SAMBUCA.opti_params.Zi]

                        ;print, 'fixed: ', whole_guacamole.name(Fi)
                        ;print, 'to be inverted:',whole_guacamole.name(Zi)
                        ;print, 'sum of parameters = ',n_elements(Zi) + n_elements(Fi)
                        ;==============================================

                        ntry=0
                        abs_tol = 1     ; largest (absolute) error function value accepted for retrieval of minimum
                        fractional_tol =1e-4 ; largest fractional decrease in error function accepted for retrieval of minimum
                        max_iterations = 500
                        ;max_iterations = 10
                        fval_threshold = .005
                        ;fval_threshold = .001
                        ;trajec=fltarr(n_elements(SAMBUCA.opti_params.Zi),max_iterations+5)
                        trajec=fltarr(n_elements(SAMBUCA.opti_params.Zi),max_iterations+15)

                        ;grid_steps=n_gridsteps ; number of stps in the grid

                        if zmin lt zmax then $
                            ;r = AMOEBA_CLW_grid(fractional_tol,abs_tol,function_name='sub5_SAMBUCA_SA_V12',SCALE =P_scale, P0=P_start,FUNCTION_VALUE=fval,ncalls=ncall,NMAX=max_iterations, grid_steps=grid_steps) $
                            r = AMOEBA_CLW7(fractional_tol,abs_tol,function_name='sub5_SAMBUCA_SA_V12',SCALE =P_scale, P0=P_start,FUNCTION_VALUE=fval,ncalls=ncall,NMAX=max_iterations) $
                        else $
                            r=-1

                        if print_debug then print, string([n_pixel_run,ntry,fval[0],r])
                        n_iter=n_iter+ntry
                        n_iteration_spectrum[n]=n_iteration_spectrum[n]+ntry

                        ;*******
                        ;CHECKING INVERSION SUCCESS AND WRITING ANSWERS TO TEMP ARRAYS
                        if (n_elements(r) GT 1) then begin   ;checking amoeba has an answer
                            if (fval(0) LT min_fval) then begin
                                min_fval = fval(0)
                                min_amoeba = r
                                min_rrr = rrr
                                min_rr = rr
                                amoeba_converged=1b
                            endif
                        endif      ; checking for amoeba having an answer
                    endfor       ; substrate loops
                endfor       ; substrate loops

                if print_debug then print,"out of the substrate loop"
                if print_debug then print,min_amoeba
                if print_debug then print,r
                if print_debug then print,amoeba_converged

                if ( amoeba_converged EQ 0) then begin
                    if print_debug then print,"AMOEBA did not converge"
                    ; AMOEBA did not converge:
                    ; set all the output values to the non converged code
                    depth_t[n] = -0.001
                    fval_t[n] = -0.001
                    P_t[n] = -0.001
                    G_t[n] = -0.001
                    Tr_t[n] =-0.001
                    SDI[n] =-0.001
                    dist_t[n,*]=-0.001 ;VB
                    WGOSW[n,*]=-0.001 ;VB
                    subs_t(n,SAMBUCA.inputR.n_spectra)=1.
                    closed_R0 [n,*] =make_array(/float,n_wavs, value=-0.001); VB
                    closed_R0dp [n,*] =make_array(/float,n_wavs, value=-0.001); VB
                    ;closed_deep_diff [n,*] =make_array(/float,n_wavs, value=-0.001); VB
                    closed_diff [n,*] =make_array(/float,n_wavs, value=-0.001); VB
                    WC_mixel[n,*]=make_array(/float,n_wavs, value=-0.001); VB
                    UN_mixel[n,*]=make_array(/float,n_wavs, value=-0.001); VB
                    SubsDet[n,*]=make_array(/float,n_wavs, value=-0.001); VB
                    Kd[n,*]=make_array(/float,n_wavs, value=-0.001); VB
                    Kub[n,*]=make_array(/float,n_wavs, value=-0.001); VB
                    Kuc[n,*]=make_array(/float,n_wavs, value=-0.001); VB
                endif else begin
                    ; AMOEBA did  converge:
                    if print_debug then print,"AMOEBA DID converge"
                    n_pixel_conv=n_pixel_conv+1
                    ;----------------------
                    ; run  forward with the solution to retrieve the closed spectra from the common
                    SAMBUCA.inputR.index=[min_rr,min_rrr]
                    if print_debug then print,"AMOEBA DID converge", SAMBUCA.inputR.names[SAMBUCA.inputR.index]

                    ;----------------------
                    ; if pixel is optically deep get as shallow as possible ....
                    ; i.e. run sambuca fwd fixing everything while decreasing depth
                    if go_shallow then begin
                        shallow_amoeba = min_amoeba
                        h_min = shallow_amoeba[H_no]
                        if print_debug then print,"AMOEBA DID converge:SDI= ", SAMBUCA.imagespectra.SDI
                        if print_debug then print,"AMOEBA DID converge:h_min= ", h_min

                        while SAMBUCA.imagespectra.SDI eq 0 and H_min gt 0.1 do begin
                            if print_debug then print,"AMOEBA go_shallow :SDI= ",SAMBUCA.imagespectra.SDI
                            ;while SAMBUCA.imagespectra.SDI eq 1 do begin
                            shallow_amoeba[H_no] = shallow_amoeba[H_no]*.9
                            h_min = shallow_amoeba[H_no]
                            if print_debug then print,"AMOEBA go_shallow :H= ",min_amoeba[h_no],shallow_amoeba[H_no]
                            result = sub5_SAMBUCA_SA_V12(shallow_amoeba)
                            ;if SAMBUCA.imagespectra.SDI eq 1 then  min_amoeba = shallow_amoeba
                            if SAMBUCA.imagespectra.SDI eq 0 then  min_amoeba = shallow_amoeba
                        endwhile

                        if print_debug then journal,"AMOEBA DID converge:SDI=0, shallow iteration finished"
                    endif;   go_shallow

                    ; run forward with the solution to retrieve the closed spectra from the common
                    result=sub5_SAMBUCA_SA_V12(min_amoeba)

                    if print_debug then journal,"AMOEBA DID converge: run fwd finished"
                    ;if print_debug then print, result,min_fval,fval

                    ; save min_amoeba to variables !
                    if run_TR eq 0 then begin
                        P_t[n] = min_amoeba[chl_no]
                        G_t[n] = min_amoeba[cdom_no]
                    endif

                    Tr_t[n] = min_amoeba[tr_no]
                    fval_t[n] = min_fval

                    if rundeep eq 0 then begin
                        depth_t[n] = min_amoeba[H_no]- tidal_offset
                        subs_t[n,min_rr]=min_amoeba[q1_no]
                        subs_t[n,min_rrr]=1-min_amoeba[q1_no]
                    endif

                    ;VB09:WGOSW
                    WGOSW[n,*]=[SAMBUCA.WGOSW.a440,$
                        SAMBUCA.WGOSW.bb555,$
                        SAMBUCA.WGOSW.Rbot555,$
                        SAMBUCA.WGOSW.Z,$
                        SAMBUCA.WGOSW.LSQ]

                    ; the spectra
                    closed_R0 [n,*] =SAMBUCA.imagespectra.closed_spectrum/image_scale; VB
                    closed_R0dp [n,*] =SAMBUCA.imagespectra.closed_deep_spectrum/image_scale; VB
                    closed_deep_diff[n,*]= closed_R0[n,*] - closed_R0dp[n,*]
                    closed_diff[n,*]= (SAMBUCA.imagespectra.image_spectrum - SAMBUCA.imagespectra.closed_spectrum)/image_scale

                    ; the two mixel spectra
                    WC_mixel[n,*]=SAMBUCA.imagespectra.water_corrected_mixel
                    UN_mixel[n,*]=SAMBUCA.imagespectra.unmixed_mixel
                    SubsDet[n,*]=SAMBUCA.imagespectra.SubsDet
                    kd[n,*]=SAMBUCA.imagespectra.kd
                    kub[n,*]=SAMBUCA.imagespectra.kub
                    kuc[n,*]=SAMBUCA.imagespectra.kuc

                    ; and all the three distances
                    dist_t[n,*]=[SAMBUCA.distances.distance_alpha , SAMBUCA.distances.distance_f, SAMBUCA.distances.distance_alpha_f]
                    ;index of optical depth
                    SDI[n]=SAMBUCA.imagespectra.SDI

                    ;----------------------   if deep=closed, flag pixel as optically deep
                    if SAMBUCA.imagespectra.SDI eq 1 then subs_t(n, SAMBUCA.inputR.n_spectra)=1.

                    if print_debug then journal,"AMOEBA DID converge: results copied to output arrays"

                endelse ; end of check for amoeba returning -1
            endelse ; end of check for 0 pixel

            spectrum_time[n]=1000.*(systime(1)-start_spectrum_time)
            if print_debug then print, systime(0)
            if print_debug then print, string([n_pixel_run,spectrum_time[n]])

        endfor ; pixel [n]

        ;WRITING OUT ANSWERS TO IMAGES

        case  file_type of
        ; 0: ENVI standard image, 4: ENVI library
            0 : begin
                if (*pstate).output.depth_concs then writeu, out_ZCA, (reform ([[P_t], [G_t],[Tr_t],[depth_t],[fval_t],SDI],ns,6)); depth_concs.lib
                if (*pstate).output.distances then writeu, out_dist , float(dist_t)
                if (*pstate).output.iter then writeu,out_iter, (reform ([float(n_iteration_spectrum),spectrum_time],ns,2))
                if (*pstate).output.subs then writeu, out_subs, fix((100*subs_t))
                if (*pstate).output.closed_spectra then writeu, out_R0, float((closed_R0))
                if (*pstate).output.closed_deep_spectra then writeu, out_R0dp, float((closed_R0dp))
                if (*pstate).output.diff_deep_spectra then writeu, out_R0dp_diff, float((closed_deep_diff))
                if (*pstate).output.diff_spectra then writeu, out_diff, float((closed_diff))
                if (*pstate).output.WCmixel_spectra then writeu, out_WCmix, float(WC_mixel)
                if (*pstate).output.UNmixel_spectra then writeu, out_UNmix, float(UN_mixel)
                if (*pstate).output.kd then writeu, out_kd, float(kd)
                if (*pstate).output.kub then writeu, out_kub, float(kub)
                if (*pstate).output.kuc then writeu, out_kuc, float(kuc)
                if (*pstate).output.SubsDet_spectra then writeu, out_SubsDet, float(SubsDet)
                ;VB09:WGOSW
                writeu, out_WGOSW, float(WGOSW)
            end
            4 : begin
                if (*pstate).output.depth_concs then  writeu, out_ZCA, transpose(reform ([[P_t], [G_t],[Tr_t],[depth_t],[fval_t],SDI],ns,6)); depth_concs.lib
                if (*pstate).output.distances  then writeu, out_dist , float(transpose(dist_t))
                if (*pstate).output.iter then writeu,out_iter, transpose(reform ([float(n_iteration_spectrum),spectrum_time],ns,2))
                if (*pstate).output.subs then writeu, out_subs, fix(transpose(100*subs_t))
                if (*pstate).output.closed_spectra then writeu, out_R0, float(transpose(closed_R0))
                if (*pstate).output.closed_deep_spectra then writeu, out_R0dp, float(transpose(closed_R0dp))
                if (*pstate).output.diff_deep_spectra  then writeu, out_R0dp_diff, float(transpose(closed_deep_diff))
                if (*pstate).output.diff_spectra  then writeu, out_diff, float(transpose(closed_diff))
                if (*pstate).output.WCmixel_spectra then   writeu, out_WCmix,   float(transpose(WC_mixel))
                if (*pstate).output.UNmixel_spectra then writeu, out_UNmix,   float(transpose(UN_mixel))
                if (*pstate).output.kd then writeu, out_kd,   float(transpose(kd))
                if (*pstate).output.kub then writeu, out_kub,   float(transpose(kub))
                if (*pstate).output.kuc then writeu, out_kuc,   float(transpose(kuc))
                if (*pstate).output.SubsDet_spectra then writeu, out_SubsDet, float(transpose(SubsDet))
                ;VB09:WGOSW
                writeu, out_WGOSW, float(transpose(WGOSW))
            end
        endcase
    endfor ; tile

    ;----------------------
    ;ENVI HEADERS FOR ANSWERS
    case  file_type of
    ;0: ENVI standard image, 4: ENVI library
        0 : begin
            if (*pstate).output.depth_concs then $
                ENVI_SETUP_HEAD, fname=out_name_ZCA, $
                ns=image_info.ns, nl=image_info.nl, nb=6, $
                file_type=file_type,$
                bnames=["CHL","CDOM","TR","Z","fval","SDI"],$
                interleave=1, data_type=4, $
                inherit=image_info.inherit_spatial,$
                descrip="concentrations",$
                /write, /open

            if (*pstate).output.subs then $
                ENVI_SETUP_HEAD, fname=out_name_SUBS, $
                ns=image_info.ns, nl=image_info.nl, nb= SAMBUCA.inputR.n_spectra+1, $
                file_type=file_type,$
                bnames=subs_names,$
                interleave=1, data_type=2, $
                def_stretch = ENVI_DEFAULT_STRETCH_CREATE(LINEAR, VAL1=0, VAL2=100),$
                inherit=image_info.inherit_spatial,$
                descrip="substrate relative abundance",$
                /write, /open

            if (*pstate).output.distances  then $
                ENVI_SETUP_HEAD, fname=out_name_dist, $
                ns=image_info.ns, nl=image_info.nl, nb=3, $
                file_type=file_type,$
                bnames=["distance_alpha" , "distance_f", "distance_alpha*f"],$
                interleave=1, data_type=4, $
                inherit=image_info.inherit_spatial,$
                descrip="spectral distances",$
                /write, /open

            if (*pstate).output.closed_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_R0, $
                ;ns=image_info.ns, nl=image_info.nl, nb=image_info.nb, $
                ;file_type=file_type,  wl=image_info.wl,$
                ;bnames=image_info.bnames,$
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="closed R0",$
                /write, /open

            if (*pstate).output.closed_deep_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_R0dp, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="closed R0 deep",$
                /write, /open

            if (*pstate).output.diff_deep_spectra  then $
                ENVI_SETUP_HEAD, fname=out_name_R0dp_diff, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="difference between closed R0 and  closed R0 deep",$
                /write, /open

            if (*pstate).output.diff_spectra  then $
                ENVI_SETUP_HEAD, fname=out_name_diff, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="difference between closed R0 and  image",$
                /write, /open

            if (*pstate).output.UNmixel_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_UNmix, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="substrate Unmixing mixel",$
                /write, /open

            if (*pstate).output.WCmixel_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_wcmix, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="substrate water corrected mixel",$
                /write, /open

            if (*pstate).output.kd then $
                ENVI_SETUP_HEAD, fname=out_name_kd, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="upwelling vertical attenuation Kd",$
                /write, /open

            if (*pstate).output.kub then $
                ENVI_SETUP_HEAD, fname=out_name_kub, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="upwelling vertical attenuation Kub",$
                /write, /open

            if (*pstate).output.kuc then $
                ENVI_SETUP_HEAD, fname=out_name_kuc, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="upwelling vertical attenuation Kuc",$
                /write, /open

            if (*pstate).output.SubsDet_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_SubsDet, $
                ns=image_info.ns, nl=image_info.nl, nb=n_wavs, $
                file_type=file_type,  wl=image_info.wl[wavs_input],$
                bnames=image_info.bnames[wavs_input],$
                inherit=image_info.inherit_spatial,$
                interleave=1, data_type=4, $
                descrip="Substrate detectability",$
                /write, /open

            if (*pstate).output.iter  then $
                ENVI_SETUP_HEAD, fname=out_name_iter, $
                ns=image_info.ns, nl=image_info.nl, nb=2, $
                file_type=file_type,$
                bnames=["n_iteration_spectrum","spectrum_time"],$
                interleave=1, data_type=4, $
                inherit=image_info.inherit_spatial,$
                descrip="iteration info",$
                /write, /open

            ;VB09:WGOSW
            ENVI_SETUP_HEAD, fname=out_name_WGOSW, $
            ns=image_info.ns, nl=image_info.nl, nb=5, $
            file_type=4,$
            bnames=["a_440","bb_555","Rbot555","Z","LSQ"],$
            interleave=1, data_type=4, $
            inherit=image_info.inherit_spatial,$
            descrip="output for Working Group for Optically Shallow Water",$
            /write, /open

        end ;case 0:
        4 : begin
            if (*pstate).output.depth_concs then $
                ENVI_SETUP_HEAD, fname=out_name_ZCA, $
                ns=6, nl=lib.nl, nb=1, $
                file_type=4,$
                spec_names=lib.spec_names,bnames=["CHL","CDOM","TR","Z","fval","SDI"],$
                interleave=0, data_type=4, $
                descrip="concentrations",$
                /write, /open

            if (*pstate).output.subs then $
                ENVI_SETUP_HEAD, fname=out_name_SUBS, $
                ns= SAMBUCA.inputR.n_spectra+1, nl=lib.nl, nb=1, $
                file_type=4,$
                spec_names=lib.spec_names,bnames=subs_names,$
                interleave=0, data_type=2, $
                descrip="substrate relative abundance",$
                /write, /open

            if (*pstate).output.distances  then $
                ENVI_SETUP_HEAD, fname=out_name_dist, $
                ns=3, nl=lib.nl, nb=1, $
                file_type=4,$
                spec_names=lib.spec_names,$
                bnames=["distance_alpha" , "distance_f", "distance_alpha*f"],$
                interleave=0, data_type=4, $
                descrip="spectral distances",$
                /write, /open

            if (*pstate).output.closed_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_R0, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="closed R0",$
                /write, /open

            if (*pstate).output.closed_deep_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_R0dp, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="closed R0 deep",$
                /write, /open

            if (*pstate).output.diff_deep_spectra  then $
                ENVI_SETUP_HEAD, fname=out_name_R0dp_diff, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="difference between closed R0 and  closed R0 deep",$
                /write, /open

            if (*pstate).output.diff_spectra  then $
                ENVI_SETUP_HEAD, fname=out_name_diff, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="difference between closed R0 and  image",$
                /write, /open

            if (*pstate).output.UNmixel_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_unmix, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="substrate Unmixing mixel",$
                /write, /open

            if (*pstate).output.WCmixel_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_wcmix, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="substrate water corrected mixel",$
                /write, /open

            if (*pstate).output.kd then $
                ENVI_SETUP_HEAD, fname=out_name_kd, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="downwelling vertical attenuation Kd",$
                /write, /open

            if (*pstate).output.kub then $
                ENVI_SETUP_HEAD, fname=out_name_kub, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="upwelling vertical attenuation Kub",$
                /write, /open

            if (*pstate).output.kuc then $
                ENVI_SETUP_HEAD, fname=out_name_kuc, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="upwelling vertical attenuation Kuc",$
                /write, /open

            if (*pstate).output.SubsDet_spectra then $
                ENVI_SETUP_HEAD, fname=out_name_SubsDet, $
                ns=n_wavs, nl=lib.nl, nb=1, $
                file_type=4,wl=out_wls,$
                spec_names=lib.spec_names,bnames=lib.bnames,$
                interleave=0, data_type=4, $
                descrip="Substrate detectability",$
                /write, /open

            if (*pstate).output.iter  then $
                ENVI_SETUP_HEAD, fname=out_name_iter, $
                ns=2, nl=lib.nl, nb=1, $
                file_type=4,$
                spec_names=lib.spec_names,$
                bnames=["n_iteration_spectrum","spectrum_time"],$
                interleave=0, data_type=4, $
                descrip="iteration info",$
                /write, /open

            ;VB09:WGOSW
            ENVI_SETUP_HEAD, fname=out_name_WGOSW, $
            ns=5, nl=lib.nl, nb=1, $
            file_type=4,$
            spec_names=lib.spec_names,$
            bnames=["a_440","bb_555","Rbot555","Z","LSQ"],$
            interleave=0, data_type=4, $
            descrip="output for Working Group for Optically Shallow Water",$
            /write, /open
        end ;case 4:
    endcase

    PRINT, "DC!!!!"

    if (*pstate).output.closed_deep_spectra then begin
        close, out_R0dp & free_lun, out_R0dp
    endif
    if (*pstate).output.closed_spectra then begin
        close, out_R0 & free_lun, out_R0
    endif
    if (*pstate).output.depth_concs then begin
        close, out_ZCA & free_lun, out_ZCA
    endif
    if (*pstate).output.subs  then begin
        close, out_subs & free_lun, out_subs
    endif
    if (*pstate).output.distances  then begin
        close, out_dist & free_lun, out_dist
    endif
    if (*pstate).output.diff_deep_spectra  then begin
        close, out_R0dp_diff & free_lun, out_R0dp_diff
    endif
    if (*pstate).output.diff_spectra  then begin
        close, out_diff & free_lun, out_diff
    endif
    if (*pstate).output.WCmixel_spectra then begin
        close, out_WCmix & free_lun, out_WCmix
    endif
    if (*pstate).output.UNmixel_spectra then begin
        close, out_unmix & free_lun, out_unmix
    endif
    if (*pstate).output.kd then begin
        close, out_kd & free_lun, out_kd
    endif
    if (*pstate).output.kub then begin
        close, out_kub & free_lun, out_kub
    endif
    if (*pstate).output.kuc then begin
        close, out_kuc & free_lun, out_kuc
    endif
    if (*pstate).output.SubsDet_spectra then begin
        close, out_SubsDet & free_lun, out_SubsDet
    endif
    ;if (*pstate).output.iter then begin$
    close,out_iter & free_lun, out_iter
    ;endif

    ;VB09:WGOSW
    close, out_WGOSW & free_lun,out_WGOSW

    ptr_free, pstate
    heap_gc

    ;envi_report_init, base=base, /finish
    PRINT,runname, " done in :", SYSTIME(1) - TIC, ' Seconds; ' , n_iter, ' total iterations', n_pixel_run,' total pixels', n_pixel_conv, ' pixel  converged'
    JOURNAL
end ;procedure SAMBUCA_2009

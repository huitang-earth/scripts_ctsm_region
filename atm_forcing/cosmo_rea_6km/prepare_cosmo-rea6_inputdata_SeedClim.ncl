load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;load "/projects/NS2806K/huit/reanalysis/cosmo_6km/unrot_lonlat.ncl"

begin

;#### lowest point
    plot_lat=(/61.0243,60.8231,60.8328,60.9335,60.8203,60.876,61.0866,60.5445,61.0355,60.8803,60.6652,60.6901/)
    plot_lon=(/8.12343,7.27596,7.17561,6.41504,8.70466,7.17666,6.63028,6.51468,9.07876,7.16982,6.33738,5.96487/)    
    plot_xfloor=(/61.0193,60.8181,60.8278,60.9285,60.8153,60.871,61.0816,60.5395,61.0305,60.8753,60.6602,60.6851/)
    plot_xceil =(/61.0293,60.8281,60.8378,60.9385,60.8253,60.881,61.0916,60.5495,61.0405,60.8853,60.6702,60.6951/)
    plot_yfloor=(/8.11843,7.27096,7.17061,6.41004,8.69966,7.17166,6.62528,6.50968,9.07376,7.16482,6.33238,5.95987/)
    plot_yceil =(/8.12843,7.28096,7.18061,6.42004,8.70966,7.18166,6.63528,6.51968,9.08376,7.17482,6.34238,5.96987/)

    plot_name=(/"ALP1","ALP2","ALP3","ALP4","SUB1","SUB2","SUB3","SUB4","BOR1","BOR2","BOR3","BOR4"/)

    clim_output   = "/cluster/work/users/huit/SeedClim/"
    clim_input    = "/cluster/shared/noresm/inputdata/atm/datm7/cosmo_rea_6km/clm_atmforcing"

    system("mkdir -p "+ clim_output)
    
    cruCreate=True

    mon = ispan(0,11,1)
    mon@units  = "month"
    month =cd_string(mon,"%N")   
    print(month)

    da = ispan(0,30,1)
    da@units  = "day"
    day =cd_string(da,"%D")   
    print(day)

    if (cruCreate) then
    do year=1995,2009,1       
      do m=0,11,1
         frsds=addfile(clim_input+"/clmforc.COSMOREA6.Solr."+year+"-"+month(m)+".nc","r")      
         fprec=addfile(clim_input+"/clmforc.COSMOREA6.Prec."+year+"-"+month(m)+".nc","r")
         ftpqwl=addfile(clim_input+"/clmforc.COSMOREA6.TPQWL."+year+"-"+month(m)+".nc","r")

         edgew   =frsds->EDGEW
         edgee   =frsds->EDGEE
         edges   =frsds->EDGES
         edgen   =frsds->EDGEN
         longxy  =frsds->LONGXY
         latixy  =frsds->LATIXY

         rsds1=frsds->SWDIFDS_RAD(:,:,:)
         rsds2=frsds->SWDIRS_RAD(:,:,:)

       
         prec    =fprec->PRECIPmms(:,:,:)
         rain_con=fprec->RAIN_CON(:,:,:)           ; !!!! time variable can be modified in the attributes of the variable is also copied. make sure to use (/ /) to only copy data.
         rain_gsp=fprec->RAIN_GSP(:,:,:)   
         snow_con=fprec->SNOW_CON(:,:,:)   
         snow_gsp=fprec->SNOW_GSP(:,:,:)  
         
         tbot    =ftpqwl->T(:,:,:)
         wind    =ftpqwl->WIND(:,:,:)
         psrf    =ftpqwl->PS(:,:,:)
         qbot    =ftpqwl->Q(:,:,:)
         flds    =ftpqwl->FLDS(:,:,:)
               
         printVarSummary(tbot)      

         time    =frsds->time(:)
         lon2d   =frsds->LONGXY(:,:)
         lat2d   =frsds->LATIXY(:,:)

         printVarSummary(lon2d)
         printVarSummary(lat2d)
         rsds1_plot=rcm2points(lat2d,lon2d,rsds1,plot_lat,plot_lon,0)           ; using inverse distance interpolation to avoid negative values
         rsds2_plot=rcm2points(lat2d,lon2d,rsds2,plot_lat,plot_lon,0)           ; using inverse distance interpolation to avoid negative values
         prec_plot=rcm2points(lat2d,lon2d,prec,plot_lat,plot_lon,0)
         rain_con_plot=rcm2points(lat2d,lon2d,rain_con,plot_lat,plot_lon,0)
         rain_gsp_plot=rcm2points(lat2d,lon2d,rain_gsp,plot_lat,plot_lon,0)     
         snow_con_plot=rcm2points(lat2d,lon2d,snow_con,plot_lat,plot_lon,0)
         snow_gsp_plot=rcm2points(lat2d,lon2d,snow_gsp,plot_lat,plot_lon,0)    
 
         tbot_plot=rcm2points(lat2d,lon2d,tbot,plot_lat,plot_lon,0)
         wind_plot=rcm2points(lat2d,lon2d,wind,plot_lat,plot_lon,0)        
         psrf_plot=rcm2points(lat2d,lon2d,psrf,plot_lat,plot_lon,0)
         qbot_plot=rcm2points(lat2d,lon2d,qbot,plot_lat,plot_lon,0)
         flds_plot=rcm2points(lat2d,lon2d,flds,plot_lat,plot_lon,0)         


         printVarSummary(prec_plot)
 
;###
         do nplot=0,11,1

            system("rm -f "+clim_output+plot_name(nplot)+"/clm1pt_"+plot_name(nplot)+"_"+year+"-"+month(m)+".nc")    ; remove if exists
            system("mkdir -p "+ clim_output + plot_name(nplot))           

            fclim  = addfile(clim_output+plot_name(nplot)+"/clm1pt_"+plot_name(nplot)+"_"+year+"-"+month(m)+".nc","c")
            ntim  = dimsizes(time)                 ; get dimension sizes                                                 
            nlat  = 1  
            nlon  = 1
            nscalar = 1

            setfileoption(fclim,"DefineMode",True)
            fAtt               = True            ; assign file attributes
            fAtt@case_title    = "COSMOREA6: SEEDCLIM"  
            fAtt@conventions   = "CF-1.0" 
            fAtt@title         = "CLM single point datm input data"  
            fAtt@history       = "Original data from COSMOREA6 data"
            fAtt@creation_date = systemfunc ("date")        
            fileattdef( fclim, fAtt )            ; copy file attributes  

            dimNames = (/"scalar","lon","lat","time"/)  
            dimSizes = (/ nscalar, nlon, nlat, -1 /) 
            dimUnlim = (/ False, False, False, True/)   
            filedimdef(fclim,dimNames,dimSizes,dimUnlim)

            filevardef(fclim, "EDGEW" ,typeof(edgew),getvardims(edgew)) 
            filevardef(fclim, "EDGEE"  ,typeof(edgee),getvardims(edgee))                           
            filevardef(fclim, "EDGES"  ,typeof(edges),getvardims(edges))                          
            filevardef(fclim, "EDGEN"  ,typeof(edgen),getvardims(edgen))                          
            filevardef(fclim, "LONGXY" ,typeof(longxy)  ,getvardims(longxy))    
            filevardef(fclim, "LATIXY"  ,typeof(latixy) ,getvardims(latixy))   
            filevardef(fclim, "SWDIFDS_RAD",typeof(rsds1),getvardims(rsds1))
            filevardef(fclim, "SWDIRS_RAD",typeof(rsds2),getvardims(rsds2))
            filevardef(fclim, "RAIN_CON",typeof(rain_con),getvardims(rain_con))
            filevardef(fclim, "RAIN_GSP",typeof(rain_con),getvardims(rain_con))
            filevardef(fclim, "SNOW_GSP",typeof(rain_con),getvardims(rain_con))
            filevardef(fclim, "SNOW_CON",typeof(rain_con),getvardims(rain_con))
            filevardef(fclim, "PRECTmms",typeof(prec),getvardims(prec))            
            filevardef(fclim, "TBOT",typeof(tbot),getvardims(tbot))
            filevardef(fclim, "WIND",typeof(wind),getvardims(wind))
            filevardef(fclim, "PSRF",typeof(psrf),getvardims(psrf))
            filevardef(fclim, "SHUM",typeof(qbot),getvardims(qbot)) 
            filevardef(fclim, "FLDS",typeof(flds),getvardims(flds))
            filevardef(fclim, "time",typeof(time),getvardims(time))          

            filevarattdef(fclim,"EDGEW",edgew)                           
            filevarattdef(fclim,"EDGEE",edgee)                   
            filevarattdef(fclim,"EDGES",edges)                    
            filevarattdef(fclim,"EDGEN",edgen)                    
            filevarattdef(fclim,"LONGXY",longxy)                     
            filevarattdef(fclim,"LATIXY",latixy)                      
            filevarattdef(fclim,"SWDIFDS_RAD",rsds1)
            filevarattdef(fclim,"SWDIRS_RAD",rsds2)
            filevarattdef(fclim,"RAIN_CON",rain_con)  
            filevarattdef(fclim,"RAIN_GSP",rain_con)  
            filevarattdef(fclim,"SNOW_CON",rain_con)  
            filevarattdef(fclim,"SNOW_GSP",rain_con)    
            filevarattdef(fclim,"PRECTmms",prec)    
            filevarattdef(fclim,"TBOT",tbot)
            filevarattdef(fclim,"WIND",wind)
            filevarattdef(fclim,"PSRF",psrf)
            filevarattdef(fclim,"SHUM",qbot)
            filevarattdef(fclim,"FLDS",flds)   
            filevarattdef(fclim,"time",time)  

            setfileoption(fclim,"DefineMode",False)


            fclim->time   = (/time/)        ; "(/", "/)" syntax tells NCL to only output the data values to the predefined locations on the file.
            fclim->EDGEW  = (/plot_xfloor(nplot)/)
            fclim->EDGEE  = (/plot_xceil(nplot)/) 
            fclim->EDGES  = (/plot_yfloor(nplot)/) 
            fclim->EDGEN  = (/plot_yceil(nplot)/)
            fclim->LONGXY = (/plot_lon(nplot)/)
            fclim->LATIXY  = (/plot_lat(nplot)/)
            fclim->SWDIFDS_RAD   = (/rsds1_plot(:,nplot)/) 
            fclim->SWDIRS_RAD   = (/rsds2_plot(:,nplot)/)    
            fclim->RAIN_CON   = (/rain_con_plot(:,nplot)/)         ; !!!! time variable can be modified in the attributes of the variable is also copied. make sure to use (/ /) to only copy data.
            fclim->RAIN_GSP   = (/rain_gsp_plot(:,nplot)/)
            fclim->SNOW_CON   = (/snow_con_plot(:,nplot)/)
            fclim->SNOW_GSP   = (/snow_gsp_plot(:,nplot)/)
            fclim->PRECTmms  = (/prec_plot(:,nplot)/)
            fclim->TBOT   = (/tbot_plot(:,nplot)/)
            fclim->WIND   = (/wind_plot(:,nplot)/)
            fclim->PSRF   = (/psrf_plot(:,nplot)/)
            fclim->SHUM   = (/qbot_plot(:,nplot)/)
            fclim->FLDS   = (/flds_plot(:,nplot)/)
         end do

         delete(time)
         delete(rsds1)
         delete(rsds2)
         delete(rain_gsp)
         delete(rain_con)
         delete(snow_gsp)
         delete(snow_con)
         delete(prec)
         delete(tbot)
         delete(wind)
         delete(psrf)
         delete(qbot)
         delete(flds)

         delete(rsds1_plot)
         delete(rsds2_plot)
         delete(rain_gsp_plot)
         delete(rain_con_plot)
         delete(snow_gsp_plot)
         delete(snow_con_plot)
         delete(prec_plot)
         delete(tbot_plot)
         delete(wind_plot)
         delete(psrf_plot)
         delete(qbot_plot)
         delete(flds_plot)
      end do
   end do
   end if

   
end
  




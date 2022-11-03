load "/cluster/software/NCL/6.6.2-intel-2020a/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/cluster/software/NCL/6.6.2-intel-2020a/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/cluster/software/NCL/6.6.2-intel-2020a/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/cluster/software/NCL/6.6.2-intel-2020a/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/cluster/software/NCL/6.6.2-intel-2020a/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "/cluster/software/NCL/6.6.2-intel-2020a/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  indir_prefix="/cluster/projects/nn2806k/huit/ryan_albedo"   ; pleae change the directory according to your own data folder

  f1           = addfile(indir_prefix+"/Surface_data_UiO.nc","r")
  f2           = addfile(indir_prefix+"/Fenno_mask_UiO.nc","r")

  lat          = f1->Latitude(::-1)
  lon          = f1->Longitude(:)
  landsea      = f2->Fennoscandic_Mask(:,::-1)
  printVarSummary(lat)
  printVarSummary(lon)
  printVarSummary(landsea)


  Opt1                = True
  Opt1@ForceOverwrite = True
  Opt1@PrintTimings    = True
  Opt1@Title           = "Fenno Grid"
  Opt1@GridMask        = landsea(row|:,col|:)

  rectilinear_to_SCRIP(indir_prefix+"/SCRIPgrid_Fenno_land_mask.nc",lat,lon,Opt1)
    
end 

# This document explain: 
- how COSMO REA 6km data (COSMOREA) has been processed to be usable for CTSM,
- How CTSM should be configured to read COSMOREA properly for regional or singale site simulations.

# pre-processing COSMO REA 6km data 
- Raw data of COSMO REA 6km are downloaded from:  https://opendata.dwd.de/climate_environment/REA/COSMO_REA6/
- Use "prepare_cosmo-rea6_inputdata.ncl" to prepare data files to be usable for CTSM
  -- The ready-use data are kept on FRAM: /cluster/shared/noresm/inputdata/atm/datm7/cosmo_rea_6km/clm_atmforcing
- Use "prepare_cosmo-rea6_inputdata_SeedClim.ncl" to prepare single-site forcing data for Vestland Climate Grids. 
  -- The ready-use data are kept on SAGA: /cluster/projects/nn2806k/COSMOREA_VCG

# creat mesh file for COSMOREA forcing (not needed if using single-site forcing data)
- create mesh file of COSMOREA
```
# create script grid for COSMOREA 
ncl prepare_scriptgrid_COSMO_ocean.ncl

# creat mesh file 
./create_mesh.sh
```
# modify datm settings for using COSMOREA in ctsm
- To use regional COSMOREA data, replace the following files with the files provided in "ctsm_config_reg" (This works for both regional and any single site simulations)
```
ctsm/components/cdeps/datm/cime_config/namelist_definition_datm.xml
ctsm/components/cdeps/datm/cime_config/stream_definition_datm.xml
ctsm/components/cdeps/datm/cime_config/config_component.xml
```

- To use single-site COSMOREA data for VCG, replace the above files with the files provided in "ctsm_config_VCG" (This works only for VCG sites)
- To better track what has been modified, please compare the files with that in "ctsm_config_default". Minor adjustment can be done according to your need.




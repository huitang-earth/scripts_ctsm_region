# Workflow for regional CTSM simulation, with a focus on creating mesh files for different land and atmospheric domains (on FRAM)

## Make script grid for desired land or atmospheric domain.

  - use ncl script here: `prepare_scriptgrid_fenno_ocean.ncl` (*land mask need to be 1*)
  - detailed instruction is in the file.
  - ***would be good to improve this part (e.g., using python)***
```
module load NCL/6.6.2-intel-2020a
ncl prepare_scriptgrid_fenno_ocean.ncl
```

## Creat mesh file 
  - use shell script and ESMF applications here: `create_mesh.sh`
  - detailed instruction is in the file. 
  - ***would be good to improve this part (e.g., using python and ESMPy)***
```
./create_mesh.sh
```

## Set up ctsm simulation
- Download newest ctsm model version (e.g. your home directory $HOME) 
```
# Go to home directory on fram
cd $HOME   

# Clone CTSM
git clone https://github.com/ESCOMP/CTSM.git  

# Go to model folder
cd CTSM  

# Load external model and libraries for running CTSM
./manage_externals/checkout_externals  
```
- Download dotcime for setting compiling/running environment of CTSM
```
# Go to home directory on fram
cd $HOME  

# Clone dotcime
git clone https://github.com/MetOs-UiO/dotcime.git  

# Move dotcime to .cime
mv dotcime .cime
```
- Creat a running case of CTSM
```
# Go to script folder of ctsm
cd $HOME/CTSM/cime/scripts/

# Creat a new case  
./create_newcase --case ../../../ctsm_cases/2000CLM-SP_clm5.1dev113 --compset 2000_DATM%GSWP3v1_CLM51%SP_SICE_SOCN_MOSART_SGLC_SWAV --res CLM_USRDAT --machine fram --run-unsupported --project nn2806k

# Go into case folder
cd $HOME/ctsm_cases/2000CLM-SP_clm5.1dev113

# set up cpus used in the case.
Go to env_mach_pes.xml, modify the following parts accordingly.
--------------------------------------------
    <entry id="NTASKS">
      <type>integer</type>
      <values>
        <value compclass="ATM">-2</value>
        <value compclass="CPL">-2</value>
        <value compclass="OCN">-2</value>
        <value compclass="WAV">-2</value>
        <value compclass="GLC">-2</value>
        <value compclass="ICE">-2</value>
        <value compclass="ROF">-2</value>
        <value compclass="LND">-2</value>
        <value compclass="ESP">1</value>
--------------------------------------------

# Set up the case
./case.setup
```
- Set up the inputdata correctly
1.  Surface data: go to `user_nl_clm` in the case folder. Add addition line as following
```
fsurdat='/cluster/projects/nn2806k/huit/inputdata/lnd/clm2/surfdata_map/surfdata_fenno_5x5km_simyr2000_0.5x0.5lai.nc'
``` 
- This is an old surface data I generated for the nordic region.
- *If you want to make new surface data for specific domain on your own, please follow the [scripts](https://github.com/huitang-earth/NLP_prep/blob/main/workflow_setup_site_simulation.sh) L101-136 on github (work for SAGA)*
- ***This is the part that need to be streamlined too***. Simple solution is to overwrite *mkmapdata.sh* with the one provided in the repo.

2. Mesh files: need to modify `env_run.xml` in the case folder. Use the same mesh file seem to work for my testing case.
```
# set up atm mesh file:
./xmlchange --file env_run.xml --id ATM_DOMAIN_MESH --val /cluster/projects/nn2806k/huit/inputdata/share/meshes/0.05x0.05_mesh_landmask.nc

# set up lnd mesh file:
./xmlchange --file env_run.xml --id LND_DOMAIN_MESH --val /cluster/projects/nn2806k/huit/inputdata/share/meshes/0.05x0.05_mesh_landmask.nc

# set up mask mesh file:
./xmlchange --file env_run.xml --id MASK_MESH --val /cluster/projects/nn2806k/huit/inputdata/share/meshes/0.05x0.05_mesh_landmask.nc
```
3. Change other running settings
```
# set up the time unit (e.g., nyears, nmonths, ndays).
./xmlchange --file env_run.xml --id STOP_OPTION --val nmonths   

# set up the length of the simulation.
./xmlchange --file env_run.xml --id STOP_N --val 2
```
## Build and run ctsm simulations
```
# Go to case folder
cd $HOME/ctsm_cases/2000CLM-SP_clm5.1dev113

# Build the case (about 10 minutes)
./case.build

# Run the case (about 10 minutes)
./case.submit 
```
## Check the output
```
# Go to the archive folder (output in netcdf format)
cd $USERWORK/archive/2000CLM-SP_clm5.1dev113/lnd/hist
```

## Adding new atmospheric forcing and its mesh file
- To be done!

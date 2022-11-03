#!/bin/bash

#SBATCH --account=nn2806k
#SBATCH --job-name=mesh
#SBATCH --time=1:59:00
#SBATCH --nodes=1 --ntasks-per-node=32

module purge --force
module load StdEnv
module load ESMF/8.2.0-intel-2021b
module list

#file_i=/cluster/projects/nn2806k/huit/ryan_albedo/SCRIPgrid_Fenno_ocean_mask.nc
file_i=/cluster/projects/nn2806k/huit/ryan_albedo/SCRIPgrid_Fenno_land_mask.nc
file_o=/cluster/projects/nn2806k/huit/inputdata/share/meshes/0.05x0.05_mesh_landmask.nc
mpirun -np 1 ESMF_Scrip2Unstruct $file_i $file_o  0 ESMF

#file_i=/cluster/projects/nn2806k/huit/ryan_albedo/SCRIPgrid_COSMOREA6_nomask.nc
#file_o=/cluster/projects/nn2806k/huit/inputdata/share/meshes/COSMOREA6_nomask_mesh.nc
#mpirun -np 32 ESMF_Scrip2Unstruct $file_i $file_o  0 ESMF

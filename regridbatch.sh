#!/bin/bash
#
#
# Batch script to submit to create mapping files for all standard
# resolutions.  If you provide a single resolution via "$RES", only
# that resolution will be used. In that case: If it is a regional or
# single point resolution, you should set '#PBS -n' to 1, and be sure
# that '-t regional' is specified in cmdargs.
#
# cheyenne specific batch commands:

#SBATCH --account=nn2806k 
#SBATCH --job-name=mkmapdata
#SBATCH --mem-per-cpu=256G --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --time=05:00:00

source /cluster/bin/jobsetup
module load ESMF/8.2.0-intel-2021b
module load NCO/5.0.3-intel-2021b 
#module load NCL/6.6.2-intel-2019b

#export ESMF_NETCDF_LIBS="-lnetcdff -lnetcdf -lnetcdf_c++"
#export ESMF_DIR=/usit/abel/u1/huit/ESMF/esmf
#export ESMF_COMPILER=intel
#export ESMF_COMM=openmpi
#export ESMF_NETCDF="test"
#export ESMF_NETCDF_LIBPATH=/cluster/software/ESMF/8.0.0-intel-2019b/lib
#export ESMF_NETCDF_INCLUDE=/cluster/software/ESMF/8.0.0-intel-2019b/include
ulimit -s unlimited

export ESMFBIN_PATH=/cluster/software/ESMF/8.2.0-intel-2021b/bin
export CSMDATA=/cluster/shared/noresm/inputdata
export MPIEXEC=mpirun

#phys="clm4_5"
RES="1x1"
GRIDFILE="/cluster/projects/nn2806k/huit/ryan_albedo/SCRIPgrid_Fenno_nomask.nc"


#----------------------------------------------------------------------
# Set parameters
#----------------------------------------------------------------------

#----------------------------------------------------------------------
# Begin main script
#----------------------------------------------------------------------

if [ -z "$RES" ]; then
   echo "Run for all valid resolutions"
   resols=`../../bld/queryDefaultNamelist.pl -res list -silent`
   if [ ! -z "$GRIDFILE" ]; then
      echo "When GRIDFILE set RES also needs to be set for a single resolution"
      exit 1
   fi
else
   resols="$RES"
fi
if [ -z "$GRIDFILE" ]; then
  grid=""
else
   if [[ ${#resols[@]} > 1 ]]; then
      echo "When GRIDFILE is specificed only one resolution can also be given (# resolutions ${#resols[@]})"
      echo "Resolutions input is: $resols"
      exit 1
   fi
   grid="-f $GRIDFILE"
fi

if [ -z "$MKMAPDATA_OPTIONS" ]; then
   echo "Run with standard options"
   options=" "
else
   options="$MKMAPDATA_OPTIONS"
fi
echo "Create mapping files for this list of resolutions: $resols"

#----------------------------------------------------------------------

for res in $resols; do
   echo "Create mapping files for: $res"
#----------------------------------------------------------------------
   cmdargs="-r $res $grid $options"

   # For single-point and regional resolutions, tell mkmapdata that
   # output type is regional
   if [[ `echo "$res" | grep -c "1x1_"` -gt 0 || `echo "$res" | grep -c "5x5_"` -gt 0 ]]; then
       res_type="regional"
   else
       res_type="global"
   fi
   # Assume if you are providing a gridfile that the grid is regional
   if [ $grid != "" ];then
       res_type="regional"
   fi

   cmdargs="$cmdargs -t $res_type"

   echo "$res_type"
   if [ "$res_type" = "regional" ]; then
       echo "regional"
       # For regional and (especially) single-point grids, we can get
       # errors when trying to use multiple processors - so just use 1.
       regrid_num_proc=1
   else
       echo "global"
       regrid_num_proc=8
   fi

   if [ ! -z "$LSFUSER" ]; then
       echo "batch"
       cmdargs="$cmdargs -b"
   fi
   if [ ! -z "$PBS_O_WORKDIR" ]; then
       cd $PBS_O_WORKDIR
       cmdargs="$cmdargs -b"
   fi

   echo "args: $cmdargs"
   echo "time env REGRID_PROC=$regrid_num_proc ./mkmapdata.sh $cmdargs\n"
   time env REGRID_PROC=$regrid_num_proc ./mkmapdata.sh $cmdargs -v
done

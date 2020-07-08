ROOT=..

export MESHFUSION_PATH=$ROOT/external/mesh-fusion
export HDF5_USE_FILE_LOCKING=FALSE # Workaround for NFS mounts

INPUT_PATH=$ROOT/data/external/pix3d/model

MANIFOLD_BUILD_PATH=$ROOT/data/build/pix3d_manifold_build
MANIFOLDPLUS_BUILD_PATH=$ROOT/data/build/pix3d_manifoldPlus_build
OCCUPANCY_BUILD_PATH=$ROOT/data/build/pix3d_build

MANIFOLD_OUTPUT_PATH=$ROOT/data/external/pix3d/occupancy_manifold_small
MANIFOLDPLUS_OUTPUT_PATH=$ROOT/data/external/pix3d/occupancy_manifoldPlus_small
OCCUPANCY_OUTPUT_PATH=$ROOT/data/external/pix3d/occupancy_small
SN_OUTPUT_PATH=$ROOT/data/pix3d_SN

NPROC=0
TIMEOUT=180

declare -a CLASSES=(
bed
bookcase
chair
desk
misc
sofa
table
tool
wardrobe
)

# Utility functions
lsfilter() {
 folder=$1
 other_folder=$2

 for d in "$folder"/*; do
   dirname=$(basename $d)
   if [ -f $folder/$dirname/model.obj ] && [ ! -f $other_folder/${dirname}.obj ] && [ ! -d $other_folder/${dirname}.obj ]; then
    echo $dirname
   fi
 done
}

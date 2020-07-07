ROOT=..

export MESHFUSION_PATH=$ROOT/external/mesh-fusion
export HDF5_USE_FILE_LOCKING=FALSE # Workaround for NFS mounts

#INPUT_PATH=$ROOT/data/external/Pix3d/model
INPUT_PATH=$ROOT/data/external/Pix3d/model

MANIFOLD_BUILD_PATH=$ROOT/data/build/Pix3d_manifold_build
MANIFOLDPLUS_BUILD_PATH=$ROOT/data/build/Pix3d_manifoldPlus_build
OCCUPANCY_BUILD_PATH=$ROOT/data/build/Pix3d_build

MANIFOLD_OUTPUT_PATH=$ROOT/data/external/Pix3d/occupancy_manifold
MANIFOLDPLUS_OUTPUT_PATH=$ROOT/data/external/Pix3d/occupancy_manifoldPlus
OCCUPANCY_OUTPUT_PATH=$ROOT/data/external/Pix3d/occupancy
SN_OUTPUT_PATH=$ROOT/data/Pix3d_SN

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

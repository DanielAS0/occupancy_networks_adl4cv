source dataset_pix3d/config.sh

# Function for processing a single model
reorganize_data() {
  modelname=$(basename "$1")
  output_path=$2/$modelname
  build_path=$3
  mkdir -p $output_path
  cp "$build_path/2_watertight/$modelname.obj" "$output_path/model.obj"
  cp "$build_path/4_points/$modelname.npz" "$output_path/points.npz"
  cp "$build_path/4_pointcloud/$modelname.npz" "$output_path/pointcloud.npz"
}

export -f reorganize_data

# Make output directories
mkdir -p $MANIFOLDPLUS_OUTPUT_PATH

# Run build
for c in ${CLASSES[@]}; do

  echo "Parsing class $c"
  BUILD_PATH_C=$MANIFOLDPLUS_BUILD_PATH/$c
  OUTPUT_PATH_C=$MANIFOLDPLUS_OUTPUT_PATH/$c
  INPUT_PATH_C=$INPUT_PATH/$c
  mkdir -p $OUTPUT_PATH_C
  ls $INPUT_PATH_C | parallel -P $NPROC --timeout $TIMEOUT \
    reorganize_data {} $OUTPUT_PATH_C $BUILD_PATH_C

done

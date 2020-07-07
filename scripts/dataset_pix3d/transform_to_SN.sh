source dataset_pix3d/config.sh

# Function for processing a single model
reorganize_data() {
  modelname=$(basename "$1")
  output_path=$2/$modelname
  build_path=$3
  mkdir -p $output_path
  cp "$build_path/4_points/$modelname.npz" "$output_path/points.npz"
  cp "$build_path/4_pointcloud/$modelname.npz" "$output_path/pointcloud.npz"
  # Copy default .binvox file (not used for occnet but required for dataloader)
  cp '/home/daniel/ADL4CV/datasets/OccNet/ShapeNet/02828884/1a40eaf5919b1b3f3eaa2b95b99dae6/model.binvox' "$output_path/model.binvox"
}

export -f reorganize_data

# Make output directories
mkdir -p $SN_OUTPUT_PATH

build_path=$MANIFOLDPLUS_BUILD_PATH
output_path=$SN_OUTPUT_PATH

# Copy points
for c in ${CLASSES[@]}; do

  echo "Parsing class $c"
  BUILD_PATH_C=$build_path/$c
  OUTPUT_PATH_C=$output_path/$c
  INPUT_PATH_C=$INPUT_PATH/$c
  mkdir -p $OUTPUT_PATH_C
  ls $INPUT_PATH_C | parallel -P $NPROC --timeout $TIMEOUT \
    reorganize_data {} $OUTPUT_PATH_C $BUILD_PATH_C

done

# Process and copy images and train/test split
python process_pix3d_SN.py

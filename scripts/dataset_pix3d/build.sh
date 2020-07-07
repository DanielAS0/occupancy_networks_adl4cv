source dataset_pix3d/config.sh
# Make output directories
mkdir -p $OCCUPANCY_BUILD_PATH

# Run build
for c in ${CLASSES[@]}; do
  echo "Processing class $c"
  input_path_c=$INPUT_PATH/$c
  build_path_c=$OCCUPANCY_BUILD_PATH/$c

  mkdir -p $build_path_c/0_in \
           $build_path_c/1_scaled \
           $build_path_c/1_transform \
           $build_path_c/2_depth \
           $build_path_c/2_watertight \
           $build_path_c/3_simplified \
           $build_path_c/4_points \
           $build_path_c/4_pointcloud \

  echo "Copying meshes to 0_in"
  lsfilter $input_path_c $build_path_c/0_in .obj | parallel -P $NPROC --timeout $TIMEOUT \
     cp $input_path_c/{}/model.obj $build_path_c/0_in/{}.obj;

  echo "Scaling meshes"
  python $MESHFUSION_PATH/1_scale_obj.py \
    --n_proc $NPROC \
    --in_dir $build_path_c/0_in \
    --out_dir $build_path_c/1_scaled \
    --t_dir $build_path_c/1_transform

  echo "Create depths maps"
  python $MESHFUSION_PATH/2_fusion_obj.py \
    --mode=render --n_proc $NPROC \
    --in_dir $build_path_c/1_scaled \
    --out_dir $build_path_c/2_depth

  echo "Produce watertight meshes"
  python $MESHFUSION_PATH/2_fusion_obj.py \
    --mode=fuse --n_proc $NPROC \
    --in_dir $build_path_c/2_depth \
    --out_dir $build_path_c/2_watertight \
    --t_dir $build_path_c/1_transform

  echo "Simplify and smooth meshes"
  python $MESHFUSION_PATH/3_simplify.py \
      --in_dir $build_path_c/2_watertight \
      --out_dir $build_path_c/3_simplified

  echo "Process simplified meshes"
  python sample_mesh_obj.py $build_path_c/3_simplified \
      --n_proc $NPROC \
      --pointcloud_folder $build_path_c/4_pointcloud \
      --points_folder $build_path_c/4_points \
      --pointcloud_size 200000 \
      --points_size 200000 \
      --packbits --float16
done
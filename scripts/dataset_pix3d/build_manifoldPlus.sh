source dataset_pix3d/config.sh
# Make output directories
mkdir -p $MANIFOLDPLUS_BUILD_PATH

# Run build
for c in ${CLASSES[@]}; do
  echo "Processing class $c"
  input_path_c=$INPUT_PATH/$c
  build_path_c=$MANIFOLDPLUS_BUILD_PATH/$c

  mkdir -p $build_path_c/0_in \
           $build_path_c/2_watertight \
           $build_path_c/4_points \
           $build_path_c/4_pointcloud \

  echo "Copying meshes to 0_in"
  lsfilter $input_path_c $build_path_c/0_in | parallel -P $NPROC --timeout $TIMEOUT \
     cp $input_path_c/{}/model.obj $build_path_c/0_in/{}.obj;

  echo "Produce watertight meshes using ManifoldPLus"
  for f in $build_path_c/0_in/*; do
    filename=$(basename $f)
    ./$ROOT/../ManifoldPlus/build/manifold --input $f --output $build_path_c/2_watertight/$filename
  done

  echo "Process simplified meshes"
  python sample_mesh_obj.py $build_path_c/2_watertight \
      --n_proc $NPROC \
      --pointcloud_folder $build_path_c/4_pointcloud \
      --points_folder $build_path_c/4_points \
      --pointcloud_size 200000 \
      --points_size 200000 \
      --packbits --float16
done
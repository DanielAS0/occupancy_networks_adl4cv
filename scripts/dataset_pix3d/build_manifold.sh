source dataset_pix3d/config.sh
# Make output directories
mkdir -p $MANIFOLD_BUILD_PATH

# Run build
for c in ${CLASSES[@]}; do
  echo "Processing class $c"
  input_path_c=$INPUT_PATH/$c
  build_path_c=$MANIFOLD_BUILD_PATH/$c

  mkdir -p $build_path_c/0_in \
           $build_path_c/1_scaled \
           $build_path_c/1_transform \
           $build_path_c/2_depth \
           $build_path_c/2_watertight \
           $build_path_c/3_simplified \
           $build_path_c/4_points \
           $build_path_c/4_pointcloud \

  echo "Copying meshes to 0_in"
  lsfilter $input_path_c $build_path_c/0_in  | parallel -P $NPROC --timeout $TIMEOUT \
     cp $input_path_c/{}/model.obj $build_path_c/0_in/{}.obj;

  echo "Produce and simplify watertight meshes using Manifold"
  for f in $build_path_c/0_in/*; do
    filename=$(basename $f)
    ./$ROOT/../Manifold/build/manifold $f $build_path_c/2_watertight/$filename 50000
    ./$ROOT/../Manifold/build/simplify -i $build_path_c/2_watertight/$filename -o $build_path_c/3_simplified/$filename -m -f 120000 -c 1e-2 -r 0.2
  done

  echo "Process simplified meshes"
  python sample_mesh_obj.py $build_path_c/3_simplified \
      --n_proc $NPROC \
      --pointcloud_folder $build_path_c/4_pointcloud \
      --points_folder $build_path_c/4_points \
      --pointcloud_size 200000 \
      --points_size 200000 \
      --packbits --float16
done
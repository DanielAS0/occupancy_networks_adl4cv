import glob
import os
import pandas as pd
import trimesh
from im2mesh.eval import MeshEvaluator
import numpy as np

pix3d_path = '../../datasets/pix3d'
eval_dicts = []
evaluator = MeshEvaluator(n_points=200000)
folders = ['occupancy', 'occupancy_manifold', 'occupancy_manifoldPlus']
classes = ['bookcase', 'desk', 'sofa', 'wardrobe', 'table', 'bed', 'misc', 'tool']

for f in folders:
    print('processing folder %s' % f)
    for c in classes:
        print('processing class %s' % c)
        path = os.path.join(pix3d_path, f, c, '*/model.obj')

        for file in glob.glob(path):
            modelname = file.split('/')[-2]
            model_path = os.path.join(pix3d_path, f, c, modelname)
            eval_dict = {
                'type': f,
                'class': c,
                'modelname': modelname,
            }
            eval_dicts.append(eval_dict)

            # Points
            points_path = os.path.join(model_path, 'points.npz')
            if os.path.exists(points_path):
                points = np.load(points_path)
                occupancies = np.unpackbits(points['occupancies'])[:points['points'].shape[0]]
                occupancies = occupancies.astype(np.float32)
                occupiedPoints = points['points'][occupancies > 0]
                occupied_perc = 100*occupiedPoints.shape[0]/occupancies.shape[0]
                eval_dict['occupancy rate'] = occupied_perc
            else:
                print('Warning: %s points for %s %s do not exist' % (f, c, modelname))

            # Pointcloud
            pointcloud_path = os.path.join(model_path, 'pointcloud.npz')
            if os.path.exists(pointcloud_path):
                pointcloud = np.load(pointcloud_path)
                # Original Mesh
                mesh_path = os.path.join(pix3d_path, 'model', c, modelname, 'model.obj')
                if os.path.exists(mesh_path):
                    # Read Pix3D Mesh
                    mesh_orig = trimesh.load(mesh_path)
                    pointcloud_orig, idx = mesh_orig.sample(200000, return_index=True)
                    pointcloud_orig = pointcloud_orig.astype(np.float32)
                    normals_orig = mesh_orig.face_normals[idx]
                    # Define Targets
                    normals_tgt = pointcloud['normals'].astype(np.float32)
                    pointcloud_tgt = pointcloud['points'].astype(np.float32)
                    # Evaluate
                    eval_dict_pointcloud = evaluator.eval_pointcloud(
                        pointcloud_orig, pointcloud_tgt, normals_orig, normals_tgt)
                    for k, v in eval_dict_pointcloud.items():
                        eval_dict[k] = v
                else:
                    print('Warning: original mesh for %s does not exist' % (c, modelname))
            else:
                print('Warning: %s pointcloud for %s %s does not exist' % (f, c, modelname))
# statistics
out_file = os.path.join(pix3d_path, 'eval_generation_full.pkl')
out_file_class = os.path.join(pix3d_path, 'eval_generation.csv')
eval_df = pd.DataFrame(eval_dicts)
eval_df.to_pickle(out_file)

# Create CSV file  with main statistics
eval_df_class = eval_df.groupby(by=['class', 'type']).mean()
eval_df_class.to_csv(out_file_class)

# Print results
eval_df_class.loc['mean'] = eval_df_class.mean()
print(eval_df_class)





import math
import json
import os
from PIL import Image


def transformImage(img_in, mask, bbox):
    """takes Pix3D image, crops background and resizes to 124x124"""

    # crop image to mask
    img_white = Image.new('RGB', img_in.size, (255, 255, 255))
    img_c = Image.composite(img_in, img_white, mask)

    # crop image to bbox
    img_c = img_c.crop(bbox)

    # make image square with padding on both sides
    bbox_x = bbox[2] - bbox[0]
    bbox_y = bbox[3] - bbox[1]
    bbox_max = max(bbox_x, bbox_y)
    padding = math.floor(bbox_max / 5)
    img_f = Image.new('RGB', (bbox_max + padding, bbox_max + padding), (255, 255, 255))
    img_f.paste(img_c, [math.floor((bbox_max - bbox_x + padding) / 2), math.floor((bbox_max - bbox_y + padding) / 2)])

    # resize image to 224x224
    img_out = img_f.resize([224, 224], Image.LANCZOS)
    return img_out


# TODO get these variables as args from bash script
pix3d_path = '/home/daniel/ADL4CV/occupancy_networks/data/external/Pix3d/'
output_path = '/home/daniel/ADL4CV/occupancy_networks/data/Pix3d_SN/'
category_list = ['table', 'tool', 'wardrobe']#'bed', 'bookcase', 'chair', 'desk', 'misc', 'sofa', 'table', 'tool', 'wardrobe']

json_path = os.path.join(pix3d_path, 'pix3d.json')
with open(json_path) as json_file:
    metadata = json.load(json_file)

for category in category_list:

    # Process Train/Test splits
    print('processing test/train splits for category %s' % category)

    with open(pix3d_path + 'pix3d_s2_test.json') as json_file:
        s2_test = json.load(json_file)
    with open(pix3d_path + 'pix3d_s2_train.json') as json_file:
        s2_train = json.load(json_file)

    c_id = [x['id'] for x in s2_train['categories'] if x['name'] == category][0]
    s2_test_c = [x['model'].split('/')[-2] for x in s2_test['annotations'] if x['category_id'] == c_id]
    s2_train_c = [x['model'].split('/')[-2] for x in s2_train['annotations'] if x['category_id'] == c_id]

    # save splits
    lst_out_path = os.path.join(output_path, category)
    with open(lst_out_path + '/train.lst', 'w') as file_handler:
        '''
        for item in set(s2_train_c):
            # check if points and pointcloud exists
            points_path = os.path.join(output_path, category, item, 'points.npz')
            pointcloud_path = os.path.join(output_path, category, item, 'pointcloud.npz')
            if(os.path.isfile(points_path) and os.path.isfile(pointcloud_path)):
                file_handler.write("{}\n".format(item))
            else:
                print('Pointcloud and/or Points do not exist for %s %s: omitting in train.lst' % (category, item))
'''
        file_handler.write("\n".join(str(item) for item in set(s2_train_c) if(
                os.path.isfile(os.path.join(output_path, category, item, 'points.npz')) and
                os.path.isfile(os.path.join(output_path, category, item, 'pointcloud.npz'))
        )))

    with open(lst_out_path + '/test.lst', 'w') as file_handler:
        '''
        for item in set(s2_test_c):
            # check if points and pointcloud exists
            points_path = os.path.join(output_path, category, item, 'points.npz')
            pointcloud_path = os.path.join(output_path, category, item, 'pointcloud.npz')
            if (os.path.isfile(points_path) and os.path.isfile(pointcloud_path)):
                file_handler.write("{}\n".format(item))
            else:
                print('Pointcloud and/or Points do not exist for %s %s: omitting in test.lst' % (category, item))
        '''
        file_handler.write("\n".join(str(item) for item in set(s2_test_c) if (
                os.path.isfile(os.path.join(output_path, category, item, 'points.npz')) and
                os.path.isfile(os.path.join(output_path, category, item, 'pointcloud.npz'))
        )))
    # Process Images
    # TODO process camera information
    print('processing images for category %s' % category)
    models = [x for x in metadata if (x['category'] == category)]
    for model in models:
        modelname = model['model'].split('/')[-2]
        imagename = model['img'].split('/')[-1].split('.')[0]
        img_path = os.path.join(pix3d_path, model['img'])
        mask_path = os.path.join(pix3d_path, model['mask'])
        bbox = model['bbox']
        # open image and mask
        img_in = Image.open(img_path)
        mask = Image.open(mask_path)
        if img_in.size == mask.size:
            image = transformImage(img_in, mask, bbox)
            out_path = os.path.join(output_path, category, modelname, 'images')
            if not os.path.exists(out_path):
                os.makedirs(out_path)
                # print("Directory ", out_path,  " Created ")
            out_path = os.path.join(output_path, category, modelname, 'images', (imagename+'.jpg'))
            # print('saving image ' + imagename)
            image.save(out_path)
        else:
            print('image %s and mask %s have different sizes -> skipping image' % (img_path, mask_path))




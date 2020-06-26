import os
import argparse
import ntpath
import common

class Rotation:
    """
    Perform rotation on mesh.
    """

    def __init__(self):
        """
        Constructor.
        """

        parser = self.get_parser()
        self.options = parser.parse_args()
        self.rotation_script = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'rotation.mlx')

    def get_parser(self):
        """
        Get parser of tool.

        :return: parser
        """

        parser = argparse.ArgumentParser(description='rotate meshes.')
        parser.add_argument('--in_dir', type=str, help='Path to input directory.')
        parser.add_argument('--out_dir', type=str, help='Path to output directory; files within are overwritten!')

        return parser

    def read_directory(self, directory):
        """
        Read directory.

        :param directory: path to directory
        :return: list of files
        """

        files = []
        for filename in os.listdir(directory):
            files.append(os.path.normpath(os.path.join(directory, filename)))

        return files

    def run(self):
        """
        Run rotation.
        """

        assert os.path.exists(self.options.in_dir)
        common.makedir(self.options.out_dir)
        files = self.read_directory(self.options.in_dir)

        for filepath in files:
            #added LC_NUMERIC=C
            os.system('LC_NUMERIC=C meshlabserver -i %s -o %s -s %s' % (
                filepath,
                os.path.join(self.options.out_dir, ntpath.basename(filepath)),
                self.rotation_script
            ))

if __name__ == '__main__':
    app = Rotation()
    app.run()

import os
import glob
import argparse

def print_file_contents(path, extension):
    for filename in glob.glob(os.path.join(path, '*'+extension)):
        print('File Path and Name: ', filename)
        print('Contents:')
        with open(filename, 'r') as f:
            print(f.read())
            
        print('--------')

parser = argparse.ArgumentParser()

parser.add_argument('-p', '--path', type=str, help='The path where to look for files')
parser.add_argument('-e', '--ext', type=str, help='The file extension to look for')

args = parser.parse_args()

code = print_file_contents(args.path, args.ext)

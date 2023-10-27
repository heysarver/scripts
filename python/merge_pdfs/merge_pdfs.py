import os
import sys
from PyPDF2 import PdfMerger, PdfReader

# get directory and output file from command line arguments
pdf_dir = sys.argv[1]
output_file = sys.argv[2]

# get all pdf files in directory
pdf_files = [f for f in os.listdir(pdf_dir) if f.lower().endswith("pdf")]

# sort files alphabetically
pdf_files.sort()

merger = PdfMerger()

for filename in pdf_files:
    merger.append(PdfReader(os.path.join(pdf_dir, filename), "rb"))

merger.write(output_file)

import sys
import os
import numpy as np 

vals_min = []
vals_max = []
vals_mean = []
f_merged = sys.argv[1]
path_out = sys.argv[2]
fo = open(f_merged,'r')
lines = fo.readlines()
for line in lines:
    ar_tmp = line.split("\t")
    ar_values = ar_tmp[-1].split(",")
    vals_min.append(float(ar_values[0]))
    vals_max.append(float(ar_values[1]))
    vals_mean.append(float(ar_values[2]))

path_outFile_name = path_out+"/merged.diff.perc"
percfile = open(f'{path_outFile_name}','w')
percentile_min = np.percentile(vals_min,[i for i in range(1,101)])
percentile_max = np.percentile(vals_max,[i for i in range(1,101)])
percentile_mean  = np.percentile(vals_mean,[i for i in range(1,101)])
upperIdx = 1;
for i in reversed(range(100)):
    percfile.write(f"{upperIdx}\t{percentile_min[i]}\t{percentile_max[i]}\t{percentile_mean[i]}\n")
    upperIdx = upperIdx + 1
percfile.close()

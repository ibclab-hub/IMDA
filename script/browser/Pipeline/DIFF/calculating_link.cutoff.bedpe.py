
import sys
import json

inpair = sys.argv[1]
binsize = int(sys.argv[2])
spcs = sys.argv[3]
tissue = sys.argv[4]
outdir = sys.argv[5]
cutoff = int(sys.argv[6])

d_bins = {}
d_size = {}
for line in open(inpair):
    if line.startswith("#chromsize:"):
        a_line = line.split()
        nchr, chrsize = a_line[1], int(a_line[2])
        d_size[nchr] = chrsize
        d_bins[nchr] = {}
        for i in range(0, chrsize+1, binsize):
            cbin = (i, i+binsize)
            if i+binsize > chrsize: cbin = (i, chrsize)
            d_bins[nchr][cbin] = {}
    elif line.startswith("#"): continue
    else:
        a_line = line.split()
        nchr1, pos1 = a_line[1], int(a_line[2])
        nchr2, pos2 = a_line[3], int(a_line[4])
        
        bin1 = ((pos1//binsize)*binsize,(pos1//binsize)*binsize+binsize)
        bin2 = ((pos2//binsize)*binsize,(pos2//binsize)*binsize+binsize)
        if bin1[1] > d_size[nchr1]: bin1 = ((pos1//binsize)*binsize,d_size[nchr1])
        if bin2[1] > d_size[nchr2]: bin2 = ((pos2//binsize)*binsize,d_size[nchr2])

        if (nchr2, bin2) in d_bins[nchr1][bin1]:
             d_bins[nchr1][bin1][(nchr2, bin2)] += 1
        elif (nchr1, bin1) in d_bins[nchr2][bin2]:
             d_bins[nchr2][bin2][(nchr1, bin1)] += 1
        else:
            d_bins[nchr1][bin1][(nchr2, bin2)] =0
            d_bins[nchr1][bin1][(nchr2, bin2)] += 1

outd = {spcs:{tissue:[]}}
outl = outd[spcs][tissue]

outfile = open(f"{outdir}/hic.resolFix.bedpe",'w')
idcount = 1
for nchr in d_bins:
    for bin1 in d_bins[nchr]:
        for bininfo in d_bins[nchr][bin1]:
            if d_bins[nchr][bin1][bininfo] <= cutoff: continue

            outfile.write(f"{nchr}\t{bin1[0]}\t{bin1[1]}\t{bininfo[0]}\t{bininfo[1][0]}\t{bininfo[1][1]}\t{spcs}:{spcs}\t{d_bins[nchr][bin1][bininfo]}\t+\t+\n")





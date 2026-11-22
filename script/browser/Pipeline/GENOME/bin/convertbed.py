
import sys
import os

insize = sys.argv[1]
indir = sys.argv[2]
outdir = sys.argv[3]


gapfile = open(f"{outdir}/genome_gap.result.bed",'w')
entfile = open(f"{outdir}/genome_ent.result.bed",'w')

inchr = {}


for line in open(insize):
    a_line = line.split()
    inchr[a_line[0]] = a_line[1]

for nchr in inchr:
    inconvfile = f"{indir}/{nchr}.conv.scores"
    for line in open(inconvfile):
        if "NCHR" in line : continue
        a_line = line.split()
        nchr, pos, ent, gap = a_line[0], int(a_line[1]), a_line[-2], a_line[-1]
        gapfile.write(f"{nchr}\t{pos}\t{pos+1}\t.\t{gap}\n")        
        entfile.write(f"{nchr}\t{pos}\t{pos+1}\t.\t{ent}\n")        


gapfile.close()
entfile.close()

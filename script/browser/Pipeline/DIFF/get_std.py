# modules
import sys
import os
import subprocess as subp
import numpy as np
import pathlib
script_directory = pathlib.Path(__file__).parent.resolve()

def get_params(fparam):

    # paramter file processing

    datcount = 0
    d_param = {"dat":{}}
    filestat = 0
    for line in open(fparam):
        if line == "\n" : continue
        if line[0] == "#" : continue
        a_line = line.split()
        if len(a_line) == 2:
            name, value = line.split()
            d_param[name] = value
        else:
            tmp_arr = line.split()
            if len(tmp_arr)==3:
                asmid, spcname, fpath, = line.split()        
                if not asmid in d_param["dat"]: d_param["dat"][asmid] = []
                d_param["dat"][asmid].append([spcname,fpath])
                datcount += 1

            else:
                asmid, spcname, fpath, res = line.split()        
                if not asmid in d_param["dat"]: d_param["dat"][asmid] = []
                d_param["dat"][asmid].append([spcname,fpath,res])
                datcount += 1
            
            

    asms = list(set(list(d_param["dat"].keys())))


    if len(set(asms)) > 1 : diffstat = 1
    else: diffstat = 0

    return d_param, diffstat, datcount

def save_info(asm_id, nchr, start, val, ncount,d_prof, end="",name=""):
   
    # saving base value information in dictionary
    # structure:
    # {asm_id: {
    #   nchr:{
    #       dic_key:[0.1, 0.0, 0.3]
    # }}}
    if not nchr in d_prof[asm_id]: d_prof[asm_id][nchr] = {}

    if end=="": dic_key = start
    else: dic_key = (start, end, name)
    # HIC usage
    # start = nchr2
    # end = (start1, end1)
    # name = (start2, end2)
    # dic_key -> nchr(1): (nchr2, coord of (1) , coord of (2) )
    
    # nchr1 start1 end1 <-> nchr2 start2 end2

    if not dic_key in d_prof[asm_id][nchr] : 
        d_prof[asm_id][nchr][dic_key] = []


    while ncount != len(d_prof[asm_id][nchr][dic_key]):
        d_prof[asm_id][nchr][dic_key].append(0)
    d_prof[asm_id][nchr][dic_key].append(val)

    return d_prof

def save_geneprofile(d_param):

   	# Saving single-species gene expression profile values

    dat = d_param["dat"]

    d_prof = {}
    for asm_id in dat:
        files = dat[asm_id]
        if not asm_id in d_prof: d_prof[asm_id] = {}

        ncount = 0
        for info in files:
            filename = info[1]
            for line in open(filename):
                a_line = line.split()
                nchr, start, curend, curname,val = a_line[0], int(a_line[1]), int(a_line[2]), a_line[3],float(a_line[-1])
                d_prof=save_info(asm_id, nchr, start, val, ncount ,d_prof, end=curend,name=curname)
            ncount += 1

    return d_prof, ncount


def save_regionprofile(d_param):

    # saving information from region-based bed file 

    dat = d_param["dat"]

    d_prof = {}
    for asm_id in dat:
        files = dat[asm_id]
        if not asm_id in d_prof: d_prof[asm_id] = {}

        d_prof[asm_id]["ncount"] = 0
        for info in files:
            filename = info[1]
            for line in open(filename):
                a_line = line.split()
                nchr, start, end, val = a_line[0], int(a_line[1]), int(a_line[2]), float(a_line[-1])
                
                # region to base level conversion
                for pos in range(start, end+1):
                    d_prof=save_info(asm_id, nchr, pos, val, d_prof[asm_id]["ncount"] ,d_prof)
            
            d_prof[asm_id]["ncount"] += 1
        ncount = d_prof[asm_id]["ncount"]
        del d_prof[asm_id]["ncount"]
    return d_prof, ncount

def save_baseprofile(d_param):

    # saving information from base-level-based bed file 

    dat = d_param["dat"]
    d_prof = {}

    for asm_id in dat:
        files = dat[asm_id]
        if not asm_id in d_prof: d_prof[asm_id] = {}

        d_prof[asm_id]["ncount"] = 0
        for info in files:
            filename = info[1]

            for line in open(filename):
                a_line = line.split()
                nchr, start, end, val = a_line[0], int(a_line[1]), int(a_line[2]), float(a_line[-1])
                d_prof=save_info(asm_id, nchr, start, val, d_prof[asm_id]["ncount"],d_prof)
            d_prof[asm_id]["ncount"] += 1
        ncount = d_prof[asm_id]["ncount"]
        del d_prof[asm_id]["ncount"]
    return d_prof,ncount

def save_contactprofile(d_param):
    dat = d_param["dat"]
    minres = d_param["minres"]

    d_prof = {}
    for asm_id in dat:
        files = dat[asm_id]
        if not asm_id in d_prof: d_prof[asm_id] = {}

        countpath = script_directory
        for info in files:
            filename = info[1]
            res = info[2]
            if res != minres:
                pairsdir = "/".join(filename.split("/")[:-1])
                pairs = pairsdir+"/filtered.pairs"
                pairsID= filename.split("/")[-2]
                newoutdir = f"{d_param['outdir']}/{pairsID}"
                os.system(f"mkdir -m777 -p {newoutdir}/")
                
                cmd = f"python3 {countpath}/calculating_link.cutoff.bedpe.py {pairs} {minres} - - {newoutdir} 10 "
                run = subp.Popen(cmd.split(" "), shell=False,stdout=subp.PIPE, stderr=subp.PIPE) 
                run.wait()
                
                info[1] = newoutdir+f"/hic.resolFix.bedpe"
        ncount = 0;        
        for info in files:
            filename = info[1]
            for line in open(filename):
                a_line = line.split()
                nchr1, start1, end1, nchr2, start2, end2, val = a_line[0], int(a_line[1]), int(a_line[2]), a_line[3],int(a_line[4]), int(a_line[5]), int(a_line[7])
                d_prof=save_info(asm_id, nchr1, nchr2, val, ncount ,d_prof, end=(start1,end1),name=(start2,end2))
            ncount += 1
        print (ncount)
    return d_prof,ncount

def save_fileinfo(d_param):
    filename = d_param["dat"][d_param["ref"]][0][1]
    vals = []
    if d_param["type"] == "hic":
        for line in open(filename):
            a_line = line.split()
            val = int(a_line[7])
            vals.append(val)
    else:
        for line in open(filename):
            a_line = line.split()
            val = float(a_line[-1])
            vals.append(val)
    percfile = open(f"{d_param['outdir']}/raw_1.diff.perc",'w')
    percentile = np.percentile(vals,[i for i in range(1,101)])
    for i in range(100):
        percfile.write(f"{i+1}\t{percentile[i]}\n")
    percfile.close()


def convert_pos(d_param, d_prof):
    posdir = d_param['posdir']
    asms = list(set(list(d_param["dat"].keys())))
    ref = d_param["ref"]
    if len(asms) == 1 and asms[0] == ref: return d_prof[ref]

    d_syn = {}

    for asm_id in asms:
        dat_count = len(d_param["dat"][asm_id])
        if asm_id==ref:continue
        posfiles = os.popen(f"ls {posdir}/{ref}-{asm_id}.*.pos").read().split()
        
        for posfile in posfiles:

            for line in open(posfile):
                a_line = line.split()
                refchr, tarchr= a_line[0], a_line[2]
                refpos, tarpos = int(a_line[1]), int(a_line[3])

                if not refchr in d_syn: d_syn[refchr] = {}

                if d_prof[ref].get(refchr) and d_prof[ref][refchr].get(refpos):
                    d_syn[refchr][refpos] = d_prof[ref][refchr].get(refpos)
                    del d_prof[ref][refchr][refpos]
                    if d_prof[asm_id].get(tarchr) and d_prof[asm_id][tarchr].get(tarpos):
                        tarval = d_prof[asm_id][tarchr][tarpos]
                        d_syn[refchr][refpos] += tarval
                        del d_prof[asm_id][tarchr][tarpos]
                    else:
                        d_syn[refchr][refpos] += [0 for i in range(dat_count)]
    return d_syn

def print_results(d_param, d_syn,ncount):
    if d_param["type"] == 'hic': 
        outfile = open(f"{d_param['outdir']}/raw.diff.bedpe",'w')
    else: 
        outfile = open(f"{d_param['outdir']}/raw.diff.bed",'w')
    maxfile = open(f"{d_param['outdir']}/raw.diff.max",'w')
    ref = d_param["ref"]
    max = 0
    stds = [] 

    if d_param["type"] == "hic":
        spcname = set([s[0] for s in list(d_param["dat"].values())[0]])
        spcname = list(spcname)[0]

    for nchr in d_syn:
        if nchr=="ncount": continue
        for pos in d_syn[nchr]:
            if d_param["type"] == "gene" :
                if len(d_syn[nchr][pos]) != ncount: d_syn[nchr][pos] += [0 for i in range(ncount-len(d_syn[nchr][pos]))]
                std = np.std(d_syn[nchr][pos], ddof=1)
                vals = list(map(str,d_syn[nchr][pos]))
                vals = ",".join(vals)
                if std > max: max = std
                outfile.write(f"{nchr}\t{pos[0]}\t{pos[1]}\t{pos[2]}\t{std}\n")
                continue
            if d_param["type"] == "hic":
                if len(d_syn[nchr][pos]) != ncount: d_syn[nchr][pos] += [0 for i in range(ncount-len(d_syn[nchr][pos]))]
                std = np.std(d_syn[nchr][pos], ddof=1)
                stds.append(std)
                if std > max: max = std
                outfile.write(f"{nchr}\t{pos[1][0]}\t{pos[1][1]}\t{pos[0]}\t{pos[2][0]}\t{pos[2][1]}\t{spcname}:{spcname}\t{std}\t+\t+\n")
                continue
            else:
                if len(d_syn[nchr][pos]) != ncount: d_syn[nchr][pos] += [0 for i in range(ncount-len(d_syn[nchr][pos]))]
                std = np.std(d_syn[nchr][pos], ddof=1)
                stds.append(std)
                vals = list(map(str,d_syn[nchr][pos]))
                vals = ",".join(vals)
                if std > max: max = std
                outfile.write(f"{nchr}\t{pos}\t{pos+1}\t.\t{std}\n")
                continue
    maxfile.write(str(max))
    outfile.close()
    maxfile.close()


###################################################################
# variables
fparam = sys.argv[1]
logfile = ""
conv_df =  ""

# main
d_param,columns,datcount = get_params(fparam)
logfile = open(f"{d_param['outdir']}/log.txt",'a')


if datcount == 1:
    logfile.write("## Calculating the standard deviation of profile values\n")
    save_fileinfo(d_param)
else:
    logfile.write("## Processing all multi-omics data values\n")
    if d_param["type"] == "region":
        d_prof,ncount = save_regionprofile(d_param)
        pass
    elif d_param["type"] == "gene":
        d_prof,ncount = save_geneprofile(d_param)
        pass
    elif d_param["type"] == "hic":
        d_prof,ncount = save_contactprofile(d_param)
        pass
    else:
        d_prof,ncount = save_baseprofile(d_param)
        pass

    logfile.write("## Converting positions for comparing with a reference\n")
    if d_param["type"] == "gene" or d_param["type"] == "hic": 
        d_prof = d_prof[d_param['ref']]
        pass
    else: 
        d_prof = convert_pos(d_param, d_prof)
    logfile.write("## Calculating the standard deviation of profile values\n")
    print_results(d_param, d_prof,ncount)

logfile.close()


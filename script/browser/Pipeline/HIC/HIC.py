######################################################################################################
# Processing hi-c read data to contact map pipeline #
######################################################################################################

############################################## libraries ########################################################
import sys
import os
import multiprocessing as mp
import subprocess as subp
import math
import json
import shlex
#################################################################################################################


############################################## variables ########################################################
d_dat = {}
d_step = {}
d_chr = {}
d_pairs = {}
ref_size = ""

#################################################################################################################


def processing_params(params_f):
    
    """
    # input : parammeter file
    # output : 0
    # processing parameter and save it to global dictionary input file to run program
    """

    status = 0

    for line in open(params_f):
        if line.startswith("##"):
            param_info = line.replace("##","").rstrip()
            if param_info == "Program path":
                status = 1
            elif param_info == "Pipeline IO":
                status = 2
            elif param_info == "parameters":
                status = 3
            continue
        if line=="\n": continue
        elif status == 1:
            if line.startswith("#"):
                a_line = line.replace("#","").split()
                d_step[a_line[0]] = {}
                d_step[a_line[0]]["name"] = "_".join(a_line[1:])
            else:
                a_line = line.replace("S",'').split()
                d_step[a_line[0]]["path"] = a_line[1]
        elif status == 2:
            a_line = line.split()
            if a_line[0] == "sample_name":
                if not a_line[0] in d_dat: d_dat[a_line[0]] = {a_line[1]:{}}
                else: d_dat[a_line[0]][a_line[1]] = {}
            elif "sample_name" in d_dat and a_line[0] in d_dat["sample_name"]:
                d_dat["sample_name"][a_line[0]][a_line[1]] = a_line[2]
            else:d_dat[a_line[0]] = a_line[1]
        elif status == 3:
            a_line = line.replace("S",'').split()
            d_step[a_line[0]] = {}
            d_step[a_line[0]]["params"] = []
            d_step[a_line[0]]["params"].append(tuple(a_line[1:]))
    
    
    if not os.path.isdir(d_dat["dir_out"]):
        os.system(f"mkdir {d_dat['dir_out']}")
    
    f_pid = open(f'{d_dat["dir_out"]}/pid.txt','w')
    f_pid.write(str(os.getpid()))
    f_pid.close()

    d_dat["f_cmd"] = d_dat["dir_out"]+"/CMDs"
    d_dat["f_log"] = d_dat["dir_out"]+"/log.txt"
    d_dat["f_logAll"] = d_dat["dir_out"]+"/All.log.txt"

    dir_for_output = ["tmp","filt","merge",'raw','result']

    for s in dir_for_output:
        if not os.path.isdir(d_dat["dir_out"]+"/"+s): 
            os.system(f"mkdir -m777 -p {d_dat['dir_out']}/{s}")
	
    linkcmd = f"ln -s {d_dat['f_refFasta']} {d_dat['dir_out']}/tmp/"
    link = subp.Popen(linkcmd,shell=True)
    link.wait()
    d_dat['f_refFasta'] = f"{d_dat['dir_out']}/tmp/{d_dat['f_refFasta'].split('/')[-1]}"


    sizecmd = f"faSize -detailed {d_dat['f_refFasta']} > {d_dat['dir_out']}/tmp/ref.sizes"
    size = subp.Popen(sizecmd, shell=True)
    size.wait()
    d_dat["f_refsize"] = f"{d_dat['dir_out']}/tmp/ref.sizes"
    ref_size = d_dat["f_refsize"]

    # parsing size file
    for line in open(ref_size):
        if line == "\n" : continue
        a_line = line.split()
        nchr, size = a_line[0], int(a_line[1])
        d_chr[nchr] = size

    minbinsize = int(d_dat["bin_size"])


    return 1

def running(step, cmd):

    f_cmd.write(f"{step}\n{cmd}\n")

    f_logAll.write(f"{step}\n{cmd}\n")
    f_logAll.flush()

    f_log.write(f"{step}\n")
    f_log.flush()

    run = subp.Popen(cmd,shell=True)
    #cmd = cmd.split(" ")
    #run = subp.Popen(cmd, shell=False,stdout=subp.PIPE, stderr=subp.PIPE) 
    run.wait()

    return 0

def indexing_ref():
    program = "bwa"
    l_params = d_step['1']['params']
    
    dat_ref = d_dat["f_refFasta"]
    outdir = f"{d_dat['dir_out']}/tmp"
    cmd = f"{program} index -a bwtsw {dat_ref} 2> {outdir}/faidx.log"
    running(f"## BWA indexing", cmd)

    return 1


def mapping_reads():
    cpu = d_dat['threads']

    outdir = d_dat["dir_out"]+"/raw"
    
    dat_ref = d_dat["f_refFasta"]
    dat_read = d_dat["sample_name"]
    d_dat["raw"] = {}
    
    for s in dat_read:
        d_dat["raw"][s]={}
        cur_read = list(dat_read[s].values())
        cmd = f"bwa mem -SP5M -t {cpu} {dat_ref} {' '.join(cur_read)} 2>{outdir}/map.log| samtools view -bhS -o {outdir}/{s}.bam -"
        f_log.write(f"## BWA alignment {s} \n")
        f_log.flush()
        #f_cmd.write(cmd+"\n")
        running(f"## BWA alignment", cmd)
        d_dat["raw"][s] = f"{outdir}/{s}.bam"
        #run = subp.Popen(cmd, shell=True,stderr=subp.PIPE)
        """
        maplog = open(f"{outdir}/{s}.mapping.log",'w')
        for line in iter(run.stderr.readline,b''):
            line = line.decode('utf8')
            maplog.write(line)
        run.wait()
        """
    return 1

def checking_multisample():
    bamfiles = list(d_dat["raw"].values())
    if len(bamfiles) >= 2:
        merging_reads(bamfiles)
    else:
        d_dat["raw"] = bamfiles[0]
        

    return 1

def merging_reads(bamfiles):
    cpu = d_dat['threads']
    outdir = d_dat["dir_out"]+"/merge"
    outfile = d_dat["dir_out"]+"/merge/all.bam"
    
    cmd = f"samtools merge --threads {cpu} {outfile} {' '.join(bamfiles)} 2> {outdir}/merge.log"
    running('## BWA merge',cmd)
    d_dat["raw"] = outfile

    return 1

def filtering_reads():

    outdir = d_dat["dir_out"]+"/filt"

    dat_raw = d_dat["raw"]
    ref_size = d_dat["f_refsize"]
    cpu = d_dat["threads"]
    cmd = f"samtools view -h {dat_raw} | pairtools parse --nproc-in {cpu} --nproc-out {cpu} -c {ref_size} -o {outdir}/parsed.pairsam 2> {outdir}/filt.log"
    running(f"## Filtering reads and Converting alignment file to pairs file", cmd)

    cmd = f"pairtools sort --tmpdir={outdir} --nproc {cpu} -o {outdir}/sorted.pairsam {outdir}/parsed.pairsam  2> {outdir}/pairtools.sort.log"    # by JK
    running(f"## Sorting pairsam", cmd)
    
    cmd = f"pairtools dedup --nproc-in {cpu} --nproc-out {cpu} --mark-dups -o {outdir}/deduped.pairsam {outdir}/sorted.pairsam 2> {outdir}/pairtools.dedu.log"
    running(f"## Marking duplications in pairsam", cmd)

    cmd = f"pairtools select --nproc-in {cpu} --nproc-out {cpu} "+'\'(pair_type == "UU") or (pair_type == "UR") or (pair_type == "RU")\''+f" -o {outdir}/filtered.pairsam {outdir}/deduped.pairsam 2> {outdir}/pairtools.select.log" 
    running(f"## Select only UU/UR/RU pairs", cmd)

    cmd = f"pairtools split --nproc-in {cpu} --nproc-out {cpu} --output-pairs {outdir}/filtered.pairs {outdir}/filtered.pairsam 2> {outdir}/pairtools.split.log"
    running(f"## Parsing pairsam into pairs", cmd)

    d_dat['pairs'] = f"{outdir}/filtered.pairs"

    return 1


    

def counting_pairs():

    cmd = f"python3 {binpath}/calculating_link.cutoff.bedpe.py {pairs} {d_dat['bin_size']} {d_dat['spcs']} {d_dat['tissue']} {d_dat['dir_out']} {d_dat['cutoff']}   2> {d_dat['dir_out']}/calcLink.log "
    running("## Calculating link", cmd)
    

    return 1

# pipes
binpath = os.path.dirname(os.path.abspath(__file__))+"/bin"

processing_params(sys.argv[1])
f_cmd = open(d_dat["f_cmd"],'w')
f_log = open(d_dat["f_log"],'a')
f_logAll = open(d_dat["f_logAll"],'a')


f_log.flush()
f_logAll.flush()

# log file
# making output directories
f_log.write("## BWA Alignment\n")
f_log.flush()
#step 1
indexing_ref()
# step 2
mapping_reads()
# step 3
checking_multisample()
# step 4
filtering_reads()

# step 5
f_log.write("## Making Results\n")
f_log.flush()
pairs = f"{d_dat['dir_out']}/filt/filtered.pairs"
counting_pairs()

f_cmd.close()
f_log.close()

# closeAll all file

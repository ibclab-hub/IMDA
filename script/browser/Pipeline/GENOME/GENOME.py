# Pile up the alignment file                                                                         #
import sys
import os
import multiprocessing as mp
import subprocess as subp
import math
import json

d_dat = {}
l_chr = {}
d_step = {}
d_tarsyn = {}
d_allsyn = {}
d_usingsyn = []
binpath =os.path.dirname(os.path.abspath(__file__))+"/bin"

def processing_params(params_f):
    
    """

    # input : parammeter file
    # output : saving information 
    #   program path : d_step
    #   pipline IO : d_dat
    #   parameters : d_step["params"] 
    # processing parameter and save it to global dictionary input file to run program
    
    """

    status = 0

    for line in open(params_f):
        if line.startswith("#"):
            param_info = line.replace("##","").rstrip()
            if param_info == "Pipeline IO":
                status = 1
            continue

        if line=="\n": continue # pass the empty line

        elif status == 1: # Pipeline IO
            a_line = line.split()
            if a_line[0] == "spcs" or a_line[0] == "asms":
                d_dat[a_line[0]] = a_line[1].split(",")
            else:d_dat[a_line[0]] = a_line[1]

    # if dir_out is not existed, make directory
    if not os.path.isdir(d_dat["dir_out"]): 
        os.system(f"mkdir -p -m777  {d_dat['dir_out']}")
    
    piddir ="/".join(d_dat['dir_out'].split("/")[:-1])
    f_pid = open(f'{piddir}/pid.txt','w')
    f_pid.write(str(os.getpid()))
    f_pid.close()

    # make log and cmd file
    d_dat["f_cmd"] = d_dat["dir_out"]+"/CMDs"
    d_dat["f_log"] = "/".join(d_dat["dir_out"].split("/")[:-1])+"/log.txt"

    # construct output directory architecture
    dir_for_output = ["seqs","alns","results","tmp","pos"]
    for s in dir_for_output:
        if not os.path.isdir(d_dat["dir_out"]+"/"+s): 
            os.system(f"mkdir -p -m777  {d_dat['dir_out']}/{s}")
    return 1

def running(step, cmd):

    """

    # input : explanation for cmd, cmd
    # output : run programs
    # run cmd, write logs and cmds to cmd file
    
    """

    f_cmd.write(f"##{step}\n{cmd}\n")

    f_log.write(f"{step}\n")
    f_log.flush()
    
    # return True if running is finishied (wait())
    cmd = cmd.split(" ")
    running = subp.Popen(cmd, stdout=subp.PIPE, stderr=subp.PIPE)
    running.wait()
    out, err= running.communicate()


def fna_to_2bit(name, idx):
    
    """

    # input : species name and index of species in the all_spcs list 
    # output : saving 2bit file 
    # converting fna to 2bit file 
    
    """

    outdir = d_dat["dir_out"]+"/seqs"

    if idx == 0:
        cur_seq = "ref"
    else:
        cur_seq = "tar_"+str(idx)
    

    # convert fna to 2bit
    program = "faToTwoBit"
    sequence = d_dat[cur_seq]

    cmd = f"{program} {sequence} {outdir}/{name}.2bit"
    running(f"\tconverting {name} fa to 2bit",cmd)

    # get size from 2bit
    program = "twoBitInfo"
    twobit =  f"{outdir}/{name}.2bit"
    
    cmd = f"{program} {twobit} {outdir}/{name}.sizes"

    running(f"\tgetting {name} genome size", cmd)

    seqdir = d_dat["dir_out"]+"/seqs"
    
    for s in d_dat["spcs"]:
        for line in open(f'{d_dat["dir_out"]}/seqs/{ref}.sizes'):
            a_line = line.split()
            if not s in l_chr : l_chr[s] = {}
            l_chr[s][a_line[0]]=int(a_line[1])


    return 1

def parsing_syn():

    """

    # input : synteny file
    # output : parsed synteny file
    # parsing synteny file (Conserved.Segments) into txt file
    
    """
    ori_syn = d_dat["synteny"]
    syn_out = f"{d_dat['dir_out']}/synteny.txt"
    f_syn = open(syn_out,'w')

    # file header information
    header = ["#id"]
    for spcs in d_dat["spcs"]:
        header.append(f"{spcs}_chr\t{spcs}_start\t{spcs}_end\t{spcs}_strand")
    
    f_syn.write("\t".join(header)+"\n")

    # check the file format (preparing for other data types)
    for line in open(ori_syn):
        if line.startswith(">"):
            syn_id = line.rstrip().replace(">",'')
            info = [syn_id]
        elif line != "\n":
            spcs,pos = line.rstrip().split(":")
            nchr = spcs.split(".")[1]
            start,end = pos.split()[0].split("-")
            strand = pos.split()[1]
            info.append(f"{nchr}\t{start}\t{end}\t{strand}")
        else:
            f_syn.write("\t".join(info)+"\n")

    f_syn.close()

    # save synteny file path
    d_dat["synteny"] = syn_out

    return 1

def mking_input(ref, tar, tar_idx):
    
    """

    # input : reference species name, target species name, target index
    # output : parsed chain file that contained by synteny
    # get chain which is used to make synteny
    
    """

    # make output directory
    outdir = d_dat["dir_out"]+f"/alns/{ref}_{tar}"
    if not os.path.isdir(outdir): 
        os.system(f"mkdir -p -m777  {outdir}")
    if not os.path.isdir(f"{outdir}/alll_chr"):
        os.system(f"mkdir -p -m777 {outdir}/all")
    if not os.path.isdir(f"{d_dat['dir_out']}/alns/axts"):
        os.system(f"mkdir -p -m777 {d_dat['dir_out']}/alns/axts")

    seqdir = d_dat["dir_out"]+"/seqs"

    cur_tar = "tar_"+str(tar_idx)

    allchain =  d_dat[f"ref_{cur_tar}"]+"/all.chain"

    chainNet_cmd = f"chainNet {allchain} {seqdir}/{ref}.sizes {seqdir}/{tar}.sizes {outdir}/all/all.net {outdir}/{tar}.net"
    running('\tchain to net conversion',chainNet_cmd)

    allnet = f"{outdir}/all/all.net"
    split_cmd = f"{binpath}/splitChainNet.pl -b {binpath} --chain {allchain} --net {allnet} -o {outdir}"
    running('\tsplit chain, net file to chromosome level', split_cmd)

    chaindir = f"{outdir}/chain"
    netdir = f"{outdir}/net"
    synteny = d_dat["synteny"]
    

    # get reference and target synteny pos  
    
    ntoa_cmd = open(f"{outdir}/ntoa.{tar}.cmd",'w')
    pileup_cmd = open(f"{d_dat['dir_out']}/tmp/pileup.cmd",'w')
    for chrs in l_chr[ref]:
        ntoa_cmd.write(net_to_axt(ref,tar,cur_tar,chrs,outdir)+"\n")
        pileup_cmd.write(f"python3 {binpath}/pileup.py {chrs} {','.join(d_dat['spcs'])} {seqdir} {d_dat['dir_out']}/alns/axts {d_dat['dir_out']}/results {d_dat['dir_out']}/synteny.txt 1> {d_dat['dir_out']}/results/{chrs}.pileup.log\n")
    ntoa_cmd.close()
    pileup_cmd.close()

    ntoa_cmd = f"python3 {binpath}/mp.py {outdir}/ntoa.{tar}.cmd {d_dat['threads']}"
    running('\tconvert net to axt', ntoa_cmd)

    return 1    
    
def net_to_axt(ref,tar,cur_tar, nchr,outdir):

    outdir = f"{outdir}"
    
    program = "netToAxt"
    seqdir = d_dat["dir_out"]+"/seqs"

    cur_chain = f"{outdir}/chain/{nchr}.chain"
    cur_net =f"{outdir}/net/{nchr}.net"

    cmd = f"{program} -noSplit -maxGap=1000000 {cur_net} {cur_chain} {seqdir}/{ref}.2bit {seqdir}/{tar}.2bit {d_dat['dir_out']}/alns/axts/{ref}_{tar}.{nchr}.axt 2> {d_dat['dir_out']}/alns/axts/nettoaxt.{tar}.{nchr}.log"
    
    return cmd



def making_json():
    outpath = "/".join(d_dat['dir_out'].split("/")[:-1])
    json_cmd = f"python3 {binpath}/convertbed.py {d_dat['dir_out']}/seqs/{ref}.sizes {d_dat['dir_out']}/results {outpath} out.bed"
    running('\tConverting conv.scores to json', json_cmd)


#main

processing_params(sys.argv[1])

f_cmd = open(d_dat["f_cmd"],"w")
f_log = open(d_dat["f_log"],"a")

ref = d_dat["spcs"][0]

f_log.write("### Genome conservation score calculation\n")
f_log.flush()


f_log.write("## Preprocessing input files\n")
f_log.flush()

for i in range(len(d_dat["spcs"])):
   fna_to_2bit(d_dat["spcs"][i], i)

parsing_syn()

for i in range(1, len(d_dat["spcs"])):
    mking_input(ref,d_dat["spcs"][i],i)

pileup_cmd = f"python {binpath}/mp.py {d_dat['dir_out']}/tmp/pileup.cmd {d_dat['threads']}"
f_log.write(f"## Pileup Sequences and calculate scores -> {pileup_cmd}\n")
f_log.flush()
running("\tpileup sequences and calculate scores", pileup_cmd)

making_json()
        
f_cmd.close()
f_log.close()

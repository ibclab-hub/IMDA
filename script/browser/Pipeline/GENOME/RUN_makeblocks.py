import sys
import os
import subprocess as subp
from timeit import timeit
from datetime import datetime

###################################################################
# Variables

param = sys.argv[1] # input parameter file
abs_path = os.path.abspath(__file__) # current path
c_path, scriptname = os.path.split(abs_path)
f_log = ""
###################################################################
# Functions

def parsing_params(param:str)->dict:
    d_param = {}
    fp = open(param, 'r')
    for line in fp:
        line = line.strip()
        if line == "":
            continue
        if line[0] == '#':
            index = line[1:]
            if index == 'TAR':
                d_param[index] = {}
        else:
            if index == 'TAR':
                info = line.split()
                d_param[index][info[1]] = (info[0],info[2])
            elif index == "REF":
                d_param[index] = line.split()
            else:
                d_param[index] = line
    fp.close()
    
    outpath = "/".join(d_param['OUT_DIR'].split("/")[:-1])

    f_pid = open(f'{outpath}/pid.txt','w')
    f_pid.write(str(os.getpid()))
    f_pid.close()


    f_log = f"{outpath}/log.txt"
    f_log = open(f_log, 'a')
    f_log.write("### Makeblocks Synteny generation\n")
    f_log.write("## Preprocessing input files\n")
    f_log.flush()
    os.system(f"mkdir -p -m777 {d_param['OUT_DIR']}")
    os.chdir(d_param['OUT_DIR'])

    os.system(f"mkdir -p -m777 ./chainnet")
    
    f_size = d_param["GENOME_DIR"]+"/"+d_param["REF"][1]+"/"+d_param["REF"][1]+".size"
    get_size(f_size)
    os.makedirs(f"chainnet/{d_param['REF'][0]}", exist_ok = True)
    
    for s in d_param["TAR"]:
        os.makedirs(f"chainnet/{d_param['REF'][0]}/{d_param['TAR'][s][0]}",exist_ok=True)
        os.system(f"cp {d_param['CHAINNET_DIR']}/{d_param['TAR'][s][1]}/all.chain ./")
        
        f_size = d_param["GENOME_DIR"]+"/"+s+"/"+s+".size"
        get_size(f_size)
        
        chainNet_cmd = f"chainNet ./all.chain {d_param['REF'][1]}.size {s}.size all.net tar.net"
        run = subp.Popen(chainNet_cmd, shell=True, stderr=subp.PIPE)
        run.wait()

        split_cmd = f"{c_path}/bin/splitChainNet.pl -b {c_path}/bin --chain all.chain --net all.net -o chainnet/{d_param['REF'][0]}/{d_param['TAR'][s][0]}"
        
        run = subp.Popen(split_cmd, shell=True)
        run.wait()
        
        os.system("rm -rf ./all.chain ./all.net")
    

    return d_param,f_log

def get_size(asm_size_file):
    cmd = f"cp {asm_size_file} ./"
    run = subp.Popen(cmd, shell=True)
    run.wait()

def make_config(d_param:dict):
    f = open(f'{d_param["OUT_DIR"]}/config', 'w')
    f.write(f">chaindir\n./chainnet\n\n")
    f.write(f">netdir\n./chainnet\n\n")
    f.write(f">resolution\n{d_param['RESOLUTION']}\n\n")
    f.write(f">species\n")
    f.write(f"{d_param['REF'][0]} 0\n")
    for sid in d_param['TAR']:
        f.write(f"{d_param['TAR'][sid][0]} 1\n")
        f.write("")
    f.close()

def run_makeblocks(d_param:dict)->None:
    cmd = f"{c_path}/bin/run.Makeblocks {d_param['OUT_DIR']}/config 2> {d_param['OUT_DIR']}/makeblocks.log"
    f_log.write("## Constructing synteny\n")
    f_log.flush()
    f_log.write(f"# Making synteny by makeblocks -> {cmd}\n")
    f_log.flush()
    run = subp.Popen(cmd,shell=True)
    run.wait()
    outputcs = f"{d_param['OUT_DIR']}/Conserved.Segments"
    outputgo = f"{d_param['OUT_DIR']}/Genomes.Order"
    if  os.path.isfile(outputcs) and  os.path.isfile(outputgo):
        csSize = os.path.getsize(outputcs)
        goSize = os.path.getsize(outputgo)
        if csSize == 0 or goSize ==0:
            return 0    
    else:
        return 0
    os.system(f"cp {d_param['OUT_DIR']}/Conserved.Segments ../")
    

    f = open('./json_config', 'w')
    f.write(f"SF=Conserved.Segments\n")
    f.write(f"Ref={d_param['REF'][0]}\n")
    f.write(f"Size={d_param['REF'][0]}:{d_param['REF'][1]}.size\n")
    for sid in d_param['TAR']:
        f.write(f"Size={d_param['TAR'][sid][0]}:{sid}.size\n")
    f.close()

    cmd = f"{c_path}/bin/sf2json_addorder_cs.pl {d_param['OUT_DIR']}/json_config > ./synteny.json"
    f_log.write("## Converting synteny to json\n")
    f_log.flush()
    f_log.write(f"# Converting Conserved.Segments to json -> {cmd}\n")
    f_log.flush()
    run = subp.Popen(cmd,shell=True)
    run.wait()
    return 1

###################################################################
# Main
# Time check
setup = 'from datetime import datetime'
statement  ='datetime.now'
result = timeit(setup=setup, stmt=statement)

# Loading parameters
d_param,f_log = parsing_params(param)

f_log.flush()

# Run Makeblocks
make_config(d_param)
csdone = run_makeblocks(d_param)

f_log.close()

if csdone == 0:
    os.system(f"touch error")

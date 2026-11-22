import sys
import os
import subprocess as subp
from timeit import timeit
from datetime import datetime

# Class for reference
class Ref:
  nid = ''
  name = ''
  filename = ''
  size = ''

  def setdata(self, id, name, filename):
    self.nid = id
    self.name = name
    self.filename = filename


# Class for targets
class Tar:
  nid = ''
  name = ''
  filename = ''
  alnid = ''
  size = ''
  ready = ''

  def __init__(self, id, name, filename, alnid,ready, distance):
    self.nid = id
    self.name = name
    self.filename = filename
    self.alnid = alnid
    self.ready = ready
    self.distance = distance


def run(step,cmd):
    #f_log.write(f"{step} -> {cmd}\n")
    #f_log.flush()
    run = subp.Popen(cmd,shell=True)
    run.wait()



def parsing_params(fparam:str):

    """Parsing parameters

    Args:
        fparam (str): Parameter file path

    Returns:
        ref : reference information class
        targets : target information class
        d_params : paramter information dictionary
        
    """

    ref = Ref()
    targets = []
    fparam= open(fparam,'r')
    for line in fparam:
        line = line.strip()
        if line == "": continue
        info = line.split()
        if info[0] == 'ref':
            ref.setdata(info[1], info[2], info[3])
            ref.size = get_size(ref)
        elif info[0].startswith("tar"):
            tar = Tar(info[1], info[2], info[3], info[4], info[5],info[6])
            tar.size = get_size(tar)
            targets.append(tar)
        else:
            d_params[info[0]] = info[1]
    
    fparam.close()
    dirout = d_params["dir_out"]
    f_pid = open(f'{dirout}/pid.txt','w')
    f_pid.write(str(os.getpid()))
    f_pid.close()

    if not os.path.isdir(d_params["dir_out"]):
        os.system(f"mkdir {d_params['dir_out']}")
        os.system(f"chmod 777 {d_params['dir_out']}")

    return ref,targets,d_params

def get_size(spcs):
    cmd = f"{c_path}/bin/faSize -detailed {spcs.filename} > {d_params['dir_out']}/{spcs.nid}.sizes"
    os.system(cmd)
    return f"{d_params['dir_out']}/{spcs.nid}.sizes"

def check_alignment(tar)-> None:
    if tar.ready == "X": return 0
    else: return 1

def wg_alignment(ref,tar,f_log):
    if not check_alignment(tar):
        run_lastz(ref,tar,f_log)
    else:
        log_print = "## Skip alignment : Alignment between "+ref.name+" - "+tar.name+" already exists! \n"
        f_log.write(log_print)
        f_log.flush()

def run_lastz(ref,tar,f_log):
    cmd = f'{c_path}/buildChainNet_forkManager.pl --divtime {tar.distance} -p {nncpu} -o {d_params["dir_out"]}/{tar.alnid}  -ref_size {ref.size}  -tar_size {tar.size}  {ref.filename} {tar.filename} 2> {d_params["dir_out"]}/lastz.log.txt' # by JK
    log_print = "## LASTZ alignment : "+ref.name+" - "+tar.name+"\n"
    f_log.write(log_print)
    f_log.flush()
    run(f"# ({ref.name},{tar.name}) by lastz",cmd)
    

def make_net(ref,tar):
    cmd = f'chainNet /DATA/ALIGNMENT/LASTZ/{tar.alnid}/all.chain -minSpace=1 {ref.size} {tar.size} stdout /dev/null | netSyntenic stdin /DATA/ALIGNMENT/LASTZ/{tar.alnid}/all.net'
    run(f"# Converting ({ref.name},{tar.name}) chain file to net file", cmd)


def split_chain_net(ref,tar):
    cmd = f'{c_path}/splitChainNet.pl -b {c_path}/bin -chain {d_params["dir_out"]}/{tar.nid}/all.chain -net {d_params["dir_out"]}/{tar.nid}/all.net -o {d_params["dir_out"]}{tar.nid}'
    run("# Spliting chain and net for synteny", cmd)

def swap_chain(ref,tar):
    cmd = f"{c_path}/bin/chainSwap {d_params['dir_out']}/{ref.nid}/{tar.nid}/raw_chainNet/all.chain {d_params['dir_out']}/{tar.nid}/{ref.nid}/all.chain"
    run("",cmd)


###################################################################
# Variables
param = sys.argv[1] # input parameter file
nncpu = sys.argv[2] # by JK
abs_path = os.path.abspath(__file__) # current path
c_path, scriptname = os.path.split(abs_path)
index = ''
targets = []
d_params = {}
###################################################################



###################################################################
# Main
setup = 'from datetime import datetime'
statement  ='datetime.now'
result = timeit(setup=setup, stmt=statement)

# Loading parameters
ref,targets,d_params = parsing_params(param)
f_log = "/".join(d_params['dir_out'].split("/")[:-2])+"/log.txt"
f_log = open(f_log, 'a')

# Making whole-genome alignment for all targets
f_log.write("## Whole genome alignment\n")
f_log.flush()
stat = 0
for tar in targets:
    wg_alignment(ref,tar,f_log)

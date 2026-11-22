#!/usr/bin/env python3.6

import sys
import multiprocessing as mp
import subprocess as subp

incmds = open(sys.argv[1]).read().split("\n")
cpu = int(sys.argv[2])

def processing(cmd):
    run = subp.Popen(cmd, shell=True)
    run.wait()


if __name__=="__main__":
    pool = mp.Pool(processes = cpu)
    pool.map(processing,incmds)

    pool.close()
    pool.join()



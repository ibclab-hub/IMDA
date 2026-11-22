#!/usr/bin/env python3.6

import sys
import os
import math
import subprocess as subp

def saving_syn(syn_out):
    # conseved.segments -> 0-based
    # saving synteny information

    # d_tarsyn : {nid : (nchr, start, end, strand, qchr1, qchr2, ...)}
    # d_allsyn : {tar_chr:
    #             {que_chr: [(syn_id, tar_info, que_info)]}
    #            }

    d_tarsyn = {}
    d_allsyn = {}

    for line in open(syn_out): 
        if "#" in line or line == "\n": continue
        a_line = line.split()
        nid, nchr, start, end, strand = a_line[0:5]

        d_tarsyn[nid] = [nchr,start,end, strand]
        for i in range(len(que)):
            ques = que[i]
            if not ques in d_allsyn:
                d_allsyn[ques] = {}
    
            d_syn = d_allsyn[ques]
            syn_id, tar_info, que_info = a_line[0], a_line[1:5], a_line[4*(i+1)+1:4*(i+1)+5]
            tar_chr, que_chr = tar_info[0], que_info[0]
            d_tarsyn[nid].append(que_chr)
            if not tar_chr in d_syn:
                d_syn[tar_chr] = {}
            if not que_chr in d_syn[tar_info[0]]:
                d_syn[tar_chr][que_chr] = []

            d_syn[tar_chr][que_chr].append((syn_id, tar_info, que_info))
        d_tarsyn[nid] = tuple(d_tarsyn[nid])
    return d_tarsyn, d_allsyn

def saving_size():
    # saving chromosome size
    for s in spcs:
        sizefile = f"{seqdir}/{s}.sizes"
        d_sizes[s] = {}
        for line in open(sizefile):
            nchr, size = line.split()
            d_sizes[s][nchr] = int(size)

def pileup_seq():

    # saving per base entropy, gap proportion
    
    print("# Pileing up sequences", file=sys.stderr)
    
    d_pileup = {}
    cur_outfile = open(f"{outdir}/{nchr}.conv.scores",'w')
    cur_outfile.write("NCHR\tPOS\t")
    for k in range(len(que)):
        cur_outfile.write(f"Q{k+1}_NCHR\tQ{k+1}_POS\t")
    cur_outfile.write("ENTROPY\tGAP_PROP\n")

    for i in range(len(que)):
        ques= que[i]
        # saving alignment information
        d_pileup[ques] = {}
        
        cur_axt = axtdir+f"/{tar}_{ques}.{nchr}.axt"

        # axt saving
        for line in open(cur_axt):
            if "#" in line: continue
            if len(line.split()) >= 2:
                a_line = line.split()
                tchr = a_line[1]
                tstart, tend = list(map(int, a_line[2:4]))
                tstart = tstart 
                qchr = a_line[4]
                qstart, qend = list(map(int,a_line[5:7]))
                qstart = qstart
                strand = a_line[7]
                
                # strannd "-", saving position (reverse)
                if strand == "-":
                    qstart, qend = d_sizes[ques][qchr]-qstart+1, d_sizes[ques][qchr]-qend
                
                if not qchr in d_pileup[ques]:
                    d_pileup[ques][qchr] = []
                
                cur_stat = 0

            elif line != "\n":

                if cur_stat == 0:
                    tar_seq = line.rstrip()
                    cur_stat += 1

                elif cur_stat == 1:
                    que_seq = line.rstrip()
                    cur_stat += 1  
                if cur_stat == 2:
                    d_pileup[ques][qchr].append([(tchr, tstart, tend), (qchr, qstart, qend, strand), tar_seq, que_seq])
                    cur_stat = 0 
   
    print("# Calculating scores")
    # calculate entropy per synteny

    meanfile = open(f"{outdir}/{nchr}.syn.mean.txt",'w')
    meanfile.write("ID\tGAP_MEAN\tENTROPY_MEAN\tBASECNT\n")
    for nid in d_tarsyn:
        tarsyn = d_tarsyn[nid]
        s_tchr, s_tstart, s_tend, s_str = tarsyn[:4]
        mean_entval, mean_gap = 0,0
        basecnt = 0
        if s_tchr != nchr: continue
        else:
            s_tstart, s_tend = int(s_tstart)+1,int(s_tend)
            
           
            for windows in range(s_tstart, s_tend+1, 1000000):
                c_tstart, c_tend = windows, windows+1000000-1
                if c_tend > s_tend: c_tend = s_tend
                d_bases = {}

                for bpos in range(c_tstart, c_tend+1):
                    d_bases[bpos] = [[0,0,0,0,0,[0 for i in range(len(que))]],{}]
            

                for i in range(len(que)):

                
                    ques = que[i]
                    s_qchr = tarsyn[3+i+1] # take qchr from tarsyn and find same syntenys 
                    cur_syn = d_allsyn[ques][s_tchr][s_qchr]
                    quesyn = ''
                    for s in cur_syn: 
                        if s[0] == nid:
                            quesyn = s
                            break
                    
                    # target synteny information
                    s_qstart, s_qend, s_str = int(quesyn[2][1]), int(quesyn[2][2]), quesyn[2][3]
                    for seqs in d_pileup[ques][s_qchr]:
                        
                        # get axt file line
                        tinfo, qinfo, tar_seq, que_seq = seqs
                        if (tinfo[2] < c_tstart) or (tinfo[1] > c_tend): continue
                        else:
                            if (qinfo[2] < s_qstart) or (qinfo[1] > s_qend) or s_str != qinfo[3] : continue
                            else:
                                tgap_cnt = 0
                                qgap_cnt = 0
                                cur_start = 0
                                len_syn = 0
                                stat = 0
                                
                                for j in range(len(tar_seq)):
                                    # per base position

                                    # target base position
                                    if tar_seq[j] == "-":
                                        tgap_cnt += 1
                                        continue
                                    if que_seq[j] == "-" : 
                                        qgap_cnt += 1
                                    tpos = tinfo[1] + j - tgap_cnt

                                    # query base position (if strand is '-', reversed)
                                    if qinfo[3] == "-":
                                        qpos = qinfo[1] - j + qgap_cnt
                                    else:
                                        qpos = qinfo[1] + j - qgap_cnt

                                    if tpos >= c_tstart and tpos <= c_tend and qpos >= s_qstart and qpos <= s_qend:
                                        if i==0:
                                            d_bases[tpos] = saving_base(tar_seq[j],tpos,i,d_bases[tpos])
                                            d_bases[tpos] = saving_pos(tpos,que[i], s_qchr, qpos, d_bases[tpos])
                                            d_bases[tpos] = saving_base(que_seq[j],tpos,i,d_bases[tpos])

                                        else:
                                            d_bases[tpos] = saving_pos(tpos,que[i], s_qchr, qpos, d_bases[tpos])
                                            d_bases[tpos] = saving_base(que_seq[j],tpos,i,d_bases[tpos])
                                            
                                       

                for bpos in d_bases:
                    result= calculating_entropy((s_tchr,bpos),d_bases[bpos],cur_outfile)
                    if result == 0 : continue
                    else:
                        if nid==126 or nid==12:
                            print(nid,s_tchr,bpos,result[0],result[1],sep='\t')
                        mean_gap += result[1]
                        mean_entval += result[0]
                        basecnt += 1                    
                
        meanfile.write(f"{nid}\t{mean_gap/basecnt}\t{mean_entval/basecnt}\t{basecnt}\n")
    cur_outfile.close() 

def saving_base(bp,tpos,quenum,baseinfo):
    cur_base = sum(baseinfo[0][:5])+sum(baseinfo[0][5])
    if cur_base > len(spcs): return baseinfo

    if bp != "-":
        base_index = base.index(bp.upper())
        baseinfo[0][base_index] += 1

    else:
        baseinfo[0][5][quenum] += 1
    return baseinfo

def saving_pos(tpos,name, s_qchr, qpos,baseinfo):
    
    cur_base = sum(baseinfo[0][:5])+sum(baseinfo[0][5])
    if cur_base > len(spcs): return baseinfo


    baseinfo[1][name] = (s_qchr,qpos)
    return baseinfo

def calculating_entropy(pos,bases,outfile):
    bpsum = sum(bases[0][:5])+sum(bases[0][5])
    if bpsum == 0: return 0
    gap_ratio, ent = 0,0
    base_cnt = sum(bases[0][:5])
    for base in bases[0][:5]:
        if base :
            ent -= base*(math.log2(base/base_cnt))
        
    if sum(bases[0][:5])+sum(bases[0][5]) != 0 : gap_ratio = sum(bases[0][5])/(sum(bases[0][:5])+sum(bases[0][5]))
    outstr = f"{pos[0]}\t{pos[1]}\t"
    outstr += f"{ent}\t{gap_ratio}\n"
    outfile.write(outstr)

    saving_tarpos(pos,bases,spcs)
    return ent, gap_ratio

def mking_posfile(spcs):
    d_posf = {}
    ref = spcs[0]
    for i in range(1,(len(spcs))):
        d_posf[f"{ref}-{spcs[i]}"] = open(f"{outdir}/pos/{ref}-{spcs[i]}.{nchr}.pos",'w')

    return d_posf

def saving_tarpos(pos, bases, spcs):
    ref = spcs[0]
    for i in range(1,(len(spcs))):
        if not spcs[i] in bases[1] : continue
        d_posf[f"{ref}-{spcs[i]}"].write(f"{pos[0]}\t{pos[1]}\t{bases[1][spcs[i]][0]}\t{bases[1][spcs[i]][1]}\n")


def close_posfile(spcs):
    ref = spcs[0]
    for i in range(1,(len(spcs))):
        d_posf[f"{ref}-{spcs[i]}"].close()


#################################################### Variables ####################################################
nchr = sys.argv[1]
spcs = sys.argv[2].split(",")
tar = spcs[0]
que = spcs[1:]
seqdir = sys.argv[3]
axtdir = sys.argv[4]
outdir = sys.argv[5]
synteny = sys.argv[6]
base = ["A","C","G","T","N"]
d_sizes = {}
d_posf = {}

#################################################### Pileup alignments ####################################################

os.makedirs(f"{outdir}/pos/",exist_ok=True)
d_posf = mking_posfile(spcs)
d_tarsyn,d_allsyn = saving_syn(synteny)
saving_size()
pileup_seq()








#!/usr/bin/env python3

import sys
import os
import json

insynteny = sys.argv[1]

user = "webtest"
db_name = "KUBDS"

getsyncmd = f'mysql -sN -u {user} -e\'SELECT s.synteny_id, CONCAT(t.name,"(", a.breed,")") as reference , GROUP_CONCAT(DISTINCT(CONCAT(t2.name,"(",a2.breed,"|",d.distance,")"))) as target ,  s.resolution, s.alignment_program, s.program, s.path FROM synteny s INNER JOIN assembly a ON a.assembly_id=s.reference_assembly INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id INNER JOIN species_set ss ON ss.species_set_id = s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id INNER JOIN distance d ON (d.species1=a.assembly_id AND d.species2=a2.assembly_id) OR (d.species1=a2.assembly_id AND d.species2=a.assembly_id) WHERE s.synteny_id='+insynteny+f' GROUP BY s.synteny_id;\' {db_name}'
syninfo = os.popen(getsyncmd).read().rstrip().split()

synd = {"data_type":"Synteny","info":{}}
header = ["id", "Target_genome", "Compared_genome", "Minimum_resolution", "Alignment_program", "Synteny_block_detection_program", "path"]
for i in range(len(syninfo)):
    synd["info"][header[i]] = syninfo[i]
    if header[i] == "path":
        synd["info"][header[i]] = synd["info"][header[i]]+synd["info"]["Minimum_resolution"]+"_synteny.json"



getspcscmd = f"mysql -sN -u {user} -e \"SELECT CONCAT(s.synteny_id,'|',a.breed,',',t.name,',',a.assembly_id,'|',GROUP_CONCAT(a2.breed,':',t2.name,':',a2.assembly_id)) FROM synteny s INNER JOIN assembly a ON s.reference_assembly = a.assembly_id INNER JOIN taxon_id t ON a.taxon_id =t.taxon_id INNER JOIN species_set ss ON ss.species_set_id =s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id WHERE s.synteny_id="+insynteny+f" GROUP BY s.reference_assembly, s.target_species_set,s.resolution\" {db_name} | tr '\t' '\t'"


inspecies = os.popen(getspcscmd).read().rstrip().split("|")
inspecies_id = [inspecies[1].split(",")[2]]
inspecies_name = [inspecies[1].split(",")[1]]
inspecies_breed = [inspecies[1].split(",")[0]]

new_species_name = {}
new_species_name[inspecies[1].split(",")[2]] = inspecies[1].split(",")[1] 

exists_inspecies = {}
exists_inspecies[inspecies_name[0]] = 1
newcnt=1;


for s in inspecies[2].split(","):
    newSpc = s.split(":")[1]
    if newSpc in exists_inspecies:
        newSpc = newSpc+"_"+str(newcnt)
        newcnt = newcnt+1
    else:
        exists_inspecies[newSpc]=1
 
    inspecies_id.append(s.split(":")[2])
    inspecies_name.append(newSpc)
    new_species_name[s.split(":")[2]] = newSpc 
    inspecies_breed.append(s.split(":")[0])

inspecies = inspecies_id


prefix = {}
prefix["Epigenome_chip"] = "C"
prefix["Epigenome_hic"] = "H"
prefix["Epigenome_meth"] = "M"
prefix["Transcriptome"]="T"
query = {}
query["Gene annotation"] = 'SELECT a.assembly_id, t.name, a.breed, a.annotation_path FROM assembly a INNER JOIN taxon_id t ON a.taxon_id=t.taxon_id WHERE a.assembly_id in ('+",".join(inspecies)+');'
query["Histone modification"] ='SELECT ec.data_id,t.name,CONCAT("(",ec.param_bandwith,",",ec.param_qcutoff,")"),GROUP_CONCAT(si.tissue separator ","),ec.antibody,GROUP_CONCAT(si.cell_type  separator ","),GROUP_CONCAT(si.sample_name separator ","),ec.json_path ,a.assembly_id FROM Epigenome_ChIP ec INNER JOIN sample_set ss ON ss.sample_set_id=ec.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON ec.ref_assembly = a.assembly_id  WHERE ec.data_type="profile"  AND a.assembly_id IN ("' + '","'.join(inspecies)+'") GROUP BY ec.data_id' 
query["Chromatin interaction"] = 'SELECT eh.data_id,t.name,CONCAT("(",eh.param_bin_cnt,",",param_resolution,")"),GROUP_CONCAT(si.tissue separator ","),GROUP_CONCAT(si.cell_type separator ","),GROUP_CONCAT(si.sample_name separator ","),eh.json_path  ,a.assembly_id FROM Epigenome_HiC eh INNER JOIN sample_set ss ON ss.sample_set_id=eh.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON eh.ref_assembly = a.assembly_id WHERE eh.data_type="profile"  AND a.assembly_id IN ("' + '","'.join(inspecies)+'") GROUP BY eh.data_id' 
query["Methylation"]='SELECT em.data_id,t.name,CONCAT("(",em.param_score_min, ",", em.param_N,",",em.param_L,",",em.param_mincov,",",em.param_minqual,")"),GROUP_CONCAT(si.tissue separator ","),GROUP_CONCAT(si.cell_type separator ","),GROUP_CONCAT(si.sample_name separator ","),em.json_path ,a.assembly_id FROM Epigenome_Meth em INNER JOIN sample_set ss ON ss.sample_set_id=em.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON em.ref_assembly = a.assembly_id WHERE em.data_type="profile" AND a.assembly_id IN ("' +'","'.join(inspecies)+'") GROUP BY em.data_id' 
query["Gene expression"] = 'SELECT tr.data_id, t.name,GROUP_CONCAT(si.tissue separator ","),GROUP_CONCAT(si.cell_type separator ","),GROUP_CONCAT(si.sample_name separator ","),tr.json_path ,tr.ref_assembly FROM Transcriptome tr INNER JOIN sample_set ss ON ss.sample_set_id=tr.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON tr.ref_assembly = a.assembly_id  WHERE tr.data_type="profile" AND a.assembly_id IN ("' + '","'.join(inspecies)+'") GROUP BY tr.data_id'
query["Genome"] = "SELECT g.data_id,s.reference_assembly, ss.assembly_id, g.path FROM Genome g INNER JOIN synteny s ON g.synteny_id=s.synteny_id INNER JOIN species_set ss ON s.target_species_set = ss.species_set_id WHERE g.synteny_id="+insynteny+";"


dirname = {"Gene annotation":"/GENOME/","Histone modification":"Epigenome_chip", "Methylation profile":"/Multiomics/Epigenome_meth","Chromatin interaction profile":"/Multiomics/Epigenome_hic","Gene expression profile":"Transcriptome","Genome":"Multiomics/Genome"}

tissue = {}
genome_path = ""

com_name = {}
for s in inspecies:
    cmd = f"mysql -sN -u {user} -e 'SELECT t.name FROM assembly a INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id WHERE a.assembly_id = \""+s+f"\";' {db_name} | tr '\t' '\t'"
    name = os.popen(cmd).read().rstrip()
    com_name[s] = name
for s in query:
    cmd = f"mysql -sN -u {user} -e '" +query[s]+f";' {db_name} | tr '\\t' '\\t'"
    data = os.popen(cmd).read().split("\n")
    if s == "Histone modification" : 
        histype = list(set([i.split()[4] for i in data if i != '']))
        for h in histype:
            s1 = s+" ("+h+")"
            tissue[s1] = {}

            for line in data:
                a_line = line.rstrip().split()
                if not a_line : continue
                if a_line[4] != h : continue
                cur_tis = ",".join(list(set(a_line[3].split(","))))
                a_line[4] =  ",".join(list(set(a_line[4].split(","))))
                if not cur_tis in tissue[s1]: tissue[s1][cur_tis] = {}
                if not a_line[1] in  tissue[s1][cur_tis] :  tissue[s1][cur_tis][a_line[1]] = []
                tissue[s1][cur_tis][a_line[1]].append((a_line[0],a_line[2],a_line[5],a_line[6],a_line[7],a_line[8]))
    else:
        tissue[s] = {}
        for line in data:
            a_line = line.rstrip().split()
            if not a_line : continue
            if s=="Genome" : 
                tissue[s] = a_line
                continue
            elif s=="Gene annotation":
                tissue[s][a_line[2]] = a_line
                continue
            elif  s == "Gene expression" : 
                a_line.insert(2,"")
            cur_tis = ",".join(list(set(a_line[3].split(","))))
            a_line[4] =  ",".join(list(set(a_line[4].split(","))))
            if not cur_tis in tissue[s]: tissue[s][cur_tis] = {}
            if not a_line[1] in  tissue[s][cur_tis] :  tissue[s][cur_tis][a_line[1]] = []
            tissue[s][cur_tis][a_line[1]].append((a_line[0],a_line[2],a_line[4],a_line[5],a_line[6],a_line[7]))
cmd = 'mysql -sN -uwebtest -e "SELECT filename FROM metadata where data_type=\'dataroot\';" KUBDS;'
webroot = os.popen(cmd).read().rstrip()
cmd = 'mysql -sN -uwebtest -e "SELECT path FROM metadata where data_type=\'webroot\';" KUBDS;'
webroot_path = os.popen(cmd).read().rstrip()
data = {"data":[]}
pr = ""
for k in tissue:
    
    if k.startswith("Histone modification"): pr = "Epigenome_chip"
    elif k == "Chromatin interaction": pr = "Epigenome_hic"
    elif k == "Methylation": pr = "Epigenome_meth"
    elif k =="Gene expression": pr = "Transcriptome"
    dirname = f"{webroot}/Multiomics/{pr}"
    dirname_p = f"{webroot_path}/Multiomics/{pr}"
    if k == "Genome":
        if tissue[k] == {} : continue
        count = 1
        for s in ["ent", "gap"]:
            dirname = f"{webroot}/Multiomics/{k}_{s}"
            tmp= {}
            if s=="ent": 
                tmp["data_type"] = "Genome conservation (Entropy)"
                pr = "Genome_ent"
            else: 
                tmp["data_type"] = "Genome alignment gap (Proportion)"
                pr = "Genome_gap"
            tmp["info"] = []
            tmp1 = {}
            tmp1["tissue"] = "General"
            tmp1["sample_info"] = []
            tmp2={}
            tmp2["spcs"] = inspecies_name[0]
            tmp2["data_id"] = str(int(sys.argv[1]))+f"_{count}"
            tmp2["data_path"] = f"{dirname}/{sys.argv[1]}"
            tmp2["sample_id"] = inspecies_breed[0]
            tmp2["project"] = pr
            tmp1["sample_info"].append(tmp2)
            tmp["info"].append(tmp1)
            data["data"].append(tmp)
            count += 1
        continue
    elif k=="Gene annotation":
        pr = "GENOME"
        tmp = {}
        tmp["data_type"] = "Gene annotation"
        tmp["info"] = []
        tmp1 = {}
        tmp1["tissue"] = "General"
        tmp1["sample_info"] = []
        for spcs in tissue[k]:
            s = tissue[k][spcs]
            tmp2 = {}
            spcname = new_species_name[s[0]]    
            tmp2["spcs"] = spcname
            tmp2["data_id"] = s[0]
            tmp2["data_path"] = f"{webroot}/GENOME/{s[0]}"
            tmp2["sample_id"] = s[2]
            tmp2["project"] = pr
            tmp1["sample_info"].append(tmp2)
        tmp["info"].append(tmp1)
        data["data"].append(tmp)
        continue

    tmp = {}
    if k == "Histone modification (NULL)":
        tmp["data_type"] = "Histone modification"
    else:
        tmp["data_type"] = k
    tmp["info"] = []
    for tis in tissue[k]:
        tmp1 = {}
        if tis=="NULL":
            tmp1["tissue"] = ""
        else:
            tmp1["tissue"] = tis.replace("(",",").replace(")","")
        tmp1["sample_info"] = []
        for s in tissue[k][tis]:
            for h in tissue[k][tis][s]:
                newspc = new_species_name[h[5]]
                tmp2 = {}
                tmp2["spcs"] = newspc
                if not h[1] == "": tmp2["params"] = h[1]
                if h[2] == "NULL":
                    tmp2["cell_type"] = ""
                else:
                    tmp2["cell_type"] = h[2]
                tmp2["data_id"] = prefix[pr]+str(h[0])
                tmp2["data_path"] = f"{dirname}/{h[0]}"
                tmp2["param_path"] = f"{dirname_p}/{h[0]}/parameters.txt"
                tmp2["project"] = pr
                tmp2["sample_id"] = h[3]
                tmp1["sample_info"].append(tmp2)
        tmp["info"].append(tmp1)
    data["data"].append(tmp)
data["data"].append(synd)
data = json.dumps(data, indent=2)

print(data)

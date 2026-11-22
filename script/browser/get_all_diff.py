#!/usr/bin/env python3

import sys
import os
import json
import mysql.connector


insynteny = sys.argv[1]
conn = mysql.connector.connect(user='webtest', database='KUBDS')
cursor = conn.cursor()

user = "webtest"
db_name = "KUBDS"

getspcscmd = f"mysql -u {user} -sN -e \"SELECT CONCAT(s.synteny_id,'|',a.assembly_id,',',t.name,'|',GROUP_CONCAT(a2.assembly_id,':',t2.name)) FROM synteny s INNER JOIN assembly a ON s.reference_assembly = a.assembly_id INNER JOIN taxon_id t ON a.taxon_id =t.taxon_id INNER JOIN species_set ss ON ss.species_set_id =s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id WHERE s.synteny_id="+insynteny+f" GROUP BY s.reference_assembly, s.target_species_set,s.resolution\" {db_name} | tr '\t' '\t'"
inspecies = os.popen(getspcscmd).read().rstrip().split("|")
inspeciesid = [inspecies[1].split(",")[0]]
inspeciesname = [inspecies[1].split(",")[1]]
nameToID = {}
for s in inspecies[2].split(","):
    inspeciesid.append(s.split(":")[0])
    inspeciesname.append(s.split(":")[1])
    nameToID[s.split(":")[1]] = s.split(":")[0]

getspcscmd = f"mysql -u {user} -sN -e \"SELECT reference_assembly from synteny WHERE synteny_id="+insynteny+f" \"  {db_name} | tr '\t' '\t'"
refspeciesid = os.popen(getspcscmd).read().rstrip()
getspcsnamecmd = f"mysql -u {user} -sN -e \"select name from taxon_id where taxon_id = (select taxon_id from assembly where assembly_id = (select reference_assembly from synteny where synteny_id="+insynteny+f" )) \"  {db_name} | tr '\t' '\t'"
refspeciesname = os.popen(getspcsnamecmd).read().rstrip()
nameToID[str(refspeciesname)] = refspeciesid

query = {}
query["CD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Epigenome_ChIP_diff_ids.diff_id, reference_assembly,Epigenome_ChIP.data_id, SRA_id, sample_set_id from Epigenome_ChIP_diff_ids inner join Epigenome_ChIP_diff on Epigenome_ChIP_diff.diff_id = Epigenome_ChIP_diff_ids.diff_id inner join Epigenome_ChIP on multiomics_data_id = Epigenome_ChIP.data_id where generated_synteny = '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']
query["HD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Epigenome_HiC_diff_ids.diff_id, reference_assembly,Epigenome_HiC.data_id, SRA_id, sample_set_id from Epigenome_HiC_diff_ids inner join Epigenome_HiC_diff on Epigenome_HiC_diff.diff_id = Epigenome_HiC_diff_ids.diff_id inner join Epigenome_HiC on multiomics_data_id = Epigenome_HiC.data_id where generated_synteny = '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']
query["MD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Epigenome_Meth_diff_ids.diff_id, reference_assembly,Epigenome_Meth.data_id, SRA_id, sample_set_id from Epigenome_Meth_diff_ids inner join Epigenome_Meth_diff on Epigenome_Meth_diff.diff_id = Epigenome_Meth_diff_ids.diff_id inner join Epigenome_Meth  on multiomics_data_id = Epigenome_Meth.data_id where generated_synteny = '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']
query["TD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Transcriptome_diff_ids.diff_id, reference_assembly,Transcriptome.data_id, SRA_id, sample_set_id from Transcriptome_diff_ids inner join Transcriptome_diff on Transcriptome_diff.diff_id = Transcriptome_diff_ids.diff_id inner join Transcriptome on multiomics_data_id = Transcriptome.data_id where generated_synteny = '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']

prefix = {}
prefix["CD"] = "C"
prefix["HD"] = "H"
prefix["MD"] = "M"
prefix["TD"]="T"

diff_id = {}
diff_species = {}
diff_samples = {}
for s in query:
    cursor = conn.cursor()
    cursor.execute(query[s][0])
    cursor.execute(query[s][1])
    cursor.execute(query[s][2])
    data = cursor.fetchall()
    cursor.execute('DROP TEMPORARY TABLE IF EXISTS temp_table_name;')
    cursor.execute('DROP TEMPORARY TABLE IF EXISTS temp_table_name2;')
    if not data == "" :
        for k in data:
            samname = ""
            if k[2] == None:
                samname = "None"
            else:
                samname = str(k[2].rstrip())
                
            this_id = s+str(k[0])+"_"+str(k[0])+"_"+s
            if samname != "None":
                this_sample = prefix[s]+str(k[1])+"("+samname+")"
            else:
                this_sample = prefix[s]+str(k[1])
            if this_id in diff_samples.keys():
                if k[4] in diff_samples[this_id]:
                    diff_samples[this_id][k[4]].append(this_sample)
                else:
                    diff_samples[this_id][k[4]] = [this_sample,]
                diff_species[this_id].append(k[3])
            else:
                diff_species[this_id] = [k[3]]
                diff_samples[this_id] = {k[4]:[this_sample,]}



query = {}
query["CD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Epigenome_ChIP_diff_ids.diff_id, reference_assembly,Epigenome_ChIP.data_id, SRA_id, sample_set_id from Epigenome_ChIP_diff_ids inner join Epigenome_ChIP_diff on Epigenome_ChIP_diff.diff_id = Epigenome_ChIP_diff_ids.diff_id inner join Epigenome_ChIP on multiomics_data_id = Epigenome_ChIP.data_id where generated_synteny != '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']
query["HD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Epigenome_HiC_diff_ids.diff_id, reference_assembly,Epigenome_HiC.data_id, SRA_id, sample_set_id from Epigenome_HiC_diff_ids inner join Epigenome_HiC_diff on Epigenome_HiC_diff.diff_id = Epigenome_HiC_diff_ids.diff_id inner join Epigenome_HiC on multiomics_data_id = Epigenome_HiC.data_id where generated_synteny != '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct  diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']
query["MD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Epigenome_Meth_diff_ids.diff_id, reference_assembly,Epigenome_Meth.data_id, SRA_id, sample_set_id from Epigenome_Meth_diff_ids inner join Epigenome_Meth_diff on Epigenome_Meth_diff.diff_id = Epigenome_Meth_diff_ids.diff_id inner join Epigenome_Meth  on multiomics_data_id = Epigenome_Meth.data_id where generated_synteny != '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']
query["TD"] = ['CREATE TEMPORARY TABLE temp_table_name  as select Transcriptome_diff_ids.diff_id, reference_assembly,Transcriptome.data_id, SRA_id, sample_set_id from Transcriptome_diff_ids inner join Transcriptome_diff on Transcriptome_diff.diff_id = Transcriptome_diff_ids.diff_id inner join Transcriptome on multiomics_data_id = Transcriptome.data_id where generated_synteny != '+insynteny+';','CREATE TEMPORARY TABLE temp_table_name2  as  select diff_id, data_id, SRA_id, name as ref, sample_set_id from assembly inner join temp_table_name on reference_assembly = assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id;','select distinct  diff_id, data_id, SRA_id, ref, name from sample_set inner join temp_table_name2 on temp_table_name2.sample_set_id = sample_set.sample_set_id inner join taxon_id on sample_set.species = taxon_id.taxon_id;']

delete_diff_ids = {}
for s in query:
    cursor = conn.cursor()
    cursor.execute(query[s][0])
    cursor.execute(query[s][1])
    cursor.execute(query[s][2])
    data = cursor.fetchall()
    cursor.execute('DROP TEMPORARY TABLE IF EXISTS temp_table_name;')
    cursor.execute('DROP TEMPORARY TABLE IF EXISTS temp_table_name2;')
    if not data == "" :
        for k in data:
            samname = ""
            if k[2] == None:
                samname = "None"
            else:
                samname = str(k[2].rstrip())
                samname = str(k[2].rstrip())
            this_id = s+str(k[0])+"_"+str(k[0])+"_"+s
            if samname != "None":
                this_sample = prefix[s]+str(k[1])+"("+samname+")"
            else:
                this_sample = prefix[s]+str(k[1])
            if k[3] not in inspeciesname : 
                delete_diff_ids[this_id] = 1
                continue
            else:
                if k[4] not in inspeciesname:
                    delete_diff_ids[this_id] = 1
                    continue
            
            if this_id in diff_samples.keys():
                if k[4] in diff_samples[this_id]:
                    diff_samples[this_id][k[4]].append(this_sample)
                else:
                    delete_diff_ids[this_id] = 1
                    diff_samples[this_id][k[4]] = [this_sample,]
                diff_species[this_id].append(k[3])
            else:
                diff_species[this_id] = [k[3]]
                diff_samples[this_id] = {k[4]:[this_sample,]}


for ids in diff_species:
    diff_species[ids] = list(set(diff_species[ids]))

for ids in delete_diff_ids:
    diff_species.pop(ids, None)
    diff_samples.pop(ids,None)

webroot  = cursor.execute('select filename from metadata where data_type = "dataroot";')
data = cursor.fetchall()
webroot = data[0][0]+"/Multiomics/Diff/"
###
dict_data_type_naming = {}
dict_data_type_naming["HD"] = "Chromatin interaction profile"
dict_data_type_naming["TD"] = "Gene expression profile"
dict_data_type_naming["MD"] = "Methylation profile"
dict_data_type_naming["CD"] = "Histone modification profile" 

diff_table_name = {}
dict_data_type_naming["HD"] = "Chromatin interaction"
dict_data_type_naming["TD"] = "Gene expression"
dict_data_type_naming["MD"] = "Methylation"
dict_data_type_naming["CD"] = "Histone modification"

dict_table_naming = {}
dict_table_naming["HD"] = "Epigenome_HiC_diff"
dict_table_naming["TD"] = "Transcriptome_diff"
dict_table_naming["MD"] = "Epigenome_Meth_diff"
dict_table_naming["CD"] = "Epigenome_ChIP_diff"


dict_dir_naming = {}
dict_dir_naming["HD"] = "HIC"
dict_dir_naming["TD"] = "RNA"
dict_dir_naming["MD"] = "METH"
dict_dir_naming["CD"] = "CHIP"
############################################
data = {"data":[]}

diff_species = sorted(diff_species.items())
for (ids,species) in diff_species:
    tmp_single_record= {}
    list_id = ids.split('_')
    cursor.execute('select inter_intra  from '+dict_table_naming[list_id[2]]+' where diff_id = '+list_id[1]+';')
    _data = cursor.fetchall()
    flag_inter_intra = str(_data[0][0])
    inter_cnt=1
    if flag_inter_intra == "inter":
        for ref_spcs in diff_samples[ids].keys():
            tmp_single_record= {}
            tmp_single_record["data_id"] = list_id[0]+"."+str(inter_cnt)
            tmp_single_record["spcs"] = ref_spcs
            tmp_single_record["type"] = dict_data_type_naming[list_id[2]]
            tmp_single_record["data_path"] = webroot+"/"+dict_dir_naming[list_id[2]]+"/"+list_id[1]+"/"+nameToID[ref_spcs]
            tmp_single_record["sample_spcs"] = list(diff_samples[ids].keys())
            tmp_single_record["sample_id"] = diff_samples[ids]
            data["data"].append(tmp_single_record)
            inter_cnt = inter_cnt+1
    else:
        tmp_single_record["spcs"] = species[0]
        spcs = species[0]
        tmp_single_record["data_id"] = list_id[0]
        tmp_single_record["type"] = dict_data_type_naming[list_id[2]]
        tmp_single_record["data_path"] = webroot+"/"+dict_dir_naming[list_id[2]]+"/"+list_id[1]+"/"+nameToID[spcs]
        tmp_single_record["sample_spcs"] = list(diff_samples[ids].keys())
        tmp_single_record["sample_id"] = diff_samples[ids]
        data["data"].append(tmp_single_record)


data = json.dumps(data, indent=2)
print (data)

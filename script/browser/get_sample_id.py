#!/usr/bin/env python3

import sys
import os
import json


insynteny = sys.argv[1]
inspeciesname = sys.argv[2]
inanalysis = sys.argv[3]

user = "webtest"
db_name = "KUBDS"

query = {}
query["CHIP"] = 'SELECT t.name,si.tissue,ec.SRA_id,ec.antibody FROM Epigenome_ChIP ec INNER JOIN sample_set ss ON ss.sample_set_id=ec.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE ec.data_type!="profile" AND t.name="'+inspeciesname+'"'  
query["HIC"] = 'SELECT t.name,si.tissue,eh.SRA_id FROM Epigenome_HiC eh INNER JOIN sample_set ss ON ss.sample_set_id=eh.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE eh.data_type!="profile" AND t.name="'+inspeciesname+'"' 
query["METH"]= 'SELECT t.name,si.tissue,em.SRA_id FROM Epigenome_Meth em INNER JOIN sample_set ss ON ss.sample_set_id=em.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE em.data_type!="profile" AND t.name="'+inspeciesname+'"'
query["RNA"] = 'SELECT t.name,si.tissue, tr.SRA_id FROM Transcriptome tr INNER JOIN sample_set ss ON ss.sample_set_id=tr.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE tr.data_type!="profile" AND t.name="'+inspeciesname+'"'

dat = {}
genome_id = []
genome_path = ""

com_name = {}
cmd = f"mysql -sN -u {user} -e '" +query[inanalysis]+f";' {db_name} | tr '\\t' '\\t'"
data = os.popen(cmd).read().split("\n")
for line in data:
	if line == "" : continue
	a_line = line.rstrip().split()
	cur_spcs = a_line[0]
	if inanalysis=="CHIP": a_line[2] = a_line[2] + "("+a_line[3]+")" 
	if not cur_spcs in dat: dat[cur_spcs] = {}
	if not a_line[1] in dat[cur_spcs] : dat[cur_spcs][a_line[1]] = []
	dat[cur_spcs][a_line[1]].append(a_line[2])


tot ={"samples":[]}
for k in dat:
	for tis in dat[k]:
		tmp = {}
		tmp["sample"] = tis
		tmp["ids"] = dat[k][tis]
		tot["samples"].append(tmp)


json_string = json.dumps(tot)
print(json_string)

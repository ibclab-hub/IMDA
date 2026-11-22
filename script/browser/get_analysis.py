#!/usr/bin/env python3

import sys
import os
import json

insynteny = sys.argv[1]

user = "webtest"
db_name = "KUBDS"

getspcscmd = f"mysql -u {user} -sN -e \"SELECT CONCAT(s.synteny_id,'|',a.assembly_id,',',t.name,'|',GROUP_CONCAT(a2.assembly_id,':',t2.name)) FROM synteny s INNER JOIN assembly a ON s.reference_assembly = a.assembly_id INNER JOIN taxon_id t ON a.taxon_id =t.taxon_id INNER JOIN species_set ss ON ss.species_set_id =s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id WHERE s.synteny_id="+insynteny+f" GROUP BY s.reference_assembly, s.target_species_set,s.resolution\" {db_name} | tr '\t' '\t'"
inspecies = os.popen(getspcscmd).read().rstrip().split("|")
inspeciesid = [inspecies[1].split(",")[0]]
inspeciesname = [inspecies[1].split(",")[1]]

for s in inspecies[2].split(","):
    inspeciesid.append(s.split(":")[0])
    inspeciesname.append(s.split(":")[1])




query = {}
query["CHIP"] = 'SELECT t.name,si.tissue,ec.SRA_id,ec.antibody FROM Epigenome_ChIP ec INNER JOIN sample_set ss ON ss.sample_set_id=ec.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE ec.data_type!="profile" AND t.name IN ("'+'","'.join(inspeciesname)+'")'
query["HIC"] = 'SELECT t.name,si.tissue,eh.SRA_id FROM Epigenome_HiC eh INNER JOIN sample_set ss ON ss.sample_set_id=eh.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE eh.data_type!="profile" AND t.name IN ("'+'","'.join(inspeciesname)+'")' 
query["METH"]= 'SELECT t.name,si.tissue,em.SRA_id FROM Epigenome_Meth em INNER JOIN sample_set ss ON ss.sample_set_id=em.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE em.data_type!="profile" AND t.name IN ("'+'","'.join(inspeciesname)+'")'
query["RNA"] = 'SELECT t.name,si.tissue, tr.SRA_id FROM Transcriptome tr INNER JOIN sample_set ss ON ss.sample_set_id=tr.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id WHERE tr.data_type!="profile" AND t.name IN ("'+'","'.join(inspeciesname)+'")'



analysis_lst = {"data":[]}
for s in query:
    cmd = f"mysql -sN -u {user} -e '" +query[s]+f";' {db_name} | tr '\\t' '\\t'"
    data = os.popen(cmd).read().split("\n")
    if data != [''] : 
        tmp = {"type":s,"spcs":[]}
        for k in data:
            a_line = k.split()
            if not a_line: continue
            tmp["spcs"].append(a_line[0])
        analysis_lst["data"].append(tmp)        

json_string = json.dumps(analysis_lst)
print(json_string)

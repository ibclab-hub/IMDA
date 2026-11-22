#!/usr/bin/env python3.5

import sys
import os

inref = sys.argv[1]
intar = sys.argv[2]
a_intar = intar.split(",")
a_intar.sort(key=str.lower)
intar = ",".join(a_intar)
intarget = "'"+intar+"'"
file_path = "/".join(os.path.abspath(__file__).split("/")[:-1])

user = "webtest"
db_name = "KUBDS"

synquery = "SELECT s.synteny_id, CONCAT(t.name,'(', a.breed,')') as reference , GROUP_CONCAT(DISTINCT(CONCAT(t2.name,'(',a2.breed,':',d.distance,')'))) as target ,  s.resolution, s.alignment_program, s.program, s.path, GROUP_CONCAT(a2.breed order by a2.breed) target_set FROM synteny s INNER JOIN assembly a ON a.assembly_id = s.reference_assembly INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id INNER JOIN species_set ss ON ss.species_set_id = s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id INNER JOIN species_set_header ssh ON ss.species_set_id = ssh.species_set_id INNER JOIN distance d ON (d.species1=a.assembly_id AND d.species2=a2.assembly_id) OR (d.species1=a2.assembly_id AND d.species2=a.assembly_id) WHERE a.breed='"+inref+"' GROUP BY s.synteny_id HAVING target_set="+intarget
syncmd = f"mysql -u {user} -e\""+synquery+f";\" -sN {db_name} | tr '\t' '\t' "
data = os.popen(syncmd).read().rstrip().split("\n")
if data == ['']: 
	print("NA")
	quit()
for line in data:
	a_line = line.split()
	syninfo = "\t".join(a_line[0:7])+a_line[3]+"_synteny.json"
	multicmd = file_path+"/get_syntrackdata.py "+a_line[0]
	multiomics =os.popen(multicmd).read().rstrip()
	print(syninfo+"|"+multiomics)


#!/usr/bin/env python3

import sys
import os
import json

insynteny = sys.argv[1]

user = "webtest"
db_name = "KUBDS"

getspcscmd = f"mysql -sN -u {user} -e \"SELECT CONCAT(s.synteny_id,'|',a.assembly_id,',',t.common_name,'|',GROUP_CONCAT(a2.assembly_id,':',t2.common_name)) FROM synteny s INNER JOIN assembly a ON s.reference_assembly = a.assembly_id INNER JOIN taxon_id t ON a.taxon_id =t.taxon_id INNER JOIN species_set ss ON ss.species_set_id =s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id WHERE s.synteny_id="+insynteny+f" GROUP BY s.reference_assembly, s.target_species_set,s.resolution\" {db_name} | tr '\t' '\t'"
inspecies = os.popen(getspcscmd).read().rstrip().split("|")
inspecies_id = [inspecies[1].split(",")[0]]
inspecies_name = [inspecies[1].split(",")[1]]

for s in inspecies[2].split(","):
	inspecies_id.append(s.split(":")[0])
	inspecies_name.append(s.split(":")[1])

inspecies = inspecies_id

query = {}
query["Histone Modification Profile"] = 'SELECT ec.data_id,t.name,GROUP_CONCAT(distinct si.tissue separator ","),ec.antibody,GROUP_CONCAT(si.cell_type  separator ","),GROUP_CONCAT(si.sample_name separator ","),ec.json_path FROM Epigenome_ChIP ec INNER JOIN sample_set ss ON ss.sample_set_id=ec.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON ec.ref_assembly = a.assembly_id  WHERE ec.data_type="profile" AND a.assembly_id IN ("' + '","'.join(inspecies)+'") GROUP BY ec.data_id' 

query["Chromatin interaction profile"] = 'SELECT eh.data_id,t.name,GROUP_CONCAT(distinct si.tissue separator ","),GROUP_CONCAT(si.cell_type separator ","),GROUP_CONCAT(si.sample_name separator ","),eh.json_path FROM Epigenome_HiC eh INNER JOIN sample_set ss ON ss.sample_set_id=eh.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON eh.ref_assembly = a.assembly_id WHERE eh.data_type="profile" AND a.assembly_id IN ("' + '","'.join(inspecies)+'") GROUP BY eh.data_id' 
query["Methylation profile"]= 'SELECT em.data_id,t.name,GROUP_CONCAT(distinct si.tissue separator ","),GROUP_CONCAT(si.cell_type separator ","),GROUP_CONCAT(si.sample_name separator ","),em.json_path FROM Epigenome_Meth em INNER JOIN sample_set ss ON ss.sample_set_id=em.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON em.ref_assembly = a.assembly_id WHERE em.data_type="profile" AND a.assembly_id IN ("' +'","'.join(inspecies)+'") GROUP BY em.data_id' 
query["Gene expression profile"] = 'SELECT tr.data_id,t.name,GROUP_CONCAT(distinct si.tissue separator ","),GROUP_CONCAT(si.cell_type separator ","),GROUP_CONCAT(si.sample_name separator ","),tr.json_path FROM Transcriptome tr INNER JOIN sample_set ss ON ss.sample_set_id=tr.sample_set_id INNER JOIN sample_information si ON ss.sample_id=si.sample_id INNER JOIN taxon_id t ON si.species=t.taxon_id INNER JOIN assembly a ON tr.ref_assembly = a.assembly_id  WHERE tr.data_type="profile" AND a.assembly_id IN ("' + '","'.join(inspecies)+'") GROUP BY tr.data_id' 
query["Genome"] = "SELECT g.data_id, t1.name, a1.breed, GROUP_CONCAT(t2.name), GROUP_CONCAT(a2.breed), g.path FROM Genome g INNER JOIN synteny s ON g.synteny_id=s.synteny_id INNER JOIN species_set ss ON s.target_species_set = ss.species_set_id INNER JOIN assembly a1 ON s.reference_assembly = a1.assembly_id INNER JOIN taxon_id t1 ON t1.taxon_id=a1.taxon_id INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON t2.taxon_id=a2.taxon_id WHERE g.synteny_id="+insynteny+" GROUP BY s.synteny_id, ss.species_set_id;"


genome_path = ""
omicsdata = []

com_name = {}
for s in inspecies:
	cmd = f"mysql -sN -u {user} -e 'SELECT t.name FROM assembly a INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id WHERE a.assembly_id = \""+s+f"\";' {db_name} | tr '\t' '\t'"
	name = os.popen(cmd).read().rstrip()
	com_name[s] = name
for s in query:
	cmd =f"mysql -sN -u {user} -e '" +query[s]+f";' {db_name} | tr '\\t' '\\t'"
	data = os.popen(cmd).read().rstrip().split("\n")
	if s == "Histone Modification Profile" : 
		for line in data:
			a_line = line.split()
			if not a_line : continue
			datainfo = "\t".join([a_line[0], "Histone modification profile ("+a_line[3]+")", a_line[1], a_line[2], a_line[5]])
			omicsdata.append(datainfo)
	elif s=="Genome":
		for line in data:
			a_line = line.split()
			if not a_line : continue
			ref = (a_line[2],a_line[1])
			tarsid,tarsname = a_line[4].split(","),a_line[3].split(",")
			tar = [(tarsid[i],tarsname[i]) for i in range(len(tarsid))]
			for k in [ref]+tar:
				datainfo = '\t'.join([a_line[0], s, k[1], "General", k[0]])
				omicsdata.append(datainfo)

	else:
		for line in data:
			a_line = line.split()
			if not a_line : continue
			datainfo = '\t'.join([a_line[0],s,a_line[1], a_line[2],a_line[4]])
			omicsdata.append(datainfo)

print("|".join(omicsdata))



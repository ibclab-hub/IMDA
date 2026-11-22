#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use JSON;

my $db_name = "KUBDS";
my $user_id = "webtest";
my $password = '';

my %species = ();

# connect to MySQL database
my $dbh = DBI->connect("DBI:mysql:$db_name",$user_id,$password) or die("Error connecting to the database: $DBI::errstr\n");

my $asm_sql = "select concat(kingdom.kingdom_info, '%,%' ,phylum.phylum_info, '%,%' ,class.class_info, '%,%' ,orde.order_info, '%,%' ,family.family_info, '%,%' , genus.genus_info, '%,%' ,species.species_info, '%,%' ,assembly.breed )   from (select  assembly.breed, assembly.taxon_id,  taxon_id.name  from assembly
inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id) as assembly, (Select tax_id, concat(name, '%|%' ,common_name) as species_info  from species_tax_info inner join taxon_id  on species_tax_info.tax_id=taxon_id.taxon_id) as species, (Select tax_id, concat(name, '%|%' ,common_name) as
genus_info  from species_tax_info inner join taxon_id  on species_tax_info.tax_genus=taxon_id.taxon_id) as genus, (Select tax_id, concat(name, '%|%' ,common_name) as family_info from species_tax_info inner join taxon_id  on species_tax_info.tax_family=taxon_id.taxon_id) as family, (Select tax_id,
concat(name, '%|%' ,common_name) as order_info from species_tax_info inner join taxon_id  on species_tax_info.tax_order=taxon_id.taxon_id) as orde,  (Select tax_id, concat(name, '%|%' ,common_name) as class_info from species_tax_info inner join taxon_id  on
species_tax_info.tax_class=taxon_id.taxon_id) as class ,(Select tax_id, concat(name, '%|%' ,common_name) as phylum_info from species_tax_info inner join taxon_id  on species_tax_info.tax_phylum=taxon_id.taxon_id) as phylum , (Select tax_id, concat(name, '%|%' ,common_name) as kingdom_info from
species_tax_info inner join taxon_id  on species_tax_info.tax_kingdom=taxon_id.taxon_id) as kingdom where assembly.taxon_id=species.tax_id and species.tax_id=genus.tax_id and species.tax_id=family.tax_id and species.tax_id=orde.tax_id and species.tax_id=class.tax_id and species.tax_id=phylum.tax_id
	and species.tax_id=kingdom.tax_id;";


my $asm_sth = $dbh->prepare($asm_sql);
$asm_sth->execute();

$species{"root%|%root\t"} = 1;
while(my @row = $asm_sth->fetchrow_array()){
	my @col = split(/%,%/, $row[0]);
	
	$species{"$col[0]\troot%|%root"} = 1;
	for(my $i=1; $i<=$#col; ++$i){
		$col[$i] =~ s/\s+/_/g;
		$col[$i-1] =~ s/\s+/_/g;
		$species{"$col[$i]\t$col[$i-1]"} = 1;
	}
}

print "name\tparent\n";
foreach my $comb(keys %species){
	print "$comb\n";
}

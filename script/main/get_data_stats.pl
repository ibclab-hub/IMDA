#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

my $db_name = "KUBDS";
my $user_id = "webtest";
my $password = '';

# connect to MySQL database
my $dbh = DBI->connect("DBI:mysql:$db_name",$user_id,$password) or die("Error connecting to the database: $DBI::errstr\n");

my $comp_sql = "SELECT COUNT(*) FROM synteny";

my $sql = "SELECT CONCAT (t2.name, ',', t2.common_name, ',' , a.breed,',',a.accession, ',',t.common_name ) AS assembly_information FROM assembly a INNER JOIN species_tax_info i ON a.taxon_id=i.tax_species INNER JOIN taxon_id t ON i.tax_kingdom=t.taxon_Id INNER JOIN taxon_id t2 ON i.tax_species=t2.taxon_id;";

# example: desc Combination_table;
# +----------------+---------+------+-----+---------+-------+
# | Field          | Type    | Null | Key | Default | Extra |
# +----------------+---------+------+-----+---------+-------+
# | CID            | int(11) | NO   | PRI | NULL    |       |
# | Target_species | text    | YES  |     | NULL    |       |
# +----------------+---------+------+-----+---------+-------+

my $sth = $dbh->prepare($sql);
$sth->execute();

# print contents
my %kingdom_cnt = ();
while(my $row = $sth->fetchrow_array()){
	my ($name, $com_name, $id, $id2, $kingdom) = split(/,/, $row);
	$kingdom_cnt{$kingdom}{$id} = 1;
}
$sth->finish();

my $comp_sth = $dbh->prepare($comp_sql);
$comp_sth->execute();

my $comp_cnt = 0;
while(my $row = $comp_sth->fetchrow_array()){
	$comp_cnt = $row;
}

my $spclist_path;
my $path_sql = "SELECT path FROM metadata WHERE data_type = 'dataroot'";
my $path_sth = $dbh->prepare($path_sql);
$path_sth->execute();
while(my $row = $path_sth->fetchrow_array()){
	$spclist_path = $row;
}
$path_sth->finish();

$spclist_path .= "/metadata/assembly_summary/assembly_summary_refseq_kingdom.txt";
#print STDERR $spclist_path."\n";

open (RF, $spclist_path);
while (<RF>){
	chomp;
	
	my ($taxid, $spc, $asmid, $accid, $comm_name, $kingdom) = split(/\s+/);
	$kingdom_cnt{$kingdom}{$asmid} = 1;
}
close RF;

foreach my $kingdom (keys %kingdom_cnt){
	print "$kingdom\t". (keys %{$kingdom_cnt{$kingdom}}) ."\n";
}
print "comp\t$comp_cnt\n";
$comp_sth->finish();

exit();

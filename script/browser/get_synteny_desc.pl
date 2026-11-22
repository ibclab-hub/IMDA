#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

my $acc_query = shift;

my $db_name = "KUBDS";
my $user_id = "webtest";
my $password = '';

# connect to MySQL database
my $dbh = DBI->connect("DBI:mysql:$db_name",$user_id,$password) or die("Error connecting to the database: $DBI::errstr\n");

# Get data path
my $data_path = "";
my $path_sql = "SELECT path FROM metadata WHERE data_type = 'webroot'";
my $path_sth = $dbh->prepare($path_sql);
$path_sth->execute();
while(my $row = $path_sth->fetchrow_array()){
	$data_path = $row;
}
$path_sth->finish();

my $dataroot = "";
$path_sql = "SELECT path FROM metadata WHERE data_type = 'dataroot'";
$path_sth = $dbh->prepare($path_sql);
$path_sth->execute();
while(my $row = $path_sth->fetchrow_array()){
	$dataroot = $row;
}
$path_sth->finish();

my $DIR_pos = $dataroot."/Multiomics/Genome_pos/$acc_query";

my $sql = "SELECT s.synteny_id, CONCAT(t.name,'(',a.assembly_id,'|', a.breed,')') as reference , GROUP_CONCAT(DISTINCT(CONCAT(t2.name,'(',a2.assembly_id,'|',a2.breed,'|',d.distance,')'))) as target ,  s.resolution, s.alignment_program, s.program, s.path FROM synteny s INNER JOIN assembly a ON a.assembly_id = s.reference_assembly INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id INNER JOIN species_set ss ON ss.species_set_id = s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id INNER JOIN distance d ON (d.species1=a.assembly_id AND d.species2=a2.assembly_id) OR (d.species1=a2.assembly_id AND d.species2=a.assembly_id) WHERE s.synteny_id like '$acc_query'";

my $sth = $dbh->prepare($sql);
$sth->execute();

# print contents
my @data = ();
while(my @row = $sth->fetchrow_array()){
    if (!exists($row[6])){
        $row[6] = "";
    }
	print "$row[0]\t$row[1]\t$row[2]\t$row[3]\t$row[4]\t$row[5]\t$data_path/$row[6]\t$DIR_pos\n";
}
$sth->finish();

#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

my $page_idx = shift;
my $row = shift;

my $data_minidx = $page_idx * $row;

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

my $physic_data_path = "";
$path_sql = "SELECT path FROM metadata WHERE data_type = 'dataroot'";
$path_sth = $dbh->prepare($path_sql);
$path_sth->execute();
while(my $row = $path_sth->fetchrow_array()){
    $physic_data_path = $row;
}
$path_sth->finish();

# Get the number of data
my $cnt_sql = "SELECT COUNT(*) FROM synteny where path is not null";
my $cnt_sth = $dbh->prepare($cnt_sql);
$cnt_sth->execute();
while(my @row = $cnt_sth->fetchrow_array()){
	print "$row[0]\n";
}
$cnt_sth->finish();

# Get filter condition
my $aln_sql = "SELECT DISTINCT(program) FROM alignment WHERE program!='NULL';";
my $syn_sql = "SELECT DISTINCT(program) FROM synteny WHERE program!='NULL';";

my @alns = ();
my $aln_sth = $dbh->prepare($aln_sql);
$aln_sth->execute();
while(my @row = $aln_sth->fetchrow_array()){
	push(@alns, $row[0]);
}
$aln_sth->finish();

my @syns = ();
my $syn_sth = $dbh->prepare($syn_sql);
$syn_sth->execute();
while(my @row = $syn_sth->fetchrow_array()){
	push(@syns, $row[0]);
}
$syn_sth->finish();

#my $aln_pg = join(",", @alns);
#my $syn_pg = join(",", @syns);
#print "$aln_pg\t$syn_pg\n";

# Get table data 
my $sql = "SELECT s.synteny_id, CONCAT(t.name,'(', a.breed,')') as reference , GROUP_CONCAT(DISTINCT(CONCAT(t2.name,'(',a2.breed,'|',d.distance,')'))) as target ,  s.resolution, s.alignment_program, s.program, s.path FROM synteny s INNER JOIN assembly a ON a.assembly_id = s.reference_assembly INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id INNER JOIN species_set ss ON ss.species_set_id = s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id INNER JOIN distance d ON (d.species1=a.assembly_id AND d.species2=a2.assembly_id) OR (d.species1=a2.assembly_id AND d.species2=a.assembly_id) where s.path is not null GROUP BY s.synteny_id LIMIT $data_minidx, ".($row * 5).";";

my $sth = $dbh->prepare($sql);
$sth->execute();

# print contents
my @data = ();
while(my @row = $sth->fetchrow_array()){
	print "$row[0]\t$row[1]\t$row[2]\t$row[3]\t$row[4]\t$row[5]\t$data_path/$row[6]/$row[3]_synteny.txt\n";
}
$sth->finish();

#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

my $sth_query = shift;
#my $aln_query = shift;
#my $syn_query = shift;
my $page_idx = shift;
my $row = shift;

my $syn_query = "smakeblocks";

my $data_minidx = $page_idx * $row;

my $db_name = "KUBDS";
my $user_id = "webtest";
my $password = '';

# connect to MySQL database
my $dbh = DBI->connect("DBI:mysql:$db_name",$user_id,$password) or die("Error connecting to the database: $DBI::errstr\n");

my $cnt_sql = "SELECT COUNT(DISTINCT (s.synteny_id)) FROM synteny s INNER JOIN assembly a ON a.assembly_id  = s.reference_assembly INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id   INNER JOIN species_set ss ON ss.species_set_id = s.target_species_set   INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id   INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id   INNER JOIN distance d ON (d.species1=a.assembly_id AND d.species2=a2.assembly_id) OR (d.species1=a2.assembly_id AND d.species2=a.assembly_id)";

# Get data path
my $data_path = "";
my $path_sql = "SELECT path FROM metadata WHERE data_type = 'webroot'";
my $path_sth = $dbh->prepare($path_sql);
$path_sth->execute();
while(my $row = $path_sth->fetchrow_array()){
	$data_path = $row;
}
$path_sth->finish();

my $sql = "SELECT s.synteny_id, CONCAT(t.name,'(', a.breed,')') as reference , GROUP_CONCAT(DISTINCT(CONCAT(t2.name,'(',a2.breed,'|',d.distance,')'))) as target ,  s.resolution, s.alignment_program, s.program, s.path FROM synteny s INNER JOIN assembly a ON a.assembly_id = s.reference_assembly INNER JOIN taxon_id t ON a.taxon_id = t.taxon_id INNER JOIN species_set ss ON ss.species_set_id = s.target_species_set INNER JOIN assembly a2 ON ss.assembly_id = a2.assembly_id INNER JOIN taxon_id t2 ON a2.taxon_id = t2.taxon_id INNER JOIN distance d ON (d.species1=a.assembly_id AND d.species2=a2.assembly_id) OR (d.species1=a2.assembly_id AND d.species2=a.assembly_id)"; 


my @query;
if($sth_query ne "s"){
 $sth_query =~ s/^s//;
}

if($#query >= 0){
	my $query = join(" AND ", @query);
	$cnt_sql .= " WHERE $query ";
	$sql .= " WHERE $query ";
}

$cnt_sql .= ";";
$sql .= "GROUP BY s.synteny_id ;";

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
my %hs_info = ();
my %searched_id = ();
my @data = ();
while(my @row = $sth->fetchrow_array()){
    if($#row < 6){
        $row[6] = "";
    }
    print STDERR join "\t", @row, "\n";

    if (exists($hs_info{$row[0]})){
	    $hs_info{$row[0]} .= "$row[0]\t$row[1]\t$row[2]\t$row[3]\t$row[4]\t$row[5]\t$data_path/$row[6]/$row[3]_synteny.txt\n";
    }else{
	    $hs_info{$row[0]} = "$row[0]\t$row[1]\t$row[2]\t$row[3]\t$row[4]\t$row[5]\t$data_path/$row[6]/$row[3]_synteny.txt\n";
    }
        if ($hs_info{$row[0]} =~ /$sth_query/i){
       $searched_id{$row[0]} = 1;
    }
}
$sth->finish();

my $total_cnt=scalar(keys %searched_id);
print $total_cnt."\n";

my $printidx_st = $data_minidx;
my $printcnt = 0;
my $idx = 0;
foreach my $data_id (sort {$a <=> $b} keys %searched_id){
    if ($printidx_st <= $idx){
        print "$hs_info{$data_id}";
        $printcnt++;
    }
    if ($printcnt == ($row*5)){
        last;
    }
    $idx ++;
}

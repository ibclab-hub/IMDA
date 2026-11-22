#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use FindBin '$Bin';

my $session_id = shift;
my $job_id = shift;
my $type = shift;
my $synteny_id = shift;
my $profile_data = shift;
my $emailto = pop;

### Constant_DB
my $database = "mysql:KUBDS"; ## find from database
my $db_user = "webtest"; ## constant, not argument
my $db_passwd = ''; ## constant, not argument
my $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");
##for DBwork
my $sth;
my @search_result=();
my $mysql_search_query = "";
my %assembly_ids = ();
my %hs_table_name = ("HIC" => "Epigenome_HiC", "CHIP" => "Epigenome_ChIP", "RNA" => "Transcriptome", "METH" => "Epigenome_Meth" );

my @ar_profile = split(",",$profile_data);
foreach my $curInputId (@ar_profile){
    my $dbID = substr($curInputId, 1);
    my ($curdID, $assembly_id, $spc_name) = GET_DATAINFO($dbh, $hs_table_name{$type} ,$dbID);
    $assembly_ids{$assembly_id} = "";
}

if (scalar(keys %assembly_ids) > 1) {
    `perl $Bin/run_CS_Diff_PIPE.pl $session_id $job_id $type $synteny_id $profile_data $emailto`; 
} else {
    `perl $Bin/run_Diff_PIPE.pl $session_id $job_id $type $synteny_id $profile_data $emailto`; 
}

sub GET_DATAINFO{
    my $dbh1 = shift;
    my $table_name = shift;
    my $profile_id = shift;
    $mysql_search_query = 'select '.$table_name.'.data_id,assembly.assembly_id,taxon_id.name from '.$table_name.' inner join assembly  on '.$table_name.'.ref_assembly = assembly.assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id where '.$table_name.'.data_id='.$profile_id;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my @ar_res = $sth->fetchrow_array();

    return @ar_res;
}

#!/usr/bin/perl
#
use strict;
use warnings;
use Cwd 'abs_path';
use DBI;
use File::Basename;
use FindBin '$Bin';
use lib "$Bin/pm";
use MY_DB_SEARCH;

my $session_id = shift;
my $job_id = shift;
my $type = shift;
my $synteny_id = shift;
my $profile_data = shift;
my $emailto = pop;

#### world
### Constant_DB
my $database = "mysql:KUBDS"; ## find from database 
my $db_user = "webtest"; ## constant, not argument
my $db_passwd = ''; ## constant, not argument
my $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");
##for DBwork
my $sth;
my @search_result=();
my $mysql_search_query = "";

### Constant_Env
my $PIPE_BIN = "$Bin/pipeline/diff/";
my $resolution = 1000;
my $cutoff = 0.05;  ## q-value filtering cutoff
my $merge_method = "avg";

##PIPE
my $pid = $$;
my %hs_type = ("HIC" => "hic", "CHIP" => "region", "RNA" => "gene", "METH" => "base" );
my %hs_table_name = ("HIC" => "Epigenome_HiC", "CHIP" => "Epigenome_ChIP", "RNA" => "Transcriptome", "METH" => "Epigenome_Meth" );
my %hs_diff_table_name = ("HIC" => "Epigenome_HiC_diff", "CHIP" => "Epigenome_ChIP_diff", "RNA" => "Transcriptome_diff", "METH" => "Epigenome_Meth_diff" );
my %hs_dir_name = ("HIC" => "Epigenome_hic", "CHIP" => "Epigenome_chip", "RNA" => "Transcriptome", "METH" => "Epigenome_meth" );
my $DIR_output = GET_DATAROOT($dbh)."/Multiomics/Diff/";
my $DIR_work = GET_DATAROOT($dbh)."/progress/$session_id/$job_id/";
my $DIR_profile = GET_DATAROOT($dbh)."/Multiomics/".$hs_dir_name{$type};
my $DIR_pos = GET_DATAROOT($dbh)."/Multiomics/Genome_pos/$synteny_id";
my $DIR_assembly = GET_DATAROOT($dbh)."/GENOME/";


#### Check if the analysis is available
my $check_avail = "avail";
my @ar_profile = split(",",$profile_data);
my %assembly_ids = ();
foreach my $curInputId (@ar_profile){
    my $dbID = substr($curInputId, 1);
    my ($curdID, $assembly_id, $spc_name) = GET_DATAINFO($dbh, $hs_table_name{$type} ,$dbID);
    if (exists $assembly_ids{$assembly_id}) {
        $assembly_ids{$assembly_id} += 1;
    } else {
        $assembly_ids{$assembly_id} = 1;
    }
}

#### Check if the data already exists or not
my $check_exists = CHECK_EXISTDATA($dbh, $hs_diff_table_name{$type}, $synteny_id, $profile_data, scalar(keys %assembly_ids));

if (scalar(keys %assembly_ids) > 1) {
    if ($type eq "HIC") { 
        $check_avail = "unavailable"; 
    } elsif ($type eq "RNA") {
        $check_avail = "unavailable_";  
    } else {
        if (! -f "$DIR_pos/base_aln.bedpe") {
            $check_avail = "unavailable3";            
        } else {
            my $avail_spc_n = 0;
            foreach my $id (keys %assembly_ids) {
                $avail_spc_n += ($assembly_ids{$id} >= 3) ? 1 : 0;
            }   
            if ($avail_spc_n == 0) { $check_avail = "unavailable2"; }
        }
    }
} else {
    $mysql_search_query = "select data_id from Genome where synteny_id=$synteny_id";
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my @search_result = $sth->fetchrow_array();
    if (!defined($search_result[0])){
        $check_avail = "unavailable4";
    }
}

if ($check_avail ne "avail") {
    print $check_avail;
} elsif ($check_exists eq "new") {
    print "new";
} else {
    print "exist";
}

#### Funtcions
sub GET_DATAROOT{
    my $dbh = shift;
    my $sth;
    
    $mysql_search_query = 'select path from metadata where data_type = "dataroot"';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root; 
}
sub CHECK_EXISTDATA{
    my $dbh1 = shift;
    my $table_name = shift;
    my $accession_id = shift;
    my $profile_ids = shift;
    my $species_n = shift;

    if ($species_n > 1) {
        $mysql_search_query = "select diff_id from $table_name where generated_synteny = $accession_id";
    } else {
        $mysql_search_query = "select diff_id from $table_name";
    }
    my @diff_ids = @{$dbh1->selectcol_arrayref($mysql_search_query)};

    my %omicsdata_sets = ();
    foreach my $diff_id (@diff_ids) {
        $mysql_search_query = "select multiomics_data_id from $table_name\_ids where diff_id = $diff_id";
        my @datas = sort {$a<=>$b} @{$dbh1->selectcol_arrayref($mysql_search_query)};
        my $data_str = join ",", @datas;
        $omicsdata_sets{$data_str} = (exists $omicsdata_sets{$data_str}) ? $omicsdata_sets{$data_str}.":$diff_id" : $diff_id;
    }

    my @profile_ids_ar = split(/,/, $profile_ids);
    my @db_ids_ar = ();
    foreach my $prof_id (sort @profile_ids_ar) {
        my $db_id = substr($prof_id, 1);
        push(@db_ids_ar, $db_id);
    }
    my $sort_profile_ids = join ",", @db_ids_ar;

    if (exists $omicsdata_sets{$sort_profile_ids}) {
        return $omicsdata_sets{$sort_profile_ids};
    } else {
        return "new";
    }
}
sub GET_DATAID{
    my $dbh1 = shift;
    my $table_name = shift;

    $mysql_search_query = "select diff_id from ".$table_name;
    my $ar_ids_ref = $dbh1->selectcol_arrayref($mysql_search_query);

    return $ar_ids_ref;
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


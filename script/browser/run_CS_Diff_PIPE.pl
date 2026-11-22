#!/usr/bin/perl
#
use strict;
use warnings;
use Cwd 'abs_path';
use DBI;
use File::Basename;
use FindBin '$Bin';
use Email::Send::SMTP::Gmail;

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
my $PIPE_BIN = "$Bin/Pipeline/DIFF/";
my $resolution = 1000;
my $cutoff = 0.05;  ## q-value filtering cutoff
my $merge_method = "avg";

##PIPE
my $pid = $$;
my %hs_type = ("HIC" => "hic", "CHIP" => "region", "RNA" => "gene", "METH" => "base" );
my %id_header_type = ("HIC" => "HD", "CHIP" => "CD", "RNA" => "TD", "METH" => "MD" );
my %analysis_name = ("HIC" => "Chromatin interaction comparison", "CHIP" => "Histone modification comparison", "RNA" => "Gene expression comparison", "METH" => "Methylation comparison" );
my %hs_table_name = ("HIC" => "Epigenome_HiC", "CHIP" => "Epigenome_ChIP", "RNA" => "Transcriptome", "METH" => "Epigenome_Meth" );
my %hs_diff_table_name = ("HIC" => "Epigenome_HiC_diff", "CHIP" => "Epigenome_ChIP_diff", "RNA" => "Transcriptome_diff", "METH" => "Epigenome_Meth_diff" );
my %hs_dir_name = ("HIC" => "Epigenome_hic", "CHIP" => "Epigenome_chip", "RNA" => "Transcriptome", "METH" => "Epigenome_meth" );
my $DIR_output = GET_DATAROOT($dbh)."/Multiomics/Diff/";
my $DIR_work = GET_DATAROOT($dbh)."/progress/$session_id/$job_id/";
my $DIR_worklog = "$DIR_work/_log";
my $DIR_profile = GET_DATAROOT($dbh)."/Multiomics/".$hs_dir_name{$type};
my $DIR_pos = GET_DATAROOT($dbh)."/Multiomics/Genome_pos/$synteny_id";
my $DIR_assembly = GET_DATAROOT($dbh)."/GENOME/";

#### Data id set 
my $diffDataID; ##### need to identified from the db search below 
my $pre_diffDataIDs_ref = GET_DATAID($dbh, $hs_diff_table_name{$type});
my @pre_diffDataIDs = sort {$a<=>$b} @{$pre_diffDataIDs_ref};
$diffDataID = (scalar(@pre_diffDataIDs) == 0) ? 1 : $pre_diffDataIDs[-1] + 1;

#### JOBID set (for run-exit management)
JOBID_SET($dbh, $session_id, $job_id, "DIFF_$type", $diffDataID);

#### working DIR generation
`mkdir -m 777 -p $DIR_work `;
`echo "#### Multiomics analysis $pid"  >> $DIR_work/log.txt`;
`echo "### Inter-species differential analysis ($analysis_name{$type})"  >> $DIR_work/log.txt`;
`echo "** $synteny_id" >> $DIR_work/log.txt`;

### input data information 
my $refID = GET_REFID($dbh,$synteny_id);
my $f_refSize = $DIR_assembly."/$refID/$refID.size";
my %data_info = ();
my %spc_ids = ();
my @ar_profile = split(",",$profile_data);
foreach my $curInputId (@ar_profile){
    my $dbID = substr($curInputId, 1);
    my ($curdID, $sample_id, $assembly_id, $spc_name) = GET_DATAINFO($dbh, $hs_table_name{$type} ,$dbID);
    $data_info{$dbID} = $spc_name;
    $spc_ids{$spc_name} = $assembly_id;
}

my $sample_info = join(", ", sort @ar_profile);
`echo "* $sample_info" >> $DIR_work/log.txt`;

my $basealn_path = "$DIR_pos/base_aln.bedpe";
my $resaln_path = ($resolution == 1) ? $basealn_path : "$DIR_pos/res_$resolution.align.sort.bedpe";
if (! -f $resaln_path) {
    my $binaln_cmd = "$PIPE_BIN/bin_alndata.pl $basealn_path $resolution 0.3 > $resaln_path 2>> $DIR_worklog";
    `echo "## Binning base-level alignment data with $resolution resolution" >> $DIR_work/log.txt`;
    `$binaln_cmd`;
}

### make config file
`echo "## Making config file"  >> $DIR_work/log.txt`;
my $config_path = "$DIR_work/config.file";
open(W,">$config_path");
foreach my $data_id (sort keys %data_info) {
    my $profile_path = $DIR_profile."/$data_id/raw*bed";
    $profile_path = `ls $profile_path`;
    chomp($profile_path);
    my $spc_n = $data_info{$data_id};
    my $file_format = `cat $DIR_profile/$data_id/file_format.txt`; chomp($file_format);
    print W "$data_id\t$spc_n\t$spc_n\tN\t$file_format\t$profile_path\n";
}
close(W);

### run cross-species diff analysis
my $diff_cmd = "$PIPE_BIN/find_mark.pl -c $config_path -o $DIR_work -a $resaln_path -i $diffDataID -r $resolution -m $merge_method > $DIR_work/$diffDataID.diff.txt 2>> $DIR_worklog";
`echo "## Performing cross-species differential analysis" >> $DIR_work/log.txt`;
`$diff_cmd`;

### filt diff analysis results
`echo "## Filtering differential analysis results" >> $DIR_work/log.txt`;
my $unfilt_n = 0;
open(F, "$DIR_work/$diffDataID.diff.txt");
open(W, ">$DIR_work/$diffDataID.filt.txt");
while(<F>) {
    chomp;
    if ($_ =~ /NaN/) { next; }
    $unfilt_n ++;
    print W "$_\n";
}
close(F);
close(W);

if ($unfilt_n == 0) {       ## if there is no result for diff analysis
    ### sending email
    if ($emailto ne "nomail") {
        my $subject = "[IMDA] Issue During Job Processing";
        my $message = "It was not possible to perform a significance test for the comparative analysis using the profiles you selected.\nThis problem often occurs when the number of profiles is too small or the profiles are noisy.\nWe recommend you to try the differential analysis with more profiles.\n\nSession ID: $session_id\nJob ID: $job_id\n\nWe apologize for any inconvenience this may have caused.\nThank you for your understanding.\n\nIMDA\n";
        my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
        $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
    }

    `echo "## Insufficient profiles for the inter-species differential analysis"  >> $DIR_work/log.txt`;
    `echo "## Insufficient profiles for the inter-species differential analysis"  >> $DIR_worklog`;
    `touch $DIR_work/done`;
    exit;
}

open(F, "$DIR_work/$diffDataID.filt.txt");
while(<F>) {
    chomp;
    my ($spc_chr, $s, $e, $id, $fc, $pval, $qval) = split(/\s+/);
    my ($spc, $chr) = split(/\&\^\&/, $spc_chr);
    my $assembly_id = $spc_ids{$spc};
    my $spc_fc_info = "$chr\t$s\t$e\t$id\t$fc";
    my $spc_pqval_info = "$spc_chr\t$s\t$e\t$id\t.,.,.,$pval,$qval";
    `echo "$spc_fc_info" >> $DIR_work/$assembly_id.bed`;
    `echo "$spc_pqval_info" >> $DIR_work/$assembly_id.diff.out`;
}
close(F);


### make fold-change data and index data
`echo "## Indexing differential analysis results" >> $DIR_work/log.txt`;
my @spc_ns = sort keys %spc_ids;
`mkdir -m 777 -p $DIR_output/$type/$diffDataID`;

foreach my $spc_n (@spc_ns) {
    my $spc_id = $spc_ids{$spc_n};
    my $sort_cmd = "sort -k1,2n $DIR_work/$spc_id.bed > $DIR_work/$spc_id.sort.bed";
    `$sort_cmd`;
    `mkdir -m 777 -p $DIR_output/$type/$diffDataID/$spc_id`;

    my $size_f = $DIR_assembly."/$spc_id/$spc_id.size";
    my $index_cmd = "$Bin/indexing/add_data.pl -o $DIR_output/$type -p $diffDataID -i $spc_id -d $DIR_work/$spc_id.sort.bed -t bed -s $resolution -g $size_f -l copy 2>> $DIR_worklog";
    `$index_cmd` 
}

### make merged.diff.out file
foreach my $spc_n (@spc_ns) {
    my $spc_id = $spc_ids{$spc_n};
    my $cp_cmd = "cp -f $DIR_work/$spc_id.diff.out $DIR_output/$type/$diffDataID/$spc_id/merged.diff.out";
    `$cp_cmd`;
}

### check if all data generated well
my $done_n = 0;
foreach my $spc_n (@spc_ns) {
    my $spc_id = $spc_ids{$spc_n};
    if (-f "$DIR_output/$type/$diffDataID/$spc_id/merged.diff.out") {
        $done_n ++;
    }
}

### done 
#######################################################DONE 
if ($done_n == scalar(@spc_ns)) {

    #### Add diff data to database
    my $id_header = $id_header_type{$type};
    ADD_DATA($dbh, $hs_diff_table_name{$type}, $diffDataID, "Multiomics/Diff/$type/$diffDataID", $refID, $synteny_id, $profile_data);

    ### sending email
    if ($emailto ne "nomail") {
        my $subject = "[IMDA] Job Completion Notification";
        my $message = "Thank you for your patience!\nYour request has been successfully processed, and the job has been completed.\n\nThe analysis results you requested can be found at the link below:\nhttp://biweb.konkuk.ac.kr/IMDA/browser/genome.html?accession=$synteny_id\nThe generated track ID: $id_header"."$diffDataID\n\nThank you.\n\nIMDA";
        my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
        $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
    }

    `echo "## Generated track ID: $id_header$diffDataID"  >> $DIR_work/log.txt`;
    `touch $DIR_work/done`;
} else {
    ### sending email
    if ($emailto ne "nomail") {
        my $subject = "[IMDA] Issue During Job Processing";
        my $message = "There was an issue during the processing of your job, leading to an abnormal termination.\n\nAccession : $synteny_id\nSession ID: $session_id\nJob ID: $job_id\n\nWe apologize for any inconvenience this may have caused.\nThank you for your understanding.\n\nIMDA";
        my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
        $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
    }

    `echo "## Errors occurred during the analysis."  >> $DIR_work/log.txt`;
    `echo "## Errors occurred during the analysis."  >> $DIR_worklog`;
    `touch $DIR_work/error`;
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
sub GET_REFID{
    my $dbh1 = shift;
    my $synteny_id = shift;
    $mysql_search_query = 'select reference_assembly from synteny where synteny_id='.$synteny_id;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root; 
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
    $mysql_search_query = 'select '.$table_name.'.data_id,SRA_id,assembly.assembly_id,taxon_id.name from '.$table_name.' inner join assembly  on '.$table_name.'.ref_assembly = assembly.assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id where '.$table_name.'.data_id='.$profile_id;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my @ar_res = $sth->fetchrow_array();

    return @ar_res; 
}
sub ADD_DATA{
    my $dbh1 = shift;
    my $table_name = shift;
    my $diff_id = shift;
    my $path = shift;
    my $refid = shift;
    my $synteny_id = shift;
    my $profile_data = shift;

    my $analysis_type = "inter";
    $dbh1->do("insert into $table_name values ($diff_id, '$path', $refid, $synteny_id, '$analysis_type')");
    
    my @profile_data_ar = split(/,/, $profile_data);
    foreach my $data (@profile_data_ar) {
        my $data_id = substr($data, 1);
        $dbh1->do("insert into $table_name\_ids values ($diff_id, $data_id)");
    }

    return 1;
}
sub JOBID_SET{
    my $dbh1 = shift;
    my $sid = shift;
    my $jid = shift; 
    my $analysis = shift;
    my $newdataid = shift;

    $dbh1->do('update session_info set status = 0, analysis=?, data_id=? where session_id=? and job_number=?', ,undef,$analysis, $newdataid, $sid, $jid);

    return 1;
}


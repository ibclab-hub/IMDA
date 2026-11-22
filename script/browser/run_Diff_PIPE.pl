#!/usr/bin/perl
#
#
use strict;
use warnings;
use DBI;
use File::Basename;
use FindBin '$Bin';
use lib "$Bin/pm";
use MY_DB_SEARCH;
use Email::Send::SMTP::Gmail;

my $session_id = shift;
my $job_id = shift;
my $type = shift;
my $synteny_id = shift;
my $profile_data = shift;
my $profile_data_keep =$profile_data ;
my $emailto = pop;
chomp($emailto);


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

##PIPE
my $pid = $$;
my %hs_type_prefix = ("HIC" => "H", "CHIP" => "C", "RNA" => "T", "METH" => "M" );
my %hs_type = ("HIC" => "hic", "CHIP" => "region", "RNA" => "gene", "METH" => "base" );
my %hs_table_name = ("HIC" => "Epigenome_HiC", "CHIP" => "Epigenome_ChIP", "RNA" => "Transcriptome", "METH" => "Epigenome_Meth" );
my %hs_dir_name = ("HIC" => "Epigenome_hic", "CHIP" => "Epigenome_chip", "RNA" => "Transcriptome", "METH" => "Epigenome_meth" );

my %hs_diff_table_name = ("HIC" => "Epigenome_HiC_diff", "CHIP" => "Epigenome_ChIP_diff", "RNA" => "Transcriptome_diff", "METH" => "Epigenome_Meth_diff" );
my %hs_diff_ids_table_name = ("HIC" => "Epigenome_HiC_diff_ids", "CHIP" => "Epigenome_ChIP_diff_ids", "RNA" => "Transcriptome_diff_ids", "METH" => "Epigenome_Meth_diff_ids" );
my %hs_diff_printing = ("HIC" => "Chromatin interaction comparison", "CHIP" => "Histone modification comparison", "RNA" => "Gene expression comparison", "METH" => "Methylation comparison" );

my $DIR_output = GET_DATAROOT($dbh)."/Multiomics/Diff/$type/";
my $DIR_work = GET_DATAROOT($dbh)."/progress/$session_id/$job_id/";
my $DIR_profile = GET_DATAROOT($dbh)."/Multiomics/".$hs_dir_name{$type};
my $DIR_pos = GET_DATAROOT($dbh)."/Multiomics/Genome_pos/$synteny_id";
my $DIR_assembly = GET_DATAROOT($dbh)."/GENOME/";
my $diffDataID; ##### need to identified from the db search below 
my $f_refSize = "";
my $ref_spc_name = "";
my $minres = 100000000; ##### especially for HIC 


#### working DIR generation
`mkdir -m777 -p $DIR_work `;
`echo "#### Multiomics analysis $pid"  > $DIR_work/log.txt`;
my $printing_analysis = $hs_diff_printing{$type};
`echo "### Intra-species differential analysis  ($printing_analysis)"  >> $DIR_work/log.txt`;
chmod 0777, "$DIR_work/log.txt";

$mysql_search_query = 'select data_id from Genome where synteny_id=?';
$sth = $dbh->prepare($mysql_search_query);
$sth->execute($synteny_id);
@search_result = $sth->fetchrow_array();
if (!defined($search_result[0])){
    `echo "## Required data doesn't exist!" >> $DIR_work/log.txt`;
    sleep(10);
    `touch $DIR_work/done`;
    exit();
}

$profile_data =~ s/$hs_type_prefix{$type}//g;
my $refID = GET_REFID($dbh,$profile_data, $type);  ## need to identified from Db search 
$f_refSize = $DIR_assembly."/$refID/$refID.size";

### Existing check 
#### Data id set 
$diffDataID = 1;
my $existscheck = 0;
($existscheck,$diffDataID) = EXISTSCHECK_DIFF($dbh, $type,$synteny_id,$refID,$profile_data);
if ($existscheck != 0){
    `echo "## Already exist : $diffDataID" >> $DIR_work/log.txt`;
    sleep(10);
    `touch $DIR_work/done`;
    exit;
}
#### JOBID set (for run-exit management)
JOBID_SET($dbh, $session_id, $job_id, "DIFF_$type", $diffDataID);


#### running path setting 
my $getstd_path = $PIPE_BIN."/get_std.py";
my $getstd_meth_path = $PIPE_BIN."/meth_getStd.pl";
my $merge_path = $PIPE_BIN."/comb_data.pl";
my $percCalc_path = $PIPE_BIN."/summarize_merge.py";
my $output_path = "$DIR_work/";

my %data_info = ();
### input data information 
my @ar_profile = split(",",$profile_data);
foreach my $curInputId (@ar_profile){
    my $resolution;
    my ($curdID, $assembly_id, $spc_name) = GET_DATAINFO($dbh, $hs_table_name{$type} ,$curInputId);
    $data_info{$curInputId}{"name"} = $spc_name;
    $data_info{$curInputId}{"assembly_id"} = $assembly_id;
    if ($type eq "HIC"){
        $data_info{$curInputId}{"resolution"} = GET_HICRES($dbh,$curInputId);
        if ($minres >  $data_info{$curInputId}{"resolution"}){
            $minres =  $data_info{$curInputId}{"resolution"};
        }
    }
}
my $sample_info = join(", ", sort {$a<=>$b} keys %data_info);
`echo "* $profile_data_keep" >> $DIR_work/log.txt`;
`echo "** $synteny_id"  >> $DIR_work/log.txt`;

### make param
`echo "## Making parameters"  >> $DIR_work/log.txt`;

open(F,">$DIR_work/param");
print F "outdir $DIR_work\n";
print F "ref $refID\n";
print F "type $hs_type{$type}\n";
print F "posdir  $DIR_pos\n";
if ($type eq "HIC"){
print F "minres  $minres\n";
}
foreach my $this (keys (%data_info)){
    
    my $prof_fpath = "";
   if ($type eq "HIC"){
        $prof_fpath = `ls $DIR_profile/$this/raw*bedpe`;
        
   }else{
        $prof_fpath = `ls $DIR_profile/$this/raw*bed`; 
   }
   chomp($prof_fpath);
    my $spc_name = $data_info{$this}{"name"};
    $ref_spc_name  = $spc_name;
    my $assembly_id = $data_info{$this}{"assembly_id"};
    print F "$assembly_id  $spc_name $prof_fpath";
    if ($type eq "HIC"){
        print F "  ".$data_info{$this}{"resolution"}."\n";
    }else{
        print F " -\n";
    }

}

close(F);
### run get_std 
`echo '## Calculate variance '   >> $DIR_work/log.txt`;
#`python $getstd_path ./param`;
if ($type eq "METH"){
   my $getstd_cmd = "perl $getstd_meth_path $DIR_work/param";
    `echo '$getstd_cmd' > $DIR_work/getstd.cmd `;
    `bash $DIR_work/getstd.cmd 2> $DIR_work/getstd.log`;

}else{
   my $getstd_cmd = "python $getstd_path $DIR_work/param";
    `echo '$getstd_cmd' > $DIR_work/getstd.cmd `;
    `bash $DIR_work/getstd.cmd 2> $DIR_work/getstd.log`;
}
`mkdir -p -m777 $DIR_output/$diffDataID/$refID/`;
my $DIR_output_final = "$DIR_output/$diffDataID/$refID/";

if (($type ne "HIC" && -e "$DIR_work/raw.diff.bed") || ($type eq "HIC" && -e "$DIR_work/raw.diff.bedpe")  ){
    my $sizeDiff ;
    if ($type eq "HIC" ){
        $sizeDiff = -s "$DIR_work/raw.diff.bedpe";
    }else{
        $sizeDiff = -s "$DIR_work/raw.diff.bed";
    }

    if ($sizeDiff == 0){
        if ($emailto ne "nomail") {
            my ($subject,$message) = MAIL_GEN(0,$synteny_id, $session_id, $job_id, "-");
            my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
            $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
            $mail->bye;
        }
        $dbh->do('delete from '.$hs_diff_ids_table_name{$type}.' where diff_id='.$diffDataID.';');
        $dbh->do('delete from '.$hs_diff_table_name{$type}.' where diff_id='.$diffDataID.';');
        `touch $DIR_work/error`;
        exit();
    }
}else{
    if ($emailto ne "nomail") {
        my ($subject,$message) = MAIL_GEN(0,$synteny_id, $session_id, $job_id, $diffDataID);
        my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
        $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
        $mail->bye;
    }
    $dbh->do('delete from '.$hs_diff_ids_table_name{$type}.' where diff_id='.$diffDataID.';');
    $dbh->do('delete from '.$hs_diff_table_name{$type}.' where diff_id='.$diffDataID.';');
    `touch $DIR_work/error`;
    exit();
}

### indexing
if ($type ne "HIC"){
    my $cmdIndex = "perl $Bin/indexing/add_data.pl -o  $DIR_output -p $diffDataID -i $refID -d $DIR_work/raw.diff.bed -t bed -s 1 -g $f_refSize -l copy ";
    `echo '$cmdIndex' > $DIR_work/index.cmd`;
    `bash $DIR_work/index.cmd  2> $DIR_work/index.log`;
    `echo '## Indexing'   >> $DIR_work/log.txt`;
}else{
    my $cmdIndex= "perl $Bin/indexing/add_data.pl -o  $DIR_output -p $diffDataID -i $refID -d $DIR_work/raw.diff.bedpe -t bedpe -s $minres -g $f_refSize -l copy ";
    `echo '$cmdIndex' > $DIR_work/index.cmd`;
    `bash $DIR_work/index.cmd  2> $DIR_work/index.log`;
    `echo '## Indexing'   >> $DIR_work/log.txt`;
}

### merge 
# merge resolution set 
my $wholeSize = 0;
open(F,"$f_refSize");
while(<F>){
    chomp;
    my ($chr,$size) = split("\t",$_);
    $wholeSize += $size;
}
close(F);
my $merge_resolution_raw = int($wholeSize/70);
my $res_len = length($merge_resolution_raw);
my $res_divide = int($merge_resolution_raw/(10**($res_len-1)));
my $merge_resolution = $res_divide * (10**($res_len-1));

if ($type ne "HIC"){
    `echo '## Variable region detection '   >> $DIR_work/log.txt`;
    my $combcmd = "perl $Bin/Pipeline/DIFF/comb_data.pl $ref_spc_name $f_refSize $DIR_work/raw.diff.bed $merge_resolution >  $DIR_output_final/merged.diff.out";
    `echo '$combcmd' > $DIR_work/comb.cmd`;
    `bash $DIR_work/comb.cmd 2> $DIR_work/comb.log`;
    `echo '## Summarize detected region '   >> $DIR_work/log.txt`;
    `python $Bin/Pipeline/DIFF/summarize_merge.py $DIR_output_final/merged.diff.out  $DIR_output_final/`;
}else{
    `echo '## Variable region detection '   >> $DIR_work/log.txt`;
    my $combcmd = "perl $Bin/Pipeline/DIFF/comb_data.bedpe.pl $ref_spc_name $f_refSize $DIR_work/raw.diff.bedpe $merge_resolution >  $DIR_output_final/merged.diff.out";
    `echo '$combcmd' > $DIR_work/comb.cmd`;
    `bash $DIR_work/comb.cmd 2> $DIR_work/comb.log`;
    `echo '## Summarize detected region '   >> $DIR_work/log.txt`;
    `python $Bin/Pipeline/DIFF/summarize_merge.py $DIR_output_final/merged.diff.out  $DIR_output_final/`;
}

my %prefix = (RNA=>"TD", METH=>"MD", CHIP=>"CD",HIC=>"HD");
$diffDataID = $prefix{$type}.$diffDataID; 
DIFF_DONE($dbh, $diffDataID,$type ,$DIR_output);
`echo "## Generated track ID: $diffDataID "   >> $DIR_work/log.txt`;
`touch $DIR_work/done`;

### done 
######################################################DONE 
# Send email
if ($emailto ne "nomail") {
    my ($subject,$message) = MAIL_GEN(1,$synteny_id, $session_id, $job_id, $diffDataID);
    my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
    $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
    $mail->bye;
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
sub DIFF_DONE{
    my $dbh = shift;
    my $diffID = shift;
    my $type= shift;
    my $type_path = shift;

    my $path = "$type_path/$diffID/";
    my $table = $hs_diff_table_name{$type};
    $mysql_search_query = 'update '.$table.' set path = ? where diff_id='.$diffID;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($path);
   return 0; 
}
sub GET_REFID{
    my $dbh = shift;
    my $profile_id = shift;
    my $type = shift;
    my @ar_split = split(/,/,$profile_id);
    my $prof1 = $ar_split[0];
    my $table = $hs_table_name{$type}; 
    $mysql_search_query = 'select ref_assembly from '.$table.' where data_id='.$prof1;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root; 
}
sub GET_DATAINFO{
    my $dbh = shift;
    my $table_name = shift;
    my $profile_id = shift;
    $mysql_search_query = 'select '.$table_name.'.data_id,assembly.assembly_id,taxon_id.name from '.$table_name.' inner join assembly  on '.$table_name.'.ref_assembly = assembly.assembly_id inner join taxon_id on assembly.taxon_id = taxon_id.taxon_id where '.$table_name.'.data_id='.$profile_id;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my @ar_res = $sth->fetchrow_array();

    return @ar_res; 
}
sub GET_HICRES{
    my $dbh = shift;
    my $profile_id = shift;

    $mysql_search_query = 'select param_resolution from Epigenome_HiC where data_id='.$profile_id;
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my ($resolution) = $sth->fetchrow_array();
    print STDERR $resolution."<- res \n";
    return $resolution; 
}
sub EXISTSCHECK_DIFF{
    my $dbh = shift;
    my $type = shift;
    my $synteny_id = shift;
    my $ref_id = shift;
    my $profile_data = shift;
    my $diffID;
    my @ar_profile = split(",",$profile_data);

    my $profile_data_list = "init";
    foreach my $curInputId (sort {$a <=> $b} @ar_profile){
        if ($profile_data_list eq "init"){
            $profile_data_list = $curInputId;    
        }else{
            $profile_data_list .= ",".$curInputId;
        }
    }
    $mysql_search_query = 'select '.$hs_diff_table_name{$type}.'.diff_id, group_concat(multiomics_data_id order by multiomics_data_id) as profile_ids, '.$hs_diff_table_name{$type}.'.generated_synteny from '.$hs_diff_ids_table_name{$type}.' inner join '.$hs_diff_table_name{$type}.' where '.$hs_diff_table_name{$type}.'.diff_id = '.$hs_diff_ids_table_name{$type}.'.diff_id
 group by '.$hs_diff_ids_table_name{$type}.'.diff_id having profile_ids=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($profile_data_list);
    @search_result = $sth->fetchrow_array();
    if (defined($search_result[0])){
        return (1,$search_result[0]);
    }
    #create new diffID 
    $mysql_search_query = 'select max(diff_id) from '.$hs_diff_table_name{$type};
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    $diffID = $sth->fetchrow_array();
    $diffID ++;
    $dbh->do('insert into '.$hs_diff_table_name{$type}.' (diff_id, path, generated_synteny, reference_assembly,inter_intra) values('.$diffID.',NULL,'.$synteny_id.','.$ref_id.',"intra") ');
    foreach my $curInputId (sort {$a <=> $b} @ar_profile){
        $mysql_search_query = 'insert into  '.$hs_diff_ids_table_name{$type}.' (diff_id, multiomics_data_id) values ('.$diffID.','.$curInputId.') ';
        $dbh->do($mysql_search_query );
    }
    return (0,$diffID)
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
sub JOBID_update{
    my $dbh1 = shift;
    my $sid = shift;
    my $jid = shift; 

    $dbh1->do('update session_info set status = 1 where session_id = ? and job_number = ?', ,undef,$sid, $jid );

    return 1;
}

sub MAIL_GEN{
    my $status = shift;
    my $synteny_id = shift;
    my $session_id = shift;
    my $job_id = shift;
    my $diffDataID = shift;

    
    my $subject = "";
    my $message = "";
    if ($status == 0){
        $subject = "[IMDA] Issue During Job Processing";
        $message = "There was an issue during the processing of your job, leading to an abnormal termination.\n\nAccession: $synteny_id\nSession ID: $session_id\nJob ID: $job_id\n\nWe apologize for any inconvenience this may have caused.\nThank you for your understanding.\n\nIMDA";
    }
    if ($status == 1){ #work well
        $subject = "[IMDA] Job Completion Notification";
        $message = "Thank you for your patience!\nYour request has been successfully processed, and the job has been completed.\n\nThe analysis results you requested can be found at the link below:\nhttp://biweb.konkuk.ac.kr/IMDA/browser/genome.html?accession=$synteny_id\nThe generated track ID: $diffDataID\n\nThank you.\n\nIMDA";

    }
    return ($subject, $message);
}

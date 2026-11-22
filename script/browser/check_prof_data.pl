#!/usr/bin/perl
#
#
use strict;
use warnings;
use DBI;
use Parallel::ForkManager;
use Switch;
use Cwd 'abs_path';
use FindBin '$Bin';
use Getopt::Long qw(:config no_ignore_case);
use lib "$Bin/pm";
use MY_DB_SEARCH;
use File::Basename;
use Email::Send::SMTP::Gmail;

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
my $PIPE_BIN = "$Bin/PIPE/";
my $DIR_mount = GET_DATAROOT($dbh);
my $DATA_DIR = GET_DATAROOT($dbh);
my $GENOME_DIR = $DATA_DIR."/GENOME/";
my $ALN_DIR = $DATA_DIR."/ALIGNMENT/";
my $SYN_DIR = $DATA_DIR."/SYNTENY/";
my $Multiomics_DIR = $DATA_DIR."/Multiomics/";
my $META_DIR = $DATA_DIR."/metadata/";
my $image_version = "denovo2:latest";

### General_global
my $command = shift;
my $sfid = 1;
my ($session_id, $job_id, $synteny_id) = ("",0,0);
my $help;
my $flag=0;
my $pid = $$;
my $printcmd = "";

### Run
my $par_check = 0;
my $f_param_run = "";
my $dir_local_data = "";
my $dir_local_working = "$DIR_mount/progress/";

my $local_run_cmd = "";

### Common IO
my $reference_fa = "";
my $annotation_gtf = "";
my $ref_dir = "";
my $dir_out = "";
my $checkReturn = 0;
#my $dir_out = "/DATA/Multiomics/$command/";

### Common IO
my $sample_set = "";
my $sample_set_id;
my $json_path;
my $species;
my $species_name;
my $tissue;
my $f_param_local;
my $ref_assembly_id = "";
my $ref_assembly_name = "";
my $cur_data_id;
my $dataid;


### Main
my %func = (GENOME=>\&GENOME, RNA=>\&RNA, METH=>\&METH, CHIP=>\&CHIP,HIC=>\&HIC);
my %prefix = (RNA=>"T", METH=>"M", CHIP=>"C",HIC=>"H");
die("Unknown command \"$command\".\n") if (!defined($func{$command}));
my $module_return = &{$func{$command}};
print $module_return;

#RNA
sub RNA{
    $par_check = scalar(@ARGV);
    GetOptions (
				"synteny=i" => \$synteny_id, ## input synteny id 
				"h|help" => \$help  
    );
    if(defined($help) || $par_check == 0 || !defined($session_id) || scalar(@ARGV) == 0){
        return 0;
    }
    
    ### Search data existing
    ## Search spc
    for (my $idx = 0 ; $idx <= $#ARGV; $idx++){
        my $thistmp = $ARGV[$idx];
    if ($thistmp =~ /(.+)_dataset$/){
        $ARGV[$idx] = $1;
    }
   }
    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "RNA", $sample_set_id);
    if ($checkReturn == 1){
        return "exist";
    }else{
        return "new";
    }
}
#METH 
sub METH{
    $par_check = scalar(@ARGV);
    my ($score_min, $N, $L, $mincov, $minqual) = ("L,0,-0.6",0,20,10,10);
    GetOptions (
				"synteny=i" => \$synteny_id, ## input synteny id 
				"score_min=s" => \$score_min,   
				"N=i" => \$N,  
				"L=i" => \$L, 
				"mincov=i" => \$mincov, 
				"minqual=i" => \$minqual, 
				"h|help" => \$help  
    );
    if(defined($help) || $par_check == 0 || !defined($session_id)){
            exit(0);
    }
    for (my $idx = 0 ; $idx <= $#ARGV; $idx++){
        my $thistmp = $ARGV[$idx];
    if ($thistmp =~ /(.+)_dataset$/){
        $ARGV[$idx] = $1;
    }
    }

    ### Search data existing
    ## Search spc
    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "METH", $sample_set_id, $score_min, $N, $L, $mincov, $minqual);
    if ($checkReturn == 1){
        return "exist";
    }else{
        return "new";
    }

}
#CHIP
sub CHIP{
    $par_check = scalar(@ARGV);
    my ($q_cutoff, $bandwidth) = (0.05, 300);
    GetOptions (
				"session_id=s" => \$session_id,
				"job_id=i" => \$job_id,
				"synteny=i" => \$synteny_id, ## Taxon ID of the reference species
				"q_cutoff=f" => \$q_cutoff,   
				"bandwidth=i" => \$bandwidth,   
				"h|help" => \$help  
    );
    if(defined($help) || $par_check == 0 || !defined($session_id)){
            exit(0);
    }


    ### Search data existing
    ## Search spc
    
    for (my $idx = 0 ; $idx <= $#ARGV; $idx++){
        my $thistmp = $ARGV[$idx]; 
    if ($thistmp =~ /(.+)_dataset$/){
        $ARGV[$idx] = $1;
    }
   }
    
    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "CHIP", $sample_set_id,$bandwidth, $q_cutoff);
    if ($checkReturn == 1){
        return "exist";
    }else{
        return "new";
    }
}
#HIC
sub HIC{
    $par_check = scalar(@ARGV);
    my ($binsize, $bin_cnt, $resolution) = (100000, 10, 100000);
    GetOptions (
				"session_id=s" => \$session_id,
				"job_id=i" => \$job_id,
				"synteny=i" => \$synteny_id, ## Taxon ID of the reference species
				"binsize=i" => \$binsize,
				"bincnt=i" => \$bin_cnt,
				"res=i" => \$resolution,
				"h|help" => \$help  
    );
    if(defined($help) || $par_check == 0 || !defined($session_id)){
            exit(0);
    }

    ### Search data existing
    ## Search spc
    for (my $idx = 0 ; $idx <= $#ARGV; $idx++){
        my $thistmp = $ARGV[$idx];
        if ($thistmp =~ /(.+)_dataset$/){
            $ARGV[$idx] = $1;
        }
    }

    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "HIC", $sample_set_id,$binsize, $bin_cnt, $resolution);
    if ($checkReturn == 1){
        return "exist";
    }else{
        return "new";
    }
}
sub GET_DATAROOT{
    my $dbh = shift;
    my $sth;
    
    $mysql_search_query = 'select path from metadata where data_type = "dataroot"';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root; 
}
sub JOBID_SET{
    my $dbh1 = shift;
    my $sid = shift;
    my $jid = shift; 
    my $analysis = shift;
    my $newdataid = shift;

    $dbh1->do('insert into session_info values (?,?,0,?,?)', ,undef,$sid, $jid, $analysis, $newdataid);
    return 1;
}
sub JOBID_update_genome{
    my $dbh1 = shift;
    my $sid = shift;
    my $jid = shift; 
    my $analysis = shift;
    my $newdataid = shift;

    $dbh1->do('update session_info set analysis = ?, data_id = ?  where session_id = ? and job_number = ?', ,undef,$analysis,$newdataid, $sid, $jid );

    return 1;
}
sub JOBID_done{
    my $dbh1 = shift;
    my $sid = shift;
    my $jid = shift; 
    $dbh1->do('update session_info set status = 1  where session_id = ? and job_number = ?', ,undef,$sid, $jid );
    return 1;
}

sub JOBID_update{
    my $dbh1 = shift;
    my $sid = shift;
    my $jid = shift; 

    $dbh1->do('update session_info set status = 1 where session_id = ? and job_number = ?', ,undef,$sid, $jid );

    return 1;
}

sub DATAID_update{
    my $dbh = shift;
    my $analysis = shift;
    my $dataid = shift;
    my $path = shift;
    my $ref_assembly = shift;
    switch($analysis){
        case "RNA" {
            $dbh->do('update Transcriptome set json_path = "'.$path.'"  where data_id ='. $dataid.";");
            $dbh->do('update Transcriptome set ref_assembly ='.$ref_assembly.'  where data_id = '.$dataid.';');
        }
        case "METH" {
            $dbh->do('update Epigenome_Meth set json_path = "'.$path.'"  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_Meth set ref_assembly = '.$ref_assembly.'  where data_id = '.$dataid.';');

        }
        case "CHIP" {
            $dbh->do('update Epigenome_ChIP set json_path = "'.$path.'"  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_ChIP set ref_assembly = '.$ref_assembly.'  where data_id = '.$dataid.';');
        }
        case "HIC" {
            $dbh->do('update Epigenome_HiC set json_path = "'.$path.'"  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_HiC set ref_assembly = '.$ref_assembly.'  where data_id = '.$dataid.';');
        }
    }
}
sub GET_ASSEMBLY_ID{
    my $dbh = shift;
    my $assembly_name = shift;
    my $assembly_id;
    my $taxon_name;
    my $sth;
    $mysql_search_query = 'select assembly_id, name from assembly inner join taxon_id on taxon_id.taxon_id = assembly.taxon_id  where breed=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($assembly_name);
    @search_result = $sth->fetchrow_array();
    $assembly_id = $search_result[0]; 
    $taxon_name = $search_result[1]; 
    return ($assembly_id, $taxon_name);
}
sub RES_STR{
    my $res_num = shift;
    my $res_str = "";
    if ($res_num >= 1000){
        my $res_up = int($res_num/1000);
        $res_str = $res_up."k";
    }else{
        $res_str = $res_num;
    }

    return($res_str);
}
sub SET_DISTANCE{
    my $dbh = shift;
    my $ref_assembly_id = shift;
    my $ref_tax_name = shift;
    my $tar_assembly_id = shift;
    my $tar_tax_name = shift;
    my $real_distance;
    my ($near_cri, $medium_cri) = (58.88309, 317.19518);

    #name fix
    $ref_tax_name = lc( $ref_tax_name);
    $tar_tax_name = lc( $tar_tax_name);

    #Tree file
    my $f_tree = $META_DIR."/tree/all.nwk";
    
    $mysql_search_query = 'select distance from distance where species1=? and species2=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($ref_assembly_id,$tar_assembly_id);
    @search_result = $sth->fetchrow_array();
    if (!defined($search_result[0])){
        $mysql_search_query = 'select distance from distance where species2=? and species1=?';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($ref_assembly_id,$tar_assembly_id);
        @search_result = $sth->fetchrow_array();
        if (!defined($search_result[0])){
            #get distance 
            $real_distance = `python $Bin/Pipeline/GENOME/bin/tree_distance_simple.py  $f_tree $ref_tax_name $tar_tax_name`;
            chomp($real_distance);
            my $length = length($real_distance);
            if ($length == 0){
                $dbh->do('insert into distance values (?,?,9999999)', ,undef, $ref_assembly_id, $tar_assembly_id);
                $real_distance = 999999;
            }else{
                $dbh->do('insert into distance (species1, species2, distance) values (?,?,?)', ,undef, $ref_assembly_id, $tar_assembly_id, $real_distance);
            }
        }else{
            $real_distance = $search_result[0];
        }
    }else{
        $real_distance = $search_result[0];
    }
    #dicide distance 
    if ($real_distance == 999999){
        return "far";
    }else{
        if($real_distance < $near_cri){
            return "near";
        }elsif($real_distance < $medium_cri){
            return "medium";
        }else{
            return "far";
        }
    }
}
sub SYN_DONE{
    my $dbh = shift;
    my $synID = shift;
    my $prog = shift;
    if ($prog eq "makeblocks"){
        $prog = "inferCars";
    }
    my $path = "SYNTENY/$prog/$synID/";
    $dbh->do('update synteny set path=?,status=1 where synteny_id=?', ,undef,$path ,$synID);

}
sub ALN_DONE{
    my $dbh = shift;
    my $path = shift;
    my $alnID = shift;
    $dbh->do('update alignment set path=?,status=1 where alignment_id=?', ,undef, $path, $alnID);
}
sub EXISTSCHECK_SYN{
    my $dbh = shift;
    my $ref_id = shift;
    my $tar_assembly_id_list = shift;
    my $resolution = shift;
    my $program = shift;
    my $alignment_program = shift;
    my @ar_tar_assembly_id = split(/,/,$tar_assembly_id_list);
    my $tar_num = scalar(@ar_tar_assembly_id);
    my $tar_species_set_id;
    my $synteny_id;
    my $synExist = 0;
    my $res_str = RES_STR($resolution);
    #species_set check 
    $mysql_search_query = 'select species_set.species_set_id, group_concat(assembly_id order by assembly_id) as assembly_set from species_set group by species_set_id having assembly_set=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($tar_assembly_id_list);
    @search_result = $sth->fetchrow_array();
    if (defined($search_result[0])){
        #syntey exists text 
        $tar_species_set_id = $search_result[0];
        $mysql_search_query = 'select * from synteny where reference_assembly=? and target_species_set =? and resolution = ? and program =? and alignment_program=?';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($ref_id,$tar_species_set_id,$res_str, $program, "LASTZ");
        @search_result = $sth->fetchrow_array();
        if (defined($search_result[0])){
            return (1,$search_result[0]);
        }

    }else{
        $mysql_search_query = 'select max(species_set_id) from species_set_header';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute();
        $tar_species_set_id = $sth->fetchrow_array();
        $tar_species_set_id ++;
        $dbh->do('insert into species_set_header (species_set_id, size) values(?,?) ', ,undef, $tar_species_set_id,$tar_num);
        foreach my $curid (@ar_tar_assembly_id){
            $dbh->do('insert into species_set (species_set_id, assembly_id) values(?,?) ', ,undef, $tar_species_set_id, $curid);
        }
    }
    #generate_new_synID 
    $mysql_search_query = 'select max(synteny_id) from synteny';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    $synteny_id = $sth->fetchrow_array();
    $synteny_id ++;
    $dbh->do('insert into synteny (synteny_id,reference_assembly,target_species_set,resolution,status,program,alignment_program ) values(?,?,?,?,0,?,?) ', ,undef, $synteny_id, $ref_id, $tar_species_set_id,$res_str,$program,$alignment_program);
    return(0,$synteny_id);
}
sub EXISTSCHECK_ALN{
    my $dbh = shift;
    my $ref_id = shift;
    my $tar_assembly_id = shift;
    my $tar_species_set_id;
    my $check;
    my $alnID;
    #species_set check 
    $mysql_search_query = 'select species_set.species_set_id from species_set inner join species_set_header on species_set.species_set_id=species_set_header.species_set_id where size=1 and assembly_id=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($tar_assembly_id);
    @search_result = $sth->fetchrow_array();
    if (defined($search_result[0])){
        $tar_species_set_id = $search_result[0];
        #aln exists check
        $mysql_search_query = 'select * from alignment where reference_assembly=? and target_assembly=?';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($ref_id, $tar_species_set_id);
        @search_result = $sth->fetchrow_array();
        if (defined($search_result[0])){
            return("O", $search_result[0])
        }
    }else{
        #add new species_set with single species 
        $mysql_search_query = 'select max(species_set_id) from species_set_header';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute();
        $tar_species_set_id = $sth->fetchrow_array();
        $tar_species_set_id ++;
        $dbh->do('insert into species_set_header (species_set_id, size) values(?,1) ', ,undef, $tar_species_set_id);
        $dbh->do('insert into species_set (species_set_id, assembly_id) values(?,?) ', ,undef, $tar_species_set_id, $tar_assembly_id);
    }
    #generate new ID 
    $mysql_search_query = 'select max(alignment_id) from alignment';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    $alnID = $sth->fetchrow_array();
    $alnID ++;
    $dbh->do('insert into alignment (alignment_id, reference_assembly, target_assembly, status,program ) values(?,?,?,0,"LASTZ") ', ,undef, $alnID, $ref_id, $tar_species_set_id);
    $check = "X";
    return ($check, $alnID);
}
sub GET_SPC{
    my $dbh = shift;
    my $sample_id = shift;
    my $sth;
    $mysql_search_query = 'select species from sample_information where sample_name= ?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($sample_id);
    @search_result = $sth->fetchrow_array();
    return $search_result[0];
}
sub CONVERT_SAMPLE_SET_STRING{
    my $dbh = shift;
    my $sample_set_string = shift;
    my $sample_id_set = "";
    my $sth;
    #get sample_id
    foreach my $thissample (split(/,/,$sample_set_string)){
        $mysql_search_query = 'select sample_id from sample_information where sample_name= ?';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($thissample);
        @search_result = $sth->fetchrow_array();
        $sample_id_set .= $search_result[0].",";
    }
    $sample_id_set = substr($sample_id_set,0,-1);
    return $sample_id_set;
}
sub EXISTSCHECK_SAMPLESET{
    my $dbh = shift;
    my $sample_set_string = shift;
    my $species = shift;
    my @ar_sort = sort{$a <=> $b} (split(/,/,$sample_set_string)); #sample id array 
    $sample_set_string = join(",",@ar_sort);
    my $sth;
    $mysql_search_query = 'select sample_set_id, group_concat(sample_id order by sample_id) as sample_set_string from sample_set group by sample_set_id having sample_set_string= ? ';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($sample_set_string);
    @search_result = $sth->fetchrow_array();

    if (defined($search_result[0])){
        return $search_result[0];
    }else{
        return "mew";
    }

}


sub EXISTSCHECK_THISCOMMAND{
    my $dbh = shift;
    my $analysis = shift;
    my $sample_set_id = shift;
    my @parameters = @_;
    my $datapath = "";

    switch($analysis){
        case "RNA" {
            $mysql_search_query = 'select data_id from Transcriptome where data_type="profile" and sample_set_id = ?';
            $sth = $dbh->prepare($mysql_search_query);
            $sth->execute($sample_set_id);
        }
        case "METH" {
            $mysql_search_query = 'select data_id from Epigenome_Meth where data_type="profile" and sample_set_id = ? and param_score_min= ? and param_N= ? and param_L= ? and param_mincov= ? and param_minqual= ?';
            $sth = $dbh->prepare($mysql_search_query);
            #$sth->execute($sample_set_id, $score_min, $N, $L, $mincov, $minqual);
            $sth->execute($sample_set_id, $parameters[0], $parameters[1], $parameters[2], $parameters[3], $parameters[4]);
        }
        case "CHIP" {
            $mysql_search_query = 'select data_id from Epigenome_ChIP where data_type="profile" and sample_set_id = ? and param_bandwith= ? and param_qcutoff= ?';
            $sth = $dbh->prepare($mysql_search_query);
            #$sth->execute($sample_set_id, $q_cutoff, $bandwidth);        
            $sth->execute($sample_set_id, $parameters[0], $parameters[1]);        
        }
        case "HIC" {
            $mysql_search_query = 'select data_id from Epigenome_HiC where data_type="profile" and sample_set_id = ? and param_binsize= ? and param_bin_cnt= ? and param_resolution= ?';
            $sth = $dbh->prepare($mysql_search_query);
            #$sth->execute($sample_set_id, $binsize, $bin_cnt, $resolution);        
            $sth->execute($sample_set_id, $parameters[0], $parameters[1], $parameters[2]);        
        }
    }
    @search_result = $sth->fetchrow_array();
    $datapath = $search_result[0];
    if (defined($datapath)){ #check if the data is existing 
        #return that data is existing
        return (1,$datapath); #datapath == dataid
    }else{
        return (0,0)
    }
}

sub SEARCH_REF_ASSEMBLY{
    my $dbh = shift;
    my $synteny_id = shift;
    my $species_tax = shift;
    my $docker_dir = shift;
    my $genome_path  = $docker_dir."/GENOME/";
    my $annot_path  = $docker_dir."/GENOME/";
    my $ref_assembly_id = 0; 
    my $sth;

    #1 ref check
    $mysql_search_query = ' select assembly.taxon_id, assembly.path, assembly.annotation_path, assembly.assembly_id, synteny.target_species_set from synteny inner join assembly on synteny.reference_assembly=assembly.assembly_id where synteny_id=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($synteny_id);
    @search_result = $sth->fetchrow_array();
    my $ref_taxid = $search_result[0];
    if ($species_tax == $ref_taxid){
        $genome_path .= $search_result[1];
        $annot_path .= $search_result[2];
        $ref_assembly_id = $search_result[3];
        return ($genome_path,$ref_assembly_id, $annot_path);
    }

    #2 tar check 
    my $target_species_set = $search_result[4];
    $mysql_search_query = 'select path, annotation_path, assembly.assembly_id  from species_set inner join assembly on species_set.assembly_id = assembly.assembly_id  where species_set.species_set_id= ?  and assembly.taxon_id= ? ';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($target_species_set, $species_tax);
    @search_result = $sth->fetchrow_array();
    $genome_path .= $search_result[0];
    $annot_path .= $search_result[1];
    $ref_assembly_id = $search_result[2];
    return ($genome_path,$ref_assembly_id, $annot_path);
}

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
$dbh->{mysql_auto_reconnect} = 1;   # by JK
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
my $global_cpu = GET_CPU($dbh,"biweb");
### General_global
my $command = shift;
my $emailto = pop;
chomp($emailto);
my $sfid = 1;
my ($session_id, $job_id, $synteny_id) = ("",0,0);
my $help;
my $flag=0;
my $pid = $$;
my $printcmd = "";
my $antibody_set = "";
my %hs_antibody_set = ();
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
my $generated_profile = "-";    # By JK
my $status = 1;
if ($module_return =~ /(\d+)_(\d+)/){ #profile
    $synteny_id = $1;
    $generated_profile = $prefix{$command}.$2;
    `echo "\n## Generated track ID: $generated_profile" >> $dir_local_working/log.txt`;
    `touch $dir_local_working/done`;
}elsif ($module_return == 0){ #error 
    $status=0;
    `echo "\n## Errors occurred during the analysis" >> $dir_local_working/log.txt`;
    `touch $dir_local_working/error`;
}else{ #compare genome
    $synteny_id = $module_return;
    `touch $dir_local_working/done`;
}
######################################################DONE 
# Send email
if ($emailto ne "noemail") {
    my ($subject, $message) = MAIL_GEN($status,$synteny_id, $session_id, $job_id, $generated_profile);
    my $mail=Email::Send::SMTP::Gmail->new( -smtp=>'smtp.gmail.com', -login=>'imda.server@gmail.com', -pass=>'qnnvskysqttkctoi');
    $mail->send(-to=>$emailto, -subject=>$subject, -body=>$message);
    $mail->bye;
}

#GENOME
sub GENOME{
    my $aln_program = "lastz";
    my $syn_program;
    my $resolution;
    $par_check = scalar(@ARGV);
    GetOptions (
				"session_id=s" => \$session_id,
				"job_id=s" => \$job_id,
				"syn_program=s" => \$syn_program, ## 
				"resolution=s" => \$resolution, ##  
				"h|help" => \$help  
    );
    if(defined($help) || $par_check == 0 || !defined($session_id) || scalar(@ARGV) == 0){
        return 0;
    }
    $dir_local_working = $dir_local_working."/".$session_id."/".$job_id."/";
    `mkdir -m 777  -p $dir_local_working`;
    $dir_out = $dir_local_working;
    `rm -f $dir_local_working/log.txt`;
    `touch $dir_local_working/log.txt`;
    `echo "#### GENOME analysis $pid"  > $dir_local_working/log.txt`;
    `echo "### Genome analysis"  >> $dir_local_working/log.txt`;

    ## Data ID generation
    my $dataid_aln;
    my $dataid_syn;
    my $dataid_genome;

    my $ref_assembmly_name;
    my @ar_all_assembly_names;
    my %hs_tar_assembly_info;
    my ($ref_assembly_id, $ref_tax_name) = (0,"");
    my $tar_assembly_id_list = "";
    my $tar_num = 0;

    ## JOBID set 
    JOBID_SET($dbh, $session_id, $job_id, "GENOME_ALN", 0);  
    my $this_aln_id ;
    if ($aln_program eq "lastz"){ #lastz
        `echo "### Genome alignment"  >> $dir_local_working/log.txt`;
        `echo "## Genome alignment with LASTZ"  >> $dir_local_working/log.txt`;

        $ALN_DIR .= "/LASTZ/";
        `mkdir -m770 -p $dir_local_working/alignment/`;
        # parse species 
        $ref_assembmly_name = $ARGV[0];
        my @ar_all_assembly_names = split(/,/,$ARGV[1]);
        ($ref_assembly_id, $ref_tax_name) = GET_ASSEMBLY_ID($dbh, $ref_assembmly_name);
        %hs_tar_assembly_info = ();
        foreach my $thisname (@ar_all_assembly_names){
            my ($cur_assembly_id, $cur_tax_name) = GET_ASSEMBLY_ID($dbh,$thisname);
            if ($cur_assembly_id == $ref_assembly_id){next;}
            if ($cur_tax_name eq $ref_tax_name) {$cur_tax_name .= "_1"}
            $hs_tar_assembly_info{$cur_assembly_id}{"name"} = $cur_tax_name;
        }
        #Alignment 
        #set alignment ids 
        # Find existing alignments 
        my $distance;
        foreach my $this_tar_id (sort {$a <=> $b} keys (%hs_tar_assembly_info)){
            my ($check, $alnID) = EXISTSCHECK_ALN($dbh, $ref_assembly_id, $this_tar_id);
            $hs_tar_assembly_info{$this_tar_id}{"alnReady"} = $check;
            $hs_tar_assembly_info{$this_tar_id}{"alnID"} = $alnID;
            ##FIND distance 
            $distance = SET_DISTANCE($dbh,$ref_assembly_id, $ref_tax_name, $this_tar_id, $hs_tar_assembly_info{$this_tar_id}{"name"});
            $hs_tar_assembly_info{$this_tar_id}{"distance"} = $distance;
            $tar_assembly_id_list .= "$this_tar_id,";
            $tar_num ++;
            $this_aln_id = $alnID;
        }

        #set alignment params 
        ### generate parameter file at the working directory 
        $f_param_local = $dir_local_working."/alignment//params.txt";

        $flag=0;
        open(FW,">$f_param_local");
        print FW "#PIPELINE IO\n";
        print FW "dir_out $dir_local_working/alignment/\n";
        print FW "ref $ref_assembly_id $ref_tax_name $GENOME_DIR/$ref_assembly_id/$ref_assembly_id.fa\n";
        my $tar_idx = 1;
        foreach my $this_tar_id (keys (%hs_tar_assembly_info)){
            print FW "tar_$tar_idx $this_tar_id ".$hs_tar_assembly_info{$this_tar_id}{"name"}." $GENOME_DIR/$this_tar_id/$this_tar_id.fa  ".$hs_tar_assembly_info{$this_tar_id}{"alnID"}." ".$hs_tar_assembly_info{$this_tar_id}{"alnReady"}." ".$hs_tar_assembly_info{$this_tar_id}{"distance"}."\n";
            $tar_idx ++;
        }
        close(FW);
        #run alignment pipe
        $printcmd = "python $Bin/Pipeline/GENOME/RUN_lastz.py $f_param_local $global_cpu\n";
        `echo "$printcmd" > $dir_local_working/alignment/cmd`;
        `python $Bin/Pipeline/GENOME/RUN_lastz.py $f_param_local $global_cpu`;
        
        $dbh = REFRESH_DBH($dbh);
        #organize alignment data 
        foreach my $this_tar_id (keys (%hs_tar_assembly_info)){
            if ($hs_tar_assembly_info{$this_tar_id}{"alnReady"} eq "O"){next;}
            $this_aln_id = $hs_tar_assembly_info{$this_tar_id}{"alnID"};
            `mkdir -m770 -p $ALN_DIR/$this_aln_id/`;
            `cp $dir_local_working/alignment/$this_aln_id/all.chain $ALN_DIR/$this_aln_id/`;
            ALN_DONE($dbh,"ALIGNMENT/LASTZ/$this_aln_id",$this_aln_id);
        }
        # update db complete 
    }
    ####
    JOBID_update_genome($dbh, $session_id, $job_id, "GENOME_ALN_DONE", 0);  
    #Synteny
    #exists synteny ID check and generate it 
    chop($tar_assembly_id_list);
    my $res_str = RES_STR($resolution);
    my $synExist;
    ($synExist,$synteny_id) = EXISTSCHECK_SYN($dbh,$ref_assembly_id,$tar_assembly_id_list, $resolution, $syn_program, "LASTZ");
    
    JOBID_update_genome($dbh, $session_id, $job_id, "GENOME_SYN_BEGIN", $synteny_id);  
    #set synteny params
    #run synteny pipe 
    if ($synExist == 0){
        if ($syn_program eq "makeblocks"){ #makeblocks
            `echo "### Synteny generation"  >> $dir_local_working/log.txt`;
            `echo "## Synteny generation with Makeblocks"  >> $dir_local_working/log.txt`;
            $SYN_DIR .= "/inferCars/";
            `mkdir -m770 -p $dir_local_working/synteny/`;
            $f_param_local = $dir_local_working."/synteny/params.mb.txt";
            open(FW,">$f_param_local");
            print FW "#OUT_DIR\n";
            print FW "$dir_local_working/synteny/\n";
            print FW "#CHAINNET_DIR\n";
            print FW "$ALN_DIR\n";
            print FW "#REF\n";
            print FW "$ref_tax_name $ref_assembly_id\n";
            print FW "#TAR\n";
            foreach my $this_tar_id (keys (%hs_tar_assembly_info)){
                print FW $hs_tar_assembly_info{$this_tar_id}{"name"}." $this_tar_id ".$hs_tar_assembly_info{$this_tar_id}{"alnID"}."\n";
            }
            print FW "#GENOME_DIR\n";
            print FW "$GENOME_DIR\n";
            print FW "#RESOLUTION\n";
            print FW "$resolution\n";
            close(FW);

            $printcmd = "python $Bin/Pipeline/GENOME/RUN_makeblocks.py  $f_param_local";
            `echo "$printcmd" > $dir_local_working/synteny//cmd`;
            `echo "$synteny_id" > $dir_local_working/synteny/tmp.synID`;
            `python $Bin/Pipeline/GENOME/RUN_makeblocks.py  $f_param_local`;
            $dbh = REFRESH_DBH($dbh);
            #organize alignment data 
            my $csFilename = "$dir_local_working/synteny/error";
            if ((-e $csFilename)) {
                SYN_DONE_abnormal($dbh,$synteny_id);
                return 0;
            } 
            my $CsSIze = -s "$dir_local_working/synteny/Conserved.Segments";
            if ($CsSIze == 0){
                SYN_DONE_abnormal($dbh,$synteny_id);
                return 0;
            }
            `mkdir -p -m777 $SYN_DIR/$synteny_id/`;
            `cp $dir_local_working/synteny/Conserved.Segments $SYN_DIR/$synteny_id/$res_str\_synteny.txt`;
            `cp $dir_local_working/synteny/synteny.json $SYN_DIR/$synteny_id/$res_str\_synteny.json`;
            SYN_DONE($dbh,$synteny_id,$syn_program );
            JOBID_update_genome($dbh, $session_id, $job_id, "GENOME_SYN_DONE", $synteny_id);  
            `echo "## Synteny generation is finished!"  >> $dir_local_working/log.txt`;
        }elsif($syn_program eq "halsynteny"){ #halsynteny
            `echo "### Synteny generation"  >> $dir_local_working/log.txt`;
            `echo "## Synteny generation with HalSynteny"  >> $dir_local_working/log.txt`;
            $SYN_DIR .= "/halsynteny/";
            `mkdir -m770 -p $dir_local_working/synteny/`;
            $f_param_local = $dir_local_working."/synteny/params.hs.txt";
            open(FW,">$f_param_local");
            print FW "outdir $dir_local_working/synteny/\n";
            print FW "chain $ALN_DIR/$this_aln_id/all.chain\n";
            print FW "ref  $ref_tax_name\n";
            print FW "ref_fa  $GENOME_DIR/$ref_assembly_id/$ref_assembly_id.fa\n";
            print FW "tar ";
            foreach my $this_tar_id (keys (%hs_tar_assembly_info)){
                print FW $hs_tar_assembly_info{$this_tar_id}{"name"}."\n";
                print FW "tar_fa $GENOME_DIR/$this_tar_id/$this_tar_id.fa\n";
            }
            print FW "resolution $resolution\n";
            close(FW);
            $printcmd = "perl $Bin/Pipeline/GENOME/RUN_halsynteny.pl  $f_param_local";
            `echo "$printcmd" > $dir_local_working/synteny//cmd`;
            `perl $Bin/Pipeline/GENOME/RUN_halsynteny.pl  $f_param_local`;

            `mkdir -p -m777 $SYN_DIR/$synteny_id/`;
            my $halSynSize = -s "$dir_local_working/synteny/out.synteny.psl";
            $dbh = REFRESH_DBH($dbh);
            if ($halSynSize==0){
                SYN_DONE_abnormal($dbh,$synteny_id);
                return 0;
            }
            `cp $dir_local_working/synteny/out.synteny.psl $SYN_DIR/$synteny_id/$res_str\_synteny.txt`;
            `cp $dir_local_working/synteny/synteny.json $SYN_DIR/$synteny_id/$res_str\_synteny.json`;
            SYN_DONE($dbh,$synteny_id,$syn_program);
            JOBID_update_genome($dbh, $session_id, $job_id, "GENOME_SYN_DONE", $synteny_id);  
            `echo "## Synteny generation is finished!"  >> $dir_local_working/log.txt`;
        }
    }else{
        `echo "## Synteny already exists! Accession=$synteny_id" >> $dir_local_working/log.txt`;
        JOBID_done($dbh, $session_id, $job_id);  
        $SYN_DIR .= "/inferCars/";
        #`touch $dir_local_working/done`;
        return $synteny_id;
    }
    ### 
    #GENOME analysis 
    if ($syn_program ne "makeblocks"){
        `echo "## Genome compare analysis is done! Accession=$synteny_id" >> $dir_local_working/log.txt`;
        JOBID_done($dbh, $session_id, $job_id);  
        `touch $dir_local_working/done`;
        return $synteny_id;
    }
    `echo "## Additional genome analysis" >> $dir_local_working/log.txt`;
    `mkdir -m770 -p $dir_local_working/genome/`;
    $f_param_local = $dir_local_working."/genome/params.gn.txt";
    open(FW,">$f_param_local");
    print FW "##Pipeline IO\n";
    print FW "asm_cnt ".($tar_num+1)." \n";
    print FW "spcs $ref_assembly_id,$tar_assembly_id_list \n";
    print FW "ref $GENOME_DIR/$ref_assembly_id/$ref_assembly_id.fa\n";

    # generate pos data 
    my $sizeList = "$ref_tax_name:$GENOME_DIR/$ref_assembly_id/$ref_assembly_id.size";
    my $synMid = "$dir_local_working/synteny/_orthology.blocks.tmp";
    my $chainListF = "$dir_local_working/genome/chain.list";
    open(FFW,">$chainListF");
    my $tar_idx = 1;
    foreach my $this_tar_id (keys (%hs_tar_assembly_info)){
        print FW "tar_$tar_idx  $GENOME_DIR/$this_tar_id/$this_tar_id.fa\n";
        print FW "ref_tar_$tar_idx  $ALN_DIR/".$hs_tar_assembly_info{$this_tar_id}{"alnID"}."/\n";
        $tar_idx++;

        print FFW $ref_tax_name.",".$hs_tar_assembly_info{$this_tar_id}{"name"}."\t$ALN_DIR/".$hs_tar_assembly_info{$this_tar_id}{"alnID"}."/all.chain\n";
        $sizeList .= ",$hs_tar_assembly_info{$this_tar_id}{'name'}:$GENOME_DIR/$this_tar_id/$this_tar_id.size";
    }
    close(FFW);

    print FW "synteny $SYN_DIR/$synteny_id/$res_str\_synteny.txt\n";
    print FW "dir_out $dir_local_working/genome/\n";
    print FW "threads $global_cpu\n";

    close(FW);
    `python $Bin/Pipeline/GENOME/GENOME.py $f_param_local`;
    $printcmd = "python $Bin/Pipeline/GENOME/GENOME.py $f_param_local";
    `echo "$printcmd" > $dir_local_working/genome/cmd`;

    # run new pos 
    $printcmd = "$Bin/Pipeline/GENOME/match_alnbase.pl $chainListF $synMid > $dir_local_working/genome/base_aln.bedpe";
    `echo "$printcmd" > $dir_local_working/genome/cmd_pos`;
    `$Bin/Pipeline/GENOME/match_alnbase.pl $chainListF $synMid > $dir_local_working/genome/base_aln.bedpe`;

    #move genome result to correct dir
    `mkdir -m777 -p $Multiomics_DIR/Genome_ent/$synteny_id/`;
    `mkdir -m777 -p $Multiomics_DIR/Genome_gap/$synteny_id/`;
    `mkdir -m777 -p $Multiomics_DIR/Genome_pos/$synteny_id/`;
    `cp $dir_local_working/genome/results/pos/*  $Multiomics_DIR/Genome_pos/$synteny_id/`;
    `cp $dir_local_working/genome/base_aln.bedpe  $Multiomics_DIR/Genome_pos/$synteny_id/`;
    `perl $Bin/indexing/downsample_alndata.pl $Multiomics_DIR/Genome_pos/$synteny_id/  $sizeList  $Multiomics_DIR/Genome_pos/$synteny_id/base_aln.bedpe 1 align.sort.bedpe 2> $dir_local_working/genome/baseAlnindex.log`;
    #indexing 
    `perl $Bin/indexing/add_data.pl  -o $Multiomics_DIR  -p Genome_ent -i $synteny_id -d $dir_local_working/genome/genome_ent.result.bed -t bed -s 1 -g $GENOME_DIR/$ref_assembly_id/$ref_assembly_id.size copy  2> $dir_local_working/genome/ent.index.log `;
    `perl $Bin/indexing/add_data.pl  -o $Multiomics_DIR  -p Genome_gap -i $synteny_id -d $dir_local_working/genome/genome_gap.result.bed -t bed -s 1 -g $GENOME_DIR/$ref_assembly_id/$ref_assembly_id.size copy  2> $dir_local_working/genome/gap.index.log`;

    $dbh = REFRESH_DBH($dbh);
    $dbh->do('update session_info set status = 1 where session_id = ? and job_number=?',,undef,$session_id, $job_id);
    $dbh->do('insert into Genome (synteny_id, data_type, path) values (?,"profile",?)', ,undef,$synteny_id, "Multiomics/Genome/$synteny_id");
    `echo "## Genome analysis is done! Accession=$synteny_id" >> $dir_local_working/log.txt`;
    return $synteny_id;
}
#RNA
sub RNA{
    $par_check = scalar(@ARGV);
    GetOptions (
				"session_id=s" => \$session_id,
                "job_id=s" => \$job_id,
				"synteny=i" => \$synteny_id, ## input synteny id 
				"h|help" => \$help  
    );
    if(defined($help) || $par_check == 0 || !defined($session_id) || scalar(@ARGV) == 0){
        return 0;
    }
    
    ## set working directory
    $dir_local_working = $dir_local_working."/".$session_id."/".$job_id."/";
    `mkdir -m 777  -p $dir_local_working`;
    $dir_out = $dir_local_working;
    `echo "#### Multiomics analysis $pid"  >> $dir_local_working/log.txt`;
    `echo "### Transcriptome analysis"  >> $dir_local_working/log.txt`;
    ## JOBID set 
    JOBID_SET($dbh, $session_id, $job_id, "RNA", $dataid);

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
    my $sample_set_keep = $sample_set ;
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "RNA", $sample_set_id,$sample_set_keep);
    if ($checkReturn == 1){
        `echo "## Data already exists : $dataid"  >> $dir_local_working/log.txt`;
        #`touch $dir_local_working/done`;
        JOBID_done($dbh, $session_id, $job_id, "RNA", $dataid);
        return 0;
    }
    `echo "RNA_$dataid" >  $dir_local_working/tmp.id.txt`;

    

    ## Search reference assembly
    ($reference_fa, $ref_assembly_id, $annotation_gtf) = SEARCH_REF_ASSEMBLY($dbh, $synteny_id, $species, $DATA_DIR);
    $ref_dir =  dirname($reference_fa);
    my $all_sample_list = "";
    ### generate parameter file at the working directory 
    $f_param_local = $dir_local_working."/params.txt";
    $f_param_run = $dir_local_working."/params.txt";

    $flag=0;
    open(FW,">$f_param_local");
    print FW "S1\ttrimmomatic\n";
    print FW "S2\tsortmerna\n";
    print FW "S3\tSTAR\n";
    print FW "S4\trsem-prepare-reference\n";
    print FW "S5\trsem-calculate-expression \n";
    print FW "S6\tsamtools\n";
    print FW "S7\t$Bin/Pipeline/RNA/bin/RSEMToJSON.pl\n";
    print FW "S3\trunThreadN\t$global_cpu\n";
    print FW "S3\trunMode\tgenomeGenerate\n";
    print FW "S3\tsjdbOverhang\t100\n";
    print FW "S2\tp\t$global_cpu\n";
    print FW "S3\tp\t$global_cpu\n";
    print FW "S5\tstrandedness\treverse\n";
    print FW "S5\treadpair_tag\t--paired-end\n";
    print FW "S1\tadapter_fa\t/RNA/testdata/TruSeq-LT.fa\n";
    print FW "S3\tgenomeSAindexNbases\t13\n";
    print FW "##REFERENCE INFORMATION\n";
    print FW "dir_out\t$dir_out\n";
    print FW "dir_assembly\t$ref_dir\n";
    print FW "f_refFasta\t$reference_fa\n";
    print FW "f_annotation\t$annotation_gtf\n";
    print FW "##SAMPLE INFORMATION\n";
    print FW "sample_set_name\t$sample_set_id\n";
    
    ### Get sample data 
    foreach $cur_data_id (split(/,/,$sample_set)){
        $mysql_search_query = 'select SRA_id, json_path , data_type from Transcriptome where SRA_id= ? and data_type != "profile"';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($cur_data_id);
        my($sample_name, $sample_path, $fileFormat ) = $sth->fetchrow_array();
        $dir_local_data = $DIR_mount."/".$sample_path;
        my @lsres = split(/\n/,`ls $dir_local_data*`);
        my $paired = scalar(@lsres);
       if (length($all_sample_list)<1){
             $all_sample_list = "$sample_name";
        }else{
             $all_sample_list .= ",$sample_name";
        }

        print FW "sample_name\t$sample_name\n";
        if ($paired == 2){
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path\_1.$fileFormat\n";
            print FW "$sample_name\tf_fastq2\t$DATA_DIR/$sample_path\_2.$fileFormat\n";
        }else{
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path.$fileFormat\n";
        }     
    }
    close(FW);
    `echo "* $all_sample_list"  >> $dir_local_working/log.txt`;
    `echo "** $synteny_id"  >> $dir_local_working/log.txt`;
    $local_run_cmd = "perl $Bin/Pipeline/RNA/RNA.pl $f_param_run";  
    `$local_run_cmd`;
    my $rnaout = $dir_local_working."/RNA.result.bed";
    $dbh = REFRESH_DBH($dbh);
    if (-e $rnaout){
        my $foutSize = -s $rnaout;
        if ($foutSize == 0){
            DATAID_update_del($dbh,"RNA", $dataid);
            return 0;
        }
    }else{
        DATAID_update_del($dbh,"RNA", $dataid);
        return 0;
    }
    #indexing 
    `perl $Bin/indexing/add_data.pl  -o $DIR_mount/Multiomics  -p Transcriptome -i $dataid -d $rnaout -t bed -s 1 -g $DIR_mount/GENOME/$ref_assembly_id/$ref_assembly_id.size copy  2> $dir_local_working/indexing.log`;
    print "## END_RNA_MODULE\n";
    
    #move local directory to DATA ID directory 
    `mkdir -p -m777 $DIR_mount/Multiomics/Transcriptome/$dataid/`;
    `cp $rnaout $DIR_mount/Multiomics/Transcriptome/$dataid/$dataid.bed`;
    #outputdir set and return
    my $FINAL_OUT = "Multiomics/Transcriptome/$dataid/";

    #session info db cleaning
    $dbh = REFRESH_DBH($dbh);
    JOBID_update($dbh, $session_id, $job_id);
    DATAID_update($dbh,"RNA", $dataid, $FINAL_OUT, $ref_assembly_id,$all_sample_list);
    return "$synteny_id\_$dataid";

}
#METH 
sub METH{
    $par_check = scalar(@ARGV);
    my ($score_min, $N, $L, $mincov, $minqual) = ("L,0,-0.6",0,20,10,10);
    GetOptions (
				"session_id=s" => \$session_id,
				"job_id=i" => \$job_id,
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
    
    
    ## set working directory
    $dir_local_working = $dir_local_working."/".$session_id."/".$job_id."/";
    `mkdir -m 777  -p $dir_local_working`;
    $dir_out = $dir_local_working;
    `echo "#### Multiomics analysis $pid"  >> $dir_local_working/log.txt`;
    `echo "### Methylome analysis"  >> $dir_local_working/log.txt`;


    ### Search data existing
    ## Search spc
    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    my $sample_set_keep = $sample_set;
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "METH", $sample_set_id,$sample_set_keep, $score_min, $N, $L, $mincov, $minqual);
    ## JOBID set 
    JOBID_SET($dbh, $session_id, $job_id, "METH", $dataid);
    if ($checkReturn == 1){
        `echo "## Data already exists : $dataid"  >> $dir_local_working/log.txt`;
        `touch $dir_local_working/done`;
        JOBID_done($dbh, $session_id, $job_id, "METH", $dataid);
        return 0;
    }

    `echo "METH_$dataid" >  $dir_local_working/tmp.id.txt`;

    ## Search reference assembly
    ($reference_fa, $ref_assembly_id, $annotation_gtf) = SEARCH_REF_ASSEMBLY($dbh, $synteny_id, $species, $DATA_DIR);
    $ref_dir =  dirname($reference_fa);

    ### generate parameter file at the working directory 
    $f_param_local = $dir_local_working."/params.txt";
    $f_param_run = $dir_local_working."/params.txt";
    my $all_sample_list = "";
    $flag=0;
    open(FW,">$f_param_local");
    
    print FW "S0\ttrim_galore\n";
    print FW "S1\tbismark\n";
    print FW "S2\tsamtools\n";
    print FW "S3\t$Bin/Pipeline/METH/bin/methCall.R\n";
    print FW "S4\t$Bin/Pipeline/METH/bin/profile2json.pl\n";
    print FW "S0\tpath_to_cutadapt\t/usr/local/bin/cutadapt\n";
    print FW "S1\tpath_to_bowtie2\t/mss/programs/bin/\n";
    print FW "S1\tbowtie2\t/mss/programs/bin/\n";
    print FW "S1\tsamtools_path\t/mss/programs/bin/\n";
    print FW "S1\tmulticore\t$global_cpu\n";
    print FW "S1\ttemp_dir\t./temp\n";
    print FW "\n";
    print FW "\n";
    print FW "S1\tscore_min\t$score_min\n";
    print FW "S1\tN\t$N\n";
    print FW "S1\tL\t$L\n";
    print FW "S3\tmincov\t$mincov\n";
    print FW "S3\tminqual\t$minqual\n";
    print FW "##REFERENCE INFORMATION\n";
    print FW "dir_out\t$dir_out\n";
    print FW "dir_assembly\t$ref_dir\n";
    print FW "f_refFasta\t$reference_fa\n";
    print FW "##SAMPLE INFORMATION\n";
    print FW "sample_set_name\t$sample_set_id\n";
    print FW "global_threads\t$global_cpu\n";

    ### Get sample data 
    foreach $cur_data_id (@ARGV){
        $mysql_search_query = 'select SRA_id, json_path, data_type from Epigenome_Meth where SRA_id= ? and data_type!="profile"';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($cur_data_id);
        my($sample_name, $sample_path, $fileFormat ) = $sth->fetchrow_array();
        $dir_local_data = $DIR_mount."/".$sample_path;
        my @lsres = split(/\n/,`ls $dir_local_data*`);
        my $paired = scalar(@lsres);
        if (length($all_sample_list)<1){
             $all_sample_list = "$sample_name"
        }else{
             $all_sample_list .= ",$sample_name"
        }

        print FW "sample_name\t$sample_name\n";
        if ($paired == 2){
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path\_1.$fileFormat\n";
            print FW "$sample_name\tf_fastq2\t$DATA_DIR/$sample_path\_2.$fileFormat\n";
        }else{
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path.$fileFormat\n";
        }     
    }
    close(FW);
    `echo "* $all_sample_list"  >> $dir_local_working/log.txt`;
    `echo "** $synteny_id"  >> $dir_local_working/log.txt`;
    $local_run_cmd = "perl $Bin/Pipeline/METH/METH.pl $f_param_run ";
    print STDERR $local_run_cmd."\n";
    `$local_run_cmd`;
    my $methout = $dir_local_working."/meth.result.bed";
    $dbh = REFRESH_DBH($dbh);
    if (-e $methout){
        my $foutSize = -s $methout;
        if ($foutSize == 0){
            DATAID_update_del($dbh,"METH", $dataid);
            return 0;
        }
    }else{
        DATAID_update_del($dbh,"METH", $dataid);
        return 0;
    }

    #indexing 
    `mkdir -p -m777 $DIR_mount/Multiomics/Epigenome_meth/$dataid/`;
    `cp $dir_local_working/meth.result.bed   $DIR_mount/Multiomics/Epigenome_meth/$dataid/$dataid.bed `;
    `perl $Bin/indexing/add_data.pl  -o $DIR_mount/Multiomics  -p Epigenome_meth -i $dataid -d $methout -t bed -s 1 -g $DIR_mount/GENOME/$ref_assembly_id/$ref_assembly_id.size copy  2> $dir_local_working/indexing.log `;

    my $final_parameters = "$DIR_mount/Multiomics/Epigenome_meth/$dataid/parameters.txt";
    `echo "Bismark Score function (-score_min) : $score_min"> $final_parameters `;
    `echo "Bismark Mismatch count (-N) : $N" >> $final_parameters`;
    `echo "Bismark Seed length (-L) : $L" >> $final_parameters`;

    `echo "methylKit Minimum coverage (-mincov) : $mincov" >> $final_parameters`;
    `echo "methylKit Minimum quality (-minqual) : $minqual" >> $final_parameters`;

    #outputdir set and return
    my $FINAL_OUT = "Multiomics/Epigenome_meth/$dataid/";
    $dbh = REFRESH_DBH($dbh);
    #session info db cleaning
    JOBID_update($dbh, $session_id, $job_id);
    DATAID_update($dbh,"METH", $dataid, $FINAL_OUT, $ref_assembly_id,$all_sample_list);
    return "$synteny_id\_$dataid";

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
    ## set working directory
    $dir_local_working = $dir_local_working."/".$session_id."/".$job_id."/";
    `mkdir -m 777  -p $dir_local_working`;
    $dir_out = $dir_local_working;
    `echo "#### Multiomics analysis $pid"  >> $dir_local_working/log.txt`;
    `echo "### ChIP-seq analysis"  >> $dir_local_working/log.txt`;

    ## JOBID set 
    JOBID_SET($dbh, $session_id, $job_id, "CHIP", $dataid);
    
    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    my $sample_set_keep = $sample_set;
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "CHIP", $sample_set_id,$sample_set_keep,$bandwidth, $q_cutoff);
    if ($checkReturn == 1){
        `echo "## Data already exists : $dataid"  >> $dir_local_working/log.txt`;
        `touch $dir_local_working/done`;
        JOBID_SET($dbh, $session_id, $job_id, "CHIP", $dataid);
        return 0;
    }
    
    `echo "CHIP_$dataid" >  $dir_local_working/tmp.id.txt`;

    ## Search reference assembly
    ($reference_fa, $ref_assembly_id, $annotation_gtf) = SEARCH_REF_ASSEMBLY($dbh, $synteny_id, $species, $DATA_DIR);
    $ref_dir =  dirname($reference_fa);
    my $all_sample_list = "";
    ### generate parameter file at the working directory 
    $f_param_local = $dir_local_working."/params.txt";
    $f_param_run = $dir_local_working."/params.txt";
    $flag=0;
    open(FW,">$f_param_local");
    print FW "S0\ttrim_galore\n";
    print FW "S1\tbwa\n";
    print FW "S2\tsamtools\n";
    print FW "S3\tmacs2 \n";
    print FW "S4\t$Bin/Pipeline/CHIP/bin/profile2json.pl \n";
    print FW "S0\tpath_to_cutadapt\t/usr/local/bin/cutadapt\n";
    print FW "S0\tj\t2\n";
    print FW "S1\tt\t$global_cpu\n";
    print FW "S3\tq_cutoff\t$q_cutoff\n";
    print FW "S3\tbandwidth\t$bandwidth\n";
    print FW "##REFERENCE INFORMATION\n";
    print FW "dir_out\t$dir_out\n";
    print FW "f_refFasta\t$reference_fa\n";
    print FW "##SAMPLE INFORMATION\n";
    print FW "sample_set_name\t$sample_set_id\n";
    ### Get sample data 
    
    foreach $cur_data_id (@ARGV){
        $mysql_search_query = 'select SRA_id, json_path, data_type,antibody from Epigenome_ChIP where SRA_id= ?  and data_type !="profile"';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($cur_data_id);
        my($sample_name, $sample_path, $fileFormat,$antibody) = $sth->fetchrow_array();
        $hs_antibody_set{$antibody} = 1;
        $dir_local_data = $DIR_mount."/".$sample_path;
        my @lsres = split(/\n/,`ls $dir_local_data*`);
        my $paired = scalar(@lsres);
        if (length($all_sample_list)<1){
             $all_sample_list = "$sample_name"
        }else{
             $all_sample_list .= ",$sample_name"
        }
        print FW "sample_name\t$sample_name\n";
        if ($paired == 2){
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path\_1.$fileFormat\n";
            print FW "$sample_name\tf_fastq2\t$DATA_DIR/$sample_path\_2.$fileFormat\n";
        }else{
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path.$fileFormat\n";
        }    
    }
    close(FW);
    my @ar_antbd = keys (%hs_antibody_set);
    $antibody_set = join(",",@ar_antbd);
    `echo "* $all_sample_list"  >> $dir_local_working/log.txt`;
    `echo "** $synteny_id"  >> $dir_local_working/log.txt`;

    ### generate cmd and run 
    $local_run_cmd = "perl $Bin/Pipeline/CHIP/CHIP.pl $f_param_run ";
    print $local_run_cmd."\n";
    `perl $Bin/Pipeline/CHIP/CHIP.pl $f_param_run 2> $dir_local_working/all.logs`;
    my $chipout = $dir_local_working."/chip.result.bed";
    $dbh = REFRESH_DBH($dbh);
    if (-e $chipout){
        my $foutSize = -s $chipout;
        if ($foutSize == 0){
            DATAID_update_del($dbh,"CHIP", $dataid);
            return 0;
        }
    }else{
        DATAID_update_del($dbh,"CHIP", $dataid);
        return 0;
    }

    #indexing 
    `mkdir -p -m777 $DIR_mount/Multiomics/Epigenome_chip/$dataid/`;
    `cp  $dir_local_working/chip.result.bed $DIR_mount/Multiomics/Epigenome_chip/$dataid/$dataid.bed`;
    `perl $Bin/indexing/add_data.pl  -o $DIR_mount/Multiomics  -p Epigenome_chip  -i $dataid -d $chipout -t bed -s $bandwidth -g $DIR_mount/GENOME/$ref_assembly_id/$ref_assembly_id.size copy  2> $dir_local_working/indexing.log `;
    
    #print parameters 
    my $final_parameters = "$DIR_mount/Multiomics/Epigenome_chip/$dataid/parameters.txt";
    `echo "Bandwidth (--bw) : $bandwidth "> $final_parameters `;
    `echo "Q-value cutoff (-q) : $q_cutoff" >> $final_parameters`;

    #outputdir set and return
    my $FINAL_OUT = "Multiomics/Epigenome_chip/$dataid/";

    #session info db cleaning
    $dbh = REFRESH_DBH($dbh);
    JOBID_update($dbh, $session_id, $job_id);
    DATAID_update($dbh,"CHIP", $dataid, $FINAL_OUT, $ref_assembly_id,$all_sample_list);
    CHIP_DATAID_update($dbh,"CHIP", $dataid,$antibody_set);
    return "$synteny_id\_$dataid";
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
    $binsize = $resolution;
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

    ## set working directory
    $dir_local_working = $dir_local_working."/".$session_id."/".$job_id."/";
    `mkdir -m 777  -p $dir_local_working`;
    $dir_out = $dir_local_working;
    `echo "#### Multiomics analysis $pid"  >> $dir_local_working/log.txt`;
    `echo "### HiC analysis"  >> $dir_local_working/log.txt`;

    ## JOBID set 
    JOBID_SET($dbh, $session_id, $job_id, "HIC", $dataid);
    
    $species = GET_SPC($dbh, $ARGV[0]);
    ### Sample set existing check 
    $sample_set = join(",",@ARGV);
    my $sample_set_keep = $sample_set;
    $sample_set_id = CONVERT_SAMPLE_SET_STRING($dbh, $sample_set);
    $sample_set_id = EXISTSCHECK_SAMPLESET($dbh, $sample_set_id, $species);
    ($checkReturn, $dataid) = EXISTSCHECK_THISCOMMAND($dbh, "HIC", $sample_set_id,$sample_set_keep,$binsize, $bin_cnt, $resolution);
    if ($checkReturn == 1){
        `echo "## Data already exists : $dataid"  >> $dir_local_working/log.txt`;
        `touch $dir_local_working/done`;
        JOBID_done($dbh, $session_id, $job_id, "HIC", $dataid);
        return 0;
    }
    `echo "HIC_$dataid" >  $dir_local_working/tmp.id.txt`;

    
    ## Search reference assembly
    ($reference_fa, $ref_assembly_id, $annotation_gtf) = SEARCH_REF_ASSEMBLY($dbh, $synteny_id, $species, $DATA_DIR);
    my $spcName = SEARCH_REF_ASSEMBLY_NAME($dbh, $species);
    $ref_dir =  dirname($reference_fa);

    ### generate parameter file at the working directory 
    $f_param_local = $dir_local_working."/params.txt";
    $f_param_run = $dir_local_working."/params.txt";
    my $all_sample_list = "";    
    $flag=0;
    open(FW,">$f_param_local");
    print FW "##Pipeline IO\n";
    print FW "f_refFasta\t$reference_fa\n";
    print FW "dir_out\t$dir_out\n";
    print FW "bin_size\t$binsize\n";
    print FW "cutoff\t$bin_cnt\n";

    print FW "threads\t$global_cpu\n";
    print FW "parse\tTrue\n";

    print FW "spcs $spcName\n";
    print FW "tissue -\n";

    print FW "sample_set_name\t$sample_set_id\n";

    ### Get sample data 
    foreach $cur_data_id (@ARGV){
        $mysql_search_query = 'select SRA_id, json_path , data_type  from Epigenome_HiC where SRA_id= ? and data_type!="profile" ';
        $sth = $dbh->prepare($mysql_search_query);
        $sth->execute($cur_data_id);
        my($sample_name, $sample_path,$fileFormat ) = $sth->fetchrow_array();
        $dir_local_data = $DIR_mount."/".$sample_path;
        my @lsres = split(/\n/,`ls $dir_local_data*`);
        my $paired = scalar(@lsres);
        if (length($all_sample_list)<1){
             $all_sample_list = "$sample_name"
        }else{
             $all_sample_list .= ",$sample_name"
        }

    print FW "sample_name\t$sample_name\n";
        if ($paired == 2){
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path\_1.$fileFormat\n";
            print FW "$sample_name\tf_fastq2\t$DATA_DIR/$sample_path\_2.$fileFormat\n";
        }else{
            print FW "$sample_name\tf_fastq1\t$DATA_DIR/$sample_path.$fileFormat\n";
        }
    }
    print FW "##parameters\n";
	print FW "S1 skip\n";
    print FW "S1 a bwtsw\n";

    close(FW);
    `echo "* $all_sample_list"  >> $dir_local_working/log.txt`;
    `echo "** $synteny_id"  >> $dir_local_working/log.txt`;
    ### generate cmd and run 
    $local_run_cmd = "python3 $Bin/Pipeline/HIC/HIC.py $f_param_run";
    `$local_run_cmd`;
    my $hicout = $dir_local_working."/hic.result.bedpe";
    $dbh = REFRESH_DBH($dbh);
    if (-e $hicout){
        my $foutSize = -s $hicout;
        if ($foutSize == 0){
            DATAID_update_del($dbh,"HIC", $dataid);
            return 0;
        }
    }else{
        DATAID_update_del($dbh,"HIC", $dataid);
        return 0;
    }
    #indexing
    `mkdir -p -m777 $DIR_mount/Multiomics/Epigenome_hic/$dataid/`;
    `cp $dir_local_working/hic.result.bedpe $DIR_mount/Multiomics/Epigenome_hic/$dataid/$dataid.bedpe`;
    `cp $dir_local_working/filt/filtered.pairs $DIR_mount/Multiomics/Epigenome_hic/$dataid/`;
    `perl $Bin/indexing/add_data.pl  -o $DIR_mount/Multiomics  -p Epigenome_hic -i $dataid -d $hicout -t bedpe -s $binsize -g $DIR_mount/GENOME/$ref_assembly_id/$ref_assembly_id.size copy  2> $dir_local_working/indexing.log `;

    my $final_parameters = "$DIR_mount/Multiomics/Epigenome_hic/$dataid/parameters.txt";
    `echo "Minimum read count : $bin_cnt" > $final_parameters`;
    `echo "Resolution : $resolution" >> $final_parameters`;
    
    #outputdir set 
    my $FINAL_OUT = "Multiomics/Epigenome_hic/$dataid/";

    #session info db cleaning
    $dbh = REFRESH_DBH($dbh);
    JOBID_update($dbh, $session_id, $job_id);
    DATAID_update($dbh,"HIC", $dataid, $FINAL_OUT, $ref_assembly_id,$all_sample_list);

    return "$synteny_id\_$dataid";

}
sub GET_CPU{
    my $dbh = shift;
    my $serverInfo = shift;
    my $sth;

    $mysql_search_query = 'select path from metadata where data_type="cpu" and filename=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($serverInfo);
    my($cpu) = $sth->fetchrow_array();
    return $cpu;
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
sub DATAID_SET{
    my $dbh = shift;
    my $analysis = shift;
    my $sample_set_id = shift;
    my @parameters = @_;

    switch($analysis){
        case "RNA" {
            $mysql_search_query = 'select MAX(data_id) from Transcriptome';
        }
        case "METH" {
            $mysql_search_query = 'select MAX(data_id) from Epigenome_Meth';
        }
        case "CHIP" {
            $mysql_search_query = 'select MAX(data_id) from Epigenome_ChIP';
        }
        case "HIC" {
            $mysql_search_query = 'select MAX(data_id) from Epigenome_HiC';
        }
    }

    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my $new_data_id = 0;
    $new_data_id = $sth->fetchrow_array();
    $new_data_id ++;

    switch($analysis){
        case "RNA" {
            $dbh->do('insert into Transcriptome (data_id, sample_set_id) values(?,?)', ,undef,$new_data_id, $sample_set_id);
        }
        case "METH" {
            $dbh->do('insert into Epigenome_Meth (data_id, sample_set_id, param_score_min, param_N, param_L, param_mincov, param_minqual) values(?,?,?,?,?,?,?)', ,undef,$new_data_id, $sample_set_id, $parameters[0], $parameters[1], $parameters[2], $parameters[3], $parameters[4]);
        }
        case "CHIP" {
            $dbh->do('insert into Epigenome_ChIP (data_id, sample_set_id, param_bandwith, param_qcutoff) values(?,?,?,?)', ,undef,$new_data_id, $sample_set_id, $parameters[0], $parameters[1]);
        }
        case "HIC" {
            $dbh->do('insert into Epigenome_HiC (data_id, sample_set_id, param_binsize, param_bin_cnt, param_resolution) values(?,?,?,?,?)', ,undef,$new_data_id, $sample_set_id, $parameters[0], $parameters[1], $parameters[2]);
        }
    }


    return $new_data_id;
}

sub CHIP_DATAID_update{
    my $dbh = shift;
    my $analysis = shift;
    my $dataid = shift;
    my $antibody = shift;
    $dbh->do('update Epigenome_ChIP set antibody = "'.$antibody.'"  where data_id = '.$dataid.';');
}

sub DATAID_update{
    my $dbh = shift;
    my $analysis = shift;
    my $dataid = shift;
    my $path = shift;
    my $ref_assembly = shift;
    my $sample_ids = shift;
    switch($analysis){
        case "RNA" {
            $dbh->do('update Transcriptome set json_path = "'.$path.'"  where data_id ='. $dataid.";");
            $dbh->do('update Transcriptome set ref_assembly ='.$ref_assembly.'  where data_id = '.$dataid.';');
            $dbh->do('update Transcriptome set SRA_id ='.$sample_ids.'  where data_id = '.$dataid.';');
        }
        case "METH" {
            $dbh->do('update Epigenome_Meth set json_path = "'.$path.'"  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_Meth set ref_assembly = '.$ref_assembly.'  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_Meth set SRA_id ='.$sample_ids.'  where data_id = '.$dataid.';');

        }
        case "CHIP" {
            $dbh->do('update Epigenome_ChIP set json_path = "'.$path.'"  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_ChIP set ref_assembly = '.$ref_assembly.'  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_ChIP set SRA_id ='.$sample_ids.'  where data_id = '.$dataid.';');
        }
        case "HIC" {
            $dbh->do('update Epigenome_HiC set json_path = "'.$path.'"  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_HiC set ref_assembly = '.$ref_assembly.'  where data_id = '.$dataid.';');
            $dbh->do('update Epigenome_HiC set SRA_id ="'.$sample_ids.'"  where data_id = '.$dataid.';');
        }
    }
}
sub DATAID_update_del{
    my $dbh = shift;
    my $analysis = shift;
    my $dataid = shift;
    switch($analysis){
        case "RNA" {
            $dbh->do('delete from Transcriptome where data_id ='. $dataid.";");
        }
        case "METH" {
            $dbh->do('delete from  Epigenome_Meth where data_id = '.$dataid.';');

        }
        case "CHIP" {
            $dbh->do('delete from  Epigenome_ChIP where data_id = '.$dataid.';');
        }
        case "HIC" {
            $dbh->do('delete from Epigenome_HiC where data_id = '.$dataid.';');
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
sub SYN_DONE_abnormal{
    my $dbh = shift;
    my $synID = shift;
    $dbh->do('delete from synteny where synteny_id='+$synID);

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
        return $search_result[0]
    }
    
    my $new_sample_set_id = 0;
    $mysql_search_query = 'select max(sample_set_id) from sample_set_header ';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    @search_result = $sth->fetchrow_array();
    $new_sample_set_id = $search_result[0] + 1;

    $dbh->do('insert into sample_set_header (sample_set_id, single_species) values(?,1) ', ,undef, $new_sample_set_id);
    foreach my $thissample (@ar_sort){
        $dbh->do('insert into sample_set (sample_set_id, sample_id,species ) values (?, ?, ?)', ,undef,$new_sample_set_id, $thissample, $species);
    }
    
    return $new_sample_set_id;
}


sub EXISTSCHECK_THISCOMMAND{
    my $dbh = shift;
    my $analysis = shift;
    my $sample_set_id = shift;
    my $sample_set = shift;
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
    }
    #generate new dtaid 

    switch($analysis){
        case "RNA" {
            $mysql_search_query = 'select MAX(data_id) from Transcriptome';
        }
        case "METH" {
            $mysql_search_query = 'select MAX(data_id) from Epigenome_Meth';
        }
        case "CHIP" {
            $mysql_search_query = 'select MAX(data_id) from Epigenome_ChIP';
        }
        case "HIC" {
            $mysql_search_query = 'select MAX(data_id) from Epigenome_HiC';
        }
    }

    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my $new_data_id = 0;
    $new_data_id = $sth->fetchrow_array();
    $new_data_id ++;

    switch($analysis){
        case "RNA" {
            $dbh->do('insert into Transcriptome (data_id, data_type, sample_set_id,SRA_id) values(?,"profile",?,?)', ,undef,$new_data_id, $sample_set_id,$sample_set);
        }
        case "METH" {
            $dbh->do('insert into Epigenome_Meth (data_id, data_type, sample_set_id, SRA_id, param_score_min, param_N, param_L, param_mincov, param_minqual) values(?,"profile",?,?,?,?,?,?,?)', ,undef,$new_data_id, $sample_set_id,$sample_set, $parameters[0], $parameters[1], $parameters[2], $parameters[3], $parameters[4]);
        }
        case "CHIP" {
            $dbh->do('insert into Epigenome_ChIP (data_id, data_type, sample_set_id,SRA_id, param_bandwith, param_qcutoff) values(?,"profile",?,?,?,?)', ,undef,$new_data_id, $sample_set_id,$sample_set, $parameters[0], $parameters[1]);
        }
        case "HIC" {
            $dbh->do('insert into Epigenome_HiC (data_id, data_type, sample_set_id,SRA_id, param_binsize, param_bin_cnt, param_resolution) values(?,"profile",?,?,?,?,?)', ,undef,$new_data_id, $sample_set_id,$sample_set, $parameters[0], $parameters[1], $parameters[2]);
        }
    }

    return (0,$new_data_id);
}
sub  SEARCH_REF_ASSEMBLY_NAME {
    my $dbh = shift;
    my $species_tax = shift;
    
    $mysql_search_query = ' select name from taxon_id where taxon_id=?';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($species_tax);
    my ($spcName) = $sth->fetchrow_array();
    return $spcName;
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

sub MAIL_GEN{
    my $status = shift;
    my $synteny_id = shift;
    my $session_id = shift;
    my $job_id = shift;
    my $generatedID = shift;
    
    my $subject = "";
    my $message = "";
    if ($status == 0){
         $subject = "[IMDA] Issue During Job Processing";
         $message = "There was an issue during the processing of your job, leading to an abnormal termination.\n\nAccession: $synteny_id\nSession ID: $session_id\nJob ID: $job_id\n\nWe apologize for any inconvenience this may have caused.\nThank you for your understanding.\n\nIMDA";
    }
    if ($status == 1){ #work well
         $subject = "[IMDA] Job Completion Notification";
        if ($generatedID eq "-"){   # by JK
         $message = "Thank you for your patience!\nYour request has been successfully processed, and the job has been completed.\n\nThe analysis results you requested can be found at the link below:\nhttp://biweb.konkuk.ac.kr/IMDA/browser/genome.html?accession=$synteny_id\n\nThank you.\n\nIMDA";
        }else{
         $message = "Thank you for your patience!\nYour request has been successfully processed, and the job has been completed.\n\nThe analysis results you requested can be found at the link below:\nhttp://biweb.konkuk.ac.kr/IMDA/browser/genome.html?accession=$synteny_id\nThe generated track ID: $generatedID\n\nThank you.\n\nIMDA";
        
        }
    }

    return ($subject, $message);
}
sub REFRESH_DBH{
    my $dbh = shift;
    if ( not $dbh->ping ) {
        $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");
        $dbh->{mysql_auto_reconnect} = 1;
    }
    return $dbh;
}

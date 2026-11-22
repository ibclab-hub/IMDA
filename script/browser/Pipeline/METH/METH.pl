#!/usr/bin/perl


use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';
use FindBin '$Bin';

my $param = $ARGV[0];

my %hs_params_main = ();
my %hs_params_p = ();
my @ar_sample = ();

open(F,$param);
while(<F>){
    chomp;
    if ($_=~/^\s/){next;}
    if ($_=~/^#/){next;}
    my @ar_tmp = split(/\s+/,$_);

    if ($#ar_tmp == 1){
        if ($ar_tmp[0] eq "sample_name"){
			push(@ar_sample,$ar_tmp[1]);
			next;
		}
		$hs_params_main{$ar_tmp[0]} = $ar_tmp[1];
    }
    if ($#ar_tmp == 2){
        $hs_params_p{$ar_tmp[0]}{$ar_tmp[1]} = $ar_tmp[2];
    }
}
close(F);

$hs_params_main{'dir_out'} = abs_path($hs_params_main{'dir_out'});

my $PID = $$;
`echo $PID > $hs_params_main{'dir_out'}/pid.txt`;
my $f_log = $hs_params_main{'dir_out'}."/log.txt";

open(FW,">>$f_log");
#1 bismark per sample 
print FW "## Run bismark\n";
`mkdir -p $hs_params_main{'dir_out'}/MAP/`;
chdir "$hs_params_main{'dir_out'}/MAP/";
`cp $hs_params_main{'f_refFasta'} $hs_params_main{'dir_out'}/MAP/`;
$hs_params_main{'dir_assembly'} = $hs_params_main{'dir_out'}."/MAP/";

my($assembly_name, $Adir, $Asuffix) = fileparse($hs_params_main{'f_refFasta'},".fa");
`gzip  $hs_params_main{'dir_out'}/MAP/$assembly_name.fa`;
my $f_assembly = $assembly_name.".fa.gz";
#`mv $assembly_name.fna.gz $f_assembly`;
$hs_params_main{'f_refFasta'}  = "$hs_params_main{'dir_out'}/MAP/$f_assembly";

#bismark indexing 
my $cmd_bismark_idx = "$hs_params_main{'S1'}_genome_preparation  --parallel $hs_params_main{'global_threads'}  --bowtie2  $hs_params_main{'dir_assembly'} 2> ./bismark_index.log";

print FW "## bismark indexing \n";
close(FW);
open(FWC,">$hs_params_main{'dir_out'}/MAP/cmd_index");
print FWC "$cmd_bismark_idx\n";
close(FWC);
`bash $hs_params_main{'dir_out'}/MAP/cmd_index `;

open(FW,">> $f_log");
foreach my $samplename (@ar_sample){
	#print FW "## bismark alignment $samplename \n";
	print FW "## Mapping reads by bismark\n";   # by JK
	`mkdir -p   $hs_params_main{'dir_out'}/MAP/$samplename`;
	chdir "$hs_params_main{'dir_out'}/MAP/$samplename";
	my $cmd_bismark = "";
	if (exists($hs_params_p{$samplename}{'f_fastq2'})){
		$cmd_bismark = "$hs_params_main{'S1'} -p $hs_params_main{'global_threads'}  --score_min $hs_params_p{'S1'}{'score_min'} -N $hs_params_p{'S1'}{'N'}  -L $hs_params_p{'S1'}{'L'} --genome_folder $hs_params_main{'dir_assembly'} --output_dir  $hs_params_main{'dir_out'}/MAP/$samplename   --nucleotide_coverage  --path_to_bowtie $hs_params_p{'S1'}{'path_to_bowtie2'} --bowtie2 --samtools_path $hs_params_p{'S1'}{'samtools_path'} --multicore $hs_params_p{'S1'}{'multicore'} --temp_dir $hs_params_main{'dir_out'}/MAP/$samplename/temp -1 $hs_params_p{$samplename}{'f_fastq1'} -2 $hs_params_p{$samplename}{'f_fastq2'} 2>  $hs_params_main{'dir_out'}/MAP/$samplename/log.txt";

	}else{
		$cmd_bismark = "$hs_params_main{'S1'} -p $hs_params_main{'global_threads'}  --score_min $hs_params_p{'S1'}{'score_min'} -N $hs_params_p{'S1'}{'N'}  -L $hs_params_p{'S1'}{'L'} --genome_folder $hs_params_main{'dir_assembly'} --output_dir  $hs_params_main{'dir_out'}/MAP/$samplename   --nucleotide_coverage  --path_to_bowtie $hs_params_p{'S1'}{'path_to_bowtie2'} --bowtie2 --samtools_path $hs_params_p{'S1'}{'samtools_path'} --multicore $hs_params_p{'S1'}{'multicore'} --temp_dir $hs_params_main{'dir_out'}/MAP/$samplename/temp $hs_params_p{$samplename}{'f_fastq1'}  2>  $hs_params_main{'dir_out'}/MAP/$samplename/log.txt";
	
	}

    open(FWC ," > $hs_params_main{'dir_out'}/MAP/$samplename/cmd_bismark");
	print FWC "$cmd_bismark\n";
    close(FWC);
    `bash $hs_params_main{'dir_out'}/MAP/$samplename/cmd_bismark`;
	my $raw_bamout = `ls $hs_params_main{'dir_out'}/MAP/$samplename/*.bam`;
	chomp($raw_bamout);
	#1.1 bam process (1)
	print FW "## Alignment processing (1) \n";
    open(FWC ," > $hs_params_main{'dir_out'}/MAP/$samplename/cmd_process_bam1");
	my $cmd_bam1 = "$hs_params_main{'S2'} sort --threads $hs_params_main{'global_threads'} -n $raw_bamout | $hs_params_main{'S2'}  fixmate --threads $hs_params_main{'global_threads'} -m - - | $hs_params_main{'S2'} sort --threads $hs_params_main{'global_threads'} -o $hs_params_main{'dir_out'}/MAP/$samplename/$samplename.sorted.bam 2> $hs_params_main{'dir_out'}/MAP/$samplename/log.$samplename.sort.txt";
	print FWC $cmd_bam1."\n";
    close(FWC);
    `bash $hs_params_main{'dir_out'}/MAP/$samplename/cmd_process_bam1`;

	#1.2 bam process (2)
	print FW "## Alignment processing (2) \n";
	my $cmd_bam2 = "$hs_params_main{'S2'} markdup --threads $hs_params_main{'global_threads'} -r $hs_params_main{'dir_out'}/MAP/$samplename//$samplename.sorted.bam $hs_params_main{'dir_out'}/MAP/$samplename//$samplename.sorted.deduped.bam 2> $hs_params_main{'dir_out'}/MAP/$samplename/log.$samplename.dedu.txt";
    open(FWC ," > $hs_params_main{'dir_out'}/MAP/$samplename/cmd_process_bam2");
	print FWC $cmd_bam2."\n";
    close(FWC);
    `bash $hs_params_main{'dir_out'}/MAP/$samplename/cmd_process_bam2`

}

#1.3 Final bam set : merge if multisample and leave it if not
`mkdir -p $hs_params_main{'dir_out'}/MAP/Final/`;
chdir "$hs_params_main{'dir_out'}/MAP/Final/";

if (scalar(@ar_sample)>1){
	my $flist = `ls $hs_params_main{'dir_out'}/MAP/*/*.sorted.deduped.bam`;
	my @ar_flist = split(/\n/,$flist);
	$flist = join(" ",@ar_flist);
	
	my $cmd_merge = "$hs_params_main{'S2'} merge --threads $hs_params_main{'global_threads'} final.bam $flist";
    
	`$cmd_merge`;
}else{
	my $file = `ls $hs_params_main{'dir_out'}/MAP/*/*.sorted.deduped.bam`;
	chomp($file);
	`ln -s $file ./final.bam`;
}

my $final_bam="$hs_params_main{'dir_out'}/MAP/Final/final.bam";
#3 call
print FW "\n## MethylKit Methylation call\n";
`mkdir -p $hs_params_main{'dir_out'}/CALL/`;
chdir "$hs_params_main{'dir_out'}/CALL/";
my $cmd_call = "$hs_params_main{'S3'} --inBam=$final_bam --assembly=$hs_params_main{'f_refFasta'} --mincov=$hs_params_p{'S3'}{'mincov'} --minqual=$hs_params_p{'S3'}{'minqual'}  --rds $hs_params_main{'dir_out'}/CALL/$hs_params_main{'sample_set_name'}.RDS --logFile=$hs_params_main{'dir_out'}/CALL/log.$hs_params_main{'sample_set_name'}.txt";

print FW "## MethylKit profiling \n";
close(FW);
open(FWC,"> $hs_params_main{'dir_out'}/CALL/cmd_call");
print FWC "$cmd_call\n";
close(FWC);
`bash $hs_params_main{'dir_out'}/CALL/cmd_call `;

#4 call to Bed
my $final_result =  "$hs_params_main{'dir_out'}/CALL/final_CpG.txt";
chdir "$hs_params_main{'dir_out'}/";
`$Bin/bin/ProfileToBed.pl $final_result > meth.result.bed`;

#!/usr/bin/perl
#
#
use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';

my $param = shift;
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
			push (@ar_sample,$ar_tmp[1]);
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
#1 bwa mapping per sample 

print FW "\n## BWA Alignment \n";
`mkdir -p $hs_params_main{'dir_out'}/MAP/`;
chdir "$hs_params_main{'dir_out'}/MAP/";

my($assembly_name, $Adir, $Asuffix) = fileparse($hs_params_main{'f_refFasta'},".gz");
`cp $hs_params_main{'f_refFasta'} $hs_params_main{'dir_out'}/MAP/`;
$hs_params_main{'f_refFasta'}  = "$hs_params_main{'dir_out'}/MAP/$assembly_name$Asuffix";

my $f_assembly = $assembly_name.$Asuffix;
my $cmd_index = "$hs_params_main{'S1'} index $hs_params_main{'f_refFasta'} 2> $hs_params_main{'dir_out'}/MAP/bwa.index.log";

print FW "\n## BWA Indexing \n";
open(FWC,">$hs_params_main{'dir_out'}/MAP/cmd_index");
print FWC $cmd_index."\n";;
close(FWC);
`bash $hs_params_main{'dir_out'}/MAP/cmd_index`;

my $all_mapping_cmds = "";
foreach my $samplename (@ar_sample){
	print FW "\n## BWA alignment $samplename \n";
    `mkdir -p   $hs_params_main{'dir_out'}/MAP/$samplename`;
    chdir "$hs_params_main{'dir_out'}/MAP/$samplename";
	my $cmd_call = "";
	if (exists($hs_params_p{$samplename}{'f_fastq2'})){
		$cmd_call = "$hs_params_main{'S1'} mem -t $hs_params_p{'S1'}{'t'}  $hs_params_main{'f_refFasta'} $hs_params_p{$samplename}{'f_fastq1'} $hs_params_p{$samplename}{'f_fastq2'} -o $hs_params_main{'dir_out'}/MAP/$samplename/out.sam   2> $hs_params_main{'dir_out'}/MAP/$samplename/bwa.log";
	
	}else{ #single
		$cmd_call = "$hs_params_main{'S1'} mem -t $hs_params_p{'S1'}{'t'}  $hs_params_main{'f_refFasta'} $hs_params_p{$samplename}{'f_fastq1'} -o $hs_params_main{'dir_out'}/MAP/$samplename/out.sam   2> $hs_params_main{'dir_out'}/MAP/$samplename/bwa.log";

	}
	open(FWC , ">$hs_params_main{'dir_out'}/MAP/$samplename/cmd_map");
	print FWC $cmd_call."\n";
	close(FWC);
	`bash $hs_params_main{'dir_out'}/MAP/$samplename/cmd_map`;
	
	my $raw_sam = `ls $hs_params_main{'dir_out'}/MAP/$samplename/out.sam`;
	chomp($raw_sam);
	#1.1 bam process (1) sam -> sorted.bam
	my $cmd_bam1 = "$hs_params_main{'S2'} sort --threads $hs_params_p{'S1'}{'t'} -n $raw_sam | $hs_params_main{'S2'}  fixmate --threads $hs_params_p{'S1'}{'t'} -m - - | $hs_params_main{'S2'} sort --threads $hs_params_p{'S1'}{'t'} -o ./$samplename.sorted.bam 2> ./log.$samplename.sort.txt ";
	print FW "\n## Alignment processing (1)\n";
	`$cmd_bam1`;

	#1.2 bam process (2) sorted.bam -> sorted.dedup.bam 
	my $cmd_bam2 = "$hs_params_main{'S2'} markdup --threads $hs_params_p{'S1'}{'t'} -r $samplename.sorted.bam $samplename.sorted.deduped.bam";
	print FW "\n## Alignment processing (2)\n";
	`$cmd_bam2`;

}

#1.3 Final bam set: merge if multisample and leave it if not 
`mkdir -p $hs_params_main{'dir_out'}/MAP/Final/`;
chdir "$hs_params_main{'dir_out'}/MAP/Final/";

if (scalar(@ar_sample)>1){
    my $flist = `ls $hs_params_main{'dir_out'}/MAP/*/*.sorted.deduped.bam`;
    my @ar_flist = split(/\n/,$flist);
    $flist = join(" ",@ar_flist);

    my $cmd_merge = "$hs_params_main{'S2'} merge --threads $hs_params_p{'S1'}{'t'} final.bam $flist";
    print FW $cmd_merge."\n";
	`$cmd_merge`;
}else{
    my $file = `ls $hs_params_main{'dir_out'}/MAP/*/*.sorted.deduped.bam`;
    chomp($file);
    `ln -s $file ./final.bam`;
}



my $final_bam = "$hs_params_main{'dir_out'}/MAP/Final/final.bam";

#3 macs
print FW "\n## Peak calling with MACS2\n";
`mkdir -p $hs_params_main{'dir_out'}/CALL/`;
chdir "$hs_params_main{'dir_out'}/CALL/";
my $cmd_call_broad = "$hs_params_main{'S3'} callpeak -t $final_bam -f BAM --broad -g hs --bw $hs_params_p{'S3'}{'bandwidth'} -q $hs_params_p{'S3'}{'q_cutoff'}  -n $hs_params_main{'sample_set_name'}  2> log.macs2.broad" ;
print FW "## MACS profiling\n";
open(FWC,"> $hs_params_main{'dir_out'}/CALL/call_cmds");
print FWC "$cmd_call_broad\n";
close(FWC);
`bash $hs_params_main{'dir_out'}/CALL/call_cmds`;
#4 profile2json
my $result_broadPeak = "$hs_params_main{'dir_out'}/CALL/$hs_params_main{'sample_set_name'}_peaks.broadPeak";

chdir "$hs_params_main{'dir_out'}";
`cut -f1,2,3,6 $result_broadPeak > 1`;
`cut -f5 $result_broadPeak > 2`;
`paste 1 2 > chip.result.bed`;

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
			push(@ar_sample, $ar_tmp[1]);
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
#print FW "\n#### Multiomics analysis\n";
#print FW "\n### Transcriptome profiling\n";
print FW "\n## Mapping with STAR\n";
`mkdir -m 777 -p $hs_params_main{'dir_out'}/STAR/`;
chdir "$hs_params_main{'dir_out'}/STAR/";
`cp $hs_params_main{'f_refFasta'} $hs_params_main{'dir_out'}/STAR/`;
`cp $hs_params_main{'f_annotation'} $hs_params_main{'dir_out'}/STAR/`;

my($assembly_name, $Adir, $Asuffix) = fileparse($hs_params_main{'f_refFasta'});
my($annotation_name, $Adir2, $Asuffix2) = fileparse($hs_params_main{'f_annotation'});

$hs_params_main{'f_refFasta'}  = "$hs_params_main{'dir_out'}/STAR/$assembly_name";
$hs_params_main{'f_annotation'}  = "$hs_params_main{'dir_out'}/STAR/$annotation_name";

my $maxreadlen = $hs_params_p{'S3'}{'sjdbOverhang'}+1;
my $cmd_star_index = "$hs_params_main{'S3'}  --runThreadN $hs_params_p{'S3'}{'runThreadN'} --runMode genomeGenerate  --genomeDir $hs_params_main{'dir_out'}/STAR/ --genomeFastaFiles $hs_params_main{'f_refFasta'} --sjdbGTFfile $hs_params_main{'f_annotation'} --sjdbOverhang $hs_params_p{'S3'}{'sjdbOverhang'}  2> $hs_params_main{'dir_out'}/STAR/$assembly_name.star.index.$maxreadlen.log";

print FW "\n## STAR indexing \n";
close(FW);

open(FWC,"> $hs_params_main{'dir_out'}/STAR/CMD_STARindex");
print FWC $cmd_star_index."\n";
close(FWC);
`bash $hs_params_main{'dir_out'}/STAR/CMD_STARindex`;

#1.2 Mapping per sample
open (FW,">> $f_log"); 
my $mapping_cmds = "";
foreach my $samplename (@ar_sample){
	print FW "## STAR alignment $samplename \n";
	`mkdir -m 777 -p $hs_params_main{'dir_out'}/STAR/$samplename`;
	chdir "$hs_params_main{'dir_out'}/STAR/$samplename";
	my $cmd_star = "";
	if (exists($hs_params_p{$samplename}{'f_fastq2'})){
        if ($hs_params_p{$samplename}{'f_fastq1'} =~ /\.gz\z/) {  # by JK
		    $cmd_star = "$hs_params_main{'S3'} --runThreadN $hs_params_p{'S3'}{'runThreadN'} --outSAMunmapped Within --outSAMattributes NH HI AS NM MD --genomeDir $hs_params_main{'dir_out'}/STAR/  --readFilesIn $hs_params_p{$samplename}{'f_fastq1'} $hs_params_p{$samplename}{'f_fastq2'} --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM   2> $hs_params_main{'dir_out'}/STAR/$samplename/star.log";
        } else {
		    $cmd_star = "$hs_params_main{'S3'} --runThreadN $hs_params_p{'S3'}{'runThreadN'} --outSAMunmapped Within --outSAMattributes NH HI AS NM MD --genomeDir $hs_params_main{'dir_out'}/STAR/  --readFilesIn $hs_params_p{$samplename}{'f_fastq1'} $hs_params_p{$samplename}{'f_fastq2'} --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM   2> $hs_params_main{'dir_out'}/STAR/$samplename/star.log";
        }
	}else{
        if ($hs_params_p{$samplename}{'f_fastq1'} =~ /\.gz\z/) {  # by JK
		    $cmd_star = "$hs_params_main{'S3'} --runThreadN $hs_params_p{'S3'}{'runThreadN'} --outSAMunmapped Within --outSAMattributes NH HI AS NM MD --genomeDir $hs_params_main{'dir_out'}/STAR/  --readFilesIn $hs_params_p{$samplename}{'f_fastq1'} --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM   2> $hs_params_main{'dir_out'}/STAR/$samplename/star.log";
        } else {
		    $cmd_star = "$hs_params_main{'S3'} --runThreadN $hs_params_p{'S3'}{'runThreadN'} --outSAMunmapped Within --outSAMattributes NH HI AS NM MD --genomeDir $hs_params_main{'dir_out'}/STAR/  --readFilesIn $hs_params_p{$samplename}{'f_fastq1'} --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM   2> $hs_params_main{'dir_out'}/STAR/$samplename/star.log";

        }
	}
	open(FWC,">$hs_params_main{'dir_out'}/STAR/$samplename/CMD_star_map");
	print FWC "$cmd_star\n";
	close(FWC);
	`bash $hs_params_main{'dir_out'}/STAR/$samplename/CMD_star_map `;
	$mapping_cmds .= $cmd_star."\n";
}
close(FW);


#1.3 Final bam set : merge if multisample and leave it if not 
`mkdir -m 777 -p $hs_params_main{'dir_out'}/STAR/Final/`;
chdir "$hs_params_main{'dir_out'}/STAR/Final/";

if (scalar(@ar_sample)>1){
	my $flist = `ls $hs_params_main{'dir_out'}/STAR/*/Aligned.toTranscriptome.out.bam`;
	my @ar_flist = split(/\n/,$flist);
	$flist=join(" ",@ar_flist);
	#my $cmd_merge = "$hs_params_main{'S4'} merge final.bam $flist";
	my $cmd_merge = "$hs_params_main{'S6'} merge --threads $hs_params_p{'S3'}{'p'} final.bam $flist";   # by JK
	`$cmd_merge`;
}else{ #single sample 
	 my $file = `ls $hs_params_main{'dir_out'}/STAR/*/Aligned.toTranscriptome.out.bam`; 
	 chomp ($file);
	 
	 `ln  -s $file ./final.bam`;
}
my $final_bam = "$hs_params_main{'dir_out'}/STAR/Final/final.bam";

#2 RSEM
open(FW,">>$f_log");
print FW "## Read count estimation with RSEM\n";
`mkdir -m 777 -p $hs_params_main{'dir_out'}/ReadCount/`;
chdir "$hs_params_main{'dir_out'}/ReadCount/";

my $cmd_readcount_pre = "$hs_params_main{'S4'}  --gtf $hs_params_main{'f_annotation'} --star --star-path  /programs/bin/  -p $hs_params_p{'S2'}{'p'} $hs_params_main{'f_refFasta'}  $hs_params_main{'dir_out'}/ReadCount/$assembly_name  2> $hs_params_main{'dir_out'}/ReadCount/log_pre_$assembly_name";
print FW "## Run RSEM preprocessing \n";
close(FW);
open(FWC,"> $hs_params_main{'dir_out'}/ReadCount/cmd_rc_pre");
print FWC "$cmd_readcount_pre\n";
close(FWC);
`bash $hs_params_main{'dir_out'}/ReadCount/cmd_rc_pre `;
my $cmd_readcount = ""; 

if(exists($hs_params_p{$ar_sample[0]}{'f_fastq2'})){
	$cmd_readcount = "$hs_params_main{'S5'} -p $hs_params_p{'S3'}{'p'}  -alignments $final_bam --paired-end   $hs_params_main{'dir_out'}/ReadCount/$assembly_name  $hs_params_main{'sample_set_name'}  2> $hs_params_main{'dir_out'}/ReadCount/log.rsem.$hs_params_main{'sample_set_name'}";
}else{
	$cmd_readcount = "$hs_params_main{'S5'} -p $hs_params_p{'S3'}{'p'}  --alignments $final_bam   $hs_params_main{'dir_out'}/ReadCount/$assembly_name  $hs_params_main{'sample_set_name'}  2> $hs_params_main{'dir_out'}/ReadCount/log.rsem.$hs_params_main{'sample_set_name'}";
 
}
open(FW,">>$f_log");
print FW "## Run RSEM ";
close(FW);
open(FWC,">$hs_params_main{'dir_out'}/ReadCount/cmd_rc");
print FWC $cmd_readcount ."\n";
close(FWC);
`bash $hs_params_main{'dir_out'}/ReadCount/cmd_rc`;

#3 Convert to bed

my $final_output =  `ls $hs_params_main{'dir_out'}/ReadCount/*genes.results`;
chomp($final_output);
chdir "$hs_params_main{'dir_out'}/";
`perl $Bin/bin/RSEMToBed.pl $final_output $hs_params_main{'f_annotation'} > RNA.result.bed`;
`touch done`;




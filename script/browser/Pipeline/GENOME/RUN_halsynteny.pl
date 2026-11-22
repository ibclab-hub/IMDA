#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Cwd 'abs_path';
use FindBin '$Bin';
use Getopt::Long qw(:config no_ignore_case);

my %hs_param = ();
my $f_param = shift;
open(F,"$f_param");
while(<F>){
    chomp;
    if ($_ =~ /^$/){next;}
    my @ar_split = split(/\s+/,$_);
    $hs_param{$ar_split[0]} = $ar_split[1];
}
close(F);

my $outdir = $hs_param{"outdir"};
my $ref_fa = $hs_param{"ref_fa"};
my $tar_fa = $hs_param{"tar_fa"};
my $chain = $hs_param{"chain"};
my $tar = $hs_param{"tar"};
my $ref = $hs_param{"ref"};
my $resolution = $hs_param{"resolution"};

if ($tar eq $ref){
    $tar .="_1";
}
`mkdir -p -m777  $outdir`;
#preprocess 
`$Bin/bin/faToTwoBit $ref_fa $outdir/ref.2bit  2> $hs_param{"outdir"}/log.txt`;
`$Bin/bin/faToTwoBit $tar_fa $outdir/tar.2bit 2> $hs_param{"outdir"}/log.txt`;

`$Bin/bin/faSize -detailed $ref_fa > $outdir/ref.size 2>> $hs_param{"outdir"}/log.txt`;
`$Bin/bin/faSize -detailed $tar_fa > $outdir/tar.size 2>> $hs_param{"outdir"}/log.txt`;

`$Bin/bin/chainNet $chain $outdir/ref.size $outdir/tar.size $outdir/ref.net $outdir/tar.net 2>> $hs_param{"outdir"}/log.txt`;
`$Bin/bin/netToAxt $outdir/ref.net $chain $outdir/ref.2bit $outdir/tar.2bit $outdir/ref.tar.axt 2>> $hs_param{"outdir"}/log.txt`;
`$Bin/bin/axtToMaf $outdir/ref.tar.axt $outdir/ref.size $outdir/tar.size $outdir/ref.tar.maf -qPrefix=$tar. -tPrefix=$ref.  2>> $hs_param{"outdir"}/log.txt`;
`$Bin/bin/mafToPsl $ref $tar $outdir/ref.tar.maf  $outdir/all.psl 2>> $hs_param{"outdir"}/log.txt`;

#run halsynteny
`halSynteny --queryGenome $tar --targetGenome $ref --minBlockSize $resolution --alignmentIsPsl $outdir/all.psl $outdir/out.synteny.psl 2> $outdir/log.halsynteny.txt`;

#json
my $json_config = $outdir."/json_config"; 
open(F,">$json_config");
print F "SF=$outdir/out.synteny.psl\n";
print F "Ref=$ref\n";
print F "Size=$ref:$outdir/ref.size\n";
print F "Size=$tar:$outdir/tar.size\n";
close(F);
`$Bin/bin/psl2json_addorder_cs.pl  $outdir/json_config > $outdir/synteny.json`;



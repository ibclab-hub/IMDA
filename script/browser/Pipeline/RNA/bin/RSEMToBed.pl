#!/usr/bin/perl

#gene_id	transcript_id(s)	length	effective_length	expected_count	TPM  FPKM
#ENSSSCG00000000002	ENSSSCT00000000003	2393.00	2181.34	41.00	1.24	0.78
#ENSSSCG00000000003	ENSSSCT00000000004,ENSSSCT00000052628,ENSSSCT00000064304     2246.54	2034.88	800.00	26.00	16.38


use strict;
use warnings;

my $f_in = shift;
my $f_annot_info = shift;

my %hs_gene_pos = ();
open(F,"$f_annot_info");
while(<F>){
    chomp;
    if ($_=~/^#/){next;}
    my @ar_tmp = split(/\t/,$_);
    if ($ar_tmp[2] ne "gene"){next;}
    my $chr = $ar_tmp[0];
    my $start = $ar_tmp[3];
    my $end = $ar_tmp[4];
    my $info = $ar_tmp[8];
    my @ar_info = split(/;/,$info);
    my ($tmp, $geneid,$tmp2) = split(/"/,$ar_info[0]);
    $hs_gene_pos{$geneid} = "$chr;$start;$end";
    #print STDERR "$geneid\t$chr;$start;$end";
}
close(F);
my $first = 0;
open(F,"$f_in");
while(<F>){
    chomp;
    if ($_ =~ /^gene/){next;}
    my @ar_tmp = split(/\t/,$_);
    my $geneid = $ar_tmp[0];
    my $TPM = $ar_tmp[5];
	if (!exists $hs_gene_pos{$geneid}){next;}
    my ($chr, $start, $end) = split(/;/,$hs_gene_pos{$geneid});
    print "$chr\t$start\t$end\t$geneid\t$TPM\n";
}
close(F);

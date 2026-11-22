#!/usr/bin/perl
#
use strict;
use warnings;
use JSON;

my $path = shift;

my $data_format = "$path/file_format.txt";
my $data_path = "$path/merged.diff.out";
my $meta_path = "$path/merged.diff.perc";

my %cutoff = ();
if(-f $meta_path){
    open(RF, $meta_path);
    while(<RF>){
        chomp;
        my ($perc, $min, $max, $avg) = split(/\s+/);
        $cutoff{$perc}{"max"} = $max + 0;
        $cutoff{$perc}{"min"} = $min + 0;
        $cutoff{$perc}{"avg"} = $avg + 0;
    }
    close RF;
}

my $format = "";
open(RF, $data_format);
while(<RF>){
    chomp;
    $format = $_;
}
close RF;

my @dat = ();
open(RF, $data_path);
while(<RF>){
    my ($spcchr, $start, $end, $name, $val, $spcchr1, $start1, $end1, $spcchr2, $start2, $end2);
    my ($spc, $chr, $spc1, $chr1, $spc2, $chr2);
    if($format eq "bed"){
        ($spcchr, $start, $end, $name, $val) = split(/\s+/);
        ($spc, $chr) = split(/&\^&/, $spcchr);
    }elsif($format eq "bedpe"){
        ($spcchr1, $start1, $end1, $spcchr2, $start2, $end2, $name, $val) = split(/\s+/);
        ($spc1, $chr1) = split(/&\^&/, $spcchr1);
        ($spc2, $chr2) = split(/&\^&/, $spcchr2);
    }
    
    my ($min, $max, $avg, $pval, $qval) = split(/,/, $val);
    $start += 1;
    
    if($min ne "."){
        $min += 0;
    }
    if($max ne "."){
        $max += 0;
    }
    if($avg ne "."){
        $avg += 0;
    }
    if($pval ne "."){
        $pval += 0; 
    }
    if($qval ne "."){
        $qval += 0;
    }

    my %newdat;
    if($format eq "bed"){
        %newdat = ("spc" => $spc, "chr" => $chr, "start" => $start, "end" => $end, "name" => $name, "min" => $min, "max" => $max, "avg" => $avg, "pval" => $pval, "qval" => $qval);
    }else{
        %newdat = ("spc1" => $spc1, "chr1" => $chr1, "start1" => $start1, "end1" => $end1, "spc2" => $spc2, "chr2" => $chr2, "start2" => $start2, "end2" => $end2, "name" => $name, "min" => $min, "max" => $max, "avg" => $avg, "pval" => $pval, "qval" => $qval);
    }
    
    push(@dat, \%newdat);
}
close RF;

my %data_with_meta = ();
$data_with_meta{"cutoff"} = \%cutoff;
$data_with_meta{"value"} = \@dat;

print JSON->new->pretty->encode(\%data_with_meta);

#!/usr/bin/perl

use strict;
use warnings;
use JSON;

my $config = shift;

my $sf_f = "";
my %size_f = ();
my $ref = "";
my $tar = "";
open(RF, $config);
while(<RF>){
	chomp;

	my ($key, $val) = split(/=/);
	if($key eq "SF"){
		$sf_f = $val;
	} elsif ( $key eq "Ref" ){
		$ref = $val;
	} elsif ( $key eq "Size" ){
		my ($spc, $file) = split(/:/, $val);
		$size_f{$spc} = $file;
        if ($ref ne $spc){
            $tar = $spc;
        }
	}
}
close RF;

my %cvrg_all = (); ## cvrg
my %chrs;
foreach my $spc (keys %size_f){
	my @sizes = ();
	open(RF, $size_f{$spc});
	while(<RF>){
		chomp;
		my ($chr, $size) = split(/\s+/);
		$cvrg_all{$spc} += $size; ##cvrg
		my %newchr = ( "name"=> $chr, "len"=> $size+0 );
		push(@sizes, \%newchr);
	}
	close RF;

	$chrs{$spc} = \@sizes;
}

my $id = 1;
my @order;
my @sfs;
my %pos = ();
my %cvrg_syn = ();
open(RF, $sf_f);
while(<RF>){
	chomp;

	%pos = ();
	my @col = split(/\t/,$_);
    my $dir = $col[8];
    my $ref_chr = $col[9];
    my $ref_st = $col[11];
    my $ref_ed = $col[12];
    $cvrg_syn{$ref} += $ref_ed - $ref_st ;
    my $tar_chr = $col[13];
    my $tar_st = $col[15];
    my $tar_ed = $col[16];
    $cvrg_syn{$tar} += $tar_ed - $tar_st ;

    my %curpos = (
        "chr" => $ref_chr,
        "dir" => "+",
        "end" => $ref_ed + 0,
        "start" => $ref_st + 0
    );
    $pos{$ref} = \%curpos; 
    
    my %curpos2 = (
        "chr" => $tar_chr,
        "dir" => $dir,
        "end" => $tar_ed + 0,
        "start" => $tar_st + 0
    );
    $pos{$tar} = \%curpos2;

    my %newpos = %pos;
    my %newsf;
    $newsf{"id"} = $id;
    $newsf{"pos"} = \%newpos;
    push(@sfs, \%newsf);

    $id ++;
}
close RF;
my %hs_cvrg = ();
foreach my $spc (keys %cvrg_syn){
	my $cov = $cvrg_syn{$spc}/$cvrg_all{$spc};
	$hs_cvrg{$cov} = $spc;
}
push (@order, $ref);
foreach my $thiscov (sort {$a <=> $b} keys %hs_cvrg){
	if ($hs_cvrg{$thiscov} eq $ref){next;}
	push(@order, $hs_cvrg{$thiscov});
}


my %dat = (
	"species" => \@order,
	"chr" => \%chrs,
	"sf" => \@sfs,
	#"ref" => $ref
);

print JSON->new->pretty->encode(\%dat);

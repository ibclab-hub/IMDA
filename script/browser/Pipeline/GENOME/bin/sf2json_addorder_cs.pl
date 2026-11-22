#!/usr/bin/perl

use strict;
use warnings;
use JSON;

my $config = shift;

my $sf_f = "";
my %size_f = ();
my $ref = "";

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

my $id = "";
my @order;
my @sfs;
my %pos = ();
my %cvrg_syn = ();
open(RF, $sf_f);
while(<RF>){
	chomp;

	if($_ =~ /^>/){
		$id = substr($_, 1);
		%pos = ();
	}elsif($_ eq ""){
		if(${$pos{$ref}}{"dir"} eq "-"){
			foreach my $spc (keys %pos){
				${$pos{$spc}}{"dir"} = (${$pos{$spc}}{"dir"} eq "+")? "-" : "+";
			}
		}

		my %newpos = %pos;
		
		my %newsf;
		$newsf{"id"} = $id;
		$newsf{"pos"} = \%newpos;
		push(@sfs, \%newsf);
	}else{
		my @col = split(/[:|\s]+/);
		
		my @spc_chr = split(/\./, $col[0]);
		my $spc = shift @spc_chr;
		my $chr = join(".", @spc_chr);
		
		my ($beg, $end) = split(/-/, $col[1]);
		my $dir = $col[2];

		my %curpos = (
			"chr" => $chr,
			"dir" => $dir,
			"end" => $end + 0,
			"start" => $beg + 0
		);
		$cvrg_syn{$spc} += ($end-$beg);
		$pos{$spc} = \%curpos; 
	}		
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

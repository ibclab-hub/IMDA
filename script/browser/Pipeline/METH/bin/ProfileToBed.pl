#!/usr/bin/perl
#

use strict;
use warnings;

my $f_profile = shift;
open(F,"$f_profile");
while(<F>){
	chomp;
	if ($_ =~ /^chrBase/){next;}
	my @ar_tmp = split(/\t/,$_);
	my $chr = $ar_tmp[1];
	my $st = $ar_tmp[2]-1;
	my $ed = $ar_tmp[2];
	my $value = $ar_tmp[5]/100;
	print "$chr\t$st\t$ed\t.\t$value\n";
}
close(F);



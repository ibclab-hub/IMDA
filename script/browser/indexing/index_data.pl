#!/usr/bin/perl

use strict;
use warnings;

my $data_f = shift;
my $index_res = shift;

my $bin_num = 0;
my ($pre_chr, $pre_s, $pre_ptr) = ("", 0, 0, 0);
open(F, $data_f);
my $ptr = tell(F);
while(<F>) {
	chomp;
	my ($chr, $s, $e, $val) = split(/\s+/);
	if ($pre_chr ne "" && $pre_chr ne $chr) {
		print "$pre_chr\t$pre_s\t$ptr\n";
		$bin_num = 0;
	}
	my $bin_pos = $bin_num * $index_res;

	if ($bin_pos == 0 || ($s+1<=$bin_pos && $bin_pos<=$e)) {
		print "$chr\t$s\t$ptr\n";
		$bin_num ++;
	} 

	($pre_chr, $pre_s) = ($chr, $s);
	$ptr = tell(F);
}
close(F);

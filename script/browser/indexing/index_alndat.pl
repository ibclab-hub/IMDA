#!/usr/bin/perl

use strict;
use warnings;

my $bedpe_f = shift;
my $id_gap = shift;

my $pre_id = 0;
open(F, $bedpe_f);
my $ptr = tell(F);
while(<F>) {
	chomp;
	my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $id, $dir1, $dir2) = split(/\s+/);
	if ($pre_id == 0 || $id >= $pre_id + $id_gap) {
		print "$id\t$ptr\n";
		$pre_id = $id;
	}
	$ptr = tell(F);
}
close(F);

#!/usr/bin/perl

use strict;
use warnings;
no warnings 'recursion';
use FindBin '$Bin';

my $data_dir = shift;
my $res = shift;
my $bedpe_f = shift;
my $out_f = shift;

my %spc_ids = ();
my %node_ids = ();
my %graph = ();

my $id = 1;
open(F, $bedpe_f);
while(<F>) {
	chomp;
	if ($_ eq "") { next; }
	my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $score, $dir1, $dir2) = split(/\s+/);
	my ($spc1, $spc2) = split(/:/, $name);
	my ($id1, $id2) = ($id, $id+1);
	
	$spc_ids{$spc1}{$id1} = $dir2;
	$spc_ids{$spc2}{$id2} = $dir2;
	$node_ids{$id1}{'pos'} = "$chr1:$s1-$e1";
	$node_ids{$id2}{'pos'} = "$chr2:$s2-$e2";
	$graph{$id1}{$id2} = "$spc1:$spc2";
	$graph{$id2}{$id1} = "$spc2:$spc1";

	$id += 2;
}
close(F);

foreach my $spc (keys %spc_ids) {
	my @ids = sort sort_id keys %{$spc_ids{$spc}};
	for (my $i=0; $i<=$#ids; $i++) {
		for (my $j=$i+1; $j<=$#ids; $j++) {
			my ($c1, $s1, $e1) = split(/:|-/, $node_ids{$ids[$i]}{'pos'});
			my ($c2, $s2, $e2) = split(/:|-/, $node_ids{$ids[$j]}{'pos'});
			if ($c1 ne $c2 || ($c1 eq $c2 && $s2 > $e1)) { last; }
			if ($c1 eq $c2 && ($e1 >= $s2+1 && $s1+1 <= $e2) ) {
				$graph{$ids[$i]}{$ids[$j]} = undef;
				$graph{$ids[$j]}{$ids[$i]} = undef;
			}
		}
	}
}

my $cc_id = 1;
foreach my $node (keys %graph) {
	if (!exists $node_ids{$node}{'cc'}) {
		DFS(\%graph, $node, $cc_id);
	}
	$cc_id ++;
}

foreach my $spc (keys %spc_ids) {
	`mkdir -p $data_dir/$spc`;
	my $out_fn = ($res == 1) ? "$data_dir/$spc/raw_1.$spc.align_id.bed" : "$data_dir/$spc/res_$res.$spc.align_id.bed";
	open(W, ">$out_fn");
	foreach my $id (sort sort_id keys %{$spc_ids{$spc}}) {
		my ($chr, $s, $e) = split(/:|-/, $node_ids{$id}{'pos'});
		print W "$chr\t$s\t$e\t$node_ids{$id}{'cc'}\t.\t$spc_ids{$spc}{$id}\n";
	}
	close(W);
	my $idx_res = $res * 50000;
	`perl $Bin/index_data.pl $out_fn $idx_res > $out_fn.idx`;
}

open(W, ">$out_f");
foreach my $n1 (sort sort_cc keys %graph) {
	foreach my $n2 (sort sort_cc keys %{$graph{$n1}}) {
		if (defined $graph{$n1}{$n2}) {
			my ($spc1, $spc2) = split(/:/, $graph{$n1}{$n2});
			my ($c1, $s1, $e1) = split(/:|-/, $node_ids{$n1}{'pos'});
			my ($c2, $s2, $e2) = split(/:|-/, $node_ids{$n2}{'pos'});
			my $dir2 = $spc_ids{$spc2}{$n2};
			print W "$c1\t$s1\t$e1\t$c2\t$s2\t$e2\t$graph{$n1}{$n2}\t$node_ids{$n1}{'cc'}\t+\t$dir2\n";
			$graph{$n2}{$n1} = undef;
		}
	}
}
close(W);
`perl $Bin/index_alndat.pl $out_f 1000 > $out_f.idx`;

sub DFS {
	my $_graph = shift;
	my $_node = shift;
	my $_cc_id = shift;

	$node_ids{$_node}{'cc'} = $_cc_id;
	foreach my $_node2 (keys %{$$_graph{$_node}}) {
		if (!exists $node_ids{$_node2}{'cc'}){
			DFS($_graph, $_node2, $_cc_id);
		}
	}
}


sub sort_id {
	my $a_pos = $node_ids{$a}{'pos'};
	my $b_pos = $node_ids{$b}{'pos'};

	my ($chr_a, $s_a, $e_a) = split(/:|-/, $a_pos);
	my ($chr_b, $s_b, $e_b) = split(/:|-/, $b_pos);
	my $chr_cmp = $chr_a cmp $chr_b;

	if ($chr_cmp == -1) { 
		return -1;
	} elsif ($chr_cmp == 1) {
		return 1;
	} else {
		if ($s_a < $s_b) {
			return -1;
		} else {
			return 1;
		}
	}
}

sub sort_cc {
	my $a_cc = $node_ids{$a}{'cc'};
	my $b_cc = $node_ids{$b}{'cc'};

	if ($a_cc < $b_cc) {
		return -1;
	} else {
		return 1;
	}
}

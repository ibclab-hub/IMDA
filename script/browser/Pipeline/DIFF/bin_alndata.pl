#!/usr/bin/perl

use strict;
use warnings;
no warnings 'recursion';
use POSIX;

my $data_f = shift;
my $res = shift;
my $cutoff = shift;

my %out = ();
my %ovl_len = ();
open(F, $data_f);
while(<F>) {
	chomp;
	my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $id, $dir1, $dir2) = split(/\s+/);
	my ($spc1, $spc2) = split(/:/, $name);
	my $s1_bin = ceil(($s1+1)/$res); my $e1_bin = ceil($e1/$res);
	my $s2_bin = ceil(($s2+1)/$res); my $e2_bin = ceil($e2/$res);
	my @tar1_flks = (); my @tar2_flks = ();
	my @tar1_bdrs = (); my @tar2_bdrs = ();

	for (my $bin=$s1_bin; $bin<=$e1_bin; $bin++) {
		my $e = $bin*$res;
		if ($s1+1 <= $e && $e <= $e1) { 
			push(@tar1_flks, $e); 
			push(@tar1_bdrs, $e);
			my $tar2_flk = ($dir2 eq "+") ? $s2+($e-$s1) : $e2-($e-$s1)+1;
			push(@tar2_flks, $tar2_flk);
		} 
	}
	for (my $bin=$s2_bin; $bin<=$e2_bin; $bin++) {
		my $e = ($dir2 eq "+") ? $bin*$res : ($bin*$res)+1;
		if ($s2+1 <= $e && $e <= $e2) { 
			push(@tar2_flks, $e); 
			push(@tar2_bdrs, $e);
			my $tar1_flk = ($dir2 eq "+") ? $s1+($e-$s2) : $e1-($e-$s2)+1;
			push(@tar1_flks, $tar1_flk);
		}
	}

	if (scalar(@tar1_flks) == 0 && scalar(@tar2_flks) == 0) {
		$out{"$spc1:$chr1"}{$s1_bin}{"$spc2:$chr2"}{$s2_bin} += ($dir2 eq "+") ? $e1-$s1 : ($e1-$s1)*(-1);
		$ovl_len{"$spc1:$chr1"}{$s1_bin}{"$spc2:$chr2"}{$s2_bin}{$spc1} += ($e1-$s1);
		$ovl_len{"$spc1:$chr1"}{$s1_bin}{"$spc2:$chr2"}{$s2_bin}{$spc2} += ($e2-$s2);
	} else {
		push(@tar1_flks, $e1);
		@tar1_flks = sort {$a<=>$b} @tar1_flks;

		if ($dir2 eq "+") {
			push(@tar2_flks, $e2);
			@tar2_flks = sort {$a<=>$b} @tar2_flks;
		} else {
			push(@tar2_flks, $s2+1);
			@tar2_flks = reverse sort {$a<=>$b} @tar2_flks;
		}

		my $flk_s1 = $s1 + 1;
		my $flk_s2 = ($dir2 eq "+") ? $s2+1 : $e2;
		for (my $i=0; $i<=$#tar1_flks; $i++) {
			my $aln_len = $tar1_flks[$i] - $flk_s1 + 1;
			my $aln_len2 = abs($tar2_flks[$i] - $flk_s2) + 1;
			my ($aln_bin1, $aln_bin2) = (ceil($tar1_flks[$i]/$res), ceil($tar2_flks[$i]/$res));
			$out{"$spc1:$chr1"}{$aln_bin1}{"$spc2:$chr2"}{$aln_bin2} += ($dir2 eq "+") ? $aln_len : $aln_len*(-1);
			$ovl_len{"$spc1:$chr1"}{$aln_bin1}{"$spc2:$chr2"}{$aln_bin2}{$spc1} += $aln_len;
			$ovl_len{"$spc1:$chr1"}{$aln_bin1}{"$spc2:$chr2"}{$aln_bin2}{$spc2} += $aln_len;
			($flk_s1, $flk_s2) = ($tar1_flks[$i], $tar2_flks[$i]);
		}
	}
}
close(F);

my %maxovl_bins = ();
foreach my $chr1 (sort keys %out) {
	my ($spc1, $chr1_n) = split(/:/, $chr1);
	foreach my $bin1 (sort {$a<=>$b} keys %{$out{$chr1}}) {
		my ($s1, $e1) = (($bin1-1)*$res, $bin1*$res);
		my ($max_spc2, $max_chr2, $max_bin2, $max_dir, $max_ovl) = ("", "", "","",0);
		foreach my $chr2 (sort keys %{$out{$chr1}{$bin1}}) {
			my ($spc2, $chr2_n) = split(/:/, $chr2);
			foreach my $bin2 (sort {$a<=>$b} keys %{$out{$chr1}{$bin1}{$chr2}}) {
				my $spc1_alnlen = $ovl_len{$chr1}{$bin1}{$chr2}{$bin2}{$spc1};
				my $spc2_alnlen = $ovl_len{$chr1}{$bin1}{$chr2}{$bin2}{$spc2};
				my $filt_cutoff = $res * $cutoff;
				if ($spc1_alnlen >= $filt_cutoff) {
					if (! exists $maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'}) {
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'} = $spc1_alnlen;
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'dir'} = ($out{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'bin'} = $bin2;
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'chr'} = $chr2_n;
					} elsif ($spc1_alnlen > $maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'}) {
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'} = $spc1_alnlen;
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'dir'} = ($out{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'bin'} = $bin2;
						$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'chr'} = $chr2_n;
					}
					if (! exists $maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'}) {
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'} = $spc2_alnlen;
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'dir'} = ($out{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'bin'} = $bin1;
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'chr'} = $chr1_n;
					} elsif ($spc2_alnlen > $maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'}) {
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'} = $spc2_alnlen;
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'dir'} = ($out{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'bin'} = $bin1;
						$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'chr'} = $chr1_n;
					}
				}
			}
		}
	}
}

my %spc_ids = ();
my %node_ids = ();
my %graph = ();
my $id = 1;

my @tar_spcs = sort keys (%maxovl_bins);
for (my $i=0; $i<$#tar_spcs; $i++) {
	for (my $j=$i+1; $j<=$#tar_spcs; $j++) {
		my ($spc1, $spc2) = ($tar_spcs[$i], $tar_spcs[$j]);
		foreach my $chr1 (sort keys %{$maxovl_bins{$spc1}}) {
			foreach my $bin1 (sort keys %{$maxovl_bins{$spc1}{$chr1}}) {
				if(! exists $maxovl_bins{$spc1}{$chr1}{$bin1}{$spc2}){ next; }

				my $bin2 = $maxovl_bins{$spc1}{$chr1}{$bin1}{$spc2}{'bin'};
				my $chr2 = $maxovl_bins{$spc1}{$chr1}{$bin1}{$spc2}{'chr'};

				my $tar_bin1 = $maxovl_bins{$spc2}{$chr2}{$bin2}{$spc1}{'bin'};
				my $tar_chr1 = $maxovl_bins{$spc2}{$chr2}{$bin2}{$spc1}{'chr'};

				if ($tar_bin1 == $bin1 && $tar_chr1 eq $chr1) {
					my ($s1, $e1) = (($bin1-1)*$res, $bin1*$res);
					my ($s2, $e2) = (($bin2-1)*$res, $bin2*$res);
					my $dir = $maxovl_bins{$spc1}{$chr1}{$bin1}{$spc2}{'dir'};
					#print "$chr1\t$s1\t$e1\t$chr2\t$s2\t$e2\t$spc1:$spc2\t.\t+\t$dir\n";

					my ($id1, $id2) = ($id, $id+1);
					$spc_ids{$spc1}{$id1} = $dir;
					$spc_ids{$spc2}{$id2} = $dir;
					$node_ids{$id1}{'pos'} = "$chr1:$s1-$e1";
					$node_ids{$id2}{'pos'} = "$chr2:$s2-$e2";
					$graph{$id1}{$id2} = "$spc1:$spc2";
					$graph{$id2}{$id1} = "$spc2:$spc1";

					$id+=2;
				}
			}
		}
	}
}

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

foreach my $n1 (sort sort_cc keys %graph) {
    foreach my $n2 (sort sort_cc keys %{$graph{$n1}}) {
        if (defined $graph{$n1}{$n2}) {
            my ($spc1, $spc2) = split(/:/, $graph{$n1}{$n2});
            my ($c1, $s1, $e1) = split(/:|-/, $node_ids{$n1}{'pos'});
            my ($c2, $s2, $e2) = split(/:|-/, $node_ids{$n2}{'pos'});
            my $dir2 = $spc_ids{$spc2}{$n2};
            print "$c1\t$s1\t$e1\t$c2\t$s2\t$e2\t$graph{$n1}{$n2}\t$node_ids{$n1}{'cc'}\t+\t$dir2\n";
            $graph{$n2}{$n1} = undef;
        }
    }
}


########################################################################################################

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


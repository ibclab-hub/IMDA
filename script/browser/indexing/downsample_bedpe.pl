#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
use POSIX;
use FindBin '$Bin';

my $data_dir = shift;
$data_dir = abs_path($data_dir);
my $size_f = shift;
my $data_f = shift;
my $raw_res = shift;
my $bedpe_n = shift;

my $g_size = 0;
my %chr_size = ();
open(F, $size_f);
while(<F>) {
    chomp;
    my ($chr, $size) = split(/\s+/);
    $chr_size{$chr} = $size;
    $g_size += $size;
}
close(F);

my @resolutions = ();
my %out = ();
my $min_res = 50;
my $max_res = (int(($g_size / 3000)/3000)+1) * 3000;
if ($g_size < 3000 || $max_res < $min_res) {
    print STDERR "$g_size\t$max_res\n";
    print STDERR "# Skip data separation.. Genome size is small enough to visualize!\n";
    exit;
} else {
    my $res = $min_res;
    while ($res < $max_res) {
        if ($res > $raw_res) {
            push(@resolutions, $res);
        }
        $res = ($res * 3000) / 200;
    }
    push(@resolutions, $max_res);

	open(F, $data_f);
	while(<F>) {
		chomp;
		my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $score, $dir1, $dir2) = split(/\s+/);
		my ($spc1, $spc2) = ("", "");
		if ($name =~ /(\S+):(\S+)/) { $spc1 = $1; $spc2 = $2; }
		if ($spc1 eq $spc2) {
			foreach my $res (@resolutions) {
				my $s1_bin = ceil(($s1+1)/$res); my $e1_bin = ceil($e1/$res);
				if ($s1_bin > $e1_bin) {
					my $tmp = $s1_bin; $s1_bin = $e1_bin; $e1_bin = $tmp;
				}
				my $s2_bin = ceil(($s2+1)/$res); my $e2_bin = ceil($e2/$res);
				if ($s2_bin > $e2_bin) {
					my $tmp = $s2_bin; $s2_bin = $e2_bin; $e2_bin = $tmp;
				}
				for (my $i=$s1_bin; $i<=$e1_bin; $i++) {
					for (my $j=$s2_bin; $j<=$e2_bin; $j++) {
						if ($chr1 eq $chr2 && $i > $j) { next; }
						if (exists $out{$chr1}{$i}{$chr2}{$j}) {
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'sum'} += $score;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'cnt'} ++;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'min'} = ($out{$chr1}{$i}{$chr2}{$j}{'min'} > $score) ? $score : $out{$chr1}{$i}{$chr2}{$j}{'min'};
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'max'} = ($out{$chr1}{$i}{$chr2}{$j}{'max'} < $score) ? $score : $out{$chr1}{$i}{$chr2}{$j}{'max'};
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'min_dir1'} = ($out{$chr1}{$i}{$chr2}{$j}{'min'} > $score) ? $dir1 : $out{$chr1}{$i}{$chr2}{$j}{'min_dir1'};
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'max_dir1'} = ($out{$chr1}{$i}{$chr2}{$j}{'max'} < $score) ? $dir1 : $out{$chr1}{$i}{$chr2}{$j}{'max_dir1'};
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'min_dir2'} = ($out{$chr1}{$i}{$chr2}{$j}{'min'} > $score) ? $dir2 : $out{$chr1}{$i}{$chr2}{$j}{'min_dir2'};
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'max_dir2'} = ($out{$chr1}{$i}{$chr2}{$j}{'max'} < $score) ? $dir2 : $out{$chr1}{$i}{$chr2}{$j}{'max_dir2'};
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'dir1'} += ($dir1 eq "+") ? 1 : -1;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'dir2'} += ($dir2 eq "+") ? 1 : -1;
						} else {
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'sum'} = $score;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'cnt'} = 1;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'min'} = $score;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'max'} = $score;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'min_dir1'} = $dir1;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'max_dir1'} = $dir1;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'min_dir2'} = $dir2;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'max_dir2'} = $dir2;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'avg_dir1'} = ($dir1 eq "+") ? 1 : -1;
							$out{$res}{$chr1}{$i}{$chr2}{$j}{'avg_dir2'} = ($dir2 eq "+") ? 1 : -1;
						}
					}
				}
			}
		} else {
			foreach my $res (@resolutions) {
				my $s1_bin = ceil(($s1+1)/$res); my $e1_bin = ceil($e1/$res);
				my $s2_bin = ceil(($s2+1)/$res); my $e2_bin = ceil($e2/$res);
				my $bin_n1 = $e1_bin - $s1_bin + 1;
				my $bin_n2 = $e2_bin - $s2_bin + 1;

				if ($bin_n1 != $bin_n2) {
					my $f_len = ($bin_n1 > $bin_n2) ? abs(($s1_bin*$res) - $s1) : abs(($s2_bin*$res) - $s2);
					my $b_len = ($bin_n1 > $bin_n2) ? abs($e1 - (($e1_bin-1)*$res)) : abs($e2 - (($e2_bin-1)*$res));
					if ($bin_n1 > $bin_n2) {
						$s1_bin = ($f_len < $b_len) ? $s1_bin + 1 : $s1_bin;
						$e1_bin = ($f_len < $b_len) ? $e1_bin : $e1_bin -1;
					} else {
						$s2_bin = ($f_len < $b_len) ? $s2_bin + 1 : $s2_bin;
						$e2_bin = ($f_len < $b_len) ? $e2_bin : $e2_bin -1;
					}
				}
				
				for (my $i=0; $i<=($e1_bin - $s1_bin + 1); $i++) {
					my $aln_bin = ($dir2 eq "+") ? $s2_bin+$i : $e2_bin-$i;
					if (exists $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}) {
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'sum'} += $score;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'cnt'} ++;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min'} = ($out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min'} > $score) ? $score : $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min'};
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max'} = ($out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max'} < $score) ? $score : $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max'};
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min_dir1'} = ($out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min'} > $score) ? $dir1 : $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min_dir1'};
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max_dir1'} = ($out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max'} < $score) ? $dir1 : $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max_dir1'};
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min_dir2'} = ($out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min'} > $score) ? $dir2 : $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min_dir2'};
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max_dir2'} = ($out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max'} < $score) ? $dir2 : $out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max_dir2'};
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'dir1'} += ($dir1 eq "+") ? 1 : -1;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'dir2'} += ($dir2 eq "+") ? 1 : -1;
					} else {
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'sum'} = $score;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'cnt'} = 1;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min'} = $score;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max'} = $score;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min_dir1'} = $dir1;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max_dir1'} = $dir1;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'min_dir2'} = $dir2;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'max_dir2'} = $dir2;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'avg_dir1'} = ($dir1 eq "+") ? 1 : -1;
						$out{$res}{"$spc1:$chr1"}{$s1_bin+$i}{"$spc2:$chr2"}{$aln_bin}{'avg_dir2'} = ($dir2 eq "+") ? 1 : -1;
					}

				}
			}
		}
	}
	close(F);
}
	

foreach my $res (@resolutions) {
	my ($spc1, $spc2) = ("","");
	open(W, ">$data_dir/res_$res.$bedpe_n");
	foreach my $chr1 (sort keys %{$out{$res}}) {
		my $chr1_n = $chr1;
		if ($chr1 =~ /(\S+):(\S+)/) { $spc1 = $1; $chr1_n = $2; }
		foreach my $bin1 (sort {$a<=>$b} keys %{$out{$res}{$chr1}}) {
			my ($bin1_s, $bin1_e) = (($bin1-1)*$res, $bin1*$res);
			foreach my $chr2 (sort keys %{$out{$res}{$chr1}{$bin1}}) {
				my $chr2_n = $chr2;
				if ($chr2 =~ /(\S+):(\S+)/) { $spc2 = $1; $chr2_n = $2; }
				foreach my $bin2 (sort {$a<=>$b} keys %{$out{$res}{$chr1}{$bin1}{$chr2}}) {
					my ($bin2_s, $bin2_e) = (($bin2-1)*$res, $bin2*$res);
					my ($ds_min, $ds_max, $ds_avg) = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'min'}, $out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'max'}, $out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'sum'}/$out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'cnt'});
					my $name = ($spc1 ne $spc2) ? "$spc1:$spc2" : ".";
					my ($min_dir1, $min_dir2) = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'min_dir1'}, $out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'min_dir2'});
					my ($max_dir1, $max_dir2) = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'max_dir1'}, $out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'max_dir2'});
					my $avg_dir1 = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'avg_dir1'} >= 0) ? "+" : "-";
					my $avg_dir2 = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2}{'avg_dir2'} >= 0) ? "+" : "-";
					print W "$chr1_n\t$bin1_s\t$bin1_e\t$chr2_n\t$bin2_s\t$bin2_e\t$name\t$ds_min,$ds_max,$ds_avg\t$min_dir1,$max_dir1,$avg_dir1\t$min_dir2,$max_dir2,$avg_dir2\n";
				}
			}
		}
	}
	close(W);
	my $idx_res = $res * 50000;
	`perl $Bin/index_data.pl $data_dir/res_$res.$bedpe_n $idx_res > $data_dir/res_$res.$bedpe_n.idx`;

}

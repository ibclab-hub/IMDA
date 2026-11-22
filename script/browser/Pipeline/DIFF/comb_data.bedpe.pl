#!/usr/bin/perl

use strict;
use warnings;
use POSIX;

my $spc_n = shift;
my $size_f = shift;
my $data_f = shift;
my $tar_res = shift;

my %chr_size = ();
open(F, $size_f);
while(<F>) {
	chomp;
	my ($chr, $size) = split(/\s+/);
	$chr_size{$chr} = $size;
}
close(F);

my $s_data_ref = &_Split_data($data_f, $tar_res);
my %splitted_data = %{$s_data_ref} ;

foreach my $chr1 (sort keys %splitted_data) {
    foreach my $tbin1 (sort {$a<=>$b} keys %{$splitted_data{$chr1}}) {
        my ($tbin1_s, $tbin1_e) = (($tbin1-1)*$tar_res, $tbin1*$tar_res);
        foreach my $chr2 (sort keys %{$splitted_data{$chr1}{$tbin1}}) {
            foreach my $tbin2 (sort {$a<=>$b} keys %{$splitted_data{$chr1}{$tbin1}{$chr2}}) {
                my ($tbin2_s, $tbin2_e) = (($tbin2-1)*$tar_res, $tbin2*$tar_res);
                my ($ds_min, $ds_max, $ds_avg) = ($splitted_data{$chr1}{$tbin1}{$chr2}{$tbin2}{'min'}, $splitted_data{$chr1}{$tbin1}{$chr2}{$tbin2}{'max'}, $splitted_data{$chr1}{$tbin1}{$chr2}{$tbin2}{'sum'}/$splitted_data{$chr1}{$tbin1}{$chr2}{$tbin2}{'cnt'});
                print "$spc_n&^&$chr1\t$tbin1_s\t$tbin1_e\t$spc_n&^&$chr2\t$tbin2_s\t$tbin2_e\t.\t$ds_min,$ds_max,$ds_avg,.,.\n";
                
            }
        }
    }
}

#######################################################################################

sub _Split_data {
	my $_data_path = shift;
	my $_res = shift;

    my %_ds_data = ();
    open(F, $data_f);
    while(<F>) {
        chomp;
        my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $score, $dir1, $dir2) = split(/\s+/);
        my ($spc1, $spc2) = ("", "");
        if ($name =~ /(\S+):(\S+)/) { $spc1 = $1; $spc2 = $2; }
        my $s1_bin = ceil(($s1+1)/$_res); my $e1_bin = ceil($e1/$_res);
        if ($s1_bin > $e1_bin) {
            my $tmp = $s1_bin; $s1_bin = $e1_bin; $e1_bin = $tmp;
        }
        my $s2_bin = ceil(($s2+1)/$_res); my $e2_bin = ceil($e2/$_res);
        if ($s2_bin > $e2_bin) {
            my $tmp = $s2_bin; $s2_bin = $e2_bin; $e2_bin = $tmp;
        }
        for (my $i=$s1_bin; $i<=$e1_bin; $i++) {
            for (my $j=$s2_bin; $j<=$e2_bin; $j++) {
                if ($chr1 eq $chr2 && $i > $j) { next; }
                if (exists $_ds_data{$chr1}{$i}{$chr2}{$j}) {
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'sum'} += $score;
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'cnt'} ++;
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'min'} = ($_ds_data{$chr1}{$i}{$chr2}{$j}{'min'} > $score) ? $score : $_ds_data{$chr1}{$i}{$chr2}{$j}{'min'};
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'max'} = ($_ds_data{$chr1}{$i}{$chr2}{$j}{'max'} < $score) ? $score : $_ds_data{$chr1}{$i}{$chr2}{$j}{'max'};
                } else {
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'sum'} = $score;
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'cnt'} = 1;
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'min'} = $score;
                    $_ds_data{$chr1}{$i}{$chr2}{$j}{'max'} = $score;
                }
            }
        }
    }
    return \%_ds_data;
}

#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';
use Sort::Key::Natural 'natsort';
use FindBin '$Bin';

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
my %splitted_data = %{ $s_data_ref} ;

foreach my $chr (natsort keys %splitted_data) {
	foreach my $tar_bin (sort {$a<=>$b} keys %{$splitted_data{$chr}{$tar_res}}) {
		my ($ds_min, $ds_max, $ds_avg) = ($splitted_data{$chr}{$tar_res}{$tar_bin}{'min'}, $splitted_data{$chr}{$tar_res}{$tar_bin}{'max'}, $splitted_data{$chr}{$tar_res}{$tar_bin}{'sum'}/$splitted_data{$chr}{$tar_res}{$tar_bin}{'cnt'});
		my $bin_e = $tar_bin * $tar_res;
		my $bin_s = $bin_e - $tar_res;
		$bin_e = ($chr_size{$chr} < $bin_e) ? $chr_size{$chr} : $bin_e;
		print "$spc_n&^&$chr\t$bin_s\t$bin_e\t.\t$ds_min,$ds_max,$ds_avg,.,.\n";
	}
}

#######################################################################################

sub _Split_data {
	my $_data_path = shift;
	my $_res = shift;

	my %_ds_data = ();
	open(D, $_data_path);
	while(<D>) {
		chomp;
		my @cols = split(/\s+/);
		my ($_chr, $_start, $_end, $_name, $_val) = split(/\s+/);
		my $_start_bin = int($_start / $_res) + 1;
		my $_end_bin = int( ($_end - 1) / $_res) + 1;
		for (my $_i=$_start_bin; $_i <= $_end_bin; $_i++) {
			if (exists $_ds_data{$_chr}{$_res}{$_i}) {
				$_ds_data{$_chr}{$_res}{$_i}{'sum'} += $_val;
				$_ds_data{$_chr}{$_res}{$_i}{'cnt'} ++;
				$_ds_data{$_chr}{$_res}{$_i}{'max'} = ($_ds_data{$_chr}{$_res}{$_i}{'max'} < $_val) ? $_val : $_ds_data{$_chr}{$_res}{$_i}{'max'};
				$_ds_data{$_chr}{$_res}{$_i}{'min'} = ($_ds_data{$_chr}{$_res}{$_i}{'min'} > $_val) ? $_val : $_ds_data{$_chr}{$_res}{$_i}{'min'};
			} else {
				$_ds_data{$_chr}{$_res}{$_i}{'sum'} = $_val;
				$_ds_data{$_chr}{$_res}{$_i}{'cnt'} = 1;
				$_ds_data{$_chr}{$_res}{$_i}{'max'} = $_val;
				$_ds_data{$_chr}{$_res}{$_i}{'min'} = $_val;
			}

			if ($_name ne ".") {
				if (exists $_ds_data{$_chr}{$_res}{$_i}{'n'}) {
					$_ds_data{$_chr}{$_res}{$_i}{'n'} .= "|$_name";
				} else {
					$_ds_data{$_chr}{$_res}{$_i}{'n'} = $_name;
				}
			}
		}
	}
	close(D);

	return \%_ds_data;
}

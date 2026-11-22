#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';
use Sort::Key::Natural 'natsort';
use FindBin '$Bin';


my $data_dir = shift;
$data_dir = abs_path($data_dir);
my $size_f = shift;
my $data_f = shift;
my $raw_res = shift;
my $orig_n = shift;

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
my $min_res = 50;
my $max_res = (int(($g_size / 10000)/10000)+1) * 10000;
if ($g_size < 10000 || $max_res < $min_res) {
	print STDERR "$g_size\t$max_res\n";
	print STDERR "# Skip data separation.. Genome size is small enough to visualize!\n";
	exit;
} else {
	my $res = $min_res;
	while ($res < $max_res) {
		if ($res > $raw_res) {
			push(@resolutions, $res);
		}
		$res = ($res * 10000) / 200;
	}
	push(@resolutions, $max_res);
	print STDERR "# Resolutions for data separation\n## ";
	print STDERR join "\t", @resolutions, "\n";
	print STDERR "# Downsampling data using target resolutions..\n";
	my $s_data_ref = &_Split_data($data_f, \@resolutions);
	my %splitted_data = %{ $s_data_ref} ;

	foreach my $tar_res (@resolutions) {
		my $file_n = "$data_dir/res_$tar_res.$orig_n";
		print STDERR "## Writing downsampled data using $tar_res resolution...\n";
		open(W, ">$file_n");
		foreach my $chr (natsort keys %splitted_data) {
			foreach my $tar_bin (sort {$a<=>$b} keys %{$splitted_data{$chr}{$tar_res}}) {
				my ($ds_min, $ds_max, $ds_avg) = ($splitted_data{$chr}{$tar_res}{$tar_bin}{'min'}, $splitted_data{$chr}{$tar_res}{$tar_bin}{'max'}, $splitted_data{$chr}{$tar_res}{$tar_bin}{'sum'}/$splitted_data{$chr}{$tar_res}{$tar_bin}{'cnt'});
				my $bin_e = $tar_bin * $tar_res;
				my $bin_s = $bin_e - $tar_res;
				$bin_e = ($chr_size{$chr} < $bin_e) ? $chr_size{$chr} : $bin_e;
				my $name = (exists $splitted_data{$chr}{$tar_res}{$tar_bin}{'n'}) ? $splitted_data{$chr}{$tar_res}{$tar_bin}{'n'} : "." ;
				print W "$chr\t$bin_s\t$bin_e\t$name\t$ds_min,$ds_max,$ds_avg\n";
			}
		}
		close(W);
		print STDERR "## Generate index file for $file_n\n";
		my $index_res = $tar_res * 50000;
		`$Bin/index_data.pl $file_n $index_res > $file_n.idx`;
	}
}


###################################################################################3

sub _Split_data {
	my $_data_path = shift;
	my $_res_arr = shift;

	my %_ds_data = ();
	open(D, $_data_path);
	while(<D>) {
		chomp;
		my ($_chr, $_start, $_end, $_name, $_val) = split(/\t/);
		foreach my $_res (@{$_res_arr}) {
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
	}
	close(D);

	return \%_ds_data;
}

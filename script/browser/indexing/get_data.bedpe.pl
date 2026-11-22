#!/usr/bin/perl

use strict;
use warnings;
use JSON;
use File::Basename;
use FindBin '$Bin';

my $project_n = shift;
my $data_n = shift;
my $summ_type = shift;
my @ranges = @ARGV;

if ($summ_type ne "min" && $summ_type ne "max" && $summ_type ne "avg" && $summ_type ne "na") {
	print "Check summary type $summ_type\n";
    exit;
}

## Calculate the size of regions for visualization
my $vis_regions = 0;
foreach my $range (@ranges) {
    my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
    $vis_regions += ($qend - $qbeg);
}

## Choose an appropriate resolution for called ranges
my $data_dir = "$Bin/test/$project_n/$data_n";
#my $data_dir = "$Bin/../data/$project_n/$data_n";
#my $data_dir = "/mss_ds/project/denovo2_pipe/DATA/Multiomics/$project_n/$data_n";
if (! -d $data_dir ) {
	print "No directory for $data_dir\n";
	exit;
}

opendir(DIR, $data_dir);
my @ds_datas = grep { (/^res_/ || /^raw_/) && !/\.idx$/ && -f "$data_dir/$_" } readdir(DIR);
close DIR;

my $max_res = 0;
my $max_res_f = "";

my $ds_res = 3000;
my $tar_res = "+inf";
my $bedpe_f = "";

foreach my $ds_data (@ds_datas) {
    if ($ds_data =~ /(^raw_|res_)(\d+)\./) {
        my $res = $2;
		if ($summ_type eq "na" && $ds_data =~ /^raw/) {
			$tar_res = $res;
			$bedpe_f = "$data_dir/$ds_data";
			last;
		}
        if ($vis_regions < $res*$ds_res && $tar_res > $res) {
            $tar_res = $res;
            $bedpe_f = "$data_dir/$ds_data";
        }
		if ($max_res < $res) {
			$max_res = $res;
			$max_res_f = "$data_dir/$ds_data";
		}
    }
}
if ($bedpe_f eq "") { $bedpe_f = $max_res_f; }
my $index_f = $bedpe_f . ".idx";

#####################################################################

my @out_bins_ar = ();
my $id = 1;

foreach my $range (@ranges) {
	my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
	my $beg_ptr = -1;
	
	open(F, $index_f);
	while(<F>) {
		chomp;
		my ($chr, $s, $ptr) = split(/\s+/);
		$s = $s+1;
		if ($qchr ne $chr) { next; }
		if ($s <= $qend) { $beg_ptr = $ptr; last; }
		elsif ($beg_ptr == -1) { $beg_ptr = $ptr; }
	}
	close(F);

	if ($beg_ptr != -1) {
		open(RF, "<", $bedpe_f);
		seek(RF, $beg_ptr, 0);
		while(<RF>) {
			chomp;
			my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $score, $dir1s, $dir2s) = split(/\s+/);
			my ($spc1, $spc2) = split(/:/, $name);
			$s1++; $s2++;
			if ($chr1 ne $qchr) { last; } 
			if ($s1 > $qend && $e1 > $qend) { last; }
			my $reg2_check = &check_range(\@ranges, $chr2, $s2, $e2);
			if ($reg2_check == 0) { next; }
			if ($e1 < $qbeg) { next; } 

            my $val = $score;
			if ($score =~ /,/) {
				my ($min, $max, $avg) = split(/,/, $score);
            	if ($summ_type eq "min" ) { $val = $min; }
            	elsif ($summ_type eq "max" ) { $val = $max; }
            	elsif ($summ_type eq "avg" ) { $val = $avg; }
			}

			my $dir1 = $dir1s; my $dir2 = $dir2s;
			if ($dir1s =~ /,/) {
				my ($min1, $max1, $avg1) = split(/,/, $dir1s);
				my ($min2, $max2, $avg2) = split(/,/, $dir2s);
				if ($summ_type eq "min") { $dir1 = $min1; $dir2 = $min2; }
				elsif ($summ_type eq "max") { $dir1 = $max1; $dir2 = $max2; }
				elsif ($summ_type eq "avg") { $dir1 = $avg1; $dir2 = $avg2; }
			}

			my %bin1_info = ("chr" => $chr1, "start" => $s1, "end" => $e1, "id" => $id, "dir" => $dir1, "value" => $val);
   	        my %bin2_info = ("chr" => $chr2, "start" => $s2, "end" => $e2, "id" => $id, "dir" => $dir2, "value" => $val);
			push(@out_bins_ar, \%bin1_info);
			push(@out_bins_ar, \%bin2_info);
			$id ++;
		}	
		close(RF);
	}
}

my $out_json = \@out_bins_ar;
print JSON->new->pretty->encode(\@out_bins_ar);

sub check_range {
	my $_ranges = shift;
	my $_chr = shift;
	my $_s = shift;
	my $_e = shift;

	my $check = 0;

	foreach my $_range (@$_ranges) {
		my ($_r_chr, $_r_s, $_r_e) = split(/:|-/, $_range);
		if ($_chr ne  $_r_chr) { next; }
		if ($_s <= $_r_e && $_e >= $_r_s) {
			$check = 1; 
			return $check;
		}
	}

	return $check;
}


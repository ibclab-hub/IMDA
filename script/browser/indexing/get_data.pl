#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use FindBin '$Bin';
use JSON;

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
my $data_dir = "$Bin/../data/$project_n/$data_n";
if (! -d $data_dir ) {
    print "No directory for $data_dir\n";
    exit;
}
opendir(DIR, $data_dir);
my @ds_datas = grep { ((/^res_/ || /^raw_/) && !/\.idx$/) && -f "$data_dir/$_" } readdir(DIR);
close DIR;

my $ds_res = 10000;
my $tar_res = "+inf";
my $data_f = "";

foreach my $ds_data (@ds_datas) {
	if ($ds_data =~ /(^raw_|res_)(\d+)\./) {
		my $res = $2;
		if ($summ_type eq "na" && $ds_data =~ /^raw/) {
			$tar_res = $res;
			$data_f = "$data_dir/$ds_data";
			last;
		} elsif ($vis_regions < $res*$ds_res && $tar_res > $res) {
			$tar_res = $res;
			$data_f = "$data_dir/$ds_data";
		}
	}
}
my $index_f = $data_f . ".idx";

############################################################

my %out_bins_hs = ();
my @out_bins = ();

foreach my $range (@ranges) {
	my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
	my $beg_ptr = -1;
	my $check = 0;
	$qbeg = ($qbeg - $tar_res > 0) ? $qbeg - $tar_res : 1;	## include one bin before target bin
	
	open(F, $index_f);
	while(<F>) {
		chomp;
		my ($chr, $s, $ptr) = split(/\s+/);
		$s = $s+1;
		if ($qchr ne $chr) { next; }
		if ($s <= $qbeg) { $beg_ptr = $ptr; last; }
		elsif ($beg_ptr == -1) { $beg_ptr = $ptr; }
	}
	close(F);

	if ($beg_ptr != -1) {
		my $end_check = 0;
		open(RF, "<", $data_f);
		seek(RF, $beg_ptr, 0);
		while(<RF>) {
			chomp;
			my ($chr, $s, $e, $name, $vals) = split(/\s+/);
			$s+=1;
			my $val = $vals;
			if ($vals =~ /,/) {
				my ($min, $max, $avg) = split(/,/, $vals);
				if ($summ_type eq "min" ) { $val = $min; }
				elsif ($summ_type eq "max" ) { $val = $max; }
				elsif ($summ_type eq "avg" ) { $val = $avg; }
			} 

			if ($chr ne $qchr) { last; }
			if ($s < $qbeg && $e < $qbeg) {
				next;
			} elsif ($end_check == 1) {
				last;
			} else {
				my %bin_info = ();
				my $bin_check = "";
				if ($e - $s == 0) {
					%bin_info = ("chr"=>$chr, "pos"=>$e, "value"=>$val);
					$bin_check = "$chr:$e:$val";
				} else {
					%bin_info = ("chr"=>$chr, "start"=>$s, "end"=>$e, "value"=>$val);
					$bin_check = "$chr:$s:$e:$val";
				}
				if (!exists $out_bins_hs{$bin_check}) {
					push(@out_bins, \%bin_info);
					$out_bins_hs{$bin_check} = "";
				}
				if ($s > $qend && $e > $qend) {
					$end_check = 1;
				}
			}
		}
		close(RF);
	}
}

print JSON->new->pretty->encode(\@out_bins);
#my $out_json = "[".join(",", @out_bins)."]";
#my $out_json = "[$out_bins]";
#print $out_json, "\n";

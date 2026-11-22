#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use FindBin '$Bin';
use JSON;

my $data_dir = shift;
my $summ_type = shift;	##min_len for gene annot
my @ranges = @ARGV;

## Get data type for raw data
my $data_type = "";
my $data_n = basename($data_dir);
if (! -f "$data_dir/file_format.txt") {
	print "__ERROR__ No file format info file\n";
	exit;
}
open(F, "$data_dir/file_format.txt");
while(<F>) {
	chomp;
	$data_type = $_;
}
close(F);

## Calculate the size of regions for visualization
my $vis_regions = 0;
foreach my $range (@ranges) {
	my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
	$vis_regions += ($qend - $qbeg);
}

## Choose an appropriate resolution for called ranges
if (! -d $data_dir ) {
    print "__ERROR__ No directory for $data_dir\n";
    exit;
}

my $data_f = "";
my $index_f = "";
my $tar_res = "+inf";
if ($data_type eq "gtf" || $data_type eq "gff") {
	opendir(DIR, "$data_dir");
	my @ds_datas = grep { (/\.gtf$/ || /\.gff$/) && -f "$data_dir/$_" } readdir(DIR);
	close DIR;
	$data_f = "$data_dir/$ds_datas[0]";
	$index_f = "$data_f.idx";
} else {

	if ($summ_type ne "min" && $summ_type ne "max" && $summ_type ne "avg" && $summ_type ne "na") {
		print "__ERROR__ Check summary type $summ_type\n";
		exit;
	}

	my $ds_res = ($data_type eq "bedpe") ? 3000 : 10000;

	opendir(DIR, $data_dir);
	my @ds_datas = grep { ((/^res_/ || /^raw_/) && !/\.idx$/) && -f "$data_dir/$_" } readdir(DIR);
	close DIR;

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
	$index_f = $data_f . ".idx";
}



############################################################

my @out_bins = ();
my %out_bins_hs = ();

if ($data_type eq "gtf" || $data_type eq "gff") {
    #my $min_len = $summ_type;
    my $min_len = ($summ_type eq "na") ? 0 : $summ_type;
    my %chr_ptr = ();
    open(FI, $index_f);
    while(<FI>) {
        chomp;
        my ($chr, $ptr) = split(/\s+/);
        $chr_ptr{$chr} = $ptr;
    }
    close(FI);

    my $gene_idx = 0;
    foreach my $range (@ranges) {
        my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
        my $include = 0;
        open(F, "<", $data_f);
        seek(F, $chr_ptr{$qchr}, 0);
        while(<F>) {
            chomp;
            if ($_ =~ /^#/) { next; }
            if ($_ eq "") { next; }

            my @cols = split(/\s+/, $_);
            my ($chr, $type, $start, $end, $dir) = ($cols[0], $cols[2], $cols[3], $cols[4], $cols[6]);

            if ($chr ne $qchr) { last; }

            if ($type eq "gene") {
                if ($start > $qend) { last; }
                if (($end-$start+1) < $min_len) {
                    $include = 0;
                    next;
                }
                if ($qbeg <= $end && $qend >= $start) {
                    $_ =~ /gene_id "(\S+)"; /;
                    my @exon_arr = ();
                    my %gene_info = ("id"=>$1, "chr"=>$chr, "start"=>$start, "end"=>$end, "direction" => $dir, "exon"=>\@exon_arr);
                    push(@out_bins, \%gene_info);
                    $gene_idx ++;
                    $include = 1;
                } else {
                    $include = 0;
                }
            } elsif ($type eq "exon") {
                if ($include == 1 && $summ_type eq "na") {
                    my $id = "";
                    if ($_ =~ /exon_id "(\S+)"; /) {
                        $id = $1;
                    } elsif ($_ =~ /exon_number "(\S+)";/) {
                        $id = $1;
                    } else {
                        $id = "NA";
                    }
                    my %exon_info = ("id"=>$id, "start"=>$start, "end"=>$end);
                    my $ref= $out_bins[$gene_idx-1];
                    my @tar_exon_arr = @{$$ref{'exon'}};
                    push(@tar_exon_arr, \%exon_info);
                    $$ref{'exon'} = \@tar_exon_arr;
                }
            } else { next; }
        }
        close(F);
    }

} elsif ($data_type eq "bedpe") {
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
        	open(RF, "<", $data_f);
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
            	push(@out_bins, \%bin1_info);
            	push(@out_bins, \%bin2_info);
            	$id ++;
        	}
        	close(RF);
    	}
	}	
} else {
	foreach my $range (@ranges) {
	    my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
	    my $beg_ptr = -1;
	    my $check = 0;
		$qbeg = ($qbeg - $tar_res > 0) ? $qbeg - $tar_res : 1;  ## include one bin before target bin

		my $pre_ptr = "";
	
	    open(F, $index_f);
	    while(<F>) {
	        chomp;
	        my ($chr, $s, $ptr) = split(/\s+/);
	        $s = $s+1;
	        if ($qchr ne $chr) { next; }
	        if ($s <= $qbeg) { 
				$beg_ptr = ($pre_ptr eq "") ? $ptr : $pre_ptr; 
				last; 
			}
	        elsif ($beg_ptr == -1) { $beg_ptr = $ptr; }
			$pre_ptr = $ptr;
	    }
	    close(F);
	
		my %pre_bin = ();
	    if ($beg_ptr != -1) {
	        my $end_check = 0;
	        open(RF, "<", $data_f);
	        seek(RF, $beg_ptr, 0);
	        while(<RF>) {
	            chomp;
	            my @cols = split(/\s+/);
	            my ($chr, $s, $e, $name) = ($cols[0], $cols[1], $cols[2], $cols[3]);
	            $s+=1;
	            my $vals = ($data_type ne "bed" && basename($data_f) =~ /^raw/) ? $cols[6] : $cols[4];
	            my $val = $vals;
	            if ($vals =~ /,/) {
	                my ($min, $max, $avg) = split(/,/, $vals);
	                if ($summ_type eq "min" ) { $val = $min; }
	                elsif ($summ_type eq "max" ) { $val = $max; }
	                elsif ($summ_type eq "avg" ) { $val = $avg; }
	            }
	            my %bin_info = ();
	            my $bin_check = "";
	            if ($e - $s == 0) {
					%bin_info = ("chr"=>$chr, "pos"=>$e, "value"=>$val);
	                $bin_check = "$chr:$e:$val";
	            } else {
					%bin_info = ("chr"=>$chr, "start"=>$s, "end"=>$e, "value"=>$val);
	               	$bin_check = "$chr:$s:$e:$val";
	            }
	
	            if ($chr ne $qchr) { last; }
	            if ($s < $qbeg && $e < $qbeg) {
					%pre_bin = %bin_info;
	                next;
	            } elsif ($end_check == 1) {
	                last;
	            } else {
					if (scalar(keys %pre_bin) != 0) {
						my %tmp_hs = %{\%pre_bin};
						push(@out_bins, \%tmp_hs);
						%pre_bin = ();
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


}

print JSON->new->pretty->encode(\@out_bins);

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


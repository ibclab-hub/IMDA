#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
use POSIX;
use FindBin '$Bin';

my $data_dir = shift;
$data_dir = abs_path($data_dir);
my $size_fs = shift;
my $data_f = shift;
my $raw_res = shift;
my $bedpe_n = shift;
my $resolution = shift;

my $cutoff = 0.5;
my %size_fs_hs = ();
my @size_fs_ar = split(/,/, $size_fs);
my $g_size = 0;
foreach my $spc_size (@size_fs_ar) {
    my ($spc_n, $size_f) = split(/:/, $spc_size);
    $size_fs_hs{$spc_n} = $size_f;
    open(F, $size_f);
    while(<F>) {
        chomp;
        my ($chr, $size) = split(/\s+/);
        $g_size += $size;
    }
    close(F);
}
$g_size = int($g_size / scalar(@size_fs_ar));

my $work_dir = "$data_dir/aln_cov";
`mkdir -m 777 -p $work_dir`;

my %val_info = ();
my @resolutions = ();
my %ovl_len = ();
my $min_res = 1000;
my $max_res = (int(($g_size / 10000)/10000)+1) * 10000;
if ($g_size < 10000 || $max_res < $min_res) {
    print STDERR "$g_size\t$max_res\n";
    print STDERR "# Skip data separation.. Genome size is small enough to visualize!\n";
    exit;
} else {
	if($resolution){
		@resolutions = split(/,/, $resolution);
	}else{
	    my $res = $min_res;
	    while ($res < $max_res) {
	        if ($res > $raw_res) {
                if (-f "$data_dir/res_$res.bedpe") { `rm -f $data_dir/res_$res.bedpe`; }
                push(@resolutions, $res);
   	        }
			$res = ($res * 10000) / 200;
	    }
	    push(@resolutions, $max_res);
	}
	print STDERR "@resolutions\n";

    my %out = ();
	open(F, $data_f);
	while(<F>) {
		chomp;
		my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $id, $dir1, $dir2) = split(/\s+/);
		my ($spc1, $spc2) = split(/:/, $name);
        $val_info{$spc1}{$chr1}{$s1} = $e1;
        $val_info{$spc2}{$chr2}{$s2} = $e2;
		foreach my $res (@resolutions) {
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
				$out{$res}{"$spc1:$chr1"}{$s1_bin}{"$spc2:$chr2"}{$s2_bin} += ($dir2 eq "+") ? $e1-$s1 : ($e1-$s1)*(-1);
				$ovl_len{$res}{"$spc1:$chr1"}{$s1_bin}{"$spc2:$chr2"}{$s2_bin}{$spc1} += ($e1-$s1);
				$ovl_len{$res}{"$spc1:$chr1"}{$s1_bin}{"$spc2:$chr2"}{$s2_bin}{$spc2} += ($e2-$s2);
				#print STDERR "res$res\t$chr1\t$s1_bin\t",$s1+1,"\t$e1\t$chr2\t$s2_bin\t",$s2+1,"\t$e2\n";
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
					#print STDERR "res$res\t$chr1\t$aln_bin1\t$flk_s1\t$tar1_flks[$i]\t$chr2\t$aln_bin2\t$flk_s2\t$tar2_flks[$i]\n";
					$out{$res}{"$spc1:$chr1"}{$aln_bin1}{"$spc2:$chr2"}{$aln_bin2} += ($dir2 eq "+") ? $aln_len : $aln_len*(-1);
					$ovl_len{$res}{"$spc1:$chr1"}{$aln_bin1}{"$spc2:$chr2"}{$aln_bin2}{$spc1} += $aln_len;
					$ovl_len{$res}{"$spc1:$chr1"}{$aln_bin1}{"$spc2:$chr2"}{$aln_bin2}{$spc2} += $aln_len;
					($flk_s1, $flk_s2) = ($tar1_flks[$i], $tar2_flks[$i]);
				}

			}
		}
	}
	close(F);
    
    foreach my $spc (sort keys %val_info) {
        open(W, ">$work_dir/$spc.bed");
        foreach my $chr (sort keys %{$val_info{$spc}}) {
            foreach my $s (sort {$a<=>$b} keys %{$val_info{$spc}{$chr}}) {
                print W "$chr\t$s\t$val_info{$spc}{$chr}{$s}\n";
            }
        }
        close(W);
    }

    # Calculate cutoff
    my $cov_sum = 0;
    my $cov_cnt = 0;
    foreach my $spc (keys %size_fs_hs) {
        if (-f "$work_dir/$spc.bed") {
            `bedtools genomecov -i $work_dir/$spc.bed -g $size_fs_hs{$spc} > $work_dir/$spc.out`;
            open(C, "$work_dir/$spc.out");
            while(<C>) {
                chomp;
                my @cols = split(/\s+/);
                if ($cols[0] eq "genome" && $cols[1] == 0) {
                    my $cov = 1 - $cols[-1];
                    print STDERR "$spc\_genomecov\t$cov\n";
                    $cov_sum += $cov;
                    $cov_cnt ++;
                }
            }
            close(C);
        }
    }

    $cutoff = $cov_sum/$cov_cnt;
    $cutoff = sprintf("%.2f", $cutoff);
    $cutoff = ($cutoff > 0.5) ? 0.5 : $cutoff;
    print STDERR "Cutoff: $cutoff\n";

    # Downsampling
	foreach my $res (@resolutions) {
		my %maxovl_bins = ();
		open(W, ">>$data_dir/res_$res.bedpe");
        #open(LOG, ">>$data_dir/res_$res.log");
		foreach my $chr1 (sort keys %{$out{$res}}) {
			my ($spc1, $chr1_n) = split(/:/, $chr1);
			foreach my $bin1 (sort {$a<=>$b} keys %{$out{$res}{$chr1}}) {
				my ($s1, $e1) = (($bin1-1)*$res, $bin1*$res);
				my ($max_spc2, $max_chr2, $max_bin2, $max_dir, $max_ovl) = ("", "", "","",0);
				foreach my $chr2 (sort keys %{$out{$res}{$chr1}{$bin1}}) {
					my ($spc2, $chr2_n) = split(/:/, $chr2);
					foreach my $bin2 (sort {$a<=>$b} keys %{$out{$res}{$chr1}{$bin1}{$chr2}}) {
						my $spc1_alnlen = $ovl_len{$res}{$chr1}{$bin1}{$chr2}{$bin2}{$spc1};
						my $spc2_alnlen = $ovl_len{$res}{$chr1}{$bin1}{$chr2}{$bin2}{$spc2};
						my $filt_cutoff = $res * $cutoff;
						if ($spc1_alnlen >= $filt_cutoff) {
							if (! exists $maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'}) {
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'} = $spc1_alnlen;
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'dir'} = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'bin'} = $bin2;
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'chr'} = $chr2_n;
							} elsif ($spc1_alnlen > $maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'}) {
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'len'} = $spc1_alnlen;
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'dir'} = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'bin'} = $bin2;
								$maxovl_bins{$spc1}{$chr1_n}{$bin1}{$spc2}{'chr'} = $chr2_n;
							}
							if (! exists $maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'}) {
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'} = $spc2_alnlen;
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'dir'} = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'bin'} = $bin1;
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'chr'} = $chr1_n;
							} elsif ($spc2_alnlen > $maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'}) {
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'len'} = $spc2_alnlen;
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'dir'} = ($out{$res}{$chr1}{$bin1}{$chr2}{$bin2} >= 0) ? "+" : "-";
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'bin'} = $bin1;
								$maxovl_bins{$spc2}{$chr2_n}{$bin2}{$spc1}{'chr'} = $chr1_n;
							}
						}
                        #print LOG "$chr1\t$bin1\t$chr2\t$bin2\t$spc1_alnlen\t$spc2_alnlen\n";
					}
				}
			}
		}
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
							print W "$chr1\t$s1\t$e1\t$chr2\t$s2\t$e2\t$spc1:$spc2\t.\t+\t$dir\n";
						}
					}
				}
			}
		}
		close(W);
        #close(LOG);
		`perl $Bin/process_alndat.pl $data_dir $res $data_dir/res_$res.bedpe $data_dir/res_$res.$bedpe_n`;
		`rm -f $data_dir/res_$res.bedpe`;
	}
}

	
`perl $Bin/process_alndat.pl $data_dir 1 $data_f $data_dir/raw_1.$bedpe_n`;

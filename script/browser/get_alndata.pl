#!/usr/bin/perl

use strict;
use warnings;
use Parallel::ForkManager;
use JSON;
use DBI;

my $data_dir = shift;
my $refspc = shift;
my @ranges = @ARGV;


my %vis_reg_len = ();
my %vis_reg = ();
foreach my $range (@ranges) {
	my ($qspc, $qchr, $qpos) = split(/:/, $range);
	my ($qbeg, $qend) = split(/-/, $qpos);
#	my ($qspc, $qchr, $qbeg, $qend) = split(/:|-/, $range);
	$vis_reg{$qspc}{$qchr}{$qbeg} = $qend;
	if (exists $vis_reg_len{$qspc}) {
		$vis_reg_len{$qspc} += ($qend - $qbeg);
	} else {
		$vis_reg_len{$qspc} = ($qend - $qbeg);
	}
}

if (! -d $data_dir) {
	print "__ERROR__ No directory for $data_dir\n";
	exit;
}

my %spc_datas = ();
foreach my $tar_spc (sort keys %vis_reg_len) {
	my $data_f = "";
	my $tar_res = "+inf";
	my $ds_res = 10000;

    if(-d "$data_dir/$tar_spc"){
    	opendir(DIR, "$data_dir/$tar_spc");
    	my @ds_datas = grep { ((/^res_/ || /^raw_/) && !/\.idx$/) && -f "$data_dir/$tar_spc/$_" } readdir(DIR);
    	close DIR;

    	foreach my $ds_data (@ds_datas) {
    		if ($ds_data =~ /(^raw_|res_)(\d+)\./) {
    			my $res = $2;
    			if ($vis_reg_len{$tar_spc} < $res*$ds_res && $tar_res > $res) {
    				$tar_res = $res;
    				$data_f = "$data_dir/$tar_spc/$ds_data";
    			}
    		}
    	}
    	$spc_datas{$tar_spc}{'data'} = $data_f;
    	$spc_datas{$tar_spc}{'idx'} = $data_f.".idx";
    	$spc_datas{$tar_spc}{'res'} = $tar_res;
    }
}

my @tar_spcs = keys %spc_datas;
if($#tar_spcs == -1){ 
	print "__ERROR__ No alignment data for $data_dir\n";
    exit; 
}

my %tar_ids = ();
foreach my $range (@ranges) {
#	my ($qspc, $qchr, $qbeg, $qend) = split(/:|-/, $range);
	my ($qspc, $qchr, $qpos) = split(/:/, $range);
	my ($qbeg, $qend) = split(/-/, $qpos);

	my $beg_ptr = -1;
	my $pre_ptr = "";

    #print STDERR "$qspc\n";
	open(F, $spc_datas{$qspc}{'idx'});
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

	if ($beg_ptr != -1) {
		open(RF, "<", $spc_datas{$qspc}{'data'});
		seek(RF, $beg_ptr, 0);
		while(<RF>) {
			chomp;
			my ($chr, $s, $e, $ids, $score, $dir) = split(/\s+/);
			$s = $s+1;
			
			if ($chr ne $qchr) { last; }
			if ($qend < $s && $qend < $e) { last; }
			
			if ($qbeg <= $e && $qend >= $s) {
				my @ids_ar = split(/,/, $ids);
				foreach my $id (@ids_ar) { $tar_ids{$qspc}{$id} = ""; }
			}
		}
		close(RF);
	}
}
my %out_hs = ();

my $pm = Parallel::ForkManager->new(scalar keys %tar_ids);
$pm->run_on_finish(sub{
	my ($pid, $exit_code, $id, $exit_signal, $core_dump, $result) = @_;
	my ($spc, $spc_hs) = @{$result};
	$out_hs{$spc} = $spc_hs;
});

DATA_LOOP:

foreach my $tarspc (sort keys %tar_ids) {
	$pm->start and next DATA_LOOP;
    my $subid = 1;
	my @tar_ids_ar = sort {$a<=>$b} keys %{$tar_ids{$tarspc}};
	my $bedpe_f = ($spc_datas{$tarspc}{'res'} == 1) ? "$data_dir/raw_1.align.sort.bedpe" : "$data_dir/res_$spc_datas{$tarspc}{'res'}.align.sort.bedpe";
	my $bedpe_idx_f = "$bedpe_f.idx";
	my %spc_hs = ();
	
	$spc_hs{'resolution'} = $spc_datas{$tarspc}{'res'};
	my %coord_check = ();
	if (scalar(@tar_ids_ar) != 0) {
		my $bedpe_ptr = -1;
        #print STDERR "$tarspc\t".@tar_ids_ar."\n";

		my %ptrs = ();
		my $pre_id = -1;
		my $pre_ptr = -1;
		open(F, $bedpe_idx_f);
		while(<F>){
			chomp;
			my ($id, $ptr) = split(/\s+/);
			
			my @upd_ids_ar;
			foreach my $tar_id (sort {$a<=>$b} @tar_ids_ar){
				if($pre_id <= $tar_id && $tar_id < $id){
					$ptrs{$pre_ptr} = $ptr;
				} else {
					push(@upd_ids_ar, $tar_id);
				}
			}
			@tar_ids_ar = @upd_ids_ar;

			$pre_id = $id;
			$pre_ptr = $ptr;
		}
		close (F);

		if (scalar(@tar_ids_ar) != 0) {
			$ptrs{$pre_ptr} = -1;
		}

		open(F, "<", $bedpe_f);
		foreach my $ptr (sort {$a<=>$b} keys %ptrs){
			my $endptr = $ptrs{$ptr};

			seek(F, $ptr, 0);
			while(<F>){
				chomp;
				my $curptr = tell(F);
				if($endptr != -1 && $curptr > $endptr){ last; }

				my ($chr1, $s1, $e1, $chr2, $s2, $e2, $name, $id, $dir1, $dir2) = split(/\s+/);
				if(exists $tar_ids{$tarspc}{$id}){
					my ($spc1, $spc2) = split(/:/, $name);
					$s1++; $s2++;
                    my $subid_tarn = ($spc1 eq $refspc) ? $spc2 : $spc1;
					
					foreach my $spc ($spc1, $spc2) {
						my ($chr_t, $s_t, $e_t, $dir_t) = ("","","","");
						if ($spc1 eq $spc) { ($chr_t, $s_t, $e_t, $dir_t) = ($chr1, $s1, $e1, $dir1); }
						else { ($chr_t, $s_t, $e_t, $dir_t) = ($chr2, $s2, $e2, $dir2);  }
                        #if (exists $coord_check{"$spc:$chr_t:$s_t:$e_t"}) { next; }
						my %bin_info = ("chr"=>$chr_t, "start"=>$s_t, "end"=>$e_t, "id"=>$id, "dir"=>$dir_t, "sub_id"=>"$subid_tarn\_$subid"); 
						$coord_check{"$spc:$chr_t:$s_t:$e_t"} = "";

						if (exists $spc_hs{$spc}) {
							push(@{$spc_hs{$spc}}, \%bin_info);
						} else {
							my @bins_ar = (\%bin_info);
							$spc_hs{$spc} = \@bins_ar;
						}
					}
                    $subid ++;
				}
			}
		}
		close (F);
	}
#	$out_hs{$tarspc} = \%spc_hs;
	my @result = ($tarspc, \%spc_hs);
	$pm->finish(0, \@result);
}

$pm->wait_all_children;
print JSON->new->pretty->encode(\%out_hs);


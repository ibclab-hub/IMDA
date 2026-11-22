#!/usr/bin/perl
#
use strict;
use warnings;
use FindBin qw($Bin);
use Getopt::Long;
use Statistics::R;

my $config_f;
my $marker_id;
my $outdir;
my $aln_f;
my $resol = 1000;
my $merge_method = "avg";
my $help = 0;

## Get options for adding data
GetOptions(
    "config|c=s" => \$config_f,
    "outdir|o=s" => \$outdir,
    "alninfo|a=s" => \$aln_f,
    "id|i=s" => \$marker_id,
	"res|r=s" => \$resol,
	"merge|m=s" => \$merge_method,
    "help|h" => \$help
);

if ($help == 1) {
    &usage();
} elsif (!$config_f || !$marker_id ) {
    &usage();
}

if (! -f $aln_f) {
	print STDERR "[Error] There is no available alignment information.\n$aln_f";
	exit;
}

print STDERR "# Use alignment data ($aln_f) for resolution $resol\n";

my %mul_alns = ();
my %aln_cnt = ();

print STDERR "# Read ortholog data...\n";

my %aln_pos = ();
my %aln_info = ();
open(RF, $aln_f);
while(<RF>){
	chomp;

	my ($rchr, $rbeg, $rend, $tchr, $tbeg, $tend, $comb, $aid) = split(/\s+/);
	my ($ref, $tar) = split(/:/, $comb);

	$aln_info{$ref}{$rchr}{$rbeg}{$rend}{$aid} = 1;
	$aln_info{$tar}{$tchr}{$tbeg}{$tend}{$aid} = 1;

	$aln_pos{$aid}{$ref} = "$rchr\t$rbeg\t$rend";
	$aln_pos{$aid}{$tar} = "$tchr\t$tbeg\t$tend";
}
close RF;

print STDERR "Read profile data\n";
my %group_info = ();
my %sample_info = ();
my %merge_data = ();
open(RF, $config_f);
while(<RF>){
    chomp;
    if($_ =~ /^#/){ next; }
    my ($sample, $spc, $group, $sex, $format, $path) = split(/\s+/);

	$group_info{$group} = $spc;
    $sample_info{$group}{$sample} = uc($sex);
    if(! defined $path){ 
        print STDERR "\t[Error] Cannot parse below line.\n";
        print STDERR " - $_\n\n";
        die;
    } elsif(! -f $path){
        print STDERR "\t[Error] Cannot find $path.\n";
    } else {
		print STDERR "\tRead $path\n";
        open(RFS, $path);
        while(<RFS>){
            my @col = split(/\s+/);
            
            my ($chr, $beg, $end, $val);
            if(lc($format) eq "narrowpeak" || lc($format) eq "broadpeak"){
                $chr = $col[0];
                $beg = $col[1];
                $end = $col[2];
                $val = $col[6];
            } elsif (lc($format) eq "bed"){
                $chr = $col[0];
                $beg = $col[1];
                $end = $col[2];
                $val = $col[4];
            } else {
				print STDERR "\t[Error] Unknown file format\n";
				die;
			}

			if($resol != -1){
            	my $start_bin = int($beg / $resol);
            	my $end_bin = int($end / $resol);

            	for(my $bin = $start_bin; $bin <= $end_bin; ++$bin){
			    	my $bbeg = $bin * $resol;
                	my $bend = ($bin + 1) * $resol;
                
                	if(exists $aln_info{$group}{$chr}{$bbeg}{$bend}){
                    	foreach my $aid (keys %{$aln_info{$group}{$chr}{$bbeg}{$bend}}){
					    	$merge_data{$aid}{$group}{$sample}{"sum"} += $val;
					    	$merge_data{$aid}{$group}{$sample}{"cnt"} ++;
					    	if(! exists $merge_data{$aid}{$group}{$sample}{"max"} || $merge_data{$aid}{$group}{$sample}{"max"} < $val){
						    	$merge_data{$aid}{$group}{$sample}{"max"} = $val;
					    	}
					    	if(! exists $merge_data{$aid}{$group}{$sample}{"min"} || $merge_data{$aid}{$group}{$sample}{"min"} > $val){
						    	$merge_data{$aid}{$group}{$sample}{"min"} = $val;
					    	}
						}
                    }
                }
            } else {
				my $finish = 0;
				foreach my $bbeg (sort {$a<=>$b} keys %{$aln_info{$group}{$chr}}){
					if($finish){ last; }
					foreach my $bend (sort {$a<=>$b} keys %{$aln_info{$group}{$chr}{$bbeg}}){
						foreach my $aid (sort keys %{$aln_info{$group}{$chr}{$bbeg}{$bend}}){
							if($beg == $bbeg && $end == $bend){
								$merge_data{$aid}{$group}{$sample}{"sum"} += $val;
								$merge_data{$aid}{$group}{$sample}{"cnt"} ++;
							
								if((!exists $merge_data{$aid}{$group}{$sample}{"max"}) || $merge_data{$aid}{$group}{$sample}{"max"} < $val){
							    	$merge_data{$aid}{$group}{$sample}{"max"} = $val;
					    		}
					    		if((!exists $merge_data{$aid}{$group}{$sample}{"min"}) || $merge_data{$aid}{$group}{$sample}{"min"} > $val){
						    		$merge_data{$aid}{$group}{$sample}{"min"} = $val;
					    		}
							}elsif($end < $bbeg){
								$finish = 1;
								last;
							}
						}
					}
				}
			}
        }
        close RFS;
    }
}
close RF;

my @samples = ();
my $groups = join("\t", sort keys %sample_info);
foreach my $group (sort keys %sample_info){
    my @group_samples = sort keys %{$sample_info{$group}};
    @samples = (@samples, @group_samples);
}

my %medians = ();
open(WF, ">$outdir/$marker_id.Downsample_data.txt");
my $header = join("\t", @samples);
my %compare_input = ();
print WF "POS\t$groups\t$header\n";
foreach my $aid (keys %aln_pos){
	print WF "$aid";
    foreach my $group (sort keys %sample_info){
		if(exists $aln_pos{$aid}{$group}){
			my ($chr, $beg, $end) = split(/\s+/, $aln_pos{$aid}{$group});
			$beg += 1;
			print WF "\t$chr:$beg-$end";
		}else {
			print WF "\tNA";
		}
	}

    foreach my $group (sort keys %sample_info){
		my @vals = ();
        foreach my $sample (sort keys %{$sample_info{$group}}){
			if(exists $merge_data{$aid}{$group}{$sample}{"sum"}){
	            my $sum = $merge_data{$aid}{$group}{$sample}{"sum"};
   	        	my $avg = $merge_data{$aid}{$group}{$sample}{"sum"} / $merge_data{$aid}{$group}{$sample}{"cnt"};
   	         	my $max = $merge_data{$aid}{$group}{$sample}{"max"};
            	my $min = $merge_data{$aid}{$group}{$sample}{"min"};

				print WF "\t$sum,$avg,$max,$min";
				if(lc($merge_method) eq "avg"){
					push(@vals, $avg);
					$compare_input{$aid}{$sample} = $avg;
				} elsif (lc($merge_method) eq "sum"){
					push(@vals, $sum);
					$compare_input{$aid}{$sample} = $sum;
				} elsif (lc($merge_method) eq "max"){
					push(@vals, $max);
					$compare_input{$aid}{$sample} = $max;
				} elsif (lc($merge_method) eq "min"){
					push(@vals, $min);
					$compare_input{$aid}{$sample} = $min;
				} else {
        			print STDERR "[Error] Strange value for merge_method : $merge_method.\n";
				}
			}else{
				print WF "\tNA";
			}
        }
	
		@vals = sort {$a <=> $b} @vals;
		my $val_cnt = scalar @vals;
		my $median = "na";

		if($val_cnt >= 1){
			my $center = $val_cnt / 2;
			if($val_cnt % 2){
				$median = $vals[$center];
			} else {
				$median = ($vals[$center-1] + $vals[$center]) / 2;
			}
		}
	
		if($median ne "na"){
			$medians{$aid}{$group} = $median;
		}
	}
	print WF "\n";
		
}
close WF;

my $R = Statistics::R->new();	
foreach my $group (keys %sample_info){
   	foreach my $spl (keys %{$sample_info{$group}}){
		if(-f "$marker_id.$spl.bed"){
			`rm -f $marker_id.$spl.bed`;
		}
	}
}

print STDERR "Calculate p-value & FDR\n";
my @all_groups = sort keys %sample_info;

$R->startR;

for(my $i=0; $i<$#all_groups; ++$i){
	my $igroup = $all_groups[$i];
    my @isamples = sort keys %{$sample_info{$igroup}};
	
	for(my $j=$i+1; $j<=$#all_groups; ++$j){
		my $jgroup = $all_groups[$j];
		my @jsamples = sort keys %{$sample_info{$jgroup}};

		print STDERR "\t$igroup vs. $jgroup\n";

		open(WFN, ">$outdir/$marker_id.normalized.$igroup\_$jgroup.cnt");
		print WFN "#POS";
		foreach my $group ($igroup, $jgroup){
    		foreach my $sample (sort keys %{$sample_info{$group}}){
				print WFN "\t$group\_$sample"; 
			}
		}
		print WFN "\n";
		
		my %regularized_dat = ();
		foreach my $group ($igroup, $jgroup){
   			foreach my $sample (sort keys %{$sample_info{$group}}){
				print STDERR "\t\tNomralize $sample\n";

        		my @vals = ();
        		foreach my $aid (sort keys %compare_input){
            		if(exists $compare_input{$aid}{$sample} && exists $medians{$aid}{$igroup} && exists $medians{$aid}{$jgroup} && (!($medians{$aid}{$igroup} == 0 && $medians{$aid}{$jgroup} == 0))){
            		    push(@vals, $compare_input{$aid}{$sample});
           	 		}    
        		}
        
				my $cnt = scalar keys %aln_pos;

				$R->startR;
				$R->set("cnt", $cnt);
        		$R->set("raw_dat", \@vals);
        		$R->run(
					q`options(max.print=cnt)`,
        	    	q`reg_dat <- qqnorm(raw_dat, plot.it=F)$x`
       			);
        		my $reg_val_ref = $R->get("reg_dat");
				$R->stopR();

				my @reg_vals;
				if($#vals == 0){
					@reg_vals = ($reg_val_ref);
				}else{
        			@reg_vals = @{$reg_val_ref};
				}

        		foreach my $aid (sort keys %compare_input){
            		if(exists $compare_input{$aid}{$sample} && exists $medians{$aid}{$igroup} && exists $medians{$aid}{$jgroup} && (!($medians{$aid}{$igroup} == 0 && $medians{$aid}{$jgroup} == 0))){
						my $reg_val = shift @reg_vals;
                		$regularized_dat{$aid}{$sample} = $reg_val;
					}
            	}
        	}
    	}

		my %result;
		foreach my $aid (sort keys %aln_pos){
			my @ispls = ();
			my @igroups = ();
			my @isexs = ();
			my @ivals = ();
			my @iraws = ();

			my @jspls = ();
			my @jgroups = ();
			my @jsexs = ();
			my @jvals = ();
			my @jraws = ();

			foreach my $sample (@isamples){
				if(exists $regularized_dat{$aid}{$sample}){
			    	push(@ispls, $sample);
			    	push(@igroups, $igroup);
					push(@isexs, $sample_info{$igroup}{$sample});
					push(@ivals, $regularized_dat{$aid}{$sample});
					push(@iraws, $compare_input{$aid}{$sample});
				}
			} 
		
			foreach my $sample (@jsamples){
				if(exists $regularized_dat{$aid}{$sample}){
		    		push(@jspls, $sample);
					push(@jgroups, $jgroup);
					push(@jsexs, $sample_info{$jgroup}{$sample});
			    	push(@jvals, $regularized_dat{$aid}{$sample});
                    push(@jraws, $compare_input{$aid}{$sample});
				}
			}
	
            if(!(exists $medians{$aid}{$igroup} && exists $medians{$aid}{$jgroup} && (!($medians{$aid}{$igroup} == 0 && $medians{$aid}{$jgroup} == 0)))){
				my %spcs = ($group_info{$igroup} => 1, $group_info{$jgroup} => 1);
				if($aln_pos{$aid}{$igroup} && $aln_pos{$aid}{$jgroup}){
					foreach my $spc (sort keys %spcs){
						foreach my $group ($igroup, $jgroup){
							if($group_info{$group} eq $spc){
								print "$spc&^&$aln_pos{$aid}{$group}\t$aid&^&$igroup&^&$jgroup\tNaN\tNaN\tNaN\n";
								last;
							}
						}
					}
				}
				next;
			}else{
                my @spls = (@ispls, @jspls);
                my @groups = (@igroups, @jgroups);
                my @sexs = (@isexs, @jsexs);
                my @vals = (@ivals, @jvals);
                my @raws = (@iraws, @jraws);

                $R->set('reg_dat', \@vals);
                $R->set('sex', \@sexs);
                $R->set('group', \@groups);
                
                my %unique = ();
                foreach my $sex (@sexs){
                    $unique{$sex} = 1;
                }
                my @unique_sex = keys %unique;

                if(scalar @unique_sex != 1 &&  !exists $unique{"NA"}){
                    $R->run(
                        q`lm.fit <- lm(reg_dat~sex)`,
                        q`reg_dat <- qqnorm(lm.fit$residuals, plot.it=F)$x`,
						q`coef <- summary(lm(reg_dat~group))$coefficients[2,1]`,
                        q`pval <- summary(lm(reg_dat~group))$coefficients[2,4]`,
                    );
                } else {
                    $R->run(
						q`coef <- summary(lm(reg_dat~group))$coefficients[2,1]`,
                        q`pval <- summary(lm(reg_dat~group))$coefficients[2,4]`,
                    );
                }
        
				my $reg_val_ref = $R->get("reg_dat");
        		my @reg_vals = @{$reg_val_ref};
					
				print WFN "$aln_pos{$aid}{$igroup}";
				for(my $i = 0; $i <= $#reg_vals; ++$i){
					open(RF, ">>$outdir/$marker_id.$spls[$i].bed");
					print RF "$aln_pos{$aid}{$igroup}\t.\t$reg_vals[$i]\n";
					close RF;
					
					print WFN "\t$raws[$i],$vals[$i],$reg_vals[$i]";
				}
				print WFN "\n";
                
                my $ival_str = join(",", @iraws);
                my $isex_str = join(",", @isexs);
                my $igroup_str = join(",", @igroups);
                my $jval_str = join(",", @jraws);
                my $jsex_str = join(",", @jsexs);
                my $jgroup_str = join(",", @jgroups);

                my $pval = $R->get('pval');
				my $coef = $R->get('coef');
	
				if((!$pval) || $pval eq "NaN"){
					my %spcs = ($group_info{$igroup} => 1, $group_info{$jgroup} => 1);
					foreach my $spc (sort keys %spcs){
						foreach my $group ($igroup, $jgroup){
							if($group_info{$group} eq $spc){
								print "$spc&^&$aln_pos{$aid}{$group}\t$aid&^&$igroup&^&$jgroup\t$pval\t$coef\tNaN\n";
								last;
							}
						}
					}
				}else{
					$result{$aid}{"pos"}{$group_info{$igroup}} = $aln_pos{$aid}{$igroup};
					$result{$aid}{"pos"}{$group_info{$jgroup}} = $aln_pos{$aid}{$jgroup};
					$result{$aid}{"info"} = "$aid&^&$igroup&^&$jgroup";
					$result{$aid}{"pval"} = $pval;
					$result{$aid}{"coef"} = $coef;
				}
            }
		}
		
		my $cnt = scalar keys %result;
		my $rank = $cnt;
		my $prevq = 1;

		foreach my $aid (sort {$result{$b}{"pval"} <=> $result{$a}{"pval"}} keys %result){
			my $practicalq = $result{$aid}{"pval"} * $cnt / $rank;
			$result{$aid}{"qval"} = ($practicalq < $prevq)? $practicalq : $prevq;
	
			foreach my $spc (sort keys %{$result{$aid}{"pos"}}){
				print "$spc&^&$result{$aid}{'pos'}{$spc}\t$result{$aid}{'info'}\t$result{$aid}{'coef'}\t$result{$aid}{'pval'}\t$result{$aid}{'qval'}\n";
			}

			$prevq = $result{$aid}{"qval"};
			$rank--;
		}
	}
}
$R->stopR();


sub usage {
    print STDERR "\n======================================================================================\n\n";
    print STDERR "\$ MultiOVIS find_mark -p [project_name] -d [data_path] -n [mark_name] -l [copy|symlink|move]\n\n";
    print STDERR "Options:\n";
    print STDERR "\t-c|--config\t<path> Config file\n";
    print STDERR "\t-p|--project\tProject name to add data\n";
    print STDERR "\t-d|--data\t<path> Data file\n";
    print STDERR "\t-n|--name\tName for highlight mark\n";
    print STDERR "\t-l|--load\tMethod for managing data directory [copy|symlink|move]\n";
    print STDERR "\t-h|--help\tPrint usages\n";
    print STDERR "\n======================================================================================\n\n";
    exit;

}


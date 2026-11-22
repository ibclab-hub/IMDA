#!/usr/bin/perl
#
use strict;
use warnings;

my $chainlist = shift;
my $ortho_blk_f = shift;

my %alninfo = ();
my $refspc = "";
my $aid = 0;

open(RF, $chainlist);
while(<RF>){
    chomp;

    my ($ref, $tar, $chain_f) = split(/[,|\s]+/);
	$refspc = $ref;
    
	my ($chain, $score, $tchr, $tsize, $tstr, $tstart0, $tend0, $qchr, $qsize, $qstr, $qstart0, $qend0, $cid, $ctstart0, $cqstart0, $ctend0, $cqend0);

    open(RFC, $chain_f);
    while(<RFC>){
        chomp;

        if($_ =~ /^#/){ next; }
        
        if($_ =~ /^chain/){
            ($chain, $score, $tchr, $tsize, $tstr, $tstart0, $tend0, $qchr, $qsize, $qstr, $qstart0, $qend0, $cid) = split(/\s+/);

            $ctstart0 = $tstart0;
            $cqstart0 = $qstart0;

            $aid = 0;
        }elsif($_ eq ""){ next; }
        else{
            $aid++;
            my @col = split(/\s+/);
            
            $ctend0 = $ctstart0 + $col[0];
            $cqend0 = $cqstart0 + $col[0];

            $alninfo{"$ref.$tar"}{$cid}{$aid}{$ref} = "$tchr\t$ctstart0\t$ctend0";

            if($qstr eq "+"){
			    $alninfo{"$ref.$tar"}{$cid}{$aid}{$tar} = "$qchr\t$cqstart0\t$cqend0\t$qstr";
            }else{
			    $alninfo{"$ref.$tar"}{$cid}{$aid}{$tar} = "$qchr\t".($qsize - $cqend0)."\t".($qsize - $cqstart0)."\t$qstr";
            }

            if($#col == 2){
                $ctstart0 = $ctend0 + $col[1];
                $cqstart0 = $cqend0 + $col[2];
            }
        }
    }
    close RFC;
}
close RF;

my %blkinfo = ();
my $id = 0;

open(RF, $ortho_blk_f);
while(<RF>){
    chomp;

    if($_ =~ /^>/){
        $id = substr($_, 1);
    }elsif($_ =~ /(\S+)\s+([\+|-])\s+\[\w+\]\s+\((\d+)\)/){
        my $spcpos = $1;
        my $dir = $2;
        my $cid = $3;
        
        my $spc; my $chr; my $beg0; my $end0;
        if($spcpos =~ /(\S+)\.(\S+):(\d+)-(\d+)/){
            $spc = $1;
            $chr = $2;
            $beg0 = $3;
            $end0 = $4;
        
            $blkinfo{$id}{$spc."-CHAIN".$cid} = "$chr\t$beg0\t$end0";
        }

    }
}
close RF;

my %alninfo_inblk = ();
foreach my $sfid (sort {$a<=>$b} keys %blkinfo){
	foreach my $spccid (keys %{$blkinfo{$sfid}}){
		if($spccid eq $refspc."-CHAIN0"){ next; }

		my ($spc, $cid) = split(/-CHAIN/, $spccid);

		my ($tchr, $tbeg, $tend) = split(/\s+/, $blkinfo{$sfid}{$refspc."-CHAIN0"});
		my ($qchr, $qbeg, $qend) = split(/\s+/, $blkinfo{$sfid}{$spccid});

		my %alninfo_all = %{$alninfo{"$refspc.$spc"}{$cid}};
        foreach my $aid (sort {$a<=>$b} keys %alninfo_all){
            my ($ctchr, $ctbeg, $ctend) = split(/\t/, $alninfo_all{$aid}{$refspc});  
            my ($cqchr, $cqbeg, $cqend, $qstr) = split(/\t/, $alninfo_all{$aid}{$spc});

            if($cqbeg < $qend  && $qbeg < $cqend){
                my $left = 0;
                if($cqbeg <= $qbeg && $qbeg < $cqend){
                    $left = $qbeg - $cqbeg;
                }
                my $right = 0;
                if($cqbeg <= $qend && $qend < $cqend){
                    $right = $cqend - $qend;
                }

				if($qstr eq "+"){
                	print "$tchr\t".($ctbeg+$left)."\t".($ctend-$right)."\t$qchr\t".($cqbeg+$left)."\t".($cqend-$right)."\t$refspc:$spc\t.\t+\t$qstr\n";
				}else{
                	print "$tchr\t".($ctbeg+$left)."\t".($ctend-$right)."\t$qchr\t".($cqbeg+$right)."\t".($cqend-$left)."\t$refspc:$spc\t.\t+\t$qstr\n";
				}
            }
        }
	} 
}

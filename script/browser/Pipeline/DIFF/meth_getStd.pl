#!/usr/bin/perl
#
#
use strict;
use warnings;
use DBI;
use Cwd 'abs_path';
use FindBin '$Bin';
use Statistics::Basic qw(unbias);
use Statistics::Basic qw(:all);

my $database = "mysql:KUBDS"; ## find from database 
my $db_user = "webtest"; ## constant, not argument
my $db_passwd = ''; ## constant, not argument
my $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");
##for DBwork
$dbh->{mysql_auto_reconnect} = 1;   # by JK
my $sth;
my @search_result=();
my $mysql_search_query = "";

my $DATA_DIR = GET_DATAROOT($dbh);
my $GENOME_DIR = $DATA_DIR."/GENOME/";


my $f_param = shift;
my %hs_param = ();
my %hs_sample = ();
my $sample_cnt=0;
my $bglist = "";
open(F,"$f_param");
while(<F>){
    chomp;
    my @ar_split = split(/\s+/,$_);
    if ($ar_split[0] !~ /^\d/){
        $hs_param{$ar_split[0]} = $ar_split[1];
    }else{
        $sample_cnt++;
        $hs_sample{$sample_cnt} = $ar_split[2];
        $hs_param{$sample_cnt} = $ar_split[0]."\t".$ar_split[1]."\t";
        `mkdir -p -m777 $hs_param{"outdir"}/$sample_cnt/`;
        `cut -f1-3,5 $hs_sample{$sample_cnt} > $hs_param{"outdir"}/$sample_cnt/input.bg`;
        $bglist .= " $hs_param{'outdir'}/$sample_cnt/input.bg";
    }
}
close(F);

#sample process 
`bedtools  unionbedg -i $bglist > $hs_param{'outdir'}/input.all.bg`;
open(FW,">$hs_param{'outdir'}/raw.diff.bed");
open(F,"$hs_param{'outdir'}/input.all.bg");
while(<F>){
    chomp;
    my @ar_tmp = split(/\t/,$_);
    my $chr = shift(@ar_tmp );
    my $st = shift(@ar_tmp );
    my $ed = shift(@ar_tmp );
    my $stddev   = stddev(@ar_tmp);
    print FW "$chr\t$st\t$ed\t.\t$stddev\n";
}
close(F);
close(FW);

sub GET_DATAROOT{
    my $dbh = shift;
    my $sth;

    $mysql_search_query = 'select path from metadata where data_type = "dataroot"';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root;
}

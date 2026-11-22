#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use POSIX;
use JSON;

my $spc_n = shift;
my @ranges = @ARGV;

#### world
### Constant_DB
my $database = "mysql:KUBDS"; ## find from database
my $db_user = "webtest"; ## constant, not argument
my $db_passwd = ''; ## constant, not argument
my $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");
##for DBwork
my $sth;
my @search_result=();
my $mysql_search_query = "";

my $assembly_id = GET_DATA_PATH($dbh, $spc_n);
my $DIR_assembly = GET_DATAROOT($dbh)."/GENOME/";
my $seq_f = "$DIR_assembly/$assembly_id/$assembly_id.fa";
my $index_f = "$seq_f\.fai";

if (! -f $seq_f || ! -f $index_f) {
    print STDERR "[Error] There is no sequence file in $seq_f\n";
}

my @ptrs = ();
my %chrindex = ();

my %qseqs = ();
foreach my $range (@ranges) {
	my ($qchr, $qbeg, $qend) = split(/:|-/, $range);
	my $line_byte = 0;

	my ($start_l_byte, $start_bp, $end_l_byte, $end_bp) = (0,0,0,0);
	open(RF, $index_f);
	while(<RF>){
		chomp;
		my ($chr, $len, $bptr, $l_len, $l_byte) = split(/\s+/);
		$line_byte = $l_byte;

		if($qchr eq $chr){
			$start_l_byte = ((ceil($qbeg / $l_len)-1)*$l_byte) + $bptr;
			$start_bp = ($qbeg % $l_len == 0) ? $l_len : $qbeg % $l_len;
			$end_l_byte = ((ceil($qend / $l_len)-1)*$l_byte) + $bptr;
			$end_bp = ($qend % $l_len == 0) ? $l_len : $qend % $l_len;
		} else { next; }
	}
	close RF;

	my $qseq = "";
	my $num = 1;
	open(RF, "<", $seq_f);
	seek(RF, $start_l_byte, 0);
	while(<RF>){
		chomp;
		my $cptr = tell(RF);
		if ($start_l_byte == $end_l_byte) {
			$qseq = substr($_, $start_bp - 1, $end_bp-$start_bp + 1);
		} else {
			if ($cptr == $start_l_byte + $line_byte) {
				$qseq = substr($_, $start_bp-1);
			} elsif ($cptr == $end_l_byte + $line_byte) {
				$qseq .= substr($_, 0, $end_bp);
			} else {
				$qseq .= $_;
			}
		}
		$num++;

		if ($cptr > $end_l_byte) { last; } 
	}
	close RF;

	$qseqs{$range} = $qseq;
}

print JSON->new->pretty->encode(\%qseqs);

###################################################################################

sub GET_DATAROOT{
    my $dbh = shift;
    my $_spc_n = shift;
    my $sth;

    $mysql_search_query = 'select path from metadata where data_type = "dataroot"';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root;
}

sub GET_DATA_PATH {
    my $dbh = shift;
    my $_spc_n = shift;
    my $sth;

    $mysql_search_query = 'select taxon_id from taxon_id where name = "'.$_spc_n.'"';
    print STDERR "$mysql_search_query\n";
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my ($_taxon_id) = $sth->fetchrow_array();

    $mysql_search_query = "select assembly_id from assembly where taxon_id = '$_taxon_id'";
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my $_assembly_id = $sth->fetchrow_array();

    return $_assembly_id;
}

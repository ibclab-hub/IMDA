#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Switch;
my $pid = shift;
my $session_id = shift;
my $job_id = shift;

### Constant_DB
my $database = "mysql:KUBDS"; ## find from database
my $db_user = "webtest"; ## constant, not argument
my $db_passwd = ''; ## constant, not argument
my $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");

my $DIR_work = GET_DATAROOT($dbh)."/progress/$session_id/$job_id/";
my $get_ID = `cat $DIR_work/tmp.id.txt`;
chomp($get_ID);
my ($type, $id) = split(/_/,$get_ID);
DATAID_update_del($dbh, $type, $id);

## Kill job by pid
`kill -15 $pid`;
`kill -15 \`cat $DIR_work/pid.txt\``;
`touch $DIR_work/cancel`;

sub GET_DATAROOT{
    my $dbh = shift;
    my $sth;

    my $mysql_search_query = 'select path from metadata where data_type = "dataroot"';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root;
}
sub DATAID_update_del{
    my $dbh = shift;
    my $analysis = shift;
    my $dataid = shift;
    switch($analysis){
        case "RNA" {
            $dbh->do('delete from Transcriptome where data_id ='. $dataid.";");
        }
        case "METH" {
            $dbh->do('delete from  Epigenome_Meth where data_id = '.$dataid.';');

        }
        case "CHIP" {
            $dbh->do('delete from  Epigenome_ChIP where data_id = '.$dataid.';');
        }
        case "HIC" {
            $dbh->do('delete from Epigenome_HiC where data_id = '.$dataid.';');
        }
    }
}

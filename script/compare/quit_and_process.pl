#!/usr/bin/perl
#

use strict;
use warnings;
use DBI;
use JSON;

my $database = "mysql:KUBDS"; ## find from database
my $db_user = "webtest"; ## constant, not argument
my $db_passwd = ''; ## constant, not argument
my $dbh = DBI->connect("DBI:$database",$db_user,$db_passwd) or die("Error connecting to the database: $DBI::errstr\n");

my $sth;
my $mysql_search_query ;
$mysql_search_query = 'select path from metadata where data_type = "dataroot"';
$sth = $dbh->prepare($mysql_search_query);
$sth->execute();
my($root) = $sth->fetchrow_array();
chomp($root);


my $sid = shift;
my $jid = shift;
my $pid = shift;

$mysql_search_query = 'select analysis from session_info where  session_id= ? and job_number=?';
$sth = $dbh->prepare($mysql_search_query);
$sth->execute($sid, $jid);
my($curStep) = $sth->fetchrow_array();
chomp($curStep);

my $dataroot = $root;
my $dir_progress = $dataroot."/progress/$sid/$jid";

my $f_log = $dataroot."/progress/$sid/$jid/log.txt";
my $DIR_work = $dataroot."/progress/$sid/$jid/";
`touch $dataroot/progress/$sid/$jid/cancel`;



`kill -15 $pid`;
`kill -15 \`cat $DIR_work/alignment/pid.txt\``;
`kill -15 \`cat $DIR_work/alignment/*/pid.txt\``;

## additional process 

my $lastzPids_run = `cat $dataroot/progress/$sid/$jid/alignment/*/done/pid.run`;
my $lastzPids_done = `cat $dataroot/progress/$sid/$jid/alignment/*/done/pid.done`;


my %done = ();
foreach my $done_id (split(/\n/,$lastzPids_done)){
    $done{$done_id} = 1;
}

foreach my $run_id (split(/\n/,$lastzPids_run)){
    if (!exists($done{$run_id})){
        `kill -15 $run_id`;
    }
}

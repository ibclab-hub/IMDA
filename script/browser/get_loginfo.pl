#!/usr/bin/perl
#
use strict;
use warnings;
use FindBin '$Bin';
use DBI;
use JSON;

my $session_id = shift;
my $type = shift;

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

my $job_dir = GET_DATAROOT($dbh)."/progress/$session_id/";


my @job_status = ();
if(-d $job_dir){
    opendir my $DIR, $job_dir or die;
    my @dirs =  grep { ! /^\./ && -d "$job_dir/$_" } readdir $DIR;
    closedir $DIR;

    foreach my $job_id (@dirs){
        my $job_type = "";
        my $job_pid = "";
        my $main_category = "";
        my $middle_category = "";
        my $sub_category = "";
        my $sample_info = "";
        my $accession_info = "";
        #my $cmd = "";
        my @job_infos = ();
        
        if (!(-e "$job_dir/$job_id/log.txt")) { next; } # by JK
        open(RF, "$job_dir/$job_id/log.txt");
        while(<RF>){
            chomp;

            if($_ =~ /^####/){
                my $info = substr($_, 5);
                my @col = split(/\s+/, $info);

                $job_type = "$col[0] $col[1]";
                $job_pid = $col[2];
            } elsif($_ =~ /^###/){
                $main_category = substr($_, 4);
            } elsif($_ =~ /^##/){
                $middle_category = substr($_ ,3);
            } elsif($_ =~ /^#/){
                my $info_str = substr($_, 2);
                my @info = split(/->/, $info_str);
                $sub_category = $info[0];
                #$cmd = $info[1];
                $sub_category =~ s/\s+$//;
                #$cmd =~ s/^\s+//;
            } elsif ($_ =~ /^\*\*/) {
                $accession_info = substr($_, 3);   
            } elsif ($_ =~ /^\*/) {
                $sample_info = substr($_, 2);
            }
        }
        close RF;

        if (!(-e "$job_dir/$job_id/log.txt")) { next; } # by JK
        open(RF, "$job_dir/$job_id/log.txt");
        my @logs = <RF>;
        my %job_info = ("PID" => $job_pid, "ID" => $job_id, "Main" => $main_category, "Middle" => $middle_category, "Sub" => $sub_category, "Sample" => $sample_info, "Accession" => $accession_info, "Log" => \@logs);
        close RF;
        $job_info{"Done"} = (-f "$job_dir/$job_id/done")? "true" : "false";
        $job_info{"Cancel"} = (-f "$job_dir/$job_id/cancel") ? "true" : "false";
        $job_info{"Error"} = (-f "$job_dir/$job_id/error") ? "true" : "false";
    
        if(($job_type eq "Multiomics analysis" && $type eq "multiomics") || ($job_type ne "Multiomics analysis" && $type ne "multiomics")){
            push(@job_status, \%job_info);
        }
    }
}

print JSON->new->pretty->encode(\@job_status);

#### Functions
sub GET_DATAROOT{
    my $dbh = shift;
    my $sth;

    $mysql_search_query = 'select path from metadata where data_type = "dataroot"';
    $sth = $dbh->prepare($mysql_search_query);
    $sth->execute();
    my($root) = $sth->fetchrow_array();
    return $root;
}


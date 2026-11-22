package MY_DB_SEARCH;
use strict;
use warnings;


sub DO_SEARCH_QUERY{
    my $database = shift(@_);
    my $db_user = shift(@_);
    my $dbh = DBI->connect("DBI:$database",$db_user,) or die("Error connecting to the database: $DBI::errstr\n");
    my $mysql_search_query = shift(@_);
    my $argus = shift(@_);
    my $sth = $dbh->prepare($mysql_search_query);
    $sth->execute($argus);
    my @search_result = $sth->fetchrow_array();
    return($search_result[0]);
}
1;

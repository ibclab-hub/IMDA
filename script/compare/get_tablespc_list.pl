#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use JSON;

my $db_name = "KUBDS";
my $user_id = "webtest";
my $password = '';

my %species = ();

# connect to MySQL database
my $dbh = DBI->connect("DBI:mysql:$db_name",$user_id,$password) or die("Error connecting to the database: $DBI::errstr\n");

my $asm_sql = 'SELECT CONCAT (t2.name, "\t", t2.common_name, "\t" , a.breed, "\t", t.common_name,"\t" ) AS assembly_information FROM assembly a INNER JOIN species_tax_info i ON a.taxon_id=i.tax_species INNER JOIN taxon_id t ON i.tax_kingdom=t.taxon_Id INNER JOIN taxon_id t2 ON i.tax_species=t2.taxon_id;';
my $asm_sth = $dbh->prepare($asm_sql);
$asm_sth->execute();
while(my @row = $asm_sth->fetchrow_array()){
	my @col = split(/\s+/, $row[0]);
	
	$species{$col[0]}{$col[2]} = "$col[1]\t$col[3]";
}

my @species_json = ();
foreach my $sci_name ( sort keys %species ){
	my @asmids = sort keys %{$species{$sci_name}};
	my ($com_name, $kingdom) = split(/\t/, $species{$sci_name}{$asmids[0]});	

	my %curspc = ( "Scientific_name" => $sci_name, "Assembly" => \@asmids, "common_name" => $com_name, "class" => $kingdom );
	push (@species_json, \%curspc);
}

my $json = encode_json \@species_json;
print "$json\n";

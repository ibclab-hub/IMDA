#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use JSON::PP qw(encode_json);

my @species = @ARGV;
die "Expected 2 to 100 assembly IDs\n" if @species < 2 || @species > 100;
for my $id (@species) {
    die "Invalid assembly ID\n" unless $id =~ /\A[A-Za-z0-9_.-]+\z/;
}
my %unique = map { $_ => 1 } @species;
die "Duplicate assembly IDs\n" unless keys(%unique) == @species;

# Use the same DB credentials / secure configuration as get_synteny_desc.pl.
my $dbh = DBI->connect(
    "DBI:mysql:database=KUBDS", "webtest", "",
    { RaiseError => 1, PrintError => 0, mysql_enable_utf8mb4 => 1 }
);


# Convert assembly names (breed) to internal assembly IDs
my $placeholders = join(',', ('?') x @species);

my $assembly_sql =
    "SELECT assembly_id, breed FROM assembly " .
    "WHERE breed IN ($placeholders)";

my $assembly_sth = $dbh->prepare($assembly_sql);
$assembly_sth->execute(@species);

my %assembly_ids;

while (my ($id, $breed) = $assembly_sth->fetchrow_array()) {
    die "Ambiguous assembly name: $breed\n"
        if exists $assembly_ids{$breed};

    $assembly_ids{$breed} = $id;
}
$assembly_sth->finish();

# Check that all selected assemblies exist
for my $spc (@species) {
    die "Assembly not found: $spc\n"
        unless exists $assembly_ids{$spc};
}

# Retrieve evolutionary distances using numeric assembly IDs
my @ids = map { $assembly_ids{$_} } @species;

my $sql =
    "SELECT species1, species2, distance FROM distance " .
    "WHERE species1 IN ($placeholders) " .
    "AND species2 IN ($placeholders)";

my $sth = $dbh->prepare($sql);
$sth->execute(@ids, @ids);


my %distances;

while (my ($id1, $id2, $distance) = $sth->fetchrow_array()) {
    next unless defined($distance)
        && $distance =~ /\A(?:\d+(?:\.\d*)?|\.\d+)\z/;

    my $key = ($id1 < $id2)
        ? "$id1\t$id2"
        : "$id2\t$id1";

    $distances{$key} = 0 + $distance;
}

$sth->finish();
$dbh->disconnect();

my @pairs;

for (my $i = 0; $i < @species; $i++) {
    for (my $j = $i + 1; $j < @species; $j++) {

        my ($spc1, $spc2) = ($species[$i], $species[$j]);

        my $id1 = $assembly_ids{$spc1};
        my $id2 = $assembly_ids{$spc2};

        my $key = ($id1 < $id2)
            ? "$id1\t$id2"
            : "$id2\t$id1";

        push @pairs, {
            species1 => $spc1,
            species2 => $spc2,
            distance => exists($distances{$key})
                ? $distances{$key}
                : undef
        };
    }
}

print encode_json({ pairs => \@pairs });


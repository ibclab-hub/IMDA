#!/usr/bin/perl
use strict;
use warnings;
use JSON::PP;
use File::Spec;

my ($data_dir, $query) = @ARGV;
my $json = JSON::PP->new->utf8->canonical;

sub output { print $json->encode(shift); exit; }
output({error => 'Missing data directory or gene name'}) unless defined($data_dir) && defined($query) && length($query);
output({error => 'Data directory not found'}) unless -d $data_dir;

my $formatfile = File::Spec->catfile($data_dir, 'file_format.txt');

open(my $ff, '<', $formatfile);
my $format = <$ff> // '';
close $ff;
chomp $format;
output({error => 'Dataset is not a gene annotation'}) unless $format eq 'gtf' || $format eq 'gff';

opendir(my $dh, $data_dir) or output({error => 'Cannot read annotation directory'});
my @files = sort grep { /\.(?:gtf|gff)$/i && -f File::Spec->catfile($data_dir, $_) } readdir($dh);
closedir($dh);
output({error => 'Annotation file not found'}) unless @files;

my $file = File::Spec->catfile($data_dir, $files[0]);
open(my $fh, '<', $file) or output({error => 'Cannot read annotation file'});
my @matches;
my %seen;
my $needle = lc($query);
while (my $line = <$fh>) {
    next if $line =~ /^#/;
    next if index(lc($line), $needle) == -1;

    chomp $line;
    my @f = split /\t/, $line, 9;
    next unless @f >= 9 && $f[2] eq 'gene';
    my ($chr, $start, $end, $attrs) = ($f[0], $f[3], $f[4], $f[8]);
    next unless $start =~ /^\d+$/ && $end =~ /^\d+$/;
    my %a;
    if ($format eq 'gtf') {
        while ($attrs =~ /([\w.:-]+)\s+"([^"]*)"/g) { $a{$1} = $2; }
    } else {
        for my $pair (split /;/, $attrs) {
            my ($k, $v) = split /=/, $pair, 2;
            $a{$k} = $v if defined($k) && defined($v);
        }
    }
    my @names = grep {defined($_) && length($_)} @a{qw(gene_name gene_id Name ID)};
    next unless grep {lc($_) eq lc($query)} @names;
    my $key = join(':', $chr, $start, $end);
    next if $seen{$key}++;
    my $flnk = ($end - $start) / 4;
    push @matches, {chr => $chr, start => $start - $flnk, end => $end + $flnk, id => ($a{gene_id} // $a{ID} // ''), name => ($a{gene_name} // $a{Name} // '')};
    last if @matches >= 100;
}
close $fh;
output({matches => \@matches});


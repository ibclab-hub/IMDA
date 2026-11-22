#!/usr/bin/perl

use strict;
use warnings;
use FindBin '$Bin';
use Getopt::Long;
use File::Basename;
use Switch;

my $config_f;
my $project_n;
my $data_f;
my $data_type;
my $raw_res = 1;
my $size_f;
my $track_id;
my $load = "copy";
my $outdir = "./";
my $help = 0;

## Get options for adding data
GetOptions(
	"config|c=s" => \$config_f,
	"project|p=s" => \$project_n,
	"id|i=s" => \$track_id,
	"data|d=s" => \$data_f,
	"type|t=s" => \$data_type,
	"binsize|s=i" => \$raw_res,
	"gsize|g=s" => \$size_f,
    "load|l=s" => \$load,
    "outdir|o=s" => \$outdir,
    "help|h" => \$help
);

#if ($help == 1 || !$config_f || (!$project_n && !$data_f && !$track_id) ) {
if ($help == 1) {
	&usage();
} elsif (!$config_f && !$data_f) {
	&usage();
}

## Check parameters
if (! -d $outdir) {
	`mkdir -p $outdir`;
}

if ($load ne "copy" && $load ne "symlink" && $load ne "move") {
	print STDERR "There is no available method \"$load\" for loading data. Please check the parameter!\n";
	exit;
}

my %tar_data = ();
if ($config_f) {
	if (! -f $config_f) { 
		print STDERR "Check the config file\n";
		exit;
	} else {
		open(F, $config_f);
		while(<F>) {
			chomp;
			if ($_ =~ /^#/) { next; }
			if ($_ eq "") { next; }
			my ($prj_n, $id, $res, $dtype, $sf, $path) = split(/\s+/);
			$tar_data{$id}{'project_n'} = $prj_n;
			$tar_data{$id}{'raw_res'} = $res;
			$tar_data{$id}{'type'} = $dtype;
			$tar_data{$id}{'size'} = $sf;
			$tar_data{$id}{'dpath'} = $path;
		}
		close(F);
	}
} else {
	if (!defined($data_type)) {
		print STDERR "Please provide --type option!\n";
		exit;
	} else {
		if ($data_type ne "bed" && $data_type ne "bedpe") {
			print STDERR "No available data type!\n";
			exit;
		}
	}
	my $id = $track_id;
	$tar_data{$id}{'project_n'} = $project_n;
	$tar_data{$id}{'raw_res'} = $raw_res;
	$tar_data{$id}{'type'} = $data_type;
	$tar_data{$id}{'size'} = $size_f;
	$tar_data{$id}{'dpath'} = $data_f;
}

################################################################################################

foreach my $id (keys %tar_data) {
	my $data_dir = "$outdir/$tar_data{$id}{'project_n'}/$id";
	`mkdir -p $data_dir`;

	# Load raw data
	my $orig_data_n = basename($tar_data{$id}{'dpath'});
	my $raw_data_f = "$data_dir/raw_$tar_data{$id}{'raw_res'}.$orig_data_n";;
	my $raw_data_idx_res = $tar_data{$id}{'raw_res'} * 50000;
	&Load_data($tar_data{$id}{'dpath'}, $raw_data_f, $load, $size_f, $data_type);
	print STDERR "# Indexing data...\n";
	`$Bin/index_data.pl $raw_data_f $raw_data_idx_res > $raw_data_f.idx`;

	print STDERR "# Data downsampling and indexing...\n";
	if ($tar_data{$id}{'type'} eq "bedpe") {
		`$Bin/downsample_bedpe.pl $data_dir $tar_data{$id}{'size'} $raw_data_f $tar_data{$id}{'raw_res'} $orig_data_n`;
	} else {
		`$Bin/downsample_data.pl $data_dir $tar_data{$id}{'size'} $raw_data_f $tar_data{$id}{'raw_res'} $orig_data_n`;
	}

    my $dat_type_f = "$data_dir/file_format.txt";
    open(W2, ">$dat_type_f");
    print W2 "$tar_data{$id}{'type'}\n";
    close(W2);
}


################################################################################################

sub usage {
    print STDERR "\n======================================================================================\n\n";
    print STDERR "Usage:\n<For multiple data>\n\$ add_data.pl -c [config_file] -o [outdir]\n";
    print STDERR "<For single data>\n\$ MultiOVIS add_data.pl -o [outdir] -p [project_name] -i [track_id] -d [data_path] -t [data_type] -s [binsize] -g [size_file_path] -l [copy|symlink|move]\n\n";
    print STDERR "Options:\n";
    print STDERR "\t-c|--config\t<path> Config file\n";
    print STDERR "\t-p|--project\tProject name to add data\n";
    print STDERR "\t-i|--id\tTrack id for data\n";
    print STDERR "\t-d|--data\t<path> Data file\n";
    print STDERR "\t-o|--outdir\t<path> Out directory path\n";
    print STDERR "\t-t|--type\tType for data [bed|bedpe]\n";
    print STDERR "\t-s|--binsize\tBin size for the input data\n";
    print STDERR "\t-g|--gsize\t<path> Genome size file for target species\n";
    print STDERR "\t-l|--load\tMethod for managing data directory [copy|symlink|move]\n";
    print STDERR "\t-h|--help\tPrint usages\n";
    print STDERR "\n======================================================================================\n\n";
    exit;

}

sub Load_data {
    my $_path = shift;
    my $_new_path = shift;
    my $_load = shift;
    my $_chr_size_f = shift;
    my $_data_type = shift;

    my $error_msg = "";
    my $success = 0;

    if (! -f $_chr_size_f) {
        $error_msg = "There is no chromosome size file $_chr_size_f\n";
        return $error_msg, $success;
    }
    my %chr_info = ();
    open(S, $_chr_size_f);
    while(<S>) {
        chomp;
        my ($chr, $size) = split(/\s+/);
        $chr_info{$chr} = $size;
    }
    close(S);

    if ($_load eq "copy") {
        if ($_data_type eq "bedpe") {
            `sort -k1,1 -k2,2n -k3,3n -k4,4 -k5,5n -k6,6n $_path > $_new_path.sort.tmp`;
        } else {
            `sort -k1,1 -k2,2n -k3,3n $_path > $_new_path.sort.tmp`
        }
        open(P, "$_new_path.sort.tmp");
        open(N, ">$_new_path");
        while(<P>) {
            chomp;
            my @cols = split(/\s+/);
            if ($_data_type eq "bedpe") {
                if (! exists $chr_info{$cols[0]}) {
                    print STDERR "[Warning] There is no $cols[0] in target genome. Skip this line!\n$_\n";
                } elsif (! exists $chr_info{$cols[3]}) {
                    print STDERR "[Warning] There is no $cols[3] in target genome. Skip this line!\n$_\n";
                } else {
                    print N "$_\n";
                }
            } else {
                if (! exists $chr_info{$cols[0]}) {
                    print STDERR "[Warning] There is no $cols[0] in target genome. Skip this line!\n$_\n";
                } else {
                    print N "$_\n";
                }
            }
        }
        close(N);
        close(P);
        `rm -f $_new_path.sort.tmp`;
        return 1, "";
    } else {
        $error_msg = "[ERROR] Not supported\n";
        return $error_msg, $success;
    }
}

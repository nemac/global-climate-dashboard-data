#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'http://nomads.ncdc.noaa.gov/data/NCSP/Dashboard/outfile_sresb1.csv';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_proj_temp_low_case.csv';

#----------------------------------------------------#

my $output = '';

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4}),\s+([\d\.\-]+)\s*$/) {
		my $yr = $1;
		my $val = $2;
		
		$output .= "$yr,$val\n";
	}
}

writeData($LOCAL_FILE_NAME, $output);


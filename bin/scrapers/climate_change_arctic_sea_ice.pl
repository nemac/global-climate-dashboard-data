#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-07)
#
#asi:
#    Download URL: ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/Sep/N_09_area.txt
#
#    Processing:
#      * Original data file consists of a header line followed by lines containing
#        6 fixed-column whitespace-separated values.  The first value on each line is
#        a 4-digit year, second value is the month, and the 5th value is the desired
#        "extent" value
#      * Eliminate all lines that do not start with a 4-digit number followed by whitespace
#        (we can't simply eliminate lines containing alpha chars because the 3rd column
#        of data ('data_type') is a text field).
#      * Combine the first two columns (year and month) into a 6-digit YYYYMM format
#      * Drop all values except for this YYYYMM value, and the 5th value ("extent")
#      * Final output contains 2 values on each line, separated by a comma: YYYYMM and extent
#
#    Example Original Data:
#        line   1: year mo    data_type region extent   area
#        line   2: 1979  9      Goddard      N   7.20   4.53
#        line   3: 1980  9      Goddard      N   7.85   4.83
#        ...
#
#    Example Processed Data:
#        line   1: 197909,7.20
#        line   2: 198009,7.85
#        line   3: 198109,7.25
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/Sep/N_09_area.txt';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_arctic_sea_ice.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\s+(\d{1,2})\s+\S+\s+\S+\s+(\d+\.\d+)\s+\S+/) {
		my $yr = $1;
		my $mon = $2;
		my $extent = $3;

		if (length($mon) == 1) {
			$mon = '0' . $mon; # pad with leading zero
		}

		$output .= "$yr$mon,$extent\n";
		$lineCount++;
	}
}

# This data set is yearly and starts in 1979.  Check that we're getting
# at least [current_year - 1979] lines of output 
my $expectedLineCount = getCurrentYear() - 1979;
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


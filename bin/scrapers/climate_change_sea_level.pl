#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-16)
#
#sealevel:
#
#    Download URL: ftp://ftp.marine.csiro.au/pub/white/gmsl_files/CSIRO_Recons.csv
#
#     Processing:
#       * Original data consists of a header line, followed by lines containing
#         3 comma-and-whitespace-separated values.  The first value on each line
#         is the year, always given with a ".5" suffix. The second value is the
#         desired sea level value.
#       * Eliminate the header line by eliminating lines that do not contain 3
#         numbers separated by commas (and whitespace)
#       * Eliminate the 3rd column of values (the uncertainty values)
#       * Truncate the year (1st column) to a whole number
#       * Eliminate the whitespace between the 1st column and 2nd column
#       * Final output contains two comma-separated values per line:
#         4-digit year, GMLS value (mm)
#
#    Example Original Data:
#         line   1: "Time","GMSL (mm)","GMSL uncertainty (mm)"
#         line   2: 1880.5, -157.1,   24.2
#         line   3: 1881.5, -151.5,   24.2
#         ...
#
#     Example Processed Data:
#         line   1: 1880,-157.1
#         line   2: 1881,-151.5
#         line   3: 1882,-168.3
#         ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);

use lib qw($Bin/../../lib);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'ftp://ftp.marine.csiro.au/pub/white/gmsl_files/CSIRO_Recons.csv';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_sea_level.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\.5,\s*([\d\.\-]+)/) {
		my $yr = $1;
		my $val = $2;
		
		$output .= "$yr,$val\n";
		$lineCount++;
	}
}

# This data set is yearly and starts in 1880 and ends in 2009 (as of 2011-12-26)
# Check that we are getting a reasonable number of results.
my $expectedLineCount = getCurrentYear() - 1880 - 2;
#print "EXPECTED= $expectedLineCount\nCOUNT=$lineCount\n";
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


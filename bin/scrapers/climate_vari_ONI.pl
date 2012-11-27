#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-07)
#
#oni:
#    Download URL: ftp://ftp.cpc.ncep.noaa.gov/NCSP/Dashboard/ONI.for
#
#    Processing:
#      * Original data file consists of two comma-separated values per line.  The first value represents the
#        year and month in YYYY-MM format (with a dash); the second value is the desired index value.
#      * Remove the dash between the year and month value in the 1st column
#      * Remove any spaces between fields, leaving just a comma
#      * Final output contains two comma-separated values per line:
#        year-month value in YYYYMM format (no dash), index value
#
#    Example Original Data:
#        line   1: 1950-01,-1.700
#        line   2: 1950-02,-1.500
#        line   3: 1950-03,-1.300
#        ...
#
#    Example Processed Data:
#        line   1: 195001,-1.700
#        line   2: 195002,-1.500
#        line   3: 195003,-1.300
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'ftp://ftp.cpc.ncep.noaa.gov/NCSP/Dashboard/ONI.for';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_vari_ONI.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\-(\d{2}),\s*(\-?\d{1,2}\.\d+)/) {
		my $yr = $1;
		my $mon = $2;
		my $val = $3;
		
		$output .= "$yr$mon,$val\n";
		$lineCount++;
	}
}

# This data set is monthly and starts in 1950 
# Check that we are getting a reasonable number of results.
my $expectedLineCount = 12 * (getCurrentYear() - 1950 - 1);
#print "EXPECTED= $expectedLineCount\nCOUNT=$lineCount\n";
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}

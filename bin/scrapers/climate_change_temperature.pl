#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-12)
#
#temperature:
#    Download URL: ftp://ftp.ncdc.noaa.gov/pub/data/anomalies/annual.land_ocean.90S.90N.df_1901-2000mean.dat
#
#    Processing:
#      * Original data contains 2 whitespace-separated values on each line.  The first is a 4-digit year,
#        and the second is the desired temperature anomaly number.  The original data file uses the convention
#        of a value of -999 to represent missing data.
#      * Replace the whitespace separation between the year and value with a single comma
#      * Eliminate any lines whose 2nd column is < -100 (to eliminate the -999 missing values)
#
#    Example Original Data:
#        line   1: 1880   -0.1314
#        line   2: 1881   -0.0705
#        line   3: 1882   -0.0881
#        ...
#
#    Example Processed Data:
#        line   1: 1880,-0.1314
#        line   2: 1881,-0.0705
#        line   3: 1882,-0.0881
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";


# Where to get the data from
my $DATA_URL = 'ftp://ftp.ncdc.noaa.gov/pub/data/anomalies/annual.land_ocean.90S.90N.df_1901-2000mean.dat';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_temperature.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\s+([\d\.\-]+)/) {
		my $yr = $1;
		my $val = $2;
		
		# -999 represents no data available, so skip any numbers less than -100
		if ($val < -100) {
			next;  #skip this data point
		}
		else {
			$output .= "$yr,$val\n";
			$lineCount++;
		}
	}
}

# This data set is yearly and starts in 1880
# Check that we are getting a reasonable number of results.
my $expectedLineCount = getCurrentYear() - 1880 - 1;
#print "EXPECTED= $expectedLineCount\nCOUNT=$lineCount\n";
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


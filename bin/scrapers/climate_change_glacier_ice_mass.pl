#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-07)
#
#glacier:
#    Download URL: http://www1.ncdc.noaa.gov/pub/data/cmb/bams-sotc/2009/global-data-sets/GLACIER_wgms_ref_glaciers.txt
#
#    Processing:
#      * Original data consists of lines containing two whitespace separated values: a 4-digit year, followed
#        by a floating point glacier mass balance number.  The first 130 values in the file (for years 1850 to 1979)
#        are given as 'NaN', as is the last value, for year 2009, at the time of this writing.  The value plotted
#        in the dashboard graph is the cumulative sum of these (non-NaN) values, divided by 1000.
#      * For each non-NaN value in the input, compute its cumulative sum with all the previous non-NaN values
#      * First output value on each line is the 4-digit year
#      * Second output value on each line is the cumulative sum, divided by 1000, to 4 decimal places
#      * The first line of output should be for the the last NaN value in the input file immediately
#        preceeding the first non-NaN value; this is currently for 1979.  In other words, in the original
#        data file, the string of NaN values at the beginning of the file runs up through and including
#        1979; the first line in our output should be for the year 1979, with a value of 0.
#      * Final output contains two values on each line: year, cumulative sum divided by 1000
#      * Original data file contains documenting comments after the last line of data, so ignore
#        any lines that do not contain two whitespace-separated values, the first of which is a
#        4-digit year.
#
#    Example Original Data:
#        line   1: 1850        NaN
#        line   2: 1851        NaN
#        ...
#        line 130: 1979        NaN
#        line 131: 1980   -160.0000
#        line 132: 1981    -60.0000
#        line 133: 1982   -480.0000
#        ...
#
#    Example Processed Data:
#        line   1: 1979,0
#        line   2: 1980,-0.1600
#        line   3: 1981,-0.2200
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'http://www1.ncdc.noaa.gov/pub/data/cmb/bams-sotc/2009/global-data-sets/GLACIER_wgms_ref_glaciers.txt';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_glacier_ice_mass.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my $printed_first_val = 0;
my $sum = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\s+([\-\.\dNa]+)\s*$/) {
		my $yr = $1;
		my $val = $2;
		
		if ($val eq 'NaN') {
			next;  #skip this data point
		}
		else {
			if (! $printed_first_val) {
				$output .= sprintf("%4d,0\n", $yr - 1);
				$printed_first_val = 1;
			}
			$sum += $val;
			$output .= sprintf("%s,%.4f\n", $yr, $sum/1000);
			$lineCount++;
		}
	}
}

# This data set is yearly and starts in 1980; currently ends in 2008.  
# Check that we are getting a reasonable number of results.
my $expectedLineCount = getCurrentYear() - 1980 - 4;
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


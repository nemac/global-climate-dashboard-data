#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-07)
#
#ohc:
#    Download URL: ftp://ftp.nodc.noaa.gov/pub/data.nodc/woa/DATA_ANALYSIS/3M_HEAT_CONTENT/DATA/basin/3month/ohc_levitus_climdash_seasonal.txt
#
#    Processing:
#      * Original data file consists of two comma-separated values per line.  The first value represents the
#        year and month in YYYY-MM format (with a dash); the second value is the desired ocean heat content value.
#        [*** Added by Charlie Roberts: 
#           The month can be a single digit and will need to be zero-padded, if so.]
#      * Remove the dash between the year and month
#      * Otherwise output the original data exactly as is
#      * Final output consists of two comma-separated values per line: year/month in YYYYMM (no dash) format, followed
#        by ocean heat content value
#
#    Example Original Data:
#        line   1: 1955-03,-2.870925
#        line   2: 1955-06,-0.113296
#        line   3: 1955-09,-1.813742
#        ...
#
#    Example Processed Data:
#        line   1: 195503,-2.870925
#        line   2: 195506,-0.113296
#        line   3: 195509,-1.813742
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'ftp://ftp.nodc.noaa.gov/pub/data.nodc/woa/DATA_ANALYSIS/3M_HEAT_CONTENT/DATA/basin/3month/ohc_levitus_climdash_seasonal.txt';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_ocean_heat_content.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\-(\d{1,2})\s*,\s*(\-?\d+\.\d+)\s*$/) {
		my $yr = $1;
		my $mon = $2;
		my $val = $3;
		
		if (length($mon) == 1) {
            $mon = '0' . $mon; # pad with leading zero
        }
        
		$output .= "$yr$mon,$val\n";
		$lineCount++;
	}
}

# This data set is quarterly and starts in 1955.  
# Check that we are getting a reasonable number of results.
my $expectedLineCount = 4 * (getCurrentYear() - 1955) - 1;
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


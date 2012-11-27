#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-12)
#
#snow:
#    Download URL: http://climate.rutgers.edu/snowcover/files/ru-mean-march-april-anomalies-nhland.txt
#
#    Processing:
#      * Original data contains two whitespace-separated (actually tab-separated) values
#        on each line; first value is a 4-digit year, second value is the snow cover
#        amount.  The value plotted in the dashboard graph is this amount divided by
#        1 million.
#      * replace the whitespace (tab) separation between date and value with a single comma
#      * divide 2nd column by 1000000
#      * Final output contains two comma-separated values on each line:
#        4-digit year, snow cover amount / 1000000
#
#    Example Original Data:
#        line   1: 1967  2257261
#        line   2: 1968  -2951414
#        line   3: 1969  348671
#        ...
#
#    Example Processed Data:
#        line   1: 1967,2.257261
#        line   2: 1968,-2.951414
#        line   3: 1969,0.348671
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'http://climate.rutgers.edu/snowcover/files/ru-mean-march-april-anomalies-nhland.txt';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_snow_cover.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\s+([\d\.\-]+)/) {
		my $yr = $1;
		my $val = $2;
		
		# -999.000 means no data available
		if ($val =~ /^\-999/) {
			next;  #skip this data point
		}
		else {
			$val = sprintf("%.6f", $val / 1000000);  # format value
			$output .= sprintf("%s,%s\n", $yr, $val);
			$lineCount++;
		}
	}
}

# This data set is yearly and starts in 1967
# Check that we are getting a reasonable number of results.
my $expectedLineCount = getCurrentYear() - 1967;;
#print "EXPECTED= $expectedLineCount\nCOUNT=$lineCount\n";
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


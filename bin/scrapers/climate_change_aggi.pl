#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-07)
#
#aggi:
#    Download URL: http://www.esrl.noaa.gov/gmd/aggi/AGGI_Table.csv
#
#    Processing:
#      * Original data file consists of a header line followed by lines containing
#        9 or 10 comma-separated values.  The first value on each line is a 4-digit
#        year, and the 9th value on each line is the desired AGGI value.
#      * Eliminate the header line by dropping any lines containing alphabetic characters
#      * Drop all values except the year and AGGI value (values 1 and 9) from each line
#      * Final output contains 2 values on each line, separated by a comma: year and AGGI
#
#    Example Original Data:
#        line   1: Year,CO2,CH4,N2O,CFC12,CFC11,15-minor,Total,AGGI
# 1990 = 1,AGGI
# % change
#        line   2: 1979,1.026,0.419,0.104,0.092,0.039,0.031,1.71,0.79,
#        line   3: 1980,1.056,0.426,0.104,0.096,0.042,0.034,1.76,0.81,2.7
#        ...
#
#    Example Processed Data:
#        line   1: 1979,0.79
#        line   2: 1980,0.81
#        line   3: 1981,0.83
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";


# Where to get the data from
my $DATA_URL = 'http://www.esrl.noaa.gov/gmd/aggi/AGGI_Table.csv';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_aggi.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
my $firstLine = 0;
foreach my $line (@data) {
	my @lineItems = split(',', $line);
	# Check for expected data columns
	if ($firstLine++ == 0) {
		if ($lineItems[0] ne 'Year' || $lineItems[8] !~ /^AGGI/) {
			LOG_ERROR("Unexpected column headers! Data not updated.");
			exit 0;
		}
		next;	
	}

	if ($lineItems[0] =~ /^\d{4}$/ && $lineItems[8] =~ /^[\d\.\-]+$/) {
		$output .= $lineItems[0] . "," . $lineItems[8] . "\n";
		$lineCount++;
	}
}

# This data set is yearly and starts in 1979.  Check that we're getting
# at least [current_year - 1980] lines of output 
my $expectedLineCount = getCurrentYear() - 1980;
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
	writeData($LOCAL_FILE_NAME, $output);
}


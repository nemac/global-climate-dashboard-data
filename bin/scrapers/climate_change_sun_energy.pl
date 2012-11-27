#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-07)
#
#sunsenergy:
#    Download URL: http://lasp.colorado.edu/lisird/tss/historical_tsi.csv
#
#    Processing:
#      * Original data begins with a header line, followed by lines of comma-separated values.
#        The first value on each line is the year, specified with a ".5" suffix.  The second
#        value is the sun's energy amount.  Note that lines in this file use a DOS-style
#        carriage-return (ascii code 13) at the end of each line.
#      * Eliminate the header line by omitting any line that doesn't look like a comma-separated
#        pair of numbers
#      * Truncate year value (1st column) to a whole number
#      * Eliminate the carriage return (ascii code 13) from each line
#
#    Example Original Data:
#        line   1: time (years since 0000-01-01),Irradiance (W/m^2)
#        line   2: 1610.5,1360.6802
#        line   3: 1611.5,1360.6633
#        ...
#
#    Example Processed Data:
#        line   1: 1610,1360.6802
#        line   2: 1611,1360.6633
#        line   3: 1612,1361.0612
#        ...
#------------------------------------------------------------------------------
use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'http://lasp.colorado.edu/lisird/tss/historical_tsi.csv';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_sun_energy.csv';

#----------------------------------------------------#

my $output = '';
my $lineCount = 0;

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^(\d{4})\.5,([\d\.\-]+)/) {
		my $yr = $1;
		my $val = $2;

		$output .= "$yr,$val\n";
		$lineCount++;
	}
}

# This data set is yearly and starts in 1610.  Check that we're getting
# a reasonable number of lines of output 
my $expectedLineCount = getCurrentYear() - 1610 - 2;
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}


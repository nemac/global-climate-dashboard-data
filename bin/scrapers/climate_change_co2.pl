#!/usr/bin/perl
#------------------------------------------------------------------------------
# Documentation from http://dashboard.nemac.org/datadetails/  (2011-12-02)
#
#co2:
#    Download URL: ftp://ftp.cmdl.noaa.gov/ccg/co2/trends/co2_mm_mlo.txt
#
#    Processing:
#      * Original data file starts with several lines of comments, each comment line
#        starting with a '#' character, followed by several lines of 7 fixed-column
#        whitespace-separated values.
#      * First value on each non-comment line is year, second value is month, and 5th value
#        is desired "interpolated" co2 value
#      * Construct 6-digit YYYYMM value by combining the first two values; this is the first
#        output value
#      * Second output value is "interpolated" co2 value from 5th column of input data
#      * Third output value is a 12-month running mean of the second output ("interpolated"
#        co2) value; use -9999.0 to denote missing for the first eleven values.  Round
#        computed values to 2 decimal places.
#      * Final output contains 3 values per line, separated by commas:
#        YYYYMM, interpolated co2, running mean interpolated co2
#
#    Example Original Data:
#        line   1: # --------------------------------------------------------------------
#        line   2: # USE OF NOAA ESRL DATA
#        line   3: # 
#        line   4: # These data are made freely available to the public and the
#        line   5: # scientific community in the belief that their wide dissemination
#        ...
#        line  71: #            decimal     average   interpolated    trend    #days
#        line  72: #             date                             (season corr)
#        line  73: 1958   3    1958.208      315.71      315.71      314.61     -1
#        line  74: 1958   4    1958.292      317.45      317.45      315.29     -1
#        line  75: 1958   5    1958.375      317.50      317.50      314.71     -1
#        ...
#
#    Example Processed Data:
#        line   1: 195803,315.71,-9999.0
#        line   2: 195804,317.45,-9999.0
#        line   3: 195805,317.50,-9999.0
#        line   4: 195806,317.10,-9999.0
#        line   5: 195807,315.86,-9999.0
#        line   6: 195808,314.93,-9999.0
#        line   7: 195809,313.20,-9999.0
#        line   8: 195810,312.66,-9999.0
#        line   9: 195811,313.33,-9999.0
#        line  10: 195812,314.67,-9999.0
#        line  11: 195901,315.62,-9999.0
#        line  12: 195902,316.38,315.37
#        line  13: 195903,316.71,315.45
#        line  14: 195904,317.72,315.47
#        ...
#------------------------------------------------------------------------------

use strict;
use warnings;

use FindBin qw ($Bin);
require "$Bin/common.pm";

# Where to get the data from
my $DATA_URL = 'ftp://ftp.cmdl.noaa.gov/ccg/co2/trends/co2_mm_mlo.txt';

# File name to store formatted data
my $LOCAL_FILE_NAME = 'climate_change_co2.csv';

#----------------------------------------------------#

my $output = '';

my $lineCount = 0;
my @last12 = ();

my @data = getURL($DATA_URL);
foreach my $line (@data) {
	if ($line =~ /^\s*#/) { next; } # skip comments

	if ($line =~ /^(\d{4})\s+(\d{1,2})\s+\S+\s+\S+\s+(\d+\.\d+)\s+/) {
		my $yr = $1;
		my $mon = $2;
		my $interpolated_val = $3;

		if (length($mon) == 1) {
			$mon = '0' . $mon; # pad with leading zero
		}
		
		# Keep last 12 running values
		push(@last12, $interpolated_val);
		while ($#last12 >= 12) {
			shift(@last12);
		}
		
		# -99.99 means missing data
        if ($interpolated_val == -99.99) {
            next;  #skip this data point
        }
        if (!$yr || !$mon || !$interpolated_val) {
        	next; #skip line with missing data points
        }
		
		my $running_mean;
		if ($#last12 == 11) {
			$running_mean = sprintf("%.2f", avg(@last12));
		}
		else {
			$running_mean = "-9999.0";
		}
		
		$output .= "$yr$mon,$interpolated_val,$running_mean\n";
		$lineCount++;
	}
}

# This data set is monthly and starts in 1958-03.  Check that we're getting
# at least [current_year minus 1958 minus 3] lines of output 
my $currentYr = getCurrentYear();
my $expectedLineCount = 12 * ($currentYr - 1958 - 3);
if ($lineCount < $expectedLineCount) {
    LOG_ERROR("Expected at least $expectedLineCount lines of data, but only have $lineCount");
}
else {
    writeData($LOCAL_FILE_NAME, $output);
}

exit;

sub avg {
    my @vals = @_;
    my $sum = 0;
    foreach my $v (@vals) { $sum += $v; }
    return $sum / ($#vals + 1.0);
}
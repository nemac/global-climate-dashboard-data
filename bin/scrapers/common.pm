package main;

use FindBin qw($Bin);
use LWP::UserAgent;

$LOG_FILE = "$Bin/../../data_update.log";
$DATA_DIR = "$Bin/../../data/";  # include ending slash


sub getURL($) {
	my $url = shift;
	
	# NOTE: Had to put "Mozilla" as UserAgent to prevent getting '403 Forbidden' 
	# from an obnoxiously configured host.
	my $ua = LWP::UserAgent->new(
		agent=>'Mozilla/5.0',
		timeout=>30
	);
	my $response = $ua->get($url);
	if ($response->is_success) {
		my @content = split("\n", $response->decoded_content);
		return @content;
	}
	else {
		LOG_ERROR("Problem getting '$url': " .$response->status_line);
		return undef;
	}
}

sub writeData($$) {
	my ($filename, $content) = @_;
	
	if (!$content) {
		LOG_ERROR("No data/content provided for writing. '$filename' not updated");
		return;
	}

	my $file = $DATA_DIR . $filename;
	open(FILE, ">$file") or die "Couldn't open '$file' for writing = $!";
	print FILE $content;
	close(FILE); 

	LOG_INFO("wrote data to: $file");
	
	truncateLog();
}

sub getCurrentYear() {
	return (localtime())[5] + 1900;
}

sub LOG_INFO($) {
	my $msg = shift;
	_LOG('INFO', $msg);
}

sub LOG_WARN($) {
	my $msg = shift;
	_LOG('WARN', $msg);
}

sub LOG_ERROR($) {
	my $msg = shift;
	_LOG('ERROR', $msg);
}

sub _LOG($$) {
	my ($level,$msg) = @_;

    $msg = _prefixScriptName($msg);
    
    if ($level =~ /^ERR/ || $level =~ /^WARN/) {
    	print STDERR "$level: $msg\n";
    }

	my $date = `date "+%Y-%m-%d %H:%M:%S"`;
	chomp($date);

	open(LF, ">>" . $LOG_FILE) or die "Couldn't open ". LOG_FILE . " for appending - $!";
	print LF "$date $level: $msg\n";
	close(LF);
}

sub _prefixScriptName($) {
    my $msg = shift;
    my $name = $0;
    $name =~ s/(.*\/)?(.+)\.pl$/$2.pl/;
    return "[$name] $msg"; 
}

sub truncateLog() {
	system("tail -n5000 $LOG_FILE > $LOG_FILE.tmp") == 0 or warn "ERROR: truncating log file (1): $?\n";
	system("mv $LOG_FILE.tmp $LOG_FILE") == 0 or warn "ERROR: truncating log file (2): $?\n";
}

1;

use Getopt::Long;
use warnings;
BEGIN {
	require 'Nigdip/nigdip.pl';
}

sub main {
	my $server = '';
	my $port = 0;
	my $ssl = '';
	
	GetOptions(
		"server=s" => \$server,
		"port=i" => \$port,
		"ssl" => \$ssl
		);

	die ('server and port are required') if (!$server || !$port);
	Nigdip::loadScripts("plugins");	
	Nigdip::connect($server, $port, $ssl);
}

main();

use Getopt::Long;
use warnings;
BEGIN {
	require 'Nigdip/nigdip.pl';
	require 'Nigdip/core.pl';
}

sub loadScripts {
	my $folder = shift @_;
	opendir (DIR, $folder) or die $!;
	while (my $file = readdir(DIR)) {
		# only .pl files
		next if ($file !~ m/\.pl$/);
		print "loading script $folder/$file\n";
		Nigdip::load("$folder/$file");
	}
	closedir(DIR);
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
	loadScripts("plugins");	
	Bot->new(
		server => $server,
		port => $port,
		nick => "test",
		channels => [ "#perl"]
		);
}

main();

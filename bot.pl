BEGIN {
	require 'nigdip/nigdip.pl';
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
}


loadScripts("plugins");
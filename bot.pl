BEGIN {
	require 'nigdip/nigdip.pl';
}

Nigdip::load('plugins/test.pl');
Nigdip::unload('plugins/test.pl');
if (open my $handle, '>plugins/test.pl') {
	print $handle "print \"JEESUS SAATANA\"\n";
	close $handle;
}
Nigdip::load('plugins/test.pl');
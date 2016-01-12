BEGIN {
	require 'nigdip/nigdip.pl';
}

Nigdip::load('plugins/test.pl');
Nigdip::unload('plugins/test.pl');
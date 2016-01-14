Nigdip::register('disable', 'Module to disable commands');

sub onLoad {
	Nigdip::bindCommand('disable', \&disable, 'disable <command name>');
}

sub disable {
	print "from disable\n";
}
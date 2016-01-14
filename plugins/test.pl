
Nigdip::register('test', 'test desc');

sub onLoad {
	print "onLoad called from test.pl\n";
	Nigdip::bindCommand('test', \&callback, 'helping gg');
	Nigdip::bindCommand('test2', \&callback, 'helping gg');
	Nigdip::unbindCommand('test2');
}

sub callback {
	print "from cb\n";
}

sub onEnable {
	print "enable called from test.pl\n";
}

sub onDisable {
	print "onDisable called from test.pl\n";
}

sub onUnload {
	print "onUnload called from test.pl\n";
}
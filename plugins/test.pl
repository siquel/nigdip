
Nigdip::register('test', 'test desc');

sub onLoad {
	print "onLoad called from test.pl\n";
	Nigdip::bindCommand('test', \&callback, 'helping gg');
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

}
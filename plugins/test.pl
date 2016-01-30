use Data::Dumper;
Nigdip::register('test', 'test desc');
sub onLoad {
	print "onLoad called from test.pl\n";
	Nigdip::bindCommand('test', \&callback, 'helping gg');
}

sub callback {
	my ($bot, $args) = @_;
	$bot->say(body=>"Haista vittu Pidgin.", channel=>$args->{channel});
}

sub onEnable {
	print "enable called from test.pl\n";
}

sub onDisable {
	print "onDisable called from test.pl\n";
}

sub onUnload {

}

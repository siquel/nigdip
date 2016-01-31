

sub onLoad {
	Nigdip::bindCommand('echo', \&handleEcho, 'echo <str>');
}

sub handleEcho {
	my ($bot, $args) = @_;
	$bot->say(body=>$args->{body}, channel=>$args->{channel});
}
sub onLoad {
	Nigdip::bindCommand('youtube', \&youtube, 'youtube <query>');
}

sub youtube {
	my ($bot, $args) = @_;
	$bot->say(channel=>$args->{channel}, body=>"Not implemented yet.");
}

use warnings;
Nigdip::register('disable', 'Module to disable commands');

sub onLoad {
	Nigdip::bindCommand('disable', \&disable, 'disable <command name>');
}

sub disable {
	my ($bot, $args) = @_;
	$bot->say(
		channel => $args->{channel},
		body => "aamujaa :D"
		);
}
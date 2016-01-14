use warnings;
Nigdip::register('disable', 'Module to disable commands');

sub onLoad {
	Nigdip::bindCommand('disable', \&disable, 'disable <command name>');
	Nigdip::tryFireEventForCommand('disable');
}

sub disable {
	#my ($sender, $message, $channel) = @_;
	print "DIS";
}
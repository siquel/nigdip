package Bot;
use Bot::BasicBot;
use base qw(Bot::BasicBot);
use warnings;
my $prefix = '!';

sub said {
	my $self = shift;
	my $data = shift;
	my $msg = $data->{body};

	return undef if ($msg !~ /^$prefix/i);
	
	$msg =~ m/^$prefix(\w+)\s?/i;
	my $cmd = $1;
	Nigdip::tryFireEventForCommand($cmd, $data);
	return undef;
}
1;

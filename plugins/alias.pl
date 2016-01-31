
my %aliases;

sub onLoad {
	Nigdip::bindCommand('alias', \&parseAlias, 'alias <name> <alias expr>');
}

sub onUnload {
	foreach my $func (keys %aliases) {
		Nigdip::unbindCommand($func);
	}
}

sub parseAlias {
	my ($bot, $args) = @_;
	my $expr = $args->{body};

	#extract the name of alias 
	my @tokens = split(/ /, $expr);
	#the alias needs at least 2 tokens, 1 for the name, 1 for the command to execute
	if (scalar @tokens < 2) {
		$bot->say(channel=>$args->{channel}, body=>"Invalid amount of arguments, expected 2 but got " . scalar @tokens);
		return;
	}
	my $aliasName = $tokens[0];
	$expr =~ s/$aliasName //i;

	createAlias($aliasName, $expr);
}

sub createAlias {
	my ($name, $expr) = @_;
	return if exists $aliases{$name};
	# first we need to get it trigger TODO: if it exists already
	# so we are going to bind it as command
	Nigdip::bindCommand($name, \&parseExpression, 'TODO ADD HELP TEXT SOMEHOW');
	$aliases{$name}{expression} = $expr;

}

sub parseExpression {
	my ($bot, $args, $command) = @_;

	my $expr = $aliases{$command}{expression};
	my $rawParams = $args->{body};

	#$expr =~ s/\$0/$rawParams/ig;

	my @commands;
	my @rawCommands;
	# find all commands in pipe
	do { push @commands, $1 if $_ =~ m/(^[\w\d_-]+)/ } foreach (@rawCommands = split(/\s*\|\s*/, $expr));
	#extract 
	foreach my $index (0 .. $#commands) {
		my $command = @commands[$index];
		my $expression = @rawCommands[$index] =~ s/$command\s*//i;
		$args->{body} = $expression =~ s/\$0/$rawParams/g;
		Nigdip::tryFireEventForCommand($command, $args);
	}
	$bot->say(body=>"possible commands are: " . join(',', @commands) , channel=>$args->{channel});
	#$bot->say(body=>"Executing $expr", channel=>$args->{channel});
}
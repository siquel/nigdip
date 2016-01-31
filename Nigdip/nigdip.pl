package Nigdip;
use warnings;
use strict;
use File::Basename ();
use File::Spec();
use Symbol();
BEGIN {
	require 'Nigdip/core.pl';
}

our %plugins;
my $bot;
our $PluginRoot = '';

sub loadScripts {
	my $folder = shift @_;
	$Nigdip::PluginRoot = "$folder/";
	opendir (DIR, $folder) or die $!;
	while (my $file = readdir(DIR)) {
		# only .pl files
		next if ($file !~ m/\.pl$/);
		print "loading script $folder/$file\n";
		Nigdip::load("$folder/$file");
	}
	closedir(DIR);
}

sub connect {
	my ($server, $port, $ssl) = @_;
	$bot = Bot->new(
		server => $server,
		port => $port,
		nick => "nigdip",
		channels => [ "#kahvipaussi"],
		ssl => $ssl
		);
	$bot->run();
}

sub register {
	my ($name, $desc) = @_;
	my $pkg = findPackage();
	if (isRegistered($pkg)) {
		my $info = packageInfo($pkg);
		my $file = $info->{filename};
		print STDERR "Trying to register $file more than once!";
		return 1;
	}
	$plugins{$pkg}{name} = $name;
	$plugins{$pkg}{desc} = $desc;
	$plugins{$pkg}{loaded} = 1;
}

sub hookServer {
	return undef unless @_ >= 2;
	my ($message, $callback) = @_;

	my $pkg = findPackage();
	my $info = packageInfo($pkg);

	unless (ref $callback) {
		print STDERR "callback isn't reference";
		return undef;
	}

	push @{$info->{hooks}}, { 
		message => $message,
		callback => $callback
		};
	my @asd = @{$info->{hooks}};
	return $asd[-1];
}

sub bindCommand {
	my ($cmd, $callback, $help) = @_;
	my $hook = hookServer('PRIVMSG', $callback);
	$hook->{name} = $cmd;
	$hook->{help} = $help; 
}

sub unbindCommand {
	my ($name) = shift @_;
	my $pkg = findPackage();
	return unless (exists $plugins{$pkg}{hooks});
	my @hooks = @{$plugins{$pkg}{hooks}};
	my ($index) =  (grep { defined $hooks[$_]->{name} && $hooks[$_]->{name} eq $name} 0..$#hooks);
	return unless (defined $index);
	splice(@{$plugins{$pkg}{hooks}}, $index, 1);
}

sub unload {
	my $file = shift @_;
	my $pkg = file2Package($file);
	my $info = packageInfo($pkg);

	if ($info) {
		print "unloading $file = $pkg\n";

		if (hasFunction($pkg, 'onUnload')) {
			eval("$pkg\::onUnload()");
		}

		Symbol::delete_package($pkg);
		delete $plugins{$pkg};
		return 0;
	} 
	print STDERR "$file is not loaded";
	return 1;
}

sub load {
	my $file = shift @_;
	my $pkg = file2Package($file);
	if (exists $plugins{$pkg}) {
		my $info = packageInfo($pkg);
		my $filename = File::Basename::basename($info->{filename});
		print STDERR "File $file already loaded\n";
		return 2;
	}
	if (open my $handle, $file) {
		my $src = do { local $/; <$handle>};
		close $handle;

		$plugins{$pkg}{filename} = $file;
		my $fullpath = File::Spec->rel2abs($file);
		$src =~ s/^/#line 1 "$fullpath"\n\x7Bpackage $pkg;/;
		# add }
		$src =~ s/\Z/\x7D/;
		_eval($src);
		# theres error
		if ($@) {
			$@ =~ s/\(eval \d+\)/$file/g;
			print STDERR "Error loading '$file': \n $@\nUnloading..\n";
			Nigdip::unload($plugins{$pkg}{filename});
			return 1;
		}
		if (hasFunction($pkg, 'onLoad')) {
			eval("$pkg\::onLoad()");
		}

	} else {
		print STDERR "error opening $file : $!\n";
		return 3;
	}

	return 0;
}

sub hasFunction {
	my $module = shift @_;
	my $func = shift @_;
	no strict 'refs';
	return grep { defined &{"$module\::$func"} } keys %{"$module\::"} ;
}

sub _eval {
	no strict;
	no warnings;
	eval $_[0];
}

sub findPackage {
	my $level = 1;
	while (my ($pkg, $file, $line) = caller($level++)) {
		return $pkg if $pkg =~ /^Nigdip::Plugin::/;
	}
	die "Unable to determine pkg";
}

sub command2Package {
	my $cmd = @_;
	foreach my $pkg (keys %plugins) {
		my @hooks = @{$plugins{$pkg}{hooks}};
		for my $hook (@hooks) {
			next unless defined $hook->{name};
			return $pkg if $hook->{name} eq $cmd;
		}
	}
	return undef;
}

sub tryFireEventForCommand {
	my ($cmd, $args) = @_;
	my $pkg = command2Package($cmd);
	print "$pkg\nggggg";
	# the command does not exist
	return unless ($pkg);
	my @hooks = @{$plugins{$pkg}{hooks}};
	my ($index) =  (grep { defined $hooks[$_]->{name} && $hooks[$_]->{name} eq $cmd} 0..$#hooks);
	return unless defined $index;
	$hooks[$index]->{callback}->($bot, $args, $cmd);
}

sub packageInfo {
	my $pkg = shift @_;
	return $plugins{$pkg};
}

sub isRegistered {
	my $info = packageInfo(shift @_);
	return defined $info->{loaded};
}

sub file2Package {
	my $str = File::Basename::basename(shift @_);
	$str =~ s/\.pl$//i;
	$str =~ s|([^A-Za-z0-9/])|'_'.unpack("H*",$1)|eg;
	return "Nigdip::Plugin::$str";
}

1;

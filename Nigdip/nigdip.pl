package Nigdip;
use warnings;
use strict;
use File::Basename ();
use File::Spec();
use Symbol();

our %plugins;

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
	my %hook = (
		message => $message,
		callback => $callback
	);
	push @{$info->{hooks}}, %hook;
	my @asd = @{$info->{hooks}};
	print $asd[0]."----------\n";
	return \%hook;
}

sub bindCommand {
	my ($cmd, $callback, $help) = @_;
	my $hook = hookServer('PRIVMSG', $callback);
	$hook->{name} = $cmd;
	$hook->{help} = $help; 
	my $pkg = findPackage();
	my $info = packageInfo($pkg);
	print @{$info->{hooks}};
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
	} else {
		print STDERR "$file is not loaded";
	}
}

sub load {
	my $file = shift @_;
	my $pkg = file2Package($file);
	print $pkg;
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
		print "loaded $file = $pkg\n";
		if (hasFunction($pkg, 'onLoad')) {
			eval("$pkg\::onLoad()");
		}

	} else {
		print STDERR "error opening $file : $!\n";
		return 1;
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
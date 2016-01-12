package Nigdip;
use warnings;
use strict;
use File::Basename ();
use File::Spec();
use Symbol();

our %plugins;

sub register {
	my ($name) = shift @_;

}

sub unload {
	my $file = shift @_;
	my $pkg = file2Package($file);
	my $info = packageInfo($pkg);

	if ($info) {
		print "unloading $file = $pkg\n";
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
		if (hasFunction($pkg, 'enable')) {
			eval("$pkg\::enable()");
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

sub file2Package {
	my $str = File::Basename::basename(shift @_);
	$str =~ s/\.pl$//i;
	$str =~ s|([^A-Za-z0-9/])|'_'.unpack("H*",$1)|eg;
	return "Nigdip::Plugin::$str";
}

1;
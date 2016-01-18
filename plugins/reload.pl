use warnings;
use strict;

#my $filename = File::Basename::basename(__FILE__);

sub onLoad {
	Nigdip::bindCommand('reload', \&reload, "Use reload <script name.pl> to reload script");
}

sub reload {
	my ($bot, $args) = @_;
	my $file = $args->{body};
	$bot->say(
		channel => $args->{channel},
		body => "Trying to reload $file"
		);
	if (Nigdip::unload($file)) {
		$bot->say(channel => $args->{channel}, body => "$file is not loaded");
		return;
	}
	# 0 means everything went succesfully
	if (!Nigdip::load($Nigdip::PluginRoot . $file)) {
		$bot->say(
			channel => $args->{channel},
			body => "$Nigdip::PluginRoot$file reloaded succesfully"
		);	
	} else {
		$bot->say(
			channel => $args->{channel},
			body => "Error loading file: $file"
		);	
		$bot->say(body => $@, channel => $args->{channel}) if ($@);
	}
	
	
}
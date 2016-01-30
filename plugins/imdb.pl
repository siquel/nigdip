use WebService::OMDB;
use JSON;

sub onLoad {
	Nigdip::bindCommand('imdb', \&imdb, 'imdb gg');
}

sub search {
	my $what = shift @_;
	return WebService::OMDB::title($what);
}

sub imdb {
	my ($bot, $args) = @_;
	my $msg = $args->{body};
	my $obj = search($msg);
	my $out = formatImdb($obj);
	if ($out) {
		$bot->say(channel => $args->{channel}, body => "http://imdb.com/title/$obj->{imdbID}/");
		$bot->say(channel => $args->{channel}, body => $out) ; 
	} else {
		$bot->say(channel => $args->{channel}, body => "Cant find $msg");
	}
}

sub formatImdb {
	my $ref = shift @_;
	return undef if $ref->{Response} eq "False";
	return "[ $ref->{Title} ($ref->{Year}) ] | [ $ref->{Genre} ] | [ Runtime: $ref->{Runtime} ] | [ Rating: $ref->{imdbRating} ]";
}

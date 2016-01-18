use warnings;
use strict;
use Mojo::DOM;
use JSON;
require URI::Encode;
require LWP::UserAgent;

my $uri = URI::Encode->new( { encode_reserved => 0 } );
my $agent = LWP::UserAgent->new(
	agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:37.0) Gecko/20100101 Firefox/37.0"
	);

my $file = 'conf/GOOGLE_API_KEY';
my $apiurl = "https://www.googleapis.com";

my $APIKEY;

sub onLoad {
	if (open my $handle, $file) {
		my $row = <$handle>;
		chomp $row;
		$APIKEY = $row;
		close $handle;
	} else { 
		print STDERR "$file does not exists\n"; 
	}

	if(!$APIKEY) {
		print STDERR "No API key\n";
		die("No API key");
	}

	Nigdip::bindCommand('google', \&google, "Use google <search str>");
}

sub search {
	my $what = shift @_;
 	my $query = $uri->encode($what);
 	my $searchengine = '001637570775039008129:yvww_gjxf00';
 	my $url = "$apiurl/customsearch/v1?key=$APIKEY&cx=$searchengine&q=$query";
 	my $response = $agent->get($url);
 	my $json = decode_json($response->decoded_content);
 	return $json;
}

sub google {
	my ($bot, $args) = @_;

	my $json = search($args->{body});
	
	foreach my $result (@{$json->{items}}) {
		next if ($result->{kind} ne "customsearch#result");
		my $title = $result->{title};
		my $link = $result->{link};
		my $out = "$title -> $link";
		$bot->say(channel => $args->{channel}, body => $out);
		return; #todo x amount of results
	}
}
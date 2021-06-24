package gemprox;
use Dancer2;
use utf8;

our $VERSION = '0.1';
use Net::Gemini;
use Text::Gemini;

set template => 'simple';

sub to_html {
	my ($url) = @_;
	my $res = Net::Gemini::GET($url);
	if (!$res) {
		return sprintf('<div class="error">oops: %s</div>', $GEMINI_ERROR);
	} elsif ($res->is_success) {
		my $s = Text::Gemini::to_html($res->content);

		my $host = $url; $host =~ s|(gemini://.*?)/.*|$1|;
		$url =~ s|^gemini://|/|;

		$s =~ s|href="//|href="gemini://|g;
		$s =~ s|href="/|href="$host/|g;
		$s =~ s|href="gemini://|href="/gemini/|g;

		utf8::decode($s);
		return $s;

	} elsif ($res->is_redirect) {
		print STDERR ">> redirecting to [".$res->header."]\n";
		return to_html($res->header);

	} else {
		return sprintf('<div class="error">%s %s</div>', $res->status, $res->error);
	}
}

get '/' => sub {
	template 'proxy', {
		path  => '',
		html  => to_html('gemini://jameshunt.us/gemprox/welcome.gmi'),
		title => 'gemprox | gemini.zyxl.xyz',

		ogtitle       => 'gemprox - An HTTP -&gt; Gemini proxy',
		ogdescription => 'Browse the Gemini world, from the comfort of your own HTTP browser.',
	};
};

get '/gemini/**' => sub {
	my ($splat) = splat;
	my $gemini = sprintf('gemini://%s', join('/', @$splat));
	print STDERR ">> looking up [$gemini]\n";
	template 'proxy', {
		path  => join('/', @$splat),
		html  => to_html($gemini),
		title => $gemini.' | gemprox | gemini.zyxl.xyz',

		ogtitle       => $gemini,
		ogdescription => "The $gemini site, but this time in HTTP!",
	};
};

get '/v1/go' => sub {
	return to_html(query_parameters->{url});
};

true;

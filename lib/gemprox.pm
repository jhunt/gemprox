package gemprox;
use Dancer2;
use utf8;

our $VERSION = '0.1';
use Net::Gemini;
use Text::Gemini;

set layout   => 'main';
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
	template 'index';
};

get '/gemini/**' => sub {
	my ($splat) = splat;
	my $gemini = sprintf('gemini://%s', join('/', @$splat));
	print STDERR ">> looking up [$gemini]\n";
	template 'proxy', {
		html => to_html($gemini),
	};
};

get '/v1/go' => sub {
	return to_html(query_parameters->{url});
};

true;

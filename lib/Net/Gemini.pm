package Net::Gemini;

use strict;
use warnings;

use URI;
use URI::gemini;
use IO::Socket::SSL;
use base 'Exporter';

our @EXPORT = qw/
  $GEMINI_ERROR
/;
our @EXPORT_OK = qw/
  GET
/;

use Net::Gemini::Response;

our $GEMINI_ERROR = '';

sub new {
	my ($class, $server, $port) = @_;
	bless({
		_server => $server,
		_port   => $port || 1965,
	}, ref($class) ? ref($class) : $class);
}

sub GET {
	my ($self, $url) = @_;
	if (!ref($self)) {
		my $u = URI->new($self);
		if ($u->scheme() ne 'gemini') {
			$GEMINI_ERROR = '"'.$self.'" is not a gemini:// url';
			return undef;
		}
		return __PACKAGE__->new($u->host(), $u->port())->GET($self);
	}

	my $sock = IO::Socket::SSL->new(
		PeerHost        => $self->{_server},
		PeerPort        => $self->{_port},
		SSL_verify_mode => SSL_VERIFY_NONE,
	) or do {
		$GEMINI_ERROR = $SSL_ERROR
			? "tls connect failed: $SSL_ERROR"
			: "connect failed: $!";
		return undef;
	};

	print $sock "$url\r\n";
	my $res = <$sock>;

	if ($res =~ m/^(\d\d) (.*?)\r?\n$/) {
		$GEMINI_ERROR = '';
		return Net::Gemini::Response->new($1, $2, $sock);

	} else {
		close $sock;
		$GEMINI_ERROR = 'unrecognized gemini protocol response';
		return undef;
	}
}

1;

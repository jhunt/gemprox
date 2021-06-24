package Net::Gemini::Response;

sub new {
	my ($class, $status, $header, $io) = @_;
	return bless({
		status => $status,
		header => $header,
		io     => $io,
	}, $class);
}

sub status {
	return $_[0]->{status};
}

sub header {
	return $_[0]->{header};
}

my @errors = (
	'Unknown Error',
	'Input Required',              # 1x
	'Success',                     # 2x
	'Redirected',                  # 3x
	'Temporary Failure',           # 4x
	'Permanent Failure',           # 5x
	'Client Certificate Required', # 6x
);
sub error {
	my $st = int($_[0]->{status} / 10);
	$st = 0 if ! exists $errors[$st];
	return $errors[$st];
}

sub is_input_needed                { return $_[0]->status =~ m/^1/; }
sub is_success                     { return $_[0]->status =~ m/^2/; }
sub is_redirect                    { return $_[0]->status =~ m/^3/; }
sub is_temporary_failure           { return $_[0]->status =~ m/^4/; }
sub is_permanent_failure           { return $_[0]->status =~ m/^5/; }
sub is_client_certificate_required { return $_[0]->status =~ m/^6/; }

sub content {
	my ($self) = @_;
	if (!$self->{content} && $self->{io}) {
		my $io = $self->{io};
		$self->{content} = do { local $/; <$io> };
		close $io;
		$self->{io} = undef;
	}
	return $self->{content};
}

1;

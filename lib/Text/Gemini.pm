package Text::Gemini;

use strict;
use warnings;

sub to_html {
	my ($src) = @_;
	my @lines = split /\n/, $src;

	my $HTML  = 1;
	my $PRE   = 2;
	my $LIST  = 3;
	my $QUOTE = 4;

	my $end;
	my @out;

	my $in = $HTML;
	for (@lines) {
		if (m/^$/) {
			if ($in == $HTML || $in == $QUOTE) {
				#push @out, "<br>\n";
				push @out, "\n";
			} else {
				push @out, "\n";
			}

		} elsif (m/^=>\s+(.*?)(\s+(.*))?$/) {
			if ($end) {
				push @out, "$end\n";
				$end = undef;
			}
			push @out, sprintf('<p><a href="%s">%s</a></p>'."\n", $1, $3 ? $3 : $1);

		} elsif (m/^```/) {
			if ($end) {
				push @out, "$end\n";
				$end = undef;
			}
			if ($in == $PRE) {
				$in = $HTML;
			} else {
				push @out, "<pre>\n";
				$in = $PRE;
				$end = '</pre>';
			}

		} elsif (m/^(#+)\s+(.*)$/) {
			if ($end) {
				push @out, "$end\n";
				$end = undef;
			}
			my $n = length($1);
			push @out, "<h$n>$2</h$n>\n";

		} elsif (m/^\*\s+(.*)$/) {
			if ($in != $LIST) {
				push @out, "$end\n" if $end;
				$in = $LIST;
				$end = '</li>';
				$in = $LIST;
			}
			push @out, "<li>$1</li>\n";

		} elsif (m/^>\s*(.*)$/) {
			if ($in != $QUOTE) {
				push @out, "$end\n" if $end;
				$in = $QUOTE;
				$end = '</blockquote>';
				push @out, "<blockquote>";
			}
			push @out, "$1\n";

		} else {
			if ($in == $PRE) {
				push @out, "$_\n";
			} else {
				if ($end) {
					push @out, "$end\n";
					$end = undef;
				}
				$in = $HTML;
				push @out, "<p>$_</p>\n";
			}
		}
	}
	if ($end) {
		push @out, "$end\n";
	}
	return join('', @out);
}

1;

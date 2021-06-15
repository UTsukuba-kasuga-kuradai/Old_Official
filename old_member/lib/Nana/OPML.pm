######################################################################
# OPML.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: OPML.pm,v 1.32 2007/07/15 07:40:09 papu Exp $
#
# "Nana::OPML" version 0.1 $$
# Author: Nanami
# http://lineage.netgamers.jp/
# Copyright (C) 2004-2007 by Nekyo.
# http://nekyo.hp.infoseek.co.jp/
# Copyright (C) 2005-2007 PyukiWiki Developers Team
# http://pyukiwiki.sourceforge.jp/
# Based on YukiWiki http://www.hyuki.com/yukiwiki/
# Powerd by PukiWiki http://pukiwiki.sourceforge.jp/
# License: GPL2 and/or Artistic or each later version
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# Return:LF Code=EUC-JP 1TAB=4Spaces
######################################################################

package Nana::OPML;
use strict;
use vars qw($VERSION);

$VERSION = '0.1';

# The constructor.
sub new {
	my ($class, %hash) = @_;
	my $self = {
		version => $hash{version},
		encoding => $hash{encoding},
		channel => { },
		items => [ ],
	};
	return bless $self, $class;
}

# Setting channel.
sub channel {
	my ($self, %hash) = @_;
	foreach (keys %hash) {
		$self->{channel}->{$_} = $hash{$_};
	}
	return $self->{channel};
}

# Adding item.
sub add_item {
	my ($self, %hash) = @_;
	push(@{$self->{items}}, \%hash);
	return $self->{items};
}

sub as_string {
	my ($self) = @_;
	my $nest=0;
	my $doc = <<"EOD";
<?xml version="1.0" encoding="$self->{encoding}"?>
<opml version="1.0">
<head>
	<title>$self->{channel}->{title}</title>
</head>
<body>
EOD
	foreach(@{$self->{items}}) {
		$_->{link}=~s/[\r\n]//g;
		$_->{title}=~s/[\r\n]//g;
		$_->{xmlurl}=~s/[\r\n]//g;
		if($_->{xmlurl} eq '') {
			$doc.=qq(</outline>\n) if($nest eq 1);
			$doc.=qq(<outline text="$_->{title}" title="$_->{title}">\n);
			$nest=1;
		} else {
			$doc.=qq(<outline htmlUrl="$_->{link}" text="$_->{title}" title="$_->{title}" type="@{[$_->{type} eq '' ? 'rss' : $_->{type}]}" xmlUrl="$_->{xmlurl}" />\n);
		}
	}
	$doc.=qq(</outline>\n) if($nest eq 1);
	$doc.=<<EOD;
</body>
</opml>
EOD
	return $doc;
}

1;
__END__


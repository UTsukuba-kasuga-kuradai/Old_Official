######################################################################
# RSS.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: RSS.pm,v 1.55 2007/07/15 07:40:09 papu Exp $
#
# "Yuki::RSS" version 0.3 $$
# Author: Hiroshi Yuki
# http://www.hyuki.com/
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

package Yuki::RSS;
use strict;
use vars qw($VERSION);

$VERSION = '0.3';

# The constructor.
sub new {
	my ($class, %hash) = @_;
	my $self = {
		version => $hash{version},
		encoding => $hash{encoding},
		channel => { },
		items => [],
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

# 
sub as_string {
	my ($self) = @_;
	my $doc = <<"EOD";
<?xml version="1.0" encoding="$self->{encoding}" ?>

<rdf:RDF
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns="http://purl.org/rss/1.0/"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
>

<channel rdf:about="$self->{channel}->{link}">
 <title>$self->{channel}->{title}</title>
 <link>$self->{channel}->{link}</link>
 <description>$self->{channel}->{description}</description>
 <items>
  <rdf:Seq>
   @{[
    map {
     qq{<rdf:li rdf:resource="$_->{link}" />}
    } @{$self->{items}}
   ]}
  </rdf:Seq>
 </items>
</channel>
@{[
 map {
  qq{
   <item rdf:about="$_->{link}">
    <title>$_->{title}</title>
    <link>$_->{link}</link>
    <description>$_->{description}</description>
    <dc:date>$_->{dc_date}</dc:date>
   </item>
  }
 } @{$self->{items}}
]}
</rdf:RDF>
EOD
}

1;
__END__


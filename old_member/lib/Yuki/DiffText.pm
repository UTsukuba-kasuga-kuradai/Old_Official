######################################################################
# DiffText.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: DiffText.pm,v 1.55 2007/07/15 07:40:09 papu Exp $
#
# "Yuki::DiffText" version 0.1 $$
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

package Yuki::DiffText;
use strict;
use Algorithm::Diff qw(traverse_sequences);
use vars qw($VERSION @EXPORT_OK @ISA);
use vars qw($diff_text $diff_msgrefA $diff_msgrefB @diff_deleted @diff_added);
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(difftext);
$VERSION = '0.1';

sub difftext {
	($diff_msgrefA, $diff_msgrefB) = @_;
	undef $diff_text;
	undef @diff_deleted;
	undef @diff_added;
	traverse_sequences(
		$diff_msgrefA, $diff_msgrefB,
		{
			MATCH => \&df_match,
			DISCARD_A => \&df_delete,
			DISCARD_B => \&df_add,
		}
	);
	&diff_flush;
	return $diff_text;
}

sub diff_flush {
	$diff_text .= join('', map { "-$_\n" } splice(@diff_deleted));
	$diff_text .= join('', map { "+$_\n" } splice(@diff_added));
}

sub df_match {
	my ($a, $b) = @_;
	&diff_flush;
	$diff_text .= "=$diff_msgrefA->[$a]\n";
}

sub df_delete {
	my ($a, $b) = @_;
	push(@diff_deleted, $diff_msgrefA->[$a]);
}

sub df_add {
	my ($a, $b) = @_;
	push(@diff_added, $diff_msgrefB->[$b]);
}

1;
__END__


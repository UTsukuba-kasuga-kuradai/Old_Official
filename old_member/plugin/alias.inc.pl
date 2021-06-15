######################################################################
# alias.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: alias.inc.pl,v 1.15 2007/07/15 07:40:09 papu Exp $
#
# "PyukiWiki" version 0.1.7 $$
# Author: Nanami http://lineage.netgamers.jp/
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
# Based on PukiWiki Plugin "alias.inc.php" ver.1.5 2005/05/28
# modified by kochi
# http://221.243.18.83/~pukiwiki/index.php?%A5%D7%A5%E9%A5%B0%A5%A4%A5%F3%2Falias.inc.php
######################################################################

use strict;

$alias::loopmax=2;

%alias::loopcount;
@alias::pushmypage;

sub plugin_alias_convert {
;
	my($page,$usethispagetitle)=split(/,/, shift);
	return ' ' if($::form{mypage}=~/($::MenuBar|$::SideBar|$::Header|$::Footer)$/);
	return ' ' if($::form{cmd} ne 'read');
	return ' ' if($::form{noalias} eq 'true');
	return ' ' if($alias::loopcount{$::form{mypage}} > 0);
	$alias::loopcount{$::form{mypage}}++;
	$alias::loopcount{""}++;
	return ' ' if($alias::loopcount{""} >= $alias::loopmax);

	push(@alias::pushmypage,$::form{mypage});
	my $title=$::form{mypage};
	$::form{mypage}=$page;
	if($usethispagetitle eq 1) {
		&do_read($title);
	} else {
		&do_read;
	}
	&close_db;
	exit;
}

1;
__END__


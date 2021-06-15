######################################################################
# time.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: time.inc.pl,v 1.43 2007/07/15 07:40:09 papu Exp $
#
# "PyukiWiki" version 0.1.7 $$
# Author: Nekyo
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

use strict;
use Time::Local;

sub plugin_time_convert {
	return &plugin_time_inline(@_);
}

sub plugin_time_inline {
	my ($format,$time) = split(/,/, shift);
	my ($h,$m,$s);

	$format=&htmlspecialchars($format);
	$time=&htmlspecialchars($time);

	if($format eq '') {
		return &date($::time_format);
	}
	$time=time if($time eq '');

	if($time=~/\:/) {
		my($sec, $min, $hour, $mday, $mon, $year,$wday, $yday, $isdst) = localtime;
		($h,$m,$s)=split(/\:/,$time);
		$time=Time::Local::timelocal($s,$m,$h,$mday,$mon,$year);
	}
	return &date($format,$time);
}

1;
__END__


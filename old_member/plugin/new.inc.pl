######################################################################
# new.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: new.inc.pl,v 1.58 2007/07/15 07:40:09 papu Exp $
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

$new::dates_short=1*24*60*60
	if(!defined($new::dates_short));
$new::dates_long=5*24*60*60
	if(!defined($new::dates_long));
$new::string_short=' <span class="new1">New!</span>'
	if(!defined($new::string_short));
$new::string_long=' <span class="new5">New</span>'
	if(!defined($new::string_long));

use Time::Local;

sub plugin_new_inline {
	my $date = shift;
	if ($date eq '') { return ''; }

	my $retval = $date;
	my ($mday, $mon, $year) = (localtime())[3..5];

	my $now=Time::Local::timelocal(0,0,0,$mday,$mon,$year);
	$date =~ /(\d+)-(\d+)-(\d+)/;
	my $past=Time::Local::timelocal(0,0,0,$3,$2-1,$1-1900);
	if (($now - $past) <= $new::dates_short) {
		$retval .= $new::string_short;
	} elsif (($now - $past) <= $new::dates_long) {
		$retval .= $new::string_long;
	}
	return '<span class="comment_date">' . $retval . '</span>';
}

1;
__END__


######################################################################
# online.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: online.inc.pl,v 1.58 2007/07/15 07:40:09 papu Exp $
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

$online::timeout = 300
	if(!defined($online::timeout));

sub plugin_online_inline {
	return &plugin_online_convert;
}

sub plugin_online_convert {
	my $file = $::online_dir . 'user.dat';

	if (!(-e $file)) {
		open(FILE, ">$file");
		close(FILE);
	}
	my $addr = $ENV{'REMOTE_ADDR'};

	open(FILE, "<$file");
	my @usr_arr = <FILE>;
	close(FILE);

	open(FILE, ">$file");
	my $now = time();
	my ($ip_addr, $tim_stmp);
	foreach (@usr_arr) {
		chomp;
		($ip_addr, $tim_stmp) = split(/|/);

		if (($now - $tim_stmp) < $online::timeout and $ip_addr ne $addr) {
			print FILE "$ip_addr|$tim_stmp\n";
		}
	}
	print FILE "$addr|$now\n";
	close(FILE);

	open(FILE, "<$file");
	@usr_arr = <FILE>;
	close(FILE);
	return @usr_arr;
}
1;
__END__


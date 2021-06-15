######################################################################
# hr.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: hr.pl,v 1.33 2007/07/15 07:40:09 papu Exp $
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

use strict;
package hr;

sub plugin_block {
	return &plugin_inline;
}

sub plugin_inline {
	return '<hr class="short_line" />';
}

sub plugin_usage {
	return {
		name => 'hr',
		version => '1.0',
		author => 'Nanami <nanami (at) daiba (dot) cx>',
		syntax => '#hr',
		description => '',
		example => '#hr',
	};
}

1;
__END__


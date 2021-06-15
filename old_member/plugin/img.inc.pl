######################################################################
# img.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: img.inc.pl,v 1.56 2007/07/15 07:40:09 papu Exp $
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

sub plugin_img_convert {
	my $argv = shift;
	my ($uri, $align, $alt) = split(/,/, $argv);
	$uri   = trim($uri);
	$align = trim($align);
	$alt = trim($alt);

	if ($align =~ /^(r|right)/i) {
		$align = 'right';
	} elsif ($align =~ /^(l|left)/i) {
		$align = 'left';
	} else {
		return '<div style="clear:both"></div>';
	}
	if ($uri =~ /^(http|https|ftp):/) {
		if ($uri =~ /\.(gif|png|jpeg|jpg)$/i) {
			return <<"EOD";
<div style="float:$align;padding:.5em 1.5em .5em 1.5em">
 <img src="$uri" alt="$alt" />
</div>
EOD
		}
	}
	return '';
}
1;
__END__


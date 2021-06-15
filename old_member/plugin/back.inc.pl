######################################################################
# back.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: back.inc.pl,v 1.13 2007/07/15 07:40:09 papu Exp $
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

$back::allowpagelink=0
	if(!defined($back::allowpagelink));
$back::allowjavascript=1
	if(!defined($back::allowjavascript));

use strict;

sub plugin_back_convert {
	my($str,$align,$hr,$link)=split(/,/,shift);
	my $body;
	$str=$::resource{backbutton} if($str eq '');
	$align="center" if($align eq '');
	if($hr+0 eq 0) {
		$hr="";
	} else {
		$hr=qq(<hr class="full_hr" />\n);
	}
	if($back::allowpagelink eq 0) {
		$link="";
	} elsif($link!~/$::isurl/) {
		$link = &make_cookedurl(&encode($link));
	}
	if($link eq "") {
		if($back::allowjavascript eq 1) {
			$body=<<EOM;
<script type="text/javascript">@{[!$::is_xhtml ? "<!--\n" : '']}
if(history.length != 0) {
	document.write('$hr<div align="$align"><a href="javascript:history.go(-1)" title="$str">$str</a></div>');
}
@{[!$::is_xhtml ? '//-->' : '']}</script>
EOM
		} elsif($ENV{HTTP_REFERER} ne '') {
			$body=<<EOM;
$hr
<div align="$align">
<a href="$ENV{HTTP_REFERER}" title="$str">$str</a>
</div>
EOM
		} else {
			$body=" ";
		}
	} else {
		$body=<<EOM;
$hr
<div align="$align">
<a href="$link" title="$str">$str</a>
</div>
EOM
	}
	return $body;
}
1;
__END__


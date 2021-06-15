######################################################################
# topicpath.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: topicpath.inc.pl,v 1.30 2007/07/15 07:40:09 papu Exp $
#
# "PyukiWiki" version 0.1.7 $$
# Author: Junichi http://www.re-birth.com/
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
# オリジナルとの変更点
# ・$topicpath::ARROW, $topicpath::FRONTPAGE への代入を変更
# ・PukiWikiライクの表示設定を追加
# ・0.1.6用のURL処理に変更
######################################################################
# select or edit style
######################################################################
# Re-Birth Original
#$topicpath::AutoLoad=1					if(!defined($topicpath::AutoLoad));
#$topicpath::SEPARATOR = '/'			if(!defined($topicpath::SEPARATOR));
#$topicpath::FRONTMARK = ' ： '			if(!defined($topicpath::FRONTMARK));
#$topicpath::ARROW = ' &gt; '			if(!defined($topicpath::ARROW));
#$topicpath::FRONTPAGE = $::FrontPage	if(!defined($topicpath::FRONTPAGE));
#$topicpath::FRONTPAGENAME=$::FrontPage	if(!defined($topicpath::FRONTPAGENAME));
#$topicpath::PREFIX = '[ '				if(!defined($topicpath::PREFIX));
#$topicpath::SUFFIX = ' ]'				if(!defined($topicpath::SUFFIX));
######################################################################
# PukiWiki Like
$topicpath::AutoLoad=1					if(!defined($topicpath::AutoLoad));
$topicpath::SEPARATOR = '/'				if(!defined($topicpath::SEPARATOR));
$topicpath::FRONTMARK = ' /  '			if(!defined($topicpath::FRONTMARK));
$topicpath::ARROW = ' / '				if(!defined($topicpath::ARROW));
$topicpath::FRONTPAGE = $::FrontPage	if(!defined($topicpath::FRONTPAGE));
$topicpath::FRONTPAGENAME='Top'			if(!defined($topicpath::FRONTPAGENAME));
$topicpath::PREFIX = ''					if(!defined($topicpath::PREFIX));
$topicpath::SUFFIX = ''					if(!defined($topicpath::SUFFIX));
######################################################################

sub plugin_topicpath_inline {

	my($wikicgiflag,$page)=split(/,/, shift);
	return '' if(shift eq 1 && $topicpath::AutoLoad eq 0);

	my $mypage = $page eq '' ? $::form{mypage} : $page;

	if(!(&is_exist_page($mypage))) {
		return "";
	}

	my @path_array = split($topicpath::SEPARATOR,$mypage);


	$topicpath::FRONTPAGEUrl = &createUrl($topicpath::FRONTPAGE, $topicpath::FRONTPAGE, $topicpath::FRONTPAGE, $topicpath::FRONTPAGENAME);

	if($mypage eq $topicpath::FRONTPAGE) {
		return $topicpath::PREFIX . $topicpath::FRONTPAGEUrl . $topicpath::SUFFIX;
	}

	$result = $topicpath::FRONTPAGEUrl . $topicpath::FRONTMARK;
	my $pathname = "";
	foreach $pagename (@path_array) {

		if($pathname ne "") {
			$pathname .= $topicpath::SEPARATOR . $pagename;
		}else{
			$pathname = $pagename;
		}

		$result .= &createUrl($pagename, $pathname, $topicpath::FRONTPAGE, $topicpath::FRONTPAGENAME);


		if($pagename ne $path_array[$#path_array]){
			$result .= $topicpath::ARROW;
		}

	}
	return $topicpath::PREFIX . $result . $topicpath::SUFFIX;
}

# ex.
# $pagename : Page
# $pathname : Category/Page
sub createUrl() {
	my ($pagename,$pathname, $FRONTPAGE, $FRONTPAGENAME) = @_;

	if(&is_exist_page($pathname)) {
		return qq|<a href="@{[&make_cookedurl(&encode($pathname))]}">@{[&escape($pagename eq $FRONTPAGE ? $FRONTPAGENAME : $pagename)]}</a>|;
	} else {
		return qq|@{[&escape($pagename)]}<a href="$::script?cmd=edit&mypage=@{[&encode($pathname)]}">?</a>|;
	}
}

1;
__END__


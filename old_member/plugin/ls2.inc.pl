######################################################################
# ls2.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: ls2.inc.pl,v 1.59 2007/07/15 07:40:09 papu Exp $
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
# v0.1.6 2006/01/07 *****まで対応する、その他修正
# v0.1   2005/04/01 encode バグ Fix Tnx:Junichiさん
# v0.0   2004/11/01 簡易版 title,reverse 対応、その他は非対応
# based on ls2.inc.php by arino
#
#*プラグイン ls2
#配下のページの見出し(*,**,***)の一覧を表示する
#
#*Usage
# #ls2(パターン[,パラメータ])
#
#*パラメータ
#-パターン(最初に指定) 省略するときもカンマが必要
#-title:見出しの一覧を表示する
#-include:インクルードしているページの見出しを再帰的に列挙する
#-link:actionプラグインを呼び出すリンクを表示
#-reverse:ページの並び順を反転し、降順にする
#-compact:
######################################################################

use strict;

sub plugin_ls2_convert
{
	my $prefix = '';
	my @args = split(/,/, shift);
	my $title = 0;
	my $reverse = 0;
	my (@pages, $txt, @txt, $tocnum);
	my $body = '';

	if (@args > 0) {
		$prefix = shift(@args);
		foreach my $arg (@args) {
			if (lc $arg eq "title") {
				$title = 1;
			} elsif (lc $arg eq "reverse") {
				$reverse = 1;
			}
		}
	}
	$prefix = $::form{mypage} . "/" if ($prefix eq '');

	foreach my $page (sort keys %::database) {
		push(@pages, $page) if ($page =~ /^$prefix/ && &is_readable($page) && $page!~/$::non_list/);
	}
	@pages = reverse(@pages) if ($reverse);
	foreach my $page (@pages) {
		$body .= <<"EOD";
<li><a id ="list_1" href="@{[&make_cookedurl(&encode($page))]}" title="$page">$page</a></li>
EOD
		if ($title) {
			$txt = $::database{$page};
			@txt = split(/\r?\n/, $txt);
			$tocnum = 0;
			my (@tocsaved, @tocresult);
			foreach (@txt) {
				chomp;
				if (/^(\*{1,5})(.+)/) {
					&back_push('ul', length($1), \@tocsaved, \@tocresult);
					push(@tocresult, qq( <li><a href="@{[&make_cookedurl(&encode($page))]}#@{[&pageanchorname($page)]}$tocnum">@{[&escape($2)]}</a></li>\n));	
					$tocnum++;
				}
			}
			push(@tocresult, splice(@tocsaved));
			$body .= join("\n", @tocresult);
		}
	}
	if ($body ne '') {
		return << "EOD";
<ul class="list1" style="padding-left:16px;margin-left:16px">$body</ul>
EOD
	}
	return "<strong>'$prefix'</strong> $::resource{ls2_plugin_notpage}<br />\n";
}

1;
__END__

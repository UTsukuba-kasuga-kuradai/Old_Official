######################################################################
# yetlist.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: yetlist.inc.pl,v 1.14 2007/07/15 07:40:09 papu Exp $
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
# This is compatiblity PukiWiki plugin, but cording was original.
######################################################################

use strict;

sub plugin_yetlist_action {
	my %yet=();
	my $yetcount=0;
	my $yetlist_regex="($::bracket_name)";
	$yetlist_regex.="|($::wiki_name)" if($::nowikiname ne 1);

	foreach my $page (sort keys %::database) {
		next if ($page =~ $::non_list);
		next unless(&is_readable($page));
		my $data=$::database{$page};
		foreach my $chunk($data=~/$yetlist_regex/) {
			next if($chunk eq '');
			my ($chunk1,$chunk2);
			my $ret=&make_link($chunk);
			next if($ret!~/cmd=edit\&/);
			$chunk=&unarmor_name($chunk);
			($chunk1,$chunk2) = split(/[:>]/,$chunk);
			$chunk=$chunk2 eq '' ? $chunk1 : $chunk2;

			if(&is_exist_page($chunk) || $chunk eq '') {
				next;
			}
			$yet{$chunk}.="$page\t"
				if($yet{$chunk}!~/^$page\t|\t$page\t/);
			$yetcount++;
		}
	}
	if($yetcount eq 0) {
		return('msg'=>"\t$::resource{yetlist_plugin_title}"
			, 'body'=>"$::resource{yetlist_plugin_nopage}");
	}
	my $body="<ul>\n";
	foreach my $chunk (sort keys %yet) {
		$body.=<<EOM;
<li><a href="$::script?cmd=edit&amp;mypage=@{[&encode($chunk)]}">@{[&escape($chunk)]}</a>
<em>(
EOM
		foreach my $page(sort split(/\t/,$yet{$chunk})) {
			$body.=<<EOM;
<a href="@{[&make_cookedurl(&encode($page))]}">@{[&escape($page)]}</a>
EOM
		}
		$body.=<<EOM;
)</em></li>
EOM
	}
	return('msg'=>"\t$::resource{yetlist_plugin_title}"
		, 'body'=>$body);
}

1;
__END__


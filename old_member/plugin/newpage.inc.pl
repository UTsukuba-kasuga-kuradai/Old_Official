######################################################################
# newpage.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: newpage.inc.pl,v 1.59 2007/07/15 07:40:09 papu Exp $
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
# Return:LF Code=Shift-JIS 1TAB=4Spaces
######################################################################

sub plugin_newpage_action {
	my %auth;
	my $body;
	my $upperlist;
	if($::newpage_auth eq 1) {
		%auth=&authadminpassword("input",$::resource{admin_passwd_prompt_msg},"frozen");
	}
	if($auth{authed} eq 1 && $::form{mypage} ne '') {
		if (1 == &exist_plugin('adminedit')) {
			if($::form{under} ne '') {
				$::form{mypage}="$::form{under}/$::form{mypage}";
			}
			$::form{cmd}="adminedit";
			return &plugin_adminedit_action;
		}
	}
	if($::new_dirnavi eq 1) {
		@ALLLIST=();
		@UPPERLIST=();

		foreach my $pages (keys %::database) {
			push(@ALLLIST,$pages) if($pages!~/$::non_list/ && &is_readable($pages));
		}
		@ALLLIST=sort @ALLLIST;

		if($::form{refer} ne '') {
			my $refpage="/$::form{refer}";
			while($refpage=~/\//) {
				my $pushpage=$refpage;
				$pushpage=~s/^\///g;
				if(&is_exist_page($pushpage)) {
					my $exist=0;
					foreach(@UPPERLIST) {
						$exist=1 if($pushpage eq $_);
					}
					push(@UPPERLIST,$pushpage) if($exist eq 0 && &is_readable($pushpage));
				}
				$refpage=~s/\/[^\/]+$//g;
			}
		}
		$upperlist=<<EOM;
$::resource{newpage_plugin_under}<select name="under">
<option value="">$::resource{newpage_plugin_none}</option>
EOM

		foreach(@UPPERLIST) {
			$upperlist.=qq(<option value="$_"@{[$::form{under} eq $_ ? " selected" : ""]}>$_</option>\n);
		}
		foreach my $all(@ALLLIST) {
			my $exist=0;
			foreach(@UPPERLIST) {
				$exist=1 if($all eq $_);
			}
			if($exist eq 0) {
				$upperlist.=qq(<option value="$all"@{[$::form{under} eq $all ? " selected" : ""]}>$all</option>\n);
			}
		}
		$upperlist.=qq(</select>\n);
	}
	my $refercmd;
	$refercmd=qq(<input type="hidden" name="refercmd" value="new">)
		if($::pukilike_edit eq 3);
	$body =<<"EOD";
<form action="$::script" method="post">
    <input type="hidden" name="cmd" value="@{[$::newpage_auth eq 1 ? 'newpage' : 'edit']}">
    $::resource{newpage_plugin_msg}
    <input type="text" name="mypage" value="$::form{mypage}" size="20">
    <input type="hidden" name="refer" value="$::form{refer}">
    <input type="submit" value="$::resource{newpagebutton}"><br>
$upperlist<br />
$auth{html}
$refercmd
</form>
EOD
	return ('msg' => "\t$::resource{newpage_plugin_title}", 'body' => $body);
}
1;
__END__


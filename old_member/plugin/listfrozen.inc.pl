######################################################################
# listfrozen.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: listfrozen.inc.pl,v 1.54 2007/07/15 07:40:09 papu Exp $
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

sub plugin_listfrozen_action {
	my $body;
	my $upperlist;
	my %pageinfo;
	%::auth=&authadminpassword(submit);
	return('msg'=>"\t$::resource{listfrozen_plugin_title}",'body'=>$auth{html})
		if($auth{authed} eq 0);

	$::IN_HEAD.=<<EOM;
<script type="text/javascript"><!--
function allcheckbox(v) {
	var len=document.sel.elements.length;
	for(var i=0;i<len;i++) {
		if(document.sel.elements[i].type == "checkbox") {
			if(v == 1) {
				if(!document.sel.elements[i].checked) {
					document.sel.elements[i].click();
				}
			} else {
				if(document.sel.elements[i].checked) {
					document.sel.elements[i].click();
				}
			}
		}
	}
}
//--></script>
EOM
	foreach my $pages (keys %::database) {
		my $frozen=&is_frozen($pages);
		my $subject=&get_subjectline($pages);
		my $date=&get_info($pages, $::info_LastModified);
		if($date=~/(...) (...)\s?(.+?) (\d\d):(\d\d):(\d\d) (\d\d\d\d)/) {
			my $day=$3;
			my $hour=$4;
			my $min=$5;
			my $sec=$6;
			$date=sprintf("(%04d-%02d-%02d %02d:%02d:%02d)"
				, $7+0,
				, $2=~/Jan/ ? 1 : $2=~/Feb/ ? 2 : $2=~/Mar/ ? 3 : $2=~/Apr/ ? 4
				: $2=~/May/ ? 5 : $2=~/Jun/ ? 6 : $2=~/Jul/ ? 7 : $2=~/Aug/ ? 8
				: $2=~/Sep/ ? 6 : $2=~/Oct/ ? 10 : $2=~/Nov/ ? 11 : $2=~/Dec/ ? 12 : 0
				, $day,$hour,$min,$sec);
		}
		my $hex=$pages;
		$hex=~ s/(.)/unpack('H2', $1)/eg;
		my $checked=$::form{exec} eq '' ? $frozen: ($::form{"check_$hex"} ne '' ? 1 : 0);
		$frozen=$::form{exec} eq '' ? $frozen: ($::form{"frozen_$hex"} ne '' ? 1 : 0);
		push(@ALLLIST,"$date\t$pages\t$hex\t$frozen\t$checked\t$subject");
		if($pages=~/\//) {
			$pages=~s!/[^/]+$!!g;
			my $exist=0;
			foreach(@DIRLIST) {
				$exist=1 if($pages eq $_);
			}
			push(@DIRLIST,$pages) if($exist eq 0);
		}
	}
	if($::form{sort} eq 'name') {
		@ALLLIST=sort { (split(/\t/,$a))[1] cmp (split(/\t/,$b))[1] } @ALLLIST;
	} elsif($::form{sort} eq 'name_reverse') {
		@ALLLIST=reverse sort { (split(/\t/,$a))[1] cmp (split(/\t/,$b))[1] } @ALLLIST;
	} elsif($::form{sort} eq 'date_reverse') {
		@ALLLIST=reverse sort @ALLLIST;
	} else {
		@ALLLIST=sort @ALLLIST;
	}

	if($::form{exec} eq '') {
	$body=<<EOM;
<h2>$::resource{listfrozen_plugin_title}</h2>
$::resource{listfrozen_plugin_msg}
<form action="$::script" method="post" name="sel">
<input type="hidden" name="cmd" value="listfrozen">
$auth{html}
<input type="submit" name="exec" value="$::resource{listfrozen_plugin_btn_submit}">
<hr />
<select name="dir">
<option value="">$::resource{listfrozen_plugin_dir}</option>
EOM
	foreach(@DIRLIST) {
		$body.=<<EOM;
<option value="$_"@{[$::form{dir} eq $_ ? ' selected' : '']}>$_</option>
EOM
	}
	$body.=<<EOM;
</select>
<select name="sort">
EOM
	foreach("date","date_reverse","name","name_reverse") {
		$body.=<<EOM;
<option value="$_"@{[$::form{sort} eq $_ ? ' selected' : '']}>$::resource{"listfrozen_plugin_sort_$_"}</option>
EOM
	}
	$body.=<<EOM;
</select>
<input type="submit" name="view" value="$::resource{listfrozen_plugin_btn_view}">
<input type="button" value="$::resource{listfrozen_plugin_btn_checkon}" onclick="allcheckbox(1);">
<input type="button" value="$::resource{listfrozen_plugin_btn_checkoff}" onclick="allcheckbox(0);">
<br />
EOM
		foreach(@ALLLIST) {
			my($date,$page,$hex,$frozen,$checked,$subject)=split(/\t/,$_);
			if($::form{dir} ne '') {
				if("$::form{dir}/" ne substr($page,0,length($::form{dir})+1)) {
					$body.=<<EOM;
<input type="hidden" name="frozen_$hex" value="@{[$frozen eq 0 ? '':1]}">
<input type="hidden" name="check_$hex" value="$frozen">
<input type="hidden" name="exist_$hex" value="1">
EOM
					next;
				}
			}
			my $pg2=$page;
			$body.=<<EOM;
<input type="checkbox" name="frozen_$hex" value="1"@{[$frozen eq 0 ? '' : ' checked']}>
<input type="hidden" name="check_$hex" value="$frozen">
<input type="hidden" name="exist_$hex" value="1">
@{[&make_link($pg2)]}
&nbsp;(<a href="$::script?cmd=adminedit&amp;mypage=@{[&encode($page)]}">$::resource{editbutton}</a>)&nbsp;
$date<br />
EOM
		}
		$body.="</form>\n";
	} else {
		foreach(@ALLLIST) {
			my($date,$page,$hex,$frozen,$checked,$subject)=split(/\t/,$_);
			my $msg;
			my $nowflozen=&is_frozen($page);
			if($::form{"exist_$hex"}+0 eq 0) {
				$msg=$::resource{listfrozen_plugin_exec_newname};
			} elsif($frozen eq 0 && $nowflozen eq 0) {
				$msg=$::resource{listfrozen_plugin_exec_unfrozen};
			} elsif($frozen eq 1 && $nowflozen eq 1) {
				$msg=$::resource{listfrozen_plugin_exec_frozen};
			} elsif($frozen eq 0 && $nowflozen eq 1) {
				$msg=$::resource{listfrozen_plugin_exec_unfrozen_change};
				&set_info($page, $::info_IsFrozen, 0);
			} elsif($frozen eq 1 && $nowflozen eq 0) {
				$msg=$::resource{listfrozen_plugin_exec_frozen_change};
				&set_info($page, $::info_IsFrozen, 1);
			}
			push(@RESULT,"$date\t$page\t$msg");
			$::form{"exist_$hex"}=0;
		}
		foreach(keys %::form) {
			if(/^exist\_(.+)/) {
				my $page=$1;
				if($::form{"exist_$page"}+0>0) {
					$page=~s/([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
					$msg=$::resource{listfrozen_plugin_exec_delete};
					push(@RESULT,"$date\t$page\t$msg");
				}
			}
		}
		$body.=<<EOM;
<h2>$::resource{listfrozen_plugin_title}</h2>
$::resource{listfrozen_plugin_execmsg}
<form action="$::script" method="post" name="sel">
<input type="hidden" name="cmd" value="listfrozen">
$auth{html}
<input type="submit" name="return" value="$::resource{listfrozen_plugin_btn_return}">
<hr />
<input type="hidden" name="dir" value="$::form{dir}">
<input type="hidden" name="sort" value="$::form{sort}">
<table>
EOM
		if($::form{sort} eq 'name') {
			@RESULT=sort { (split(/\t/,$a))[1] cmp (split(/\t/,$b))[1] } @RESULT;
		} elsif($::form{sort} eq 'name_reverse') {
			@RESULT=reverse sort { (split(/\t/,$a))[1] cmp (split(/\t/,$b))[1] } @RESULT;
		} elsif($::form{sort} eq 'date_reverse') {
			@RESULT=reverse sort @RESULT;
		} else {
			@RESULT=sort @RESULT;
		}
		foreach(@RESULT) {
			my($dt,$page,$msg)=split(/\t/,$_);
			$body.="<tr><td>$msg</td><td>@{[&make_link($page)]}</td></tr>";
		}
		$body.="</table>\n";
	}
	return('msg'=>"\t$::resource{listfrozen_plugin_title}",'body'=>$body);
}
1;
__END__


######################################################################
# calendar2.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: calendar2.inc.pl,v 1.51 2007/07/15 07:40:09 papu Exp $
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
# 作者音信普通の為、承諾がとれていませんが、便宜の上で
# v0.1.6対応版を配布することとしました。
# かなり機能向上していて重くなっていますので、軽快なほうを使用したい
# 場合は、オリジナル版をご利用下さい。
# http://hpcgi1.nifty.com/it2f/wikinger/pyukiwiki.cgi?PyukiWiki%2f%a5%d7%a5%e9%a5%b0%a5%a4%a5%f3%2fcalendar
#
# calendar_viewerは、以下のをご利用下さい。(使えると思います）
# http://hpcgi1.nifty.com/it2f/wikinger/pyukiwiki.cgi?cmd=attach&pcmd=open&file=calendar_viewer%2einc%2epl&mypage=PyukiWiki%2f%a5%d7%a5%e9%a5%b0%a5%a4%a5%f3%2fcalendar&refer=%c6%fc%b5%ad%2f2004%2d11%2d02
#
# やしがにもどき氏のとは以下の点で異なります。
# ・コードベースを一部大幅に書き換えた
# ・exdate.inc.cgiが導入されている時、すべての書式が使えるようになっている
#   (ただしかなり重いです)
# ・exdate.inc.cgiが導入されている時、祝日を自動計算して表示するようになっている
#   (法律変わらない限りは変更不要です)
# ・内部的な演算方法を少し変えた
# ・新規編集画面の初期テキストを設定できるようにした。
#   サンプルで、my $$calendar2::initwikiformatが設定してあります。
#   __DATE__ は、そのカレンダーの日付に置換されます
# ・ついでですが、CSSにMenuBarとページ本体の両方を記述してありますので
#   それぞれのサイズあわせは不要です。
#
# 使用方法
#
# #calendar2(Diary,SGGY年Zn月Zj日（DL）RY RK\nRS RG XG SZ MG)
# #calendar2(ページ名,日付フォーマット)
# ページ名:ベースとなるページを指定します
# 日付フォーマット：ToolTipで表示される日付の詳細情報を指定します。
#                   \n を入れると、改行に変換されます。
#                   FireFoxでは、JavaScriptが無効ですと正常に
#                   表示されません。
#
# p.s.exdateには多くのキャッシュ保持機能があって少しでも軽くなるように
# なっていますが、それでもまだまだ重いです。汗
######################################################################

use strict;
use Time::Local;

######################################################################
# 新規編集画面での初期値
# カレンダーのALT

if($::_exec_plugined{exdate} ne '') {

	$calendar2::initwikiformat=<<EOM;
*&date(SGGY年Zn月Zj日（DL）RY RK RS RG XG SZ MG,__DATE__);
EOM
	$calendar2::altformat="DL RY RK RG";
} else {

	$calendar2::initwikiformat=<<EOM;
*&date(Y-n-j[lL],__DATE__);
EOM
	$calendar2::altformat="[lL]";
}

######################################################################
# MenuBar等に設置した場合、月の前後をMenuBarだけで動かす場合 1
$calendar2::menubaronly=1;


######################################################################
#
sub plugin_calendar2_convert {
	my ($page, $arg_date, $date_format) = split(/,/, shift);
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);
	my ($disp_wday,$today,$start,$end,$i,$label,$cookedpage,$d);
	my ($prefix,$splitter);
	my $empty = '';
	my $calendar = "";
	my ($_year,$_mon);
	($sec, $min, $hour, $mday, $mon, $year) = localtime();
	$_year=$year+1900;
	$_mon=$mon+1;
	my $crlf='&#13;&#10;';
	if($date_format eq '') {
		$date_format="Y-n-j(lL)";
	} else {
		$date_format=~s/\\n/\n/g;
	}
	if    ($page eq '') {
		$prefix = $::form{mypage};
		$splitter = '/';
	} elsif ($page eq '*') {
		$prefix = '';
		$splitter = '';
	} else {
		$prefix = $page;
		$splitter = '/';
	}
	$page = &htmlspecialchars($prefix);

	if($calendar2::menubaronly+0 eq 1) {
		$arg_date=$::form{date} if($::form{date} ne '');
	}
	if ($arg_date =~ /^(\d{4})[^\d]?(\d{1,2})$/ ) {
		$year = $1 - 1900;
		$mon = ($2-1) % 12;
	}
	my $disp_year  = $year+1900;
	my $disp_month = $mon+1;
	my $pagelink=&makepagelink($page,$page,$::resource{editthispage});
	my $prev_year=$disp_month eq 1 ? $disp_year-1 : $disp_year;
	my $prev_month=$disp_month eq 1 ? 12 : $disp_month-1;
	my $next_year=$disp_month eq 12 ? $disp_year+1 : $disp_year;
	my $next_month=$disp_month eq 12 ? 1 : $disp_month+1;
	my $label="$disp_year.$disp_month";
	my $cookedpage=&encode($page eq '' ? $::FrontPage : $page);

	my @weekstr;

	for(my $i=1; $i<=7; $i++) {
		my $tm=Time::Local::timelocal(0,0,0,$i,$disp_month-1,$disp_year-1900);
		$weekstr[&getwday($disp_year,$disp_month,$i)]
			= &date("lL",$tm);
	}
	for(my $i=0; $i<=6; $i++) {
		$weekstr[$i]=substr($weekstr[$i],0,(length($weekstr[$i])+1) % 2+1);
	}
	my $query;
	if($calendar2::menubaronly+0 eq 1) {
		$query="cmd=read&amp;mypage=@{[&encode($::pushedpage eq '' ? $::form{mypage} : $::pushedpage)]}";
	} else {
		$query="cmd=calendar2&amp;mymsg=$cookedpage&amp;format=@{[&encode($date_format)]}";
	}
	$calendar =<<"END";
<table class="style_calendar" summary="calendar body">
<tr>
<td class="style_td_caltop" colspan="7">
  <a href="$::script?$query&amp;date=@{[sprintf("%04d%02d",$prev_year,$prev_month)]}">&lt;&lt;</a>
  <strong>$label</strong>
  <a href="$::script?$query&amp;date=@{[sprintf("%04d%02d",$next_year,$next_month)]}">&gt;&gt;</a><br />
  $pagelink</td>
</tr>
<tr>
<td class="style_td_week">$weekstr[0]</td>
<td class="style_td_week">$weekstr[1]</td>
<td class="style_td_week">$weekstr[2]</td>
<td class="style_td_week">$weekstr[3]</td>
<td class="style_td_week">$weekstr[4]</td>
<td class="style_td_week">$weekstr[5]</td>
<td class="style_td_week">$weekstr[6]</td>
</tr>
<tr>
END
	my $disp_wday=&getwday($disp_year,$disp_month,1);
	for($i=0; $i< $disp_wday; $i++ ) {
		$calendar.=qq(<td class="style_td_blank">$empty</td>);
	}

	if($::_exec_plugined{exdate} ne '') {
		&date("RS",Time::Local::timelocal(0,0,0,1,$disp_month-1,$disp_year-1900));
	}
	my $initwiki_format= &code_convert(\$calendar2::initwikiformat,   $::kanjicode);

	for($i=1;$i<=&lastday($disp_year,$disp_month); $i++) {
		my $wday=&getwday($disp_year,$disp_month,$i);
		my $pagename = sprintf "%s%s%04d-%02d-%02d", $page, $splitter, $disp_year, $disp_month, $i;
		my $cookedname = &encode($pagename);

		my $style;
		$calendar.=qq(</tr>\n<tr>) if($wday eq 0 && $i ne 1);
		if($_year eq $disp_year && $_mon eq $disp_month && $i eq $mday) {
			$style='style_td_today';
		} elsif($::SYUKUJITSU{sprintf("%04d_%02d_%02d",$disp_year,$disp_month,$i)} ne '') {
			$style = 'style_td_sun';
		} elsif($wday eq 0) {
			$style = 'style_td_sun';
		} elsif($wday eq 6) {
			$style = 'style_td_sat';
		} else {
			$style = 'style_td_day';
		}
		my $alt=&date($calendar2::altformat,
			Time::Local::timelocal(0,0,0,$i,$disp_month-1,$disp_year-1900));
		$alt=~s/^\s//g while($alt=~/^\s/);
		$alt=~s/\s\s/ /g while($alt=~/\s\s/);
		$alt=~s/\s$//g while($alt=~/\s$/);
		$calendar .= qq(<td class="$style">@{[&makepagelink($pagename,"$alt","$alt",$i,$initwiki_format,"$disp_year/$disp_month/$i")]}</td>);
	}
	$disp_wday=&getwday($disp_year,$disp_month,&lastday($disp_year,$disp_month));
	if($disp_wday % 7 ne 6) {
		for($i= $disp_wday; $i<6; $i++) {
			$calendar .= "<td class=\"style_td_blank\">$empty</td>";
		}
	}

	$calendar.="</tr></table>\n";
	return $calendar;
}

sub makepagelink {
	my($page,$nonposted, $posted,$name,$wiki,$date)=@_;
	my $pagelink;
	my $cookedpage=&encode($page eq '' ? $::FrontPage : $page);
	my $cookedurl;
	if($calendar2::menubaronly+0 eq 1) {
		$cookedurl="$::script?cmd=read&amp;mypage=$cookedpage&amp;date=$::form{date}";
	} else {
		$cookedurl=&make_cookedurl($cookedpage);
	}
	if ($::database{$page}) {
		$pagelink = qq(<a title="$posted" href="$cookedurl">@{[$name eq '' ? $page : "<strong>$name</strong>"]}</a>);
	} elsif ($page eq '') {
		$pagelink = '';
	} else {
		if($wiki ne '') {
			$wiki=~s/__DATE__/$date/g;
			$wiki="&amp;plugined=1&amp;mymsg=@{[&encode($wiki)]}";
		}
		$pagelink = qq(<a title="$nonposted" class="editlink" href="$::script?cmd=adminedit&amp;mypage=$cookedpage&amp;date=$::form{date}$wiki">@{[$name eq '' ? $page : $name]}</a>);
	}
	return $pagelink;
}

sub plugin_calendar2_action {
	my $page = &escape($::form{mymsg});
	my $date = &escape($::form{date});
	my $format=&htmlspecialchars($::form{format});
	my $body = &plugin_calendar2_convert(qq($page,$date,$format));

	my $yy = sprintf("%04d.%02d",substr($date,0,4),substr($date,4,2));
	my $s_page = &htmlspecialchars($page);
	return ('msg'=>qq(calendar $s_page/$yy), 'body'=>$body);
}
1;
__END__


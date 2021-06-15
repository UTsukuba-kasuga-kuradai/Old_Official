######################################################################
# counter_viewer.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: counter_viewer.inc.pl,v 1.16 2007/07/15 07:40:09 papu Exp $
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

$counter_viewer::dateformat="Y-m-d(lL)"
	if(!defined($counter_viewer::dateformat));

sub plugin_counter_viewer_action {
	my $argv = shift;
	my ($limit, $ignore_page, $flag) = split(/,/, $argv);

	return qq(<div class="error">counter.inc.pl can't require</div>)
		if (&exist_plugin("counter") ne 1);

	my %auth=&authadminpassword(submit,"","admin");
	return('msg'=>"\t$::resource{counter_viewer_plugin_title}",'body'=>$auth{html})
		if($auth{authed} eq 0);

	my $body;

	if($::form{mypage} eq '') {
		$body=&plugin_counter_viewer_index(%auth);
	} else {
		$body=&plugin_counter_viewer_page($::form{mypage},%auth);
	}

	return('msg'=>"\t$::resource{counter_viewer_plugin_title}",'body'=>$body);
}

sub plugin_counter_viewer_page {
	my($page,%auth)=@_;
	my %counter=&plugin_counter_do($page,"r");
	my $body=<<EOM;
<h2>$page$::resource{counter_viewer_plugin_details_title}</h2>
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="counter_viewer" />
$auth{html}
<input type="hidden" name="sort" value="$::form{sort}" />
<input type="submit" name="view" value="$::resource{counter_viewer_plugin_btn_back}" />
</form>
<table class="style_table" cellspacing="1" border="0">
<thead><tr>
<td class="style_td">$::resource{counter_viewer_plugin_date}</td>
<td class="style_td">$::resource{counter_viewer_plugin_count}</td>
</tr></thead>
<td class="style_td">$::resource{counter_viewer_plugin_total}</td>
<td class="style_td">$counter{total}</td>
</tr><tr>
<td class="style_td">$::resource{counter_viewer_plugin_lastdate}</td>
<td class="style_td">@{[&plugin_counter_viewer_mkdate($counter{date})]}</td>
</tr><tr>
<td class="style_td">$::resource{counter_viewer_plugin_lastip}</td>
<td class="style_td">$counter{ip}</td>
</tr>
EOM
	for(my $i=$counter{date};
		$i>=$counter{date}-($::CounterDates >=1000 ? 1000 : $::CounterDates);
		$i--) {
		$body.=<<EOM;
</tr><tr>
<td class="style_td">@{[&plugin_counter_viewer_mkdate($i)]}</td>
<td class="style_td">@{[$counter{$i}+0]}</td>
</tr>
EOM
	}
	$body.=<<EOM;
</table>
EOM
	return $body;
}

sub plugin_counter_viewer_mkdate {
	my($dt)=@_;
	$dt=&date($counter_viewer::dateformat,$dt*86400);
	return $dt;
}

sub plugin_counter_viewer_index {
	my %auth=@_;
	my @list=();
	my $body;
	foreach my $pages (keys %::database) {
		my %counter=&plugin_counter_do($pages,"r");
		push(@list,"$pages\t$counter{total}\t$counter{today}\t$counter{yesterday}\t$counter{version}");
	}

	@list=sort { (split(/\t/,$a))[0] cmp (split(/\t/,$b))[0] } @list;
	if($::form{sort}=~/total/) {
		@list=sort { (split(/\t/,$b))[1] <=> (split(/\t/,$a))[1] } @list;
	} elsif($::form{sort}=~/today/) {
		@list=sort { (split(/\t/,$b))[2] <=> (split(/\t/,$a))[2] } @list;
	} elsif($::form{sort}=~/yesterday/) {
		@list=sort { (split(/\t/,$b))[3] <=> (split(/\t/,$a))[3] } @list;
	}
	@list=reverse @list if($::form{sort}=~/reverse/);

	$body=<<EOM;
<h2>$::resource{counter_viewer_plugin_list}</h2>
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="counter_viewer" />
$auth{html}
<select name="sort">
EOM
	foreach my $sort("name","name_reverse","total","total_reverse"
		,"today","today_reverse","yesterday","yesterday_reverse") {
		my $sortmsg=$::resource{"counter_viewer_plugin_sort_" . (split(/_/,$sort))[0]};
		$sortmsg.="($::resource{counter_viewer_plugin_sort_reverse})"
			if($sort=~/reverse/);
		$body.=<<EOM;
<option value="$sort"@{[$::form{sort} eq $sort ? ' selected' : '']}>$sortmsg</option>
EOM
	}
	$body.=<<EOM;
</select>
<input type="submit" name="view" value="$::resource{counter_viewer_plugin_btn_view}" />
</form>
<table class="style_table" cellspacing="1" border="0">
EOM
	foreach(@list) {
		my($name,$total,$today,$yesterday,$version)=split(/\t/,$_);
		my $btn=<<EOM;
<input type="hidden" name="cmd" value="counter_viewer" />
$auth{html}
<input type="hidden" name="sort" value="$::form{sort}" />
<input type="hidden" name="mypage" value="$name" />
<input type="submit" value="$::resource{counter_viewer_plugin_btn_details}"@{[$version > 1 ? '' : ' disabled']} />
&nbsp;
EOM
		$body.=<<EOM;
<form action="$::script" method="POST">
<thead><tr><td class="style_td" colspan="4"><strong>$btn<a target="_blank" href="$::script?@{[&encode($name)]}">$name</a></strong></td></tr></thead>
<tr>
<td class="style_td" align="right">$::resource{counter_viewer_plugin_total}:$total</td>
<td class="style_td" align="right">$::resource{counter_viewer_plugin_today}:$today</td>
<td class="style_td" align="right">$::resource{counter_viewer_plugin_yesterday}:$yesterday</td>
<td class="style_td" align="right">$::resource{counter_viewer_plugin_version}:$version</td>
</tr></form>
EOM
	}
	$body.=<<EOM;
</table>
EOM

	return $body;
}

1;
__END__


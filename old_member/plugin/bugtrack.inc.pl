######################################################################
# bugtrack.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: bugtrack.inc.pl,v 1.59 2007/07/15 07:40:09 papu Exp $
#
# "PyukiWiki" version 0.1.7 $$
# Author: Nekyo
# Copyright (C) 2004-2006 by Nekyo.
# http://nekyo.hp.infoseek.co.jp/
# Copyright (C) 2005-2006 PyukiWiki Developers Team
# http://pyukiwiki.sourceforge.jp/
# Based on YukiWiki http://www.hyuki.com/yukiwiki/
# Powerd by PukiWiki http://pukiwiki.sourceforge.jp/
# License: GPL2 and/or Artistic or each later version
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# Return Code:LF Japanese Code=EUC 1TAB=4Spaces
#
# Base on PukiWiki BugTrack Plugin
# CopyRight 2002 Y.MASUI GPL2
# http://masui.net/pukiwiki/ <masui (at) masui (dot) net>
######################################################################
# 変更履歴:
#  2002.06.17: 作り始め
#
# Id: bugtrack.inc.php,v 1.14 2003/05/17 11:18:22 arino Exp
#

@bugtrack::priority_list = ('緊急','重要','普通','低');
@bugtrack::state_list = ('提案','着手','CVS待ち','完了','保留','却下');
@bugtrack::state_sort = ('着手','CVS待ち','保留','完了','提案','却下');
@bugtrack::state_bgcolor = ('#ccccff','#ffcc99','#ccddcc','#ccffcc','#ffccff','#cccccc','#ff3333');

$bugtrack::title = '$1 Bugtrack Plugin';
$bugtrack::base = 'ページ';
$bugtrack::summary = 'サマリ';
$bugtrack::priority = '優先順位';
$bugtrack::state = '状態';
$bugtrack::name = '投稿者';
$bugtrack::date = '投稿日';
$bugtrack::body = 'メッセージ';
$bugtrack::category = 'カテゴリー';
$bugtrack::pagename = 'ページ名';
$bugtrack::pagename_comment = '<small>空欄のままだと自動的にページ名が振られます。</small>';
$bugtrack::version_comment = '<small>空欄でも構いません</small>';
$bugtrack::version = 'バージョン';
$bugtrack::submit = '追加';

sub plugin_bugtrack_action
{
	if ($::form{mode} eq 'submit') {
		foreach("base","pagename","summary","priority","state","category","version","body") {
			$::form{$_} = &code_convert(\$::form{$_}, $::defaultcode,$::kanjicode);
		}
		&plugin_bugtrack_write($::form{base}, $::form{pagename}, $::form{summary}, $::form{myname}, $::form{priority}, $::form{state}, $::form{category}, $::form{version}, $::form{body});
		exit;
	}
	return ('msg'=>$bugtrack::title, 'body'=>&plugin_bugtrack_print_form($::form{category}));
}

sub plugin_bugtrack_print_form
{
	my ($base, @category) = @_;
	my $select_priority = '';
	for ($i = 0; $i < @bugtrack::priority_list; ++$i) {
		my $selected = ($i < @bugtrack::lugin_priority_list - 1) ? '' : ' selected="selected"';
		$select_priority .= "<option value=\"$bugtrack::priority_list[$i]\"$selected>$bugtrack::priority_list[$i]</option>\n";
	}

	$select_state = '';
	for ($i = 0; $i < @bugtrack::state_list; ++$i) {
		$select_state .= "<option value=\"$bugtrack::state_list[$i]\">$bugtrack::state_list[$i]</option>\n";
	}

	my $encoded_category = '<input name="category" type="text" />';

	if (@category != 0) {
		$encoded_category = '<select name="category">';
		foreach my $_category (@category) {
			my $s_category = &htmlspecialchars($_category);
			$encoded_category .= "<option value=\"$s_category\">$s_category</option>\n";
		}
		$encoded_category .= '</select>';
	}

	$s_base = &htmlspecialchars($base);

	$body = <<"EOD";
<form action="$::script" method="post">
 <table border="0">
  <tr>
   <th>$bugtrack::name</th>
   <td><input name="myname" size="20" type="text" value="$::name_cookie{myname}" /></td>
  </tr>
  <tr>
   <th>$bugtrack::category</th>
   <td>$encoded_category</td>
  </tr>
  <tr>
   <th>$bugtrack::priority</th>
   <td><select name="priority">$select_priority</select></td>
  </tr>
  <tr>
   <th>$bugtrack::state</th>
   <td><select name="state">$select_state</select></td>
  </tr>
  <tr>
   <th>$bugtrack::pagename</th>
   <td><input name="pagename" size="20" type="text" />$bugtrack::pagename_comment</td>
  </tr>
  <tr>
   <th>$bugtrack::version</th>
   <td><input name="version" size="10" type="text" />$bugtrack::version_comment</td>
  </tr>
  <tr>
   <th>$bugtrack::summary</th>
   <td><input name="summary" size="60" type="text" /></td>
  </tr>
  <tr>
   <th>$bugtrack::body</th>
   <td><textarea name="body" cols="60" rows="6"></textarea></td>
  </tr>
  <tr>
   <td colspan="2" align="center">
    <input type="submit" value="$bugtrack::submit" />
    <input type="hidden" name="cmd" value="bugtrack" />
    <input type="hidden" name="mode" value="submit" />
    <input type="hidden" name="base" value="$s_base" />
   </td>
  </tr>
 </table>
</form>
EOD
	return $body;
}

sub plugin_bugtrack_template
{
	my ($base, $summary, $name, $priority, $state, $category, $version, $body) = @_;

	$name = &armor_name($name);
	$base = &armor_name($base);
	return <<"EOD";
*$summary

-$bugtrack::base: $base
-$bugtrack::name: $name
-$bugtrack::priority: $priority
-$bugtrack::state: $state
-$bugtrack::category: $category
-$bugtrack::date: @{[&get_now]}
-$bugtrack::version: $version

**$bugtrack::body
$body
----

#comment
EOD
}

sub plugin_bugtrack_write
{
	my ($base, $pagename, $summary, $name, $priority, $state, $category, $version, $body) = @_;

	$base = &unarmor_name($base);
	$pagename = &unarmor_name($pagename);

	my $postdata = &plugin_bugtrack_template($base, $summary, $name, $priority, $state, $category, $version, $body);

	$i = 0;
	do {
		$i++;
		$page = "$base/$i";
	} while ($::database{$page});


	if ($pagename == '') {
		$::form{mypage} = $page;
		$::form{mymsg} = $postdata;
		$::form{mytouch} = 'on';
		&do_write("FrozenWrite");
		exit;
	} else {




			$pagename = $page;




	}

	return $page;
}

sub plugin_bugtrack_convert
{
	my $base = $::form{mypage};
	my @category = split(/,/, shift);
	if (@category > 0) {
		my $_base = &unarmor_name(shift(@category));

		if ($::database{$_base}) {
			$base = $_base;
		}
	}
	return &plugin_bugtrack_print_form($base, @category);
}


sub plugin_bugtrack_pageinfo
{
	my ($page, $no) = @_;

	if (@_ == 1) {
		if ($page =~ /\/([0-9]+)$/) {
			$no = $1;
		} else {
			$no = 0;
		}
	}

	$source = get_source($page);
	if ($source[0] =~ /move\s*to\s*($WikiName|$InterWikiName|\[\[$BracketName\]\])/) {
		return plugin_bugtrack_pageinfo(&unarmor_name($1), $no);
	}

	$body = join("\n",$source);
	$summary = $name = $priority = $state = $category = 'test';
	$itemlist = ();
	foreach my $item (('summary','name','priority','state','category')) {
		$itemname = '_bugtrack_plugin_'.$item;

		$itemname = $$itemname;
		if ($body =~ /-\s*$itemname\s*:\s*(.*)\s*/) {
			if ($item == 'name') {
				$$item = &htmlspecialchars(&unarmor_name($1));
			} else {
				$$item = &htmlspecialchars($1);
			}
		}
	}

	if ($body =~ /\*([^\n]+)/) {
		$summary = $1;
		make_heading($summary);
	}

	return ($page, $no, $summary, $name, $priority, $state, $category);
}

sub plugin_bugtrack_list_convert
{





	$page = $::form{mypage};
	if (func_num_args()) {
		list($_page) = func_get_args();
		$_page = get_fullname(&unarmor_name($_page),$page);
		if ($::database{$_page}) {
			$page = $_page;
		}
	}

	$data = ();
	$pattern = "$page/";
	$pattern_len = strlen($pattern);
	foreach my $page (get_existpages()) {
		if (strpos($page,$pattern) == 0 and is_numeric(substr($page,$pattern_len))) {
			my $line = &plugin_bugtrack_pageinfo($page);
			array_push($data,$line);
		}
	}

	$table = ();
	for ($i = 0; $i <= count($bugtrack::state_list) + 1; ++$i) {
		$table[$i] = ();
	}


	foreach my $line ($data) {
		list($page, $no, $summary, $name, $priority, $state, $category) = $line;
		$page_link = make_pagelink($page);
		$state_no = array_search($state,$bugtrack::state_sort);
		if ($state_no == NULL or $state_no == FALSE) {
			$state_no = @bugtrack::state_list;
		}

		$bgcolor = $bugtrack::state_bgcolor[$state_no];
		$row = <<"EOD";
 <tr>
  <td style="background-color:$bgcolor">$page_link</td>
  <td style="background-color:$bgcolor">$state</td>
  <td style="background-color:$bgcolor">$priority</td>
  <td style="background-color:$bgcolor">$category</td>
  <td style="background-color:$bgcolor">$name</td>
  <td style="background-color:$bgcolor">$summary</td>
 </tr>
EOD
		$table[$state_no][$no] = $row;
	}
	$table_html = <<"EOD";
 <tr>
  <th>&nbsp;</th>
  <th>$bugtrack::state</th>
  <th>$bugtrack::priority</th>
  <th>$bugtrack::category</th>
  <th>$bugtrack::name</th>
  <th>$bugtrack::summary</th>
 </tr>
EOD
	for ($i = 0; $i <= @bugtrack::state_list; ++$i) {
		ksort($table[$i],SORT_NUMERIC);
		$table_html .= join("\n",$table[$i]);
	}

	return "<table border=\"1\">\n$table_html</table>";
}

1;
__END__


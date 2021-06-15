######################################################################
# article.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: article.inc.pl,v 1.66 2007/07/15 07:40:09 papu Exp $
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

use strict;

# テキストエリアのカラム数
$article::cols = 70
	if(!defined($article::cols));

# テキストエリアの行数
$article::rows = 5
	if(!defined($article::rows));

# 名前テキストエリアのカラム数
$article::name_cols = 24
	if(!defined($article::name_cols));

# 題名テキストエリアのカラム数
$article::subject_cols = 60
	if(!defined($article::subject_cols));

# 名前の挿入フォーマット
$article::name_format = "\'\'[[\$1>$::resource{profile_page}/\$1]]\'\'"
	if(!defined($article::name_format));

# 題名の挿入フォーマット
$article::subject_format = '**$subject'
	if(!defined($article::subject_format));

# 日付の挿入フォーマット (&new で認識できること)
$article::date_format= "Y-m-d(lL) H:i:s"
	if(!defined($article::date_format));

# 挿入する位置 1:欄の前 0:欄の後
$article::ins = 0
	if(!defined($article::ins));

# 書込み下に一行コメントを 1:入れる 0:入れない
$article::comment = 1
	if(!defined($article::comment));

# 改行を自動的変換 1:する 0:しない
$article::auto_br = 1
	if(!defined($article::auto_br));

# 名前なしで処理しない
$article::noname = 1
	if(!defined($article::noname));

# サブジェクトなしで処理しない
$article::nosubject = 0
	if(!defined($article::nosubject));

# サブジェクトなしのタイトル
$article::no_subject = "no subject"
	if(!defined($article::no_subject));

$article::no = 0;

my $_no_name = "";

sub plugin_article_action {
	if (($::form{msg} =~ /^\s*$/)
	 || ($::form{myname} =~ /^\s*$/ && $article::noname eq 1)
	 || ($::form{subject} =~ /^\s*$/ && $article::nosubject eq 1)) {
		return('msg'=>"$::form{mypage}\t\t$::resource{article_plugin_err}",'body'=>&text_to_html($::database{$::form{mypage}}),'ispage'=>1);
	}
	my $name = $_no_name;
	if ($::form{myname} ne '') {
		$name = $article::name_format;
		$name =~ s/\$1/$::form{myname}/g;
	}
	my $subject = $article::subject_format;
	if ($::form{subject} ne '') {
		$subject =~ s/\$subject/$::form{subject}/g;
	} else {
		$subject =~ s/\$subject/$article::no_subject/g;
	}
	$::form{subject} = &code_convert(\$::form{myname}, $::defaultcode);
	$::form{msg} = &code_convert(\$::form{msg}, $::defaultcode);

	$::form{msg}=~s/\x0D\x0A|\x0D|\x0A/\n/g;
	$::form{msg}=~s/^(\s|\n)//g while($::form{msg}=~/^(\s|\n)/);
	$::form{msg}=~s/(\s|\n)$//g while($::form{msg}=~/(\s|\n)$/);
	$::form{msg}=~s/\n/\~\n/g if($article::auto_br);

	my $artic = "$subject\n>$name &new{@{[&date($article::date_format)]}};~\n~\n$::form{msg}\n";
	$artic .= "\n#comment\n" if ($article::comment);
	my $postdata = '';
	my @postdata_old = split(/\r?\n/, $::database{$::form{'mypage'}});
	my $_article_no = 0;

	foreach (@postdata_old) {
		$postdata .= $_ . "\n" if (!$article::ins);
		if (/^#article/ && (++$_article_no == $::form{article_no})) {
			$postdata .= "$artic\n";
		}
		$postdata .= $_ . "\n" if ($article::ins);
	}
	$::form{mymsg} = $postdata;
	$::form{mytouch} = 'on';
	&do_write("FrozenWrite");
	&close_db;
	exit;
}

sub plugin_article_convert {
	return ' '
		if($::writefrozenplugin eq 0 && &get_info($::form{mypage}, $::info_IsFrozen) eq 1);

	$article::no++;
	my $conflictchecker = &get_info($::form{mypage}, $::info_ConflictChecker);
	return <<"EOD";
<form action="$::script" method="post">
 <div>
  <input type="hidden" name="article_no" value="$article::no" />
  <input type="hidden" name="cmd" value="article" />
  <input type="hidden" name="mypage" value="$::form{'mypage'}" />
  <input type="hidden" name="myConflictChecker" value="$conflictchecker" />
  <input type="hidden" name="mytouch" value="on" />
  $::resource{article_plugin_name} <input type="text" name="myname" size="$article::name_cols" value="$::name_cookie{myname}" /><br />
  $::resource{article_plugin_subject} <input type="text" name="subject" size="$article::subject_cols" value=""/><br />
  <textarea name="msg" rows="$article::rows" cols="$article::cols"></textarea><br />
  <input type="submit" value="$::resource{article_plugin_btn}" />
 </div>
</form>
EOD
}

1;
__END__


######################################################################
# mailform.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: mailform.inc.pl,v 1.6 2007/07/15 07:40:09 papu Exp $
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
# Author: Nanami <nanami (at) daiba (dot) cx>
######################################################################
# v0.1.7以降専用です。
#
# v 0.0.1 - ProtoType
# 以下のメールフォームのPyukiWiki移植＆高機能化です。
#
#   PukiWiki メールフォームプラグイン ver. 2002-06-18
#
#   CopyRight 2002 OKAWARA,Satoshi All rights reserved.
#   http://kawara.homelinux.net/pukiwiki/pukiwiki.php
#   http://kawara.homelinux.net/pukiwiki/pukiwiki.php?%A5%E1%A1%BC%A5%EB%A5%D5%A5%A9%A1%BC%A5%E0%A5%D7%A5%E9%A5%B0%A5%A4%A5%F3
#   <kawara (at) dml (dot) co (dot) jp>
#
# Usage:
# #mailform
# #mailform(固定表題設定,arg, arg, ...)
#
# なお、無差別SPAM防止のため、$::modifier_mail に設定されている
# アドレス以外には送信できません。
######################################################################

use strict;

# テキストエリアのカラム数
$mailform::cols=70
	if(!defined($mailform::cols));

# テキストエリアの行数
$mailform::rows=10
	if(!defined($mailform::rows));

# 名前テキストエリアのカラム数
$mailform::name_cols=24
	if(!defined($mailform::name_cols));

# メールアドレステキストエリアのカラム数
$mailform::from_cols=24
	if(!defined($mailform::from_cols));

# 題名テキストエリアのカラム数
$mailform::subject_cols=24
	if(!defined($mailform::subject_cols));

# 題名が未記入の場合の表記 
$mailform::no_subject_title = "no title"
	if(!defined($mailform::no_subject_title));

# 名前が未記入の場合の表記 
$mailform::no_name_title = "anonymous"
	if(!defined($mailform::no_name_title));

# 題名なしで処理:0、題名なしを許容する:1、題名なしを許可しない:2
$mailform::no_subject = 1
	if(!defined($mailform::no_subject));

# 名前なしで処理:0、名前なしを許容する:1、名前なしを許可しない:2
$mailform::no_name = 1
	if(!defined($mailform::no_name));

# メールアドレスなしで処理:0、メールアドレスなしを許容する:1、メールアドレスなしを許可しない:2
$mailform::no_from = 2
	if(!defined($mailform::no_from));

# 本文なしで処理しない:1
$mailform::no_data = 1
	if(!defined($mailform::no_data));

# 投稿内容のメール送信時のprefix
$mailform::subject_prefix="[Wiki]"
	if(!defined($mailform::subject_prefix));

#####################################################33

# cmd=mailform&...

sub plugin_mailform_action {
	return <<EOM if($::modifier_mail eq '');
<div class="error">
$::resource{mailform_plugin_err_to}
</div>
EOM

	my $argv=$::form{argv};
	my %option=&plugin_mailform_optionparse($argv);

	my $errstr="";


	if($::write_location eq 1) {
		if($::form{sent} ne '') {
			return('msg'=>$::form{refer} . "\t" . $::resource{mailform_plugin_mailsend}
				 , 'body'=>&text_to_html($::database{$::form{refer}}, mypage=>$::form{refer})
				 , 'ispage'=>1);
		}
	}


	$::form{mailform_from}=&trim($::form{mailform_from});
	if($option{no_from} ne 2) {
		if($::form{mailform_from} eq '') {
			$::form{mailform_from}=$::modifier_mail;
		}
	}
	if($::form{mailform_from} eq '') {
		$errstr.="$::resource{mailform_plugin_err_from_nostr}\n";
	} elsif($::form{mailform_from}!~/$::ismail/) {
		$errstr.="$::resource{mailform_plugin_err_from_err}\n";
		$::form{mailform_from}='';
	}


	$::form{mailform_name}=&trim($::form{mailform_name});
	if($option{no_name} ne 2) {
		if($::form{mailform_name} eq '') {
			$::form{mailform_name}=$::form{mailform_from};
			if($::form{mailform_name} eq $::modifier_mail) {
				$::form{mailform_name}=$mailform::no_name_title;
			}
		}
	}
	if($option{no_name} ne 0) {
		if($::form{mailform_name} eq '') {
			$errstr.="$::resource{mailform_plugin_err_noname}\n";
		}
	}


	if($option{fixsubject} ne '') {
		$::form{mailform_subject}=$option{fixsubject};
	}
	$::form{mailform_subject}=&trim($::form{mailform_subject});
	if($option{no_subject} ne 2) {
		if($::form{mailform_subject} eq '') {
			$::form{mailform_subject}=$mailform::no_subject_title;
		}
	}
	if($option{no_subject} ne 0) {
		if($::form{mailform_subject} eq '') {
			$errstr.="$::resource{mailform_plugin_err_nosubject}\n";
		}
	}


	$::form{mailform_data}=&trim($::form{mailform_data});

	if($option{no_data_check} eq 1) {
		my $dmy=$::form{mailform_data};
		$dmy=~s/[\r|\n]//g;
		$dmy=~s/\s//g;
		$dmy=~s/　//g;
		$errstr.="$::resource{mailform_plugin_err_nodata}\n" if($dmy eq '');
	}

	if($errstr eq '' && $::form{edit} eq '') {
		if($::form{confirm} ne '') {
			my $body="<h2>$::resource{mailform_plugin_msg_title}</h2>\n";
			$body.=&plugin_mailform_makeconfirm($::form{argv});
			return('msg'=>$::form{refer} . "\t" . $::resource{mailform_plugin_mailconfirm}
				 , 'body'=>$body);
		} else {
			&plugin_mailform_send;
			if($::write_location eq 0) {
				$::form{mailform_from}="";
				$::form{mailform_name}="";
				$::form{mailform_subject}="";
				$::form{mailform_data}="";

				return('msg'=>$::form{refer} . "\t" . $::resource{mailform_plugin_mailsend}
					 , 'body'=>&text_to_html($::database{$::form{refer}}, mypage=>$::form{refer})
					 , 'ispage'=>1);
			} else {
				if($::write_location eq 1) {
					print &http_header(
						"Status: 302",
						"Location: $::basehref?cmd=mailform&sent=true&refer=$::form{refer}",
						$::HTTP_HEADER
						);
					close(STDOUT);
					exit;
				}
			}
		}
	} else {
		my $body="<h2>$::resource{$::form{edit} ne '' ? 'mailform_plugin_msg_edit' : 'mailform_plugin_err_title'}</h2>\n";
		foreach(split(/\n/,$errstr)) {
			$body.=qq(<div class="error">$_</div>\n) if($_ ne '');
		}
		$body.=&plugin_mailform_makeform($::form{argv});

		return('msg'=>$::form{refer} . "\t" . $::resource{mailform_plugin_mailconfirm}
			 , 'body'=>$body);
	}
}

# メール送信本体
sub plugin_mailform_send {
	&load_module("Nana::Mail");
	Nana::Mail::send(
		to=>$::modifier_mail,
		from=>$::form{mailform_from},
		from_name=>$::form{mailform_name},
		subject=>"$mailform::subject_prefix$::form{mailform_subject}",
		data=>$::form{mailform_data});
}

# #mailform(...)

sub plugin_mailform_convert {
	my $argv=shift;

	return <<EOM if($::modifier_mail eq '');
<div class="error">
$::resource{mailform_plugin_err_to}
</div>
EOM

	return &plugin_mailform_makeform($argv);
}

# フォームのHTML生成

sub plugin_mailform_makeform {
	my $argv=shift;
	my %option=&plugin_mailform_optionparse($argv);
	my $html=<<EOM;
<form action="$::script" method="post">
<input type="hidden" name="cmd" value="mailform">
<input type="hidden" name="confirm" value="true">
<input type="hidden" name="refer" value="@{[$::form{mypage} eq '' ? $::form{refer} : $::form{mypage}]}">
<input type="hidden" name="argv" value="$argv">
<table>
EOM

	if($option{no_name} ne 0) {
		$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_name}</td>
	<td><input name="mailform_name" size="$mailform::name_cols" value="$::form{mailform_name}"></td>
</tr>
EOM
	}

	if($option{no_from} ne 0) {
		$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_from}</td>
	<td><input name="mailform_from" size="$mailform::from_cols" value="$::form{mailform_from}" style="ime-mode: disabled;"></td>
</tr>
EOM
	}

	if($option{no_subject} ne 0 && $option{fixsubject} eq '') {
		$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_subject}</td>
	<td><input name="mailform_subject" size="$mailform::subject_cols" value="$::form{mailform_subject}"></td>
</tr>
EOM
	}

	$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_data}</td>
	<td><textarea name="mailform_data" rows="$mailform::rows" cols="$mailform::cols">$::form{mailform_data}</textarea></td>
</tr>
EOM


	$html.=<<EOM;
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="$::resource{mailform_plugin_btn_mailconfirm}"></td>
</tr>
</table>
</form>
EOM
	return $html;
}

# 確認画面のHTML生成

sub plugin_mailform_makeconfirm {
	my $argv=shift;
	my %option=&plugin_mailform_optionparse($argv);
	my $html=<<EOM;
<form action="$::script" method="post">
<input type="hidden" name="cmd" value="mailform">
<input type="hidden" name="refer" value="@{[$::form{mypage} eq '' ? $::form{refer} : $::form{mypage}]}">
<input type="hidden" name="argv" value="$argv">
<table>
EOM

	if($option{no_name} ne 0) {
		$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_name}</td>
	<td>$::form{mailform_name}<input name="mailform_name" type="hidden" value="$::form{mailform_name}"></td>
</tr>
EOM
	}

	if($option{no_from} ne 0) {
		$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_from}</td>
	<td>$::form{mailform_from}<input name="mailform_from" type="hidden" value="$::form{mailform_from}"></td>
</tr>
EOM
	}

	if($option{no_subject} ne 0 && $option{fixsubject} eq '') {
		$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_subject}</td>
	<td>$::form{mailform_subject}<input name="mailform_subject" type="hidden" value="$::form{mailform_subject}"></td>
</tr>
EOM
	}

	my $txt=$::form{mailform_data};
	$txt=~s/\x0D\x0A|[\x0D\x0A]/<BR>/g;

	$html.=<<EOM;
<tr>
	<td>$::resource{mailform_plugin_info_data}</td>
	<td>$txt<input name="mailform_data" type="hidden" value="$::form{mailform_data}"></td>
</tr>
EOM


	$html.=<<EOM;
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="edit" value="$::resource{mailform_plugin_btn_back}"><input type="submit" name="post" value="$::resource{mailform_plugin_btn_mailsend}"></td>
</tr>
</table>
</form>
EOM
	return $html;
}

# オプションの解析

sub plugin_mailform_optionparse {
	my @argv = split(/,/, shift);

	my %hash;
	$hash{no_name}=$mailform::no_name;
	$hash{no_subject}=$mailform::no_subject;
	$hash{no_data_check}=$mailform::no_data;
	$hash{no_from}=$mailform::no_from;

	foreach(@argv) {
		     if(/checkdata/) 	{ $hash{no_data_check}=1;
		} elsif(/usedata/)		{ $hash{no_data_check}=0;
		} elsif(/nosubject/)	{ $hash{no_subject}=0;
		} elsif(/usesubject/)	{ $hash{no_subject}=1;
		} elsif(/checksubject/)	{ $hash{no_subject}=2;
		} elsif(/noname/)		{ $hash{no_name}=0;
		} elsif(/usename/)		{ $hash{no_name}=1;
		} elsif(/checkname/)	{ $hash{no_name}=2;
		} elsif(/nomail/)		{ $hash{no_from}=0;
		} elsif(/usemail/)		{ $hash{no_from}=1;
		} elsif(/checkmail/)	{ $hash{no_from}=2;
		} else					{ $hash{fixsubject}=$_;
		}
	}
	return %hash;
}

1;

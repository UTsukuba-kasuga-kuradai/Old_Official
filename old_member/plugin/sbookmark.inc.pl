######################################################################
# sbookmark.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: sbookmark.inc.pl,v 1.12 2007/07/15 07:40:09 papu Exp $
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
# Author: Nekyo <nekyo (at) gmail (dot) com>
######################################################################
# v0.1.6以降専用です。
#
# v 0.0.2 - URLのチェック機構の追加、日本語URLの対応
# v 0.0.1 - ProtoType
#
# https:// をチェックするには、lib/Nana/HTTP.pm を
# $Nana::HTTP::useLWP=1 にして下さい。
######################################################################

use strict;

# コメント欄の全体フォーマット
my $sbookmark_format = "[[\x08TITLE\x08>\x08URL\x08]]-- \x08NAME\x08 \x08NOW\x08~\n\x08COMMENT\x08";


# 名前なしで処理しない
$sbookmark::noname = 1
	if(!defined($sbookmark::noname));

# URLが記載されていない場合エラー
$sbookmark::nodata = 1
	if(!defined($sbookmark::nodata));

# タイトルが記載されていない場合エラー
$sbookmark::notitle = 0
	if(!defined($sbookmark::notitle));

# URLが実在するかチェック
$sbookmark::urlcheck = 1
	if(!defined($sbookmark::urlcheck));

# コメントのテキストエリアの表示幅 
$sbookmark::size_msg = 40
	if(!defined($sbookmark::size_name));

# コメントの名前テキストエリアの表示幅 
$sbookmark::size_name = 24
	if(!defined($sbookmark::size_name));

# コメントの欄の挿入フォーマット
$sbookmark::format_msg = q{$1}
	if(!defined($sbookmark::format_msg));

# 拒否するURL
$sbookmark::ignoreurl='(\/\/|\.exe|\.scr|\.bat|\.pif)$'
	if(!defined($sbookmark::ignoreurl));

# 指定したURLと同じ内容なら、URLが存在しないと仮定する。
# (DNSがワイルドカードレコードで扱われているサーバーでの対策）
# (punyURLには対応していません)
$sbookmark::wildcarddnsurl=''
	if(!defined($sbookmark::wildcardurl));

sub plugin_sbookmark_action {


	if (($::form{url} =~ /^\s*$/ && $sbookmark::nodata eq 1)
	 || ($::form{title} =~ /^\s*$/ && $sbookmark::notitle eq 1)
	 || ($::form{myname} =~ /^\s*$/ && $sbookmark::noname eq 1)) {
		return('msg'=>"$::form{mypage}\t\t$::resource{sbookmark_plugin_err}",'body'=>&text_to_html($::database{$::form{mypage}}),'ispage'=>1);
	}
	if ($::form{url} !~/$::isurl/ || $::form{url}=~/$sbookmark::ignoreurl/) {
		return('msg'=>"$::form{mypage}\t\t$::resource{sbookmark_plugin_urlerr}",'body'=>&text_to_html($::database{$::form{mypage}}),'ispage'=>1);
	}
	if ($::form{url} ne '' && $::form{title} eq '') {
		$::form{title}=$::form{url};
	}


	if($sbookmark::urlcheck eq 1) {
		&load_module("Nana::HTTP");
		my $url=$::form{url};
		if($::_exec_plugined{punyurl} ne '') {

			&load_module("IDNA::Punycode");
			if($url=~/$::isurl_puny/o) {
				$url=~/(https?|ftp):\/\/([^:\/\#]+)(.*)/;
				my $schme=$1;
				my $host=$2;
				my $last=$3;
				my $_host="";
				foreach my $str(split(/\./,$host)) {
					if($str=~/$::isurl_puny/o) {
						$str=&code_convert(\$str, 'utf8', 'euc');
						idn_prefix('xn--');
						utf8::decode($str);
						$str=IDNA::Punycode::encode_punycode("$str") . '.';
						utf8::encode($str);
						$str=~s/\-{3,9}/--/g;
						$_host.=$str;
					} else {
						$_host.="$str.";
					}
				}
				$_host=~s/\.$//g;
				$url="$schme://$_host$last";
			}
		}
		my $http=new Nana::HTTP('plugin'=>"sbookmark");
		my ($result, $stream) = $http->get($url);
		if($result ne 0 || length($stream) eq 0) {
			return('msg'=>"$::form{mypage}\t\t$::resource{sbookmark_plugin_urlnot}",'body'=>&text_to_html($::database{$::form{mypage}}),'ispage'=>1);
		}

		if($sbookmark::wildcarddnsurl ne '') {
			my $whttp=new Nana::HTTP('plugin'=>"sbookmark");
			my ($resultw, $streamw) = $whttp->get($sbookmark::wildcarddnsurl);
			if($stream eq $streamw) {
				return('msg'=>"$::form{mypage}\t\t$::resource{sbookmark_plugin_urlnot}",'body'=>&text_to_html($::database{$::form{mypage}}),'ispage'=>1);
			}
		}
	}


	my $lines = $::database{$::form{mypage}};
	my @lines = split(/\r?\n/, $lines);

	my $datestr = ($::form{nodate} == 1) ? '' : &get_now;
	my $__name=$sbookmark::format_msg;
	$__name=~s/\$1/$::form{myname}/g;
	my $_name = $::form{myname} ? " $__name : " : " ";

	my $_now = "&new{$datestr};";

	my $postdata = '';
	my $_sbookmark_no = 0;

	my $sbookmark = $sbookmark_format;
	$sbookmark =~ s/\x08TITLE\x08/$::form{title}/;
	$sbookmark =~ s/\x08URL\x08/$::form{url}/;
	$sbookmark =~ s/\x08COMMENT\x08/$::form{comment}/;
	$sbookmark =~ s/\x08NAME\x08/$_name/;
	$sbookmark =~ s/\x08NOW\x08/$_now/;
	$sbookmark = "+" . $sbookmark;

	foreach (@lines) {
		if (/^#sbookmark/ && (++$_sbookmark_no == $::form{sbookmark_no})) {
			if ($::form{above} == 1) {
				$_ = ($sbookmark . "\n" . $_);
			} else {
				$_ .= ("\n" . $sbookmark);
			}
		}
		$postdata .= $_ . "\n";
	}
	if ($::form{url}) {
		$::form{mymsg} = $postdata;
		$::form{mytouch} = 'on';
		&do_write("FrozenWrite");
	} else {
		$::form{cmd} = 'read';
		&do_read;
	}
	&close_db;
	exit;
}

my $sbookmark_no = 0;
my %sbookmark_numbers = {}; # Tnx:Birgus-Latro

sub plugin_sbookmark_convert {
	my @argv = split(/,/, shift);

	my $above = 1;
	my $nodate = '';
	my $nametags = '<tr><td>'
		. $::resource{sbookmark_plugin_yourname}
		. '</td>'
		. '<td><input type="text" name="myname" value="" size="10"></td></tr>';

	my $nametags = '<tr><td>'
		. $::resource{sbookmark_plugin_yourname}
		. '</td><td>'
		. qq(<input type="text" name="myname" value="$::name_cookie{myname}" size="$sbookmark::size_name" />)
		. '</td></tr>';

	foreach (@argv) {
		chomp;
		if (/below/) {
			$above = 0;
		} elsif (/nodate/) {
			$nodate = 1;
		} elsif (/noname/) {
			$nametags = '';
		}
	}
	if (!exists $sbookmark_numbers{$::form{mypage}}) {
		$sbookmark_numbers{$::form{mypage}} = 0;
	}
	$sbookmark_no = ++$sbookmark_numbers{$::form{mypage}};
	my $escapedmypage = &escape($::form{mypage});
	my $conflictchecker = &get_info($::form{mypage}, $::info_ConflictChecker);
	return <<"EOD";
<form action="$::script" method="post">
 <div>
   <input type="hidden" name="sbookmark_no" value="$sbookmark_no" />
   <input type="hidden" name="cmd" value="sbookmark" />
   <input type="hidden" name="mypage" value="$escapedmypage" />
   <input type="hidden" name="myConflictChecker" value="$conflictchecker" />
   <input type="hidden" name="mytouch" value="on" />
   <input type="hidden" name="nodate" value="$nodate" />
   <input type="hidden" name="above" value="$above" />
   <table>
   $nametags
   <tr><td>$::resource{sbookmark_plugin_title}</td><td><input type="text" name="title" value="" size="$sbookmark::size_msg" /></td></tr>
   <tr><td>$::resource{sbookmark_plugin_url}</td><td><input type="text" name="url" value="http://" size="$sbookmark::size_msg" /></td></tr>
   <tr><td>$::resource{sbookmark_plugin_comment}</td><td><input type="text" name="comment" value="" size="$sbookmark::size_msg" /></td>
       <td><input type="submit" value="$::resource{sbookmark_plugin_button}" /></td></tr>
   </table>
 </div>
</form>
EOD
}
1;

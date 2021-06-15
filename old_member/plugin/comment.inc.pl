######################################################################
# comment.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: comment.inc.pl,v 1.61 2007/07/15 07:40:09 papu Exp $
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
# v 0.0.2 - 2004/10/28 Tnx:Birgus-Latro
# v 0.0.1 - ProtoType
######################################################################

use strict;

# コメント欄の全体フォーマット
$comment::format = "\x08MSG\x08 -- \x08NAME\x08 \x08NOW\x08"
	if(!defined($comment::format));

# 名前なしで処理しない
$comment::noname = 1
	if(!defined($comment::noname));

# 本文が記載されていない場合エラー
$comment::nodata = 1
	if(!defined($comment::nodata));

# コメントのテキストエリアの表示幅 
$comment::size_msg = 40
	if(!defined($comment::size_name));

# コメントの名前テキストエリアの表示幅 
$comment::size_name = 10
	if(!defined($comment::size_name));

# コメントの名前挿入フォーマット
$comment::format_name = "\'\'[[\$1>$::resource{profile_page}/\$1]]\'\'"
	if(!defined($comment::format_name));

# コメントの欄の挿入フォーマット
$comment::format_msg = q{$1}
	if(!defined($comment::format_msg));

# コメントの日付挿入フォーマット (&new で認識できること)
$comment::format_now = "Y-m-d(lL) H:i:s"
	if(!defined($comment::format_now));


sub plugin_comment_action {

	if (($::form{mymsg} =~ /^\s*$/ && $comment::nodata eq 1)
	 || ($::form{myname} =~ /^\s*$/ && $comment::noname eq 1)
		&& $::form{noname} eq '') {
		return('msg'=>"$::form{mypage}\t\t$::resource{comment_plugin_err}",'body'=>&text_to_html($::database{$::form{mypage}}),'ispage'=>1);
	}
	my $lines = $::database{$::form{mypage}};
	my @lines = split(/\r?\n/, $lines);

	my $datestr = ($::form{nodate} == 1) ? '' : &date($comment::format_now);
	my $__name=$comment::format_name;
	$__name=~s/\$1/$::form{myname}/g;
	my $_name = $::form{myname} ? " $__name : " : " ";
	my $_msg=$comment::format_msg;
	$_msg=~s/\$1/$::form{mymsg}/g;
	my $_now = "&new{$datestr};";

	my $postdata = '';
	my $_comment_no = 0;

	my $comment = $comment::format;
	$comment =~ s/\x08MSG\x08/$_msg/;
	$comment =~ s/\x08NAME\x08/$_name/;
	$comment =~ s/\x08NOW\x08/$_now/;
	$comment = "-" . $comment;

	foreach (@lines) {
		if (/^#comment/ && (++$_comment_no == $::form{comment_no})) {
			if ($::form{above} == 1) {
				$_ = ($comment . "\n" . $_);
			} else {
				$_ .= ("\n" . $comment);
			}
		}
		$postdata .= $_ . "\n";
	}
	if ($::form{mymsg}) {
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

my $comment_no = 0;
my %comment_numbers = {}; # Tnx:Birgus-Latro

sub plugin_comment_convert {
	my @argv = split(/,/, shift);
	my $noname=0;
	return ' '
		if($::writefrozenplugin eq 0 && &get_info($::form{mypage}, $::info_IsFrozen) eq 1);

	my $above = 1;
	my $nodate = '';
	my $nametags = $::resource{comment_plugin_yourname} . qq(<input type="text" name="myname" value="$::name_cookie{myname}" size="$comment::size_name" />);

	foreach (@argv) {
		chomp;
		if (/below/) {
			$above = 0;
		} elsif (/nodate/) {
			$nodate = 1;
		} elsif (/noname/) {
			$nametags = '';
			$noname=1;
		}
	}
	if (!exists $comment_numbers{$::form{mypage}}) { # Tnx:Birgus-Latro
		$comment_numbers{$::form{mypage}} = 0;
	}
	$comment_no = ++$comment_numbers{$::form{mypage}};
	my $escapedmypage = &escape($::form{mypage});
	my $conflictchecker = &get_info($::form{mypage}, $::info_ConflictChecker);
	return <<"EOD";
<form action="$::script" method="post">
 <div>
   <input type="hidden" name="comment_no" value="$comment_no" />
   <input type="hidden" name="cmd" value="comment" />
   <input type="hidden" name="mypage" value="$escapedmypage" />
   <input type="hidden" name="myConflictChecker" value="$conflictchecker" />
   <input type="hidden" name="mytouch" value="on" />
   <input type="hidden" name="nodate" value="$nodate" />
   <input type="hidden" name="above" value="$above" />
   @{[$noname eq 1 ? qq(<input type="hidden" name="noname" value="1" />) : ""]}
   $nametags
   <input type="text" name="mymsg" value="" size="$comment::size_msg" />
   <input type="submit" value="$::resource{comment_plugin_commentbutton}" />
 </div>
</form>
EOD
}
1;
__END__


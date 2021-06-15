######################################################################
# urlhack.inc.cgi - This is PyukiWiki, yet another Wiki clone.
# $Id: urlhack.inc.pl,v 1.74 2007/07/15 07:40:09 papu Exp $
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
# This is extented plugin.
# To use this plugin, rename to 'urlhack.inc.cgi'
######################################################################
#
# SEO対策用URLハックプラグイン
#
######################################################################

# PATH_INFO を使う（0の場合File not foundを補足する)
$urlhack::use_path_info=1
	if(!defined($urlhack::use_path_info));

# fake extension 拡張子偽装
$urlhack::fake_extention="/"
	if(!defined($urlhack::fake_extention));

# use puny url 0:16進エンコード 1:punyエンコード
$urlhack::use_puny=1
	if(!defined($urlhack::use_puny));

# not convert Alphabet or Number ( or dot and slash) page
$urlhack::noconvert_marks=2
	if(!defined($urlhack::noconvert_marks));

# force url hack (non extention .cgi)
$urlhack::force_exec=0
	if(!defined($urlhack::force_exec));

use strict;

# Initlize

sub plugin_urlhack_init {
	&exec_explugin_sub("lang");
	unless($::form{mypage} eq '' || $::form{mypage} eq $::FrontPage) {
		return('init'=>0
			,'func'=>'make_cookedurl',
			, 'make_cookedurl'=>\&make_cookedurl);
	}
	if($urlhack::use_path_info eq 0) {
		return('init'=>&plugin_urlhack_init_notfound
			,'func'=>'make_cookedurl',
			, 'make_cookedurl'=>\&make_cookedurl);
	} else {
		return('init'=>&plugin_urlhack_init_path_info
			,'func'=>'make_cookedurl',
			, 'make_cookedurl'=>\&make_cookedurl);
	}
}

sub plugin_urlhack_init_path_info {
	my $req=$ENV{PATH_INFO};

	unless($::form{cmd} eq '' || $::form{cmd} eq 'read') {
		return 0;
	}

	if($urlhack::fake_extention ne '') {
		my $regex=$urlhack::fake_extention;
		$regex=~s/([\.\/])/'\\x' . unpack('H2', $1)/eg;
		$req=~s/$regex$//g;
	}
	if(&is_exist_page($req)) {
		$::form{cmd}='read';
		$::form{mypage}=$req;
		return 0;
	}

	$req=~s!^/!!g;
	$req=~s!/$!!g;

	if($urlhack::fake_extention ne '') {
		my $regex=$urlhack::fake_extention;
		$regex=~s/([\.\/])/'\\x' . unpack('H2', $1)/eg;
		$req=~s/$regex$//g;
	}
	if(&is_exist_page($req)) {
		$::form{cmd}='read';
		$::form{mypage}=$req;
		return 0;
	}
	$req=&plugin_urlhack_decode($req);
	if($req eq '') {
		$req=&decode($ENV{QUERY_STRING});
		if(&is_exist_page($req)) {
			$::form{cmd}='read';
			$::form{mypage}=$req;
			return 0;
		} elsif(&is_exist_page($::form{mypage})) {
			$::form{cmd}='read';
			return 0;
		}
		$::form{cmd}='read';
		$::form{mypage}=$::FrontPage;
		return 0;
	} elsif(&is_exist_page($req)) {
		$::form{cmd}='read';
		$::form{mypage}=$req;
		return 1;
	}
	return 0;
}

sub plugin_urlhack_init_notfound {
	if($urlhack::force_exec eq 0) {
		unless($ENV{SCRIPT_NAME}=~/nph-/ || $ENV{REQUEST_URI}=~/\.cgi/) {
			$::debug.="Not used urlhack.inc.cgi\n";
			return 0;
		}
	}
	my $req;

	if($::form{cmd} eq 'servererror') {
		if($ENV{REDIRECT_STATUS} eq 404) {
			$req=$ENV{REDIRECT_URL};
		} else {
			return 0;
		}
	}

	if($req ne '' || $::form{cmd} eq '' || $::form{cmd} eq 'read') {
		$req=$ENV{REQUEST_URI};
		$req="$req/" if($urlhack::force_exec eq 1 && ($ENV{REQUEST_URI}!~/\.cgi$/ || $ENV{REQUEST_URI}=~/\/$/));
	} else {
		return 0;
	}

	$req=~s/\?.*//g;

	if($urlhack::noconvert_marks eq 2) {
		my $uri;

		if($req ne '') {
			if($req eq $ENV{SCRIPT_NAME}) {
				$uri= $ENV{'SCRIPT_NAME'};
			} else {
				for(my $i=0; $i<length($ENV{SCRIPT_NAME}); $i++) {
					if(substr($ENV{SCRIPT_NAME},$i,1)
						eq substr($req,$i,1)) {
						$uri.=substr($ENV{SCRIPT_NAME},$i,1);
					} else {
						last;
					}
				}
			}
		} else {
			$uri .= $ENV{'SCRIPT_NAME'};
		}
		$uri=~s!/!\x08!g;
		$req=~s!/!\x08!g;
		$req=~s!^$uri!!g;
		$req=~s!\x08!/!g;
	} else {
		$req=~s/.*\///g;
		$req=~s/^\///g;
	}
	$req=~s!^/!!g;
	$req=~s!/$!!g;

	if($urlhack::fake_extention ne '') {
		my $regex=$urlhack::fake_extention;
		$regex=~s/([\.\/])/'\\x' . unpack('H2', $1)/eg;
		$req=~s/$regex$//g;
	}
	$req=~s/%([A-Fa-f0-9][A-Fa-f0-9])/chr(hex($1))/eg;
	if(&is_exist_page($req)) {
		$::form{cmd}='read';
		$::form{mypage}=$req;
		return 0;
	}
	$req=&plugin_urlhack_decode($req);

	if($req eq '') {
		$req=&decode($ENV{QUERY_STRING});
		if(&is_exist_page($req)) {
			$::form{cmd}='read';
			$::form{mypage}=$req;
			return 0;
		} elsif(&is_exist_page($::form{mypage})) {
			$::form{cmd}='read';
			return 0;
		}
		$::form{cmd}='read';
		$::form{mypage}=$::FrontPage;
		return 0;
	} elsif(&is_exist_page($req)) {
		$::form{cmd}='read';
		$::form{mypage}=$req;
		return 1;
	} else {
		$::form{cmd}='servererror';
		$ENV{REDIRECT_STATUS}=404;
		$ENV{REDIRECT_URL}=$ENV{REQUEST_URI};
		$ENV{REDIRECT_REQUEST_METHOD}="GET";
		return 0;
	}
}


sub make_cookedurl {
	my($cookedchunk)=@_;
	if($urlhack::force_exec eq 0 && $urlhack::use_path_info eq 0) {
		unless($ENV{SCRIPT_NAME}=~/nph-/ || $ENV{REQUEST_URI}=~/\.cgi/) {
			return("$::script?$cookedchunk");
		}
	}
	$cookedchunk=&decode($cookedchunk);
	my $orgchunk=$cookedchunk;
	if($urlhack::noconvert_marks+0 eq 0) {
		$cookedchunk=&plugin_urlhack_encode($cookedchunk);
	} elsif($cookedchunk=~/(\W)/ && $urlhack::noconvert_marks+0 eq 1) {
		$cookedchunk=&plugin_urlhack_encode($cookedchunk);
	} elsif($cookedchunk=~/([^0-9A-Za-z\.\/])/) {
		$cookedchunk=&plugin_urlhack_encode($cookedchunk);
	}
	my $script=$::script;
	$script=~s/\/$//g;
	if($cookedchunk eq '' || $orgchunk eq $::FrontPage) {
		return "$script/";
	} else {
		return "$script/$cookedchunk$urlhack::fake_extention";
	}
}

sub plugin_urlhack_decode {
	my($str)=@_;
	if($str=~/xn\-/) {
		&plugin_urlhack_usepuny;
		$str=~s/\_/\//g;
		$str=IDNA::Punycode::decode_punycode($str);
		$str=&code_convert(\$str, 'euc', 'utf8');
	} else {
		$str=~s/([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
	}
	$str=~s/\+/\ /g;
	$str=~s/\!2b/\+/g;
	return $str;
}

sub plugin_urlhack_encode {
	my($str)=@_;
	if($urlhack::use_puny eq 0) {
		$str=~ s/(.)/unpack('H2', $1)/eg;
	} else {
		&plugin_urlhack_usepuny;
		$str=~s/\+/!2b/g;
		$str=~s/\ /+/g;
		my $org=$str;
		$str=&code_convert(\$str, 'utf8', 'euc');
		utf8::decode($str);
		$str=IDNA::Punycode::encode_punycode($str);
		$str=~s/\-{3,9}/--/g;
		$str=~s/\//\_/g if($str ne $org);
		utf8::encode($str);
	}
	return $str;
}

sub plugin_urlhack_usepuny {
	if($::puny_loaded+0 ne 1) {
		if($] < 5.008001) {
			die "Perl v5.8.1 required this is $]";
		}
		$::puny_loaded=1;
		require "$::explugin_dir/IDNA/Punycode.pm";
	}
	IDNA::Punycode::idn_prefix('xn--');
}

1;
__DATA__
	return(
	'ja'=>'SEO対策用URLハック',
	'en'=>'The measure against SEO',
	'override'=>'make_cookedurl',
	'setting_ja'=>
		'$::urlhack_use_path_info=メソッド:1=PATH_INFO,0=Not Found エラー/' .
		'$::urlhack_fake_extention=偽の拡張子の設定:=なし,.html,/=ディレクトリに見せる/' .
		'$::urlhack_noconvert_marks=エンコードしない文字:0=すべてエンコード,1=アルファベットと数字のみのページのみ,2=アルファベットと数字、ドット、スラッシュ',
	'setting_en'=>
		'$::urlhack_use_path_info=Method:1=PATH_INFO,0=Not Found Error/' .
		'$::urlhack_fake_extention=Fake extention:=none,.html,/' .
		'$::urlhack_noconvert_marks=Not convert charactors:0=All encode,1=Alphabet and number of page name,2=Alphabet and number and dot and slash',
	'url'=>'http://pyukiwiki.sourceforge.jp/PyukiWiki/Plugin/ExPlugin/urlhack/'
	);
__END__


######################################################################
# lang.inc.cgi - This is PyukiWiki, yet another Wiki clone.
# $Id: lang.inc.pl,v 1.31 2007/07/15 07:40:09 papu Exp $
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
# Return:LF Code=UTF-8 1TAB=4Spaces
######################################################################
# This is extented plugin.
# To use this plugin, rename to 'lang.inc.cgi'
######################################################################
# 国際化対応拡張プラグイン
# 以下の言語別wikiディレクトリを作成して下さい。
# attach.(lang)		example attach.en
# diff.(lang)		example diff.ja
# cache.(lang)		example cache.zh-cn
# counter.(lang)	example counter.en-us
# info.(lang)		example info.fr
# wiki.(lang)		example wiki.ja
# デフォルト言語は、従来のディレクトリのままで動作します。
######################################################################

%::langlist=(
	'af'=>'Afrikaans',
	'sq'=>'Albanian',
	'ar'=>'Arabic',
	'ar-sa'=>'Arabic(Saudi Arabia)',
	'ar-iq'=>'Arabic(Iraq)',
	'ar-eg'=>'Arabic(Egypt)',
	'ar-ly'=>'Arabic(Libya)',
	'ar-dz'=>'Arabic(Algeria)',
	'ar-ma'=>'Arabic(Morocco)',
	'ar-tn'=>'Arabic(Tunisia)',
	'ar-om'=>'Arabic(Oman)',
	'ar-ye'=>'Arabic(Yemen)',
	'ar-sy'=>'Arabic(Syria)',
	'ar-jo'=>'Arabic(Jordan)',
	'ar-lb'=>'Arabic(Lebanon)',
	'ar-kw'=>'Arabic(Kuwait)',
	'ar-ae'=>'Arabic(U.A.E.)',
	'ar-bh'=>'Arabic(Bahrain)',
	'ar-qa'=>'Arabic(Qatar)',
	'eu'=>'Basque',
	'bg'=>'Bulgarian',
	'be'=>'Belarusian',
	'ca'=>'Catalan',
	'cn'=>'Chinese,中文',
	'zh'=>'Chinese,中文',
	'zh-cn'=>'Chinese,中文',
	'zh-tw'=>'Chinese(Taiwan),台灣語',
	'zh-hk'=>'Chinese(Hong Kong),香港语',
	'zh-sg'=>'Chinese(Singapore),新加坡语',
	'hr'=>'Croatian',
	'cs'=>'Czech',
	'da'=>'Danish',
	'nl'=>'Dutch',
	'nl-be'=>'Dutch(Belgian)',
	'en'=>'English',
	'en-us'=>'English(United States)',
	'en-gb'=>'English(British)',
	'en-au'=>'English(Australian)',
	'en-ca'=>'English(Canadian)',
	'en-nz'=>'English(New Zealand)',
	'en-ie'=>'English(Ireland)',
	'en-za'=>'English(South Africa)',
	'en-jm'=>'English(Jamaica)',
	'en-bz'=>'English(Belize)',
	'en-tt'=>'English(Trinidad)',
	'et'=>'Estonian',
	'fo'=>'Faeroese',
	'fa'=>'Farsi',
	'fi'=>'Finnish',
	'fr'=>'French',
	'fr-be'=>'French(Belgian)',
	'fr-ca'=>'French(Canadian)',
	'fr-ch'=>'French(Swiss)',
	'fr-lu'=>'French(Luxembourg)',
	'gd'=>'Gaelic',
	'gd-ie'=>'Gaelic(Irish)',
	'de'=>'German',
	'de-ch'=>'German(Swiss)',
	'de-at'=>'German(Austrian)',
	'de-lu'=>'German(Luxembourg)',
	'de-li'=>'German(Liechtenstein)',
	'el'=>'Greek',
	'he'=>'Hebrew',
	'hi'=>'Hindi',
	'hu'=>'Hungarian',
	'is'=>'Icelandic',
	'in'=>'Indonesian',
	'it'=>'Italian',
	'it-ch'=>'Italian(Swiss)',
	'ja'=>'Japanese,日本語',
	'ko'=>'Korean,한국어',
	'kr'=>'Korean,한국어',
	'lv'=>'Latvian',
	'lt'=>'Lithuanian',
	'mk'=>'Macedonian',
	'ms'=>'Malaysian',
	'mt'=>'Maltese',
	'no'=>'Norwegian',
	'pl'=>'Polish',
	'pt'=>'Portuguese',
	'pt-br'=>'Portuguese(Brazilian)',
	'rm'=>'Rhaeto-Romanic',
	'ro'=>'Romanian',
	'ro-mo'=>'Romanian(Moldavia)',
	'ru'=>'Russian',
	'ru-mo'=>'Russian(Moldavia)',
	'sz'=>'Sami',
	'sr'=>'Serbian',
	'sk'=>'Slovak',
	'sl'=>'Slovenian',
	'sb'=>'Sorbian',
	'es'=>'Spanish',
	'es-mx'=>'Spanish(Mexican)',
	'es-gt'=>'Spanish(Guatemala)',
	'es-cr'=>'Spanish(Costa Rica)',
	'es-pa'=>'Spanish(Panama)',
	'es-do'=>'Spanish(Dominican Republic)',
	'es-ve'=>'Spanish(Venezuela)',
	'es-co'=>'Spanish(Colombia)',
	'es-pe'=>'Spanish(Peru)',
	'es-ar'=>'Spanish(Argentina)',
	'es-ec'=>'Spanish(Ecuador)',
	'es-cl'=>'Spanish(Chile)',
	'es-uy'=>'Spanish(Uruguay)',
	'es-py'=>'Spanish(Paraguay)',
	'es-bo'=>'Spanish(Bolivia)',
	'es-sv'=>'Spanish(El Salvador)',
	'es-hn'=>'Spanish(Honduras)',
	'es-ni'=>'Spanish(Nicaragua)',
	'es-pr'=>'Spanish(Puerto Rico)',
	'sx'=>'Sutu',
	'sv'=>'Swedish',
	'sv-fi'=>'Swedish(Finland)',
	'th'=>'Thai',
	'ts'=>'Tsonga',
	'tn'=>'Tswana',
	'tr'=>'Turkish',
	'uk'=>'Ukrainian',
	'ur'=>'Urdu',
	've'=>'Venda',
	'vi'=>'Vietnamese',
	'xh'=>'Xhosa',
	'ji'=>'Yiddish',
	'zu'=>'Zulu',
);

# now unuse...reserved
%::charsetlist=(
	'ja'=>'EUC-JP,iso-2022-jp,Shift-JIS',
	'ko'=>'euc-kr,iso-2022-kr',
	'kr'=>'euc-kr,iso-2022-kr',
	'cn'=>'gb2312,gb2312-80',
	'zh'=>'gb2312,gb2312-80',
	'zh-tw'=>'big5,x-euc-tw,x-cns11643-1,x-cns11643-2',
	'ar'=>'iso-8859-6',
	'be'=>'iso-8859-5',
	'bg'=>'iso-8859-5',
	'cs'=>'iso-8859-2',
	'el'=>'iso-8859-7',
	'hr'=>'iso-8859-2',
	'hu'=>'iso-8859-2',
	'hw'=>'iso-8859-8',
	'lt'=>'iso-8859-2',
	'lv'=>'iso-8859-2',
	'mk'=>'iso-8859-5',
	'pl'=>'iso-8859-2',
	'ro'=>'iso-8859-2',
	'ru'=>'iso-8859-5',
	'sh'=>'iso-8859-5',
	'sl'=>'iso-8859-5',
	'sq'=>'iso-8859-5',
	'sr'=>'iso-8859-5',
	'th'=>'TIS620',
	'sr'=>'iso-8859-9',
	'uk'=>'iso-8859-5',
	''=>'iso-8859-1',
);

my $bot_agent='[Bb]ot|Spider|inktomi|moget|Slurp|archiver|NG|Hatena';

%::lang_cookie;
$::lang_cookie="PyukiWikiLang_"
				. length($::basepath);

sub plugin_lang_init {
	my @langlist;
	return('init'=>0) if($::lang_list eq '');
	return('init'=>0) if($ENV{HTTP_USER_AGENT}=~/$bot_agent/);
	push(@langlist,$::lang);
	foreach(split(/ /,$::lang_list)) {
		if(-d "$::data_dir.$_" && $_ ne $::lang) {
			push(@langlist,$_);
		}
	}
	return('init'=>0) if($#langlist < 1);

	$::defaultlang=$::lang;

	%::lang_cookie=();
	%::lang_cookie=&getcookie($::lang_cookie,%::lang_cookie);

	if($::langlist{$::form{lang}} ne '') {
		$::lang=$::form{lang};
	} elsif($::lang_cookie{lang} ne '') {
		$::lang=$::lang_cookie{lang};
	} else {
		my $detectacq=0;
		my $http_accept_language=$ENV{HTTP_ACCEPT_LANGUAGE};
		$http_accept_language=~s/['"]//g;
		foreach(split(/,/,$http_accept_language)) {
			my($aclang,$acq)=split(/;q=/,$_);
			$acq="1.0" if($acq eq '');
			if($detectacq+0<$acq+0) {
				foreach(@langlist) {
					if($_ eq $aclang) {
						$detectacq=$acq;
						$::lang=$aclang;
					} else {
						$aclang=~s/\-.*//g;
						if($_ eq $aclang) {
							$detectacq=$acq;
							$::lang=$aclang;
						}
					}
				}
			}
		}
	}
	foreach(@langlist) {
		if($::navi{"lang" . $_ . "_url"} eq '') {
			push(@::addnavi,"lang_$_:help");
			$::navi{"lang_" . $_ . "_title"}=&getlangname($_);
			$::navi{"lang_" . $_ . "_url"}="$::script?cmd=lang&amp;lang=$_";
			$::navi{"lang_" . $_ . "_name"}=&getlangname($_)
				if($::lang ne $_);
			$::navi{"lang_" . $_ . "_type"}="plugin";
			$::navi{"lang_" . $_ . "_height"}=14;
			$::navi{"lang_" . $_ . "_width"}=16;
		}
	}
	&init_lang;
	&init_dtd;
	%::resource = &read_resource("$::res_dir/resource.$::lang.txt",%::resource);
	&dateinit;
	if($::defaultlang ne $::lang) {
		$::wiki_title=$::wiki_title{$::lang} if($::wiki_title{$::lang} ne '');
		&close_db;
		$::data_dir.=".$::lang";
		$::diff_dir.=".$::lang";
		$::cache_dir.=".$::lang";
		$::cache_url.=".$::lang";
		$::upload_dir.=".$::lang";
		$::upload_url.=".$::lang";
		$::counter_dir.=".$::lang";
		$::info_dir.=".$::lang";
		&open_db;
	}
	my $req=&decode($ENV{QUERY_STRING});
	if(&is_exist_page($req)) {
		$::form{cmd}='read';
		$::form{mypage}=$req;
	}
	return('init'=>1, 'func'=>'init_lang', 'init_lang'=>\&init_lang);
}

sub getlangname {
	my ($v)=@_;
	my ($lang,$langutf)=split(/,/,$::langlist{$v});
	return $lang;
}

sub init_lang {
	if ($::lang eq 'ja') {
		$::defaultcode='euc';
		if(lc $::charset eq 'utf-8') {
			$::kanjicode='utf8';
		} else {
			$::charset=(
				$::kanjicode eq 'euc' ? 'EUC-JP' :
				$::kanjicode eq 'utf8' ? 'UTF-8' :
				$::kanjicode eq 'sjis' ? 'Shift-JIS' : 
				$::kanjicode eq 'jis' ? 'iso-2022-jp' : '')
		}

	} elsif ($::lang eq 'zh') {
		$::defaultcode='gb2312';
		$::charset = 'gb2312' if(lc $::charset ne 'utf-8');

	} elsif ($::lang eq 'zh-tw') {
		$::defaultcode='big5';
		$::charset = 'big5' if(lc $::charset ne 'utf-8');

	} elsif ($::lang eq 'ko' || $::lang eq 'kr') {
		$::defaultcode='euc-kr';
		$::charset = 'euc-kr' if(lc $::charset ne 'utf-8');

	} else {
		$::defaultcode='iso-8859-1';
		$::charset = 'iso-8859-1' if(lc $::charset ne 'utf-8');
	}

	if($::_exec_plugined{lang} > 0) {
		$::wiki_title=$::wiki_title{$::lang} if($::wiki_title{$::lang} ne '');
		$::modifier=$::modifier{$::lang} if($::modifier{$::lang} ne '');
		$::modifierlink=$::modifierlink{$::lang} if($::modifierlink{$::lang} ne '');
		$::modifier_mail=$::modifier_mail{$::lang} if($::modifier_mail{$::lang} ne '');
		$::meta_keyword=$::meta_keyword{$::lang} if($::meta_keyword{$::lang} ne '');
	}

	$::modifierlink=$::basehref if($::modifierlink eq '');
}

1;
__DATA__
# $charset: UTF-8$
sub plugin_lang_setup {
	return(
	'ja'=>'Wiki国際化プラグイン',
	'en'=>'International Plugin',
	'url'=>'http://pyukiwiki.sourceforge.jp/PyukiWiki/Plugin/ExPlugin/lang/'
	);
__END__


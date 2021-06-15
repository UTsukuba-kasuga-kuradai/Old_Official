######################################################################
# wiki.cgi - This is PyukiWiki, yet another Wiki clone.
# $Id: wiki.cgi,v 1.211 2007/07/15 07:40:09 papu Exp $
#
# "PyukiWiki" version 0.1.7 $$
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
##############################
# Setting Database Type
#use Yuki::YukiWikiDB;
use Nana::YukiWikiDB;

#$::modifier_dbtype = 'Yuki::YukiWikiDB';
$::modifier_dbtype = 'Nana::YukiWikiDB';

##############################
# Check if the server can use 'AnyDBM_File' or not.
# eval 'use AnyDBM_File';
# my $error_AnyDBM_File = $@;

##############################
# 2005.10.27 pochi: 自動リンク機能を拡張 ('?' | 'this' | '')
$::editchar = '?';

##############################
$::subject_delimiter = ' - ';
$::use_autoimg = 1;
$::use_exists = 0;

##############################
$::package = 'PyukiWiki';
$::version = '0.1.7';



%::functions = (
	"dbmname" => \&dbmname,
	"undbmname" => \&undbmname,
	"htmlspecialchars" => \&htmlspecialchars,
	"javascriptspecialchars" => \&javascriptspecialchars,
	"encode" => \&encode,
	"make_link" => \&make_link,
	"authadminpassword" => \&authadminpassword,
	"code_convert" => \&code_convert,
	"http_header" => \&http_header,
	"load_module" => \&load_module,
	"make_link_url" => \&make_link_url,
	"make_link_mail" => \&make_link_mail,
	"make_link_image" => \&make_link_image,
);

%::values=();



$::counter_ext = '.count';
my $lastmod;

%::database;
%::infobase;
%::diffbase;
%::interwiki;
$::pageplugin=0;

%::_plugined;
%::_exec_plugined;
%::_exec_plugined_func;
%::_exec_plugined_value;# override values
%::_module_loaded;
%::_resource_loaded;

@::navi=();
@::addnavi=();
%::navi=();
%::dtd;

%::_urlescape;
%::_dbmname_encode;
%::_dbmname_decode;

%::_date_ampm;
%::_date_ampm_locale;
%::_date_weekday;
%::_date_weekdaylength;
%::_date_weekday_locale;
%::_date_weekdaylength_locale;

$::HTTP_HEADER;
$::IN_HEAD;
$::is_xhtml;

# 2006.1.30 pochi: 改行モードを設置
$::lfmode;

@::notes = ();


$::ini_file = 'pyukiwiki.ini.cgi' if($::ini_file eq '');
require $::ini_file;
require $::setup_file if (-r $::setup_file);


&skin_init;

##############################

#$::wiki_name = '\b([A-Z][a-z]+([A-Z][a-z]+)+)\b';
$::wiki_name = '\b([A-Z][a-z]+[A-Z][a-z]+)\b';


#my $bracket_name = '\[\[([^\]]+?)\]\]';
$::bracket_name ='\[\[((?!\[)[^\]]+?)\]\]';


$::interwiki_definition = '\[((?!\[)\S+?)\ (\S+?)\](?!\])';
$::interwiki_definition2 = '\[((?!\[)\S+?)\ (\S+?)\](?!\])\ (utf8|euc|sjis|yw|asis|raw|moin)';


$::interwiki_name1 = '([^:]+):([^:].*)';
$::interwiki_name2 = '([^:]+):([^:#].*?)(#.*)?';


if($::useFileScheme eq 1) {
	$::isurl=q(s?(?:(?:(?:https?|ftp|news)://)|(?:file:[/\x5c][/\x5c]))(?:[-\x5c_.!~*'a-zA-Z0-9;/?:@&=+$,%#]+));
} else {
	$::isurl=qq(s?(?:https?|ftp|news)://[-_.!~*'a-zA-Z0-9;/?:@&=+$,%#]+);
}


$::ismail=q((?:[^(\040)<>@,;:&#"'.\\\[\]\000-\037\x80-\xff](?:[^(\040)<>@,;:&#".\\\[\]\000-\037\x80-\xff])*(?![^(\040)<>@,;:&#".\\\[\]\000-\037\x80-\xff])|["'][^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*["'])(?:\.(?:[^(\040)<>@,;:&#"'.\\\[\]\000-\037\x80-\xff](?:[^(\040)<>@,;:&#".\\\[\]\000-\037\x80-\xff])*(?![^(\040)<>@,;:&#".\\\[\]\000-\037\x80-\xff])|["'][^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*["']))*\.?@(?:[^(\040)<>@,;:&#"'.\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:&#"'.\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])(?:\.(?:[^(\040)<>@,;:&#"'.\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:&#"'.\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])));


$::ismail.=$::IntraMailAddr eq 0 ? '+' : '*';


$::image_extention=qq(([Gg][Ii][Ff]|[Pp][Nn][Gg]|[Jj][Pp](?:[Ee])?[Gg]));

##############################

$::embed_plugin = '^\#([^\(]+)(\((.*)\))?';
$::embedded_name = '(\#.+?)';

$::embedded_inline='&amp;(?:([^(;{]+)(?:[()\s?]*?)\s?\{\s?([^&}]*?)\s?\}|([^(;{]+)|([^(;{]+)\s?\(\s?([^)]*?)\s?\)|([^(;{]+)\s?\(\s?([^)]*?)\s?\)\s?\{\s?([^&}]*?)\s?\});';

##############################

$::info_ConflictChecker = 'ConflictChecker';
$::info_LastModified = 'LastModified';
$::info_CreateTime='CreateTime';
$::info_LastModifiedTime='LastModifiedTime';
$::info_UpdateTime='UpdateTime';
$::info_IsFrozen = 'IsFrozen';
$::info_AdminPassword = 'AdminPassword';
##############################


%::fixedpage = (
	$::AdminPage => 'admin',
	$::ErrorPage => '',
	$::RecentChanges => 'recent',
	$::IndexPage => 'list',
	$::SearchPage => 'search',
	$::CreatePage => 'newpage',
);


%::fixedplugin = (
	'newpage' => 1,
	'search' => 1,
	'list' => 1,
);


%::_htmlspecial = (
	'&' => '&amp;',
	'<' => '&lt;',
	'>' => '&gt;',
	'"' => '&quot;',
);


%::_unescape = (
	'amp'  => '&',
	'lt'   => '<',
	'gt'   => '>',
	'quot' => '"',
);


%::_facemark = (
	' :)'		=> 'smile',
	' (^^)'		=> 'smile',
	' :D'		=> 'bigsmile',
	' (^-^)'	=> 'bigsmile',
	' :p'		=> 'huh',
	' :d'		=> 'huh',
	' XD'		=> 'oh',
	' X('		=> 'oh',
	' ;)'		=> 'oh',
	' (;'		=> 'wink',
	' (^_-)'	=> 'wink',
	' ;('		=> 'sad',
	' :('		=> 'sad',
	' (--;)'	=> 'sad',
	' (^^;)'	=> 'worried',
	'&heart;'	=> 'heart',
	'&bigsmile;'=> 'bigsmile',
	'&huh;'		=> 'huh',
	'&oh;'		=> 'oh',	
	'&sad;'		=> 'sad',
	'&smile;'	=> 'smile',
	'&wink;'	=> 'wink',
	'&worried;' => 'worried',
);


$::_facemark=q{\ \(--\;\)|\ \(\;|\ \(\^-\^\)|\ \(\^\^\)|\ \(\^\^\;\)|\ \(\^_-\)|\ \:\(|\ \:\)|\ \:D|\ \:d|\ \:p|\ \;\(|\ \;\)|\ X\(|\ XD|\&heart\;};
$::_facemark.=q{|\&bigsmile\;|\&huh\;|\&oh\;|\&sad\;|\&smile\;|\&wink\;|\&worried\;} if($::usePukiWikiStyle eq 1);


my %command_do = (
	read => \&do_read,
	write => \&do_write,
);

&main;
exit(0);
##############################



sub main {
	&getbasehref;
	&init_lang;
	&init_dtd;
	&init_global;


	$qCGI=new CGI;


	%::resource = &read_resource("$::res_dir/resource.$::lang.txt");


	&dateinit;


	$::HTTP_HEADER = '';
	$::IN_HEAD = '';
	if($::P3P ne '') {
		$::HTTP_HEADER.=qq(P3P: CP="$::P3P"\n);
	}


	&open_db;
	&init_form;
	&init_InterWikiName;
	&init_inline_regex;


	&exec_explugin if($::useExPlugin > 0);


	my $ret=1;
	if ($command_do{$::form{cmd}}) {
		$ret=&{$command_do{$::form{cmd}}};
	}

	if($ret eq 1) {
		if (&exec_plugin == 1) {
			$::form{mypage} = $::FrontPage if (!$::form{mypage});
			$::pageplugin=1;
			&do_read;
		}
	}

	&close_db;
}




sub init_global {
	&close_db;
	%::form = ();
	%::database = ();
	%::infobase = ();
	%::diffbase = ();
	%::interwiki = ();
	%::_resource_loaded = ();
	$lastmod = "";
	%::_plugined = ();
	$::pageplugin=0;
	%::_exec_plugined=();
	%::_exec_plugined_func=();
	%::_exec_plugined_value=();
	%::_module_loaded=();

	foreach my $i (0x00 .. 0xFF) {
		$::_urlescape{chr($i)} = sprintf('%%%02x', $i);
		$::_dbmname_encode{chr($i)} = sprintf('%02X', $i);
		$::_dbmname_decode{sprintf('%02X', $i)} = chr($i);
	}
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

	$::modifierlink=$::basehref if($::modifierlink eq '');
}


sub init_dtd {

	%::dtd = (
		"html4"=>qq(<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n<html lang="$::lang">\n<head>\n<meta http-equiv="Content-Language" content="$::lang" />\n<meta http-equiv="Content-Type" content="text/html; charset=$::charset" />),
		"xhtml11"=>qq(<?xml version="1.0" encoding="$::charset" ?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="$::lang">\n<head>),
		"xhtml10"=>qq(<?xml version="1.0" encoding="$::charset" ?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml" lang="$::lang" xml:lang="$::lang">\n<head>),
		"xhtml10t"=>qq(<?xml version="1.0" encoding="$::charset" ?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml" lang="$::lang" xml:lang="$::lang">\n<head>),
		"xhtmlbasic10"=>qq(<?xml version="1.0" encoding="$::charset" ?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="$::lang">\n<head>),
	);

	$::dtd=$::dtd{$::htmlmode};
	$::dtd=$::dtd{html4} if($::dtd eq '');
	$::dtd.=<<EOM;

<meta http-equiv="Content-Style-Type" content="text/css" />
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta name="generator" content="PyukiWiki $::version" />
EOM


	$::is_xhtml=$::dtd=~/xml/;
}


sub exec_plugin {
	my $exec = 1;
	if ($::form{cmd}) {

		if (&exist_plugin($::form{cmd}) == 1) {
			my $action = "\&plugin_" . $::form{cmd} . "_action";
			my %ret = eval $action;
			$::debug.=$@;
			if (($ret{msg} ne '') && ($ret{body} ne '')) {
				$::HTTP_HEADER.=$ret{http_header};
				$::IN_HEAD.=$ret{header};
				$exec = 0;
				$::allview = 0 if($ret{notviewmenu} eq 1);
				$::pageplugin=1 if($ret{ispage} eq 1);
				&skinex($ret{msg}, $ret{body});
			}
		}
	}
	return $exec;
}


sub exec_explugin {

	opendir(DIR,"$::explugin_dir");
	while(my $dir=readdir(DIR)) {
		if($dir=~/(.*?)\.inc\.cgi$/) {
			my $explugin=$1;
			&exec_explugin_sub($explugin);
		}
	}
}


sub exec_explugin_sub {
	my($explugin)=@_;
	if (&exist_explugin($explugin) eq 1) {

		my $action = "\&plugin_" . $explugin . "_init";
		my %ret = eval $action;
		$::debug.=$@;
		$::_exec_plugined{$explugin} = 2 if($ret{init}); #execed

		foreach(split(/,/,$ret{func})) {
			if($_exec_plugined_func{$_} ne '' ) {
				&skinex("\t\t$ErrorPage","$::resource{dupexplugin}<ul><li>$_exec_plugined_func{$_}<li>$explugin</li></ul>");
				exit;
			}
			$_exec_plugined_func{$_}=$explugin;
			$::functions=$ret{$_};
		}

		foreach(split(/,/,$ret{value})) {
			if($_exec_plugined_value{$_} ne '' ) {
				&skinex("\t\t$ErrorPage","$::resource{dupexplugin}<ul><li>$_exec_plugined_value{$_}<li>$explugin</li></ul>");
				exit;
			}
			$_exec_plugined_value{$_}=$explugin;
			$::values=$ret{$_};
		}

		$::HTTP_HEADER.="$ret{http_header}\n";
		$::IN_HEAD.=$ret{header};


		if (($ret{msg} ne '') && ($ret{body} ne '')) {
			$exec = 0;
			&skinex($ret{msg}, $ret{body});
			exit;
		}
	}
}


sub skin_init {
	$::skin_file="$::skin_dir/" . &skin_check("$::skin_name.skin%s.cgi",".$::lang","");
	$::skin{default_css}=&skin_check("$::skin_name.default%s.css",".$::lang","");
	$::skin{print_css}=&skin_check("$::skin_name.print%s.css",".$::lang","");
	$::skin{common_js}=&skin_check("common%s.js",".$::kanjicode.$::lang",".$::lang");
}


sub skin_check {
	my($file)=@_;
	foreach(@_) {
		my $f=sprintf($file,$_);
		return $f if(-f "$::skin_dir/$f");
	}
	die sprintf("$file not found","");
	exit;
}


sub init_inline_regex {
	$::inline_regex =qq(($bracket_name)|($embedded_inline));
	$::inline_regex.=qq(|($isurl))
		if($::autourllink eq 1);
	$::inline_regex.=qq(|(mailto:$ismail)|($ismail))
		if($::automaillink eq 1);
	$::inline_regex.=qq(|($wiki_name))
		if($::nowikiname ne 1);
}


sub skinex {
	my ($pagename, $body, $is_page, $pageplugin) = @_;
	my $bodyclass = "normal";
	my $editable = 0;
	my $admineditable = 0;
	my ($page,$msg)=split(/\t/,$pagename);
	$pageplugin+=0;
	$::pageplugin+=0;

	if($::form{refer} eq '' && &is_frozen($page) || &is_exist_page($::form{refer}) && &is_frozen($::form{refer})) {
		$admineditable = 1;
		$bodyclass = "frozen";
	} elsif($::form{refer} eq '' && &is_editable($page) || &is_exist_page($::form{refer}) && &is_editable($::form{refer})) {

		$admineditable = 1;
		$editable = 1;
		if(!&is_exist_page($page) && $is_page) {
			$page=$pagename=$::FrontPage;
			if($::form{mypreview_cancel} ne '') {
				if(&is_exist_page($::form{refer}) && $::form{refer} ne '') {
					$page=$pagename=$::form{refer};
				}
			}
			$body=&text_to_html($::database{$pagename});
			$is_page=1;
			$admineditable=1;
			$editable=&is_frozen($pagename) ? 1 : 0;
		}
	}
	&makenavigator($::form{mypage} ne $page ? $::form{mypage} : $page,$is_page,$editable,$admineditable);


	if ($::last_modified != 0) {
		$lastmod = &date($::lastmod_format, (stat($::data_dir . "/" . &dbmname($::form{mypage}) . ".txt"))[9]);
	}


	$::IN_HEAD=&meta_robots($::form{cmd},$pagename,$body) . $::IN_HEAD;
	$::HTTP_HEADER=&http_header("Content-type: text/html; charset=$::charset", $::HTTP_HEADER);
	require $::skin_file;
	my $body=&skin($pagename, $body, $is_page, $bodyclass, $editable, $admineditable, $::basehref,$lastmod);
	$body=&_db($body);

	if($::lang eq 'ja' && $::defaultcode ne $::kanjicode) {
		$body=&code_convert(\$body,   $::kanjicode);
	}
	&content_output($::HTTP_HEADER, $body);
}


sub topicpath {
	my ($title)=@_;
	$title=$::form{mypage} if($title eq '');
	my $buf;
	if($::useTopicPath eq 1 && &exist_plugin("topicpath") ne 0) {
		$buf=&plugin_topicpath_inline("1,$title") if(&is_exist_page($title));
	}
	if($buf eq '') {
		my $cookedurl=$::basehref . '?' . &encode($title);
		return qq(<a href="$cookedurl">$cookedurl</a>);
	}
	return $buf;
}


sub makenavigator {
	my($pagename,$is_page,$editable,$admineditable)=@_;

	my($page,$message,$errmessage)=split(/\t/,$pagename);	
	my $cookedpage = &encode($page);


	my $refer=&encode($::form{refer} eq '' ? $::form{mypage} : $::form{refer});
	my $mypage=&encode($::form{refer} eq '' ? $page : $::form{refer});

	&makenavigator_sub1("newpage","refer",$mypage);
	if($::form{refer} eq '' || &is_exist_page($::form{refer})) {
		&makenavigator_sub1("edit","mypage",$mypage)
			if($editable);
		if($admineditable) {
			&makenavigator_sub1("adminedit","mypage",$mypage);
			&makenavigator_sub1("diff","mypage",$mypage);
			&makenavigator_sub1("attach","mypage",$mypage) if($::file_uploads > 0);
			&makenavigator_sub1("rename","refer",$mypage);
		}
	}
	&makenavigator_sub1("sitemap","refer",$refer)
		if($::use_Sitemap eq 1 && -f "$::plugin_dir/sitemap.inc.pl");
	&makenavigator_sub1("list","refer",$refer);
	&makenavigator_sub1("search","refer",$refer);
	&makenavigator_sub1("recent","refer",$refer);

	&makenavigator_sub2("top",$::FrontPage);
	&makenavigator_sub2("reload",$::form{refer} eq '' ? $page : $::form{refer});
	if($::use_HelpPlugin eq 0) {
		&makenavigator_sub2("help",$::resource{help});
	} else {
		$::resource{helpbutton}=$::resource{help};
		&makenavigator_sub1("help","refer",$refer);
	}
	&makenavigator_sub3("rss10");
	&makenavigator_sub3("rss20");
	&makenavigator_sub3("atom");
	&makenavigator_sub3("opml");


	my @naviindex;
	if($::naviindex eq 0) {
		@naviindex=(
			"reload","","newpage","edit","adminedit","diff","backup","attach","copy","rename","",
			"top","list","sitemap","search","recent","help",
			"rss10","rss20","atom","opml");
	} else {
		@naviindex=(
			"top","","edit","adminedit","diff","backup","attach","copy","rename","reload","",
			"newpage","list","sitemap","search","recent","help",
			"rss10","rss20","atom","opml");
	}


	foreach(@naviindex) {
		foreach my $addnavi(@::addnavi) {
			my($index,$before,$next)=split(/:/,$addnavi);
			push(@::navi,$index) if($_ eq $before && $before ne '');
		}
		push(@::navi,$_) if($::navi{"$_\_url"} ne '' || $_ eq '');
		foreach my $addnavi(@::addnavi) {
			my($index,$before,$next)=split(/:/,$addnavi);
			push(@::navi,$index) if($_ eq $next && $next ne '');
		}
	}
}

sub makenavigator_sub1 {
	my($t,$r,$p)=@_;
	if($t ne '') {
		if($::navi{$t."_url"} eq '') {
			$::navi{$t."_title"}=$::resource{$t."thispage"};
			$::navi{$t."_title"}=$::resource{$t."button"}
				if($::navi{$t."_title"} eq '');
			$::navi{$t."_url"}="$::script?cmd=$t&amp;$r=$p";
			$::navi{$t."_name"}=$::resource{$t."button"}
				if($t!~/rename/);
			$::navi{$t."_type"}="edit";
		}
	}
}

sub makenavigator_sub2 {
	my($t,$p)=@_;
	if(    $t eq "top"
		|| $t eq "help" && &is_exist_page($p)
		|| &is_exist_page($p) && (&is_exist_page($::form{refer}) || $::form{refer} eq '')) {
		if($::navi{$t."_url"} eq '') {
			$::navi{$t."_url"}=&make_cookedurl(&encode(@{[
				&is_exist_page($p) ? $p : 
				&is_exist_page($::form{refer}) ? $::form{refer} : 
				$::FrontPage]}));
			$::navi{$t."_name"}=$::resource{$t};
			$::navi{$t."_type"}="page";
		}
	}
}

sub makenavigator_sub3 {
	my($t)=@_;
	if(-f "$::plugin_dir/$t.inc.pl") {
		if($::navi{$t."_url"} eq '') {
			$::navi{"$t\_url"}="$::script?cmd=$t"
				. ($_exec_plugined{lang} > 1 ? "&amp;lang=$::lang" : "");
			$::navi{"$t\_title"}=$::resource{$t . "button"};
			if(open(R,"$::image_dir/$t.png")) {
				my $data;
				binmode(R);
				read(R, $data, 24);
				close(R);
				$::navi{"$t\_width"}  = unpack("N", substr($data, 16, 20));
				$::navi{"$t\_height"} = unpack("N", substr($data, 20, 24));
			}
			$::navi{$t."_type"}="rsslink";
		}
	}
}


sub meta_robots {
	my($cmd,$pagename,$body)=@_;
	my $robots;
	my $keyword;
	if($cmd=~/edit|admin|diff|attach/
		|| $::form{mypage} eq '' && $cmd!~/list|sitemap|recent/
		|| $::form{mypage}=~/SandBox|$::resource{help}|$::resource{rulepage}|$::MenuBar|$::non_list/
		|| &is_readable($::form{mypage}) eq 0) {
		$robots.=<<EOD;
<meta name="robots" content="NOINDEX,NOFOLLOW,NOARCHIVE" />
<meta name="googlebot" content="NOINDEX,NOFOLLOW,NOARCHIVE" />
EOD
	} else {
		$robots.=<<EOD;
<meta name="robots" content="INDEX,FOLLOW" />
<meta name="googlebot" content="INDEX,FOLLOW,ARCHIVE" />
<meta name="keywords" content="$::meta_keyword" />
EOD
	}
	return $robots;
}


sub convtime {
	if ($::enable_convtime != 0) {
		return sprintf("Powered by Perl $] HTML convert time to %.3f sec.",
			((times)[0] - $::_conv_start));
	}
}


sub content_output {
	my ($http_header,$body)=@_;
	print $http_header;
	$body=~s/\ \/>/>/g if(!$::is_xhtml);
	print $body;
	close(STDOUT);
}


sub _db {
	my($arg)=@_;
	return($arg);
}


sub http_header {
	my $http_header;
	my $nph_http_header;
	my $nph_http_header_first;

	foreach(@_) {
		$http_header.="$_\n";
	}
	$http_header=~s/\r//g;
	while($http_header=~/\n\n/) {
		$http_header=~s/\n\n/"\n"/ge;
	}
	$http_header=~s/\n$//g;
	$http_header.="\n";


	if($ENV{SCRIPT_NAME}=~/nph\-/) {
		my $cachecontrol=1;
		$ENV{SERVER_PROTOCOL}="HTTP/1.1" if($ENV{SERVER_PROTOCOL} eq '');
		$nph_http_header_first="$ENV{SERVER_PROTOCOL} 200 OK";
		foreach(split(/\n/,$http_header)) {
			if(/^Status/) {
				s/Status:\s*//g;
				$nph_http_header_first="$ENV{SERVER_PROTOCOL} $_";
				if($_ eq 401) {
					$nph_http_header_first=~s/\n//g;
					$nph_http_header_first.=" Authorization Required\n";
				}
			} elsif(/^Last-Modified|^Cache|^Expire/) {
				$cachecontrol=0;
				$nph_http_header.="$_\n";
			} else {
				$nph_http_header.="$_\n";
			}
		}
		$http_header=$nph_http_header_first . "\n" . $nph_http_header;
		if($cachecontrol eq 1) {

			$http_header.=sprintf(
				"Expires: %s GMT\n"
				, &date("D, j M Y G:i:S",0,"gmtime"));
			$http_header.=sprintf(
				"Date: %s GMT\n"
				, &date("D, j M Y G:i:S",0,"gmtime"));
		}
		$http_header=~s/\n\n/\n/g;
	}


	$http_header=~s/\x0D\x0A|\x0D|\x0A/\x0D\x0A/g;
	return "$http_header\x0D\x0A";
}


sub getbasehref {

	return if($::basehref ne '');
	$::basehost = "$ENV{'HTTP_HOST'}";


	if (($ENV{'https'} =~ /on/i) || ($ENV{'SERVER_PORT'} eq '443')) {
		$::basehost = 'https://' . $::basehost;

	} else {
		$::basehost = 'http://' . $::basehost;

		$::basehost .= ":$ENV{'SERVER_PORT'}"
			if ($ENV{'SERVER_PORT'} ne '80' && $::basehost !~ /:\d/);
	}


	my $uri;
	my $req=$ENV{REQUEST_URI};
	$req=~s/\?.*//g;
	if($req ne '') {
		if($req eq $ENV{SCRIPT_NAME}) {
			$uri= $ENV{'SCRIPT_NAME'};
		} else {
			for(my $i=0; $i<length($ENV{SCRIPT_NAME}); $i++) {
				if(substr($ENV{SCRIPT_NAME},$i,1) eq substr($req,$i,1)) {
					$uri.=substr($ENV{SCRIPT_NAME},$i,1);
				} else {
					last;
				}
			}
		}
	} else {
		$uri .= $ENV{'SCRIPT_NAME'};
	}
	$::basehref=$::basehost . $uri;
	$::basepath=$uri;
	$::basepath=~s/\/[^\/]*$//g;
	$::basepath="/" if($::basepath eq '');
	$::script=$uri if($::script eq '');
}


sub do_read {
	my($title)=@_;
	$title=$::form{mypage} if($title eq '');

	foreach(keys %::fixedpage) {
		if($::fixedpage{$_} ne '' && $_ eq $::form{mypage}) {
			my $refer=&encode($::form{mypage});
			$::form{refer}=$refer;
			$::form{cmd}=$::fixedpage{$_};
			$ENV{QUERY_STING}="cmd=$::form{cmd}$amp;refer=$refer";
			$::form{mypage}='';
			return 0 if(&exec_plugin eq 1);
		}
	}

	if(!&is_readable($::form{mypage})) {
		&print_error($::resource{auth_readfobidden});
	}

	&skinex($title, &text_to_html($::database{$::form{mypage}}, mypage=>$::form{mypage}), 1, @_);
	return 0;
}


sub do_write {
	my($FrozenWrite, $viewpage)=@_;
	if (not &is_editable($::form{mypage})) {
		&skinex($::form{mypage}, &message($::resource{cantchange}), 0);
		return 0;
	}


	foreach(split(/\n/,$::disablewords)) {
		s/\./\\\./g;
		s/\//\\\//g;
		if($::form{mymsg}=~/$_/) {
			&send_mail_to_admin($::form{mypage}, "Deny", $::form{mymsg});
			&skinex($::form{mypage}, &message($::resource{auth_writefobidden}), 0);
			return 0;
		}
	}


	if($FrozenWrite eq 'FrozenWrite') {
		if($::writefrozenplugin eq 1) {
			$::form{myfrozen} = &get_info($::form{mypage}, $info_IsFrozen);
		} elsif(&get_info($::form{mypage}, $info_IsFrozen)) {
			$::form{myfrozen}=1;
			if (&frozen_reject()) {
				$::form{cmd}=$::form{refercmd};
				$::form{mypreview} = "";
				&print_error($::resource{auth_writefobidden});
				return 1;
			}
		}
	} else {
		if (&frozen_reject()) {
			$::form{cmd}=$::form{refercmd};
			$::form{mypreview} = "";
			return 1;
		}
	}

	return 0 if (&conflict($::form{mypage}, $::form{mymsg}));


	if ($::form{mypart} =~ /^\d+$/o and $::form{mypart}) {
		$::form{mymsg} =~ s/\x0D\x0A|\x0D|\x0A/\n/og;
		$::form{mymsg} .= "\n" unless ($::form{mymsg} =~ /\n$/o);
		my @parts = &read_by_part($::form{mypage});
		$parts[$::form{mypart} - 1] = $::form{mymsg};
		$::form{mymsg} = join('', @parts);
	}


	$::form{mymsg} =~ s/\&date;/&date($::date_format)/gex;
	$::form{mymsg} =~ s/\&time;/&date($::time_format)/gex;
	$::form{mymsg} =~ s/\&new;/\&new\{@{[&get_now]}\};/gx
		if(-r "$plugin_dir/new.inc.pl");
	if($::usePukiWikiStyle eq 1) {
		$::form{mymsg} =~ s/\&now;/&date($::now_format)/gex;
		$::form{mymsg} =~ s/\&_(date|time|now);/\&$1\(\);/g;
		$::form{mymsg} =~ s/\&t;/\t/g;
		$::form{mymsg} =~ s/\&fpage;/$::form{mypage}/g;
		my $tmp=$::form{mypage};
		$tmp=~s/.*\///g;
		$::form{mymsg} =~ s/&page;/$tmp/g;
	}
	$::form{mymsg}=~s/\x0D\x0A|\x0D|\x0A/\n/g;


	if (1) {
		&open_diff;
		my @msg1 = split(/\n/, $::database{$::form{mypage}});
		my @msg2 = split(/\n/, $::form{mymsg});
		&load_module("Yuki::DiffText");
		$::diffbase{$::form{mypage}} = Yuki::DiffText::difftext(\@msg1, \@msg2);
		&close_diff;
	}


	if ($::form{mymsg}) {
		$::database{$::form{mypage}} = $::form{mymsg};
		&send_mail_to_admin($::form{mypage}, "Modify");
		&set_info($::form{mypage}, $::info_ConflictChecker, '' . localtime);
		&set_info($::form{mypage}, $::info_UpdateTime, time);
		if(&get_info($::form{mypage}, $::info_CreateTime)+0 eq 0) {
			&set_info($::form{mypage}, $::info_CreateTime, time);
		}
		if ($::form{mytouch}) {
			&set_info($::form{mypage}, $info_LastModified, '' . localtime);
			&set_info($::form{mypage}, $::info_LastModifiedTime, time);
			&update_recent_changes;
		}
		&set_info($::form{mypage}, $info_IsFrozen, 0 + $::form{myfrozen});
		if($::setting_cookie{savename}+0>0 && $::form{myname} ne '') {
			&plugin_setting_savename($::form{myname});
		}

		my $pushmypage=$::form{mypage};
		if($viewpage ne '') {
			$::form{mypage}=$viewpage
				if(&is_exist_page($viewpage));
		}

		if($::write_location eq 1) {
			print &http_header(
				"Status: 302",
				"Location: $::basehref?@{[&encode($::form{mypage})]}",
				$::HTTP_HEADER
				);
			close(STDOUT);
			exit;

		} else {
			&do_read();
		}
		$::form{mypage}=$pushmypage;

	} else {
		&send_mail_to_admin($::form{mypage}, "Delete");
		delete $::database{$::form{mypage}};
		delete $infobase{$::form{mypage}};
		&update_recent_changes if ($::form{mytouch});
		&skinex($::form{mypage}, &message($::resource{deleted}), 0);
	}
	return 0;
}



sub read_by_part {
	my ($page) = @_;
	return unless &is_exist_page($page);
	my @lines = map { $_."\n" }
			split(/\x0D\x0A|\x0D|\x0A/o, $::database{$page});
	my @parts = ('');
	foreach my $line (@lines) {
		if ($line =~ /^(\*{1,5})(.+)/) {
			push(@parts, $line);
		} else {
			$parts[$#parts] .= $line;
		}
	}
	return @parts;
}

sub print_error {
	my ($msg) = @_;
	&skinex("\t\t$ErrorPage", qq(<p><strong class="error">$msg</strong></p>), 0);
	close(STDOUT);
	exit(0);
}


sub print_content {
	my ($rawcontent,$nowpagename) = @_;
	$::form{basepage}=$nowpagename eq '' ? $::form{mypage} : $nowpagename;
	return &text_to_html($rawcontent);
}


sub text_to_html {

	my ($txt, %option) = @_;
	my (@txt) = split(/\r?\n/, $txt);
	my $verbatim;
	my $tocnum = 0;
	my (@saved, @result);
	my $prevline;
	my @col_style;
	unshift(@saved, "</p>");
	push(@result, "<p>");


	$::lfmode=$::line_break;


	my $editpart = "";
	if($::partedit > 0) {
		if ($option{mypage}) {
			my ($title, $edit, $button);
			if (&is_frozen($option{mypage})) {
				$title = "admineditthispart";
				$edit = "adminedit";
				$button = "admineditbutton";
			} else {
				$title = "editthispart";
				$edit = "edit";
				$button = "editbutton";
			}
			my $enc_mypage = &encode($option{mypage});
			$enc_mypage =~ s/%/%%/og;
			if($::partedit eq 2 || $edit eq 'edit') {
				$editpart = qq(<div class="partinfo"><a class="partedit" title="$::resource{$title}" href="$::script?cmd=$edit&amp;mypage=$enc_mypage&amp;mypart=%d">@{[$::toolbar eq 2 ? qq(<img src="$::image_url/partedit.png" height="16" width="16" alt="$::resource{$button}" />) : $::resource{$button}]}</a></div>);
			}
		}
	}
	my $backline;
	my $backcmd;
	my $nest;
	my $lines=$#txt;
	foreach (@txt) {
		$lines--;
		@col_style=() if(!/^(\,|\|)/);
		chomp;


		if($backline ne '') {
			$_=$backline . $_;
			$backline="";
		}

		if ($verbatim->{func}) {
			if (/^\Q$verbatim->{done}\E$/) {
				undef $verbatim;
				push(@result, splice(@saved));
			} else {
				push(@result, $verbatim->{func}->($_));
			}
			next;
		}

		push(@result, shift(@saved)) if (@saved and $saved[0] eq '</pre>' and /^[^ \t]/);
		my $escapedscheme=$_;

		if($escapedscheme=~/($isurl|mailto:$ismail)/) {
			my $url1=$1;
			my $url2=$url1;
			$url2=~s!:!\x08!g;
			$url2=~s!/!\x07!g;
			$escapedscheme=~s!\Q$url1!$url2!g;
		}


		if($::usePukiWikiStyle eq 1) {
			if(/^:(.*)[|:]+$/) {
				if($lines>0) {
					$backline=$_;
					next;
				}
			} elsif(/^(:|>{1,3}|-{1,3}|\+{1,3})(.+)~$/) {
				if($lines>0) {
					$backline="$1$2\x06";
					next;
				}
			}
		}


		if (/^(\*{1,5})(.+)/) {
			my $hn = "h" . (length($1) + 1);
			my $hedding = ($tocnum != 0)
				? qq(<div class="jumpmenu"><a href="@{[$::form{cmd} ne 'read' ? "?$ENV{QUERY_STRING}" : &make_cookedurl($::pushedpage eq '' ? $::form{mypage} : $::pushedpage)]}#navigator">&uarr;</a></div>\n)
				: '';
			push(@result, splice(@saved),
				$hedding . qq(<$hn id="@{[&pageanchorname($::form{mypage})]}$tocnum">) . &inline($2) . qq(</$hn>)
			);

			push(@result, sprintf($editpart, $tocnum + 2)) if($editpart);
			$tocnum++;

		} elsif (/^(-{2,3})\($/) {
			if ($& eq '--(') {
				$verbatim = { func => \&inline, done => '--)', class => 'verbatim-soft' };
			} else {
				$verbatim = { func => \&escape, done => '---)', class => 'verbatim-hard' };
			}
			&back_push('pre', 1, \@saved, \@result, " class='$verbatim->{class}'");
		} elsif (/^{{{/) {
			$verbatim = { func => \&inline, done => '}}}', class => 'verbatim-soft' };
			&back_push('pre', 1, \@saved, \@result, " class='$verbatim->{class}'");

		} elsif (/^----/) {
			push(@result, splice(@saved), '<hr />');

		} elsif (/^(-{1,3})(.+)/) {
			my $class = "";
			if ($::form{mypage} ne $::MenuBar) {
				$class = " class=\"list" . length($1) . "\" style=\"padding-left:16px;margin-left:16px;\"";
			}
			&back_push('ul', length($1), \@saved, \@result, $class);
			push(@result, '<li>' . &inline($2) . '</li>');
		} elsif (/^(\+{1,3})(.+)/) {
			my $class = "";
			if ($::form{mypage} ne $::MenuBar) {
				$class = " class=\"list" . length($1) . "\" style=\"padding-left:16px;margin-left:16px;\"";
			}
			&back_push('ol', length($1), \@saved, \@result, $class);
			push(@result, '<li>' . &inline($2) . '</li>');


		} elsif (/^(\+{1,3})(.+)/) {
			my $class = "";
			if ($::form{mypage} ne $::MenuBar) {
				$class = " class=\"list" . length($1) . "\" style=\"padding-left:16px;margin-left:16px;\"";
			}
			&back_push('ol', length($1), \@saved, \@result, $class);
			push(@result, '<li>' . &inline($2) . '</li>');


		} elsif (/^:/) {
			$escapedscheme=~/^(:{1,3})(.+)/;
			my $chunk=$2;
			my $class = "";
			if ($::form{mypage} ne $::MenuBar) {
				$class=qq( class="list) . length($1) . qq(");
			}

			$chunk=~s/\[\[([^:\]]+?):((?!\[)[^\]]+?)\]\]/[[$1\x08$2]]/g
				while($chunk=~/\[\[([^:\]]+?):((?!\[)[^\]]+?)\]\]/);
			if ($chunk=~/^([^\|]+):(.+)\|(.*)/) {
				&back_push('dl', 1, \@saved, \@result, $class);
				push(@result, '<dt>' . &inline($1) . '</dt>', '<dd>' . &inline("$2|$3") . '</dd>');
			} elsif ($chunk=~/^([^\|]+)\|(.*)/) {
				&back_push('dl', 1, \@saved, \@result, $class);
				push(@result, '<dt>' . &inline($1) . '</dt>', '<dd>' . &inline($2) . '</dd>');
			} elsif ($chunk=~/^([^:]+):(.+)/) {
				&back_push('dl', 1, \@saved, \@result, $class);
				push(@result, '<dt>' . &inline($1) . '</dt>', '<dd>' . &inline($2) . '</dd>');
			} else {
				&back_push('dl', 1, \@saved, \@result, $class);
				push(@result, '<dt>' . &inline($chunk) . '</dt>', '<dd></dd>');
			}

		} elsif (/^(>{1,5})(.+)/) {
			&back_push('blockquote', length($1), \@saved, \@result);
			push(@result, qq(<p class="quotation">))
				if($::usePukiWikiStyle eq 1);
			push(@result, &inline($2));
			push(@result, qq(</p>\n))
				if($::usePukiWikiStyle eq 1);

		} elsif (/^$/) {
			push(@result, splice(@saved));
			unshift(@saved, "</p>");
			push(@result, "<p>");


		} elsif (/^\s(.*)$/o) {
			&back_push('pre', 1, \@saved, \@result);
			push(@result, &htmlspecialchars($1)); # Not &inline, but &escape

		} elsif (/^([\,|\|])(.*?)[\x0D\x0A]*$/) {
			&back_push('table', 1, \@saved, \@result,
				' class="style_table" cellspacing="1" border="0"',
				'<div class="ie5">', '</div>');


			my $delm = "\\$1";
			my $tmp = ($1 eq ',') ? "$2$1" : "$2";
			my @value = map {/^"(.*)"$/ ? scalar($_ = $2, s/""/"/g, $_) : $_}
				($tmp =~ /("[^"]*(?:""[^"]*)*"|[^$delm]*)$delm/g);
			my @align = map {(s/^\s+//) ? ((s/\s+$//) ? ' align="center"' : ' align="right"') : ''} @value;
			my @colspan = map {$_ eq '==' ? 0 : 1} @value;
			my $pukicolspan=1;
			my $thflag='td';

			for (my $i = 0; $i < @value; $i++) {
				if ($colspan[$i]) {
					if($::usePukiWikiStyle eq 1) {

						if($value[$i]=~/^\~/) {
							$value[$i]=~s/^\~//g;
							$thflag='th';
						} elsif($value[$i] eq '~') {
							$value[$i]="";

						}

						if($value[$i] eq '>') {
							$value[$i]='';
							$pukicolspan++;
							next;
						}
					}
					while ($i + $colspan[$i] < @value and  $value[$i + $colspan[$i]] eq '==') {
						$colspan[$i]++;
					}
					$colspan[$i] = ($colspan[$i] > 1) ? sprintf(' colspan="%d"', $colspan[$i]) : '';
					if($pukicolspan > 1 && $::usePukiWikiStyle eq 1) {
						$colspan[$i] = sprintf(' colspan="%d"', $pukicolspan);
						$pukicolspan=1;
					}
					if($::usePukiWikiStyle eq 1) {
						$value[$i]=~ s!(LEFT|CENTER|RIGHT)\:!\ftext-align:$1;\t!g;
						$value[$i]=~ s!BGCOLOR\((.*?)\)\:(.*)!\fbackground-color:$1;\t$2!g;
						$value[$i]=~ s!COLOR\((.*?)\)\:(.*)!\fcolor:$1;\t$2!g;
						$value[$i]=~ s!SIZE\((.*?)\)\:(.*)!\ffont-size:$1px;\t$2!g;
						if($value[$i]=~/\f/) {
							$value_style[$i]=$value[$i];
							$value_style[$i]=~s!\t\f!!g;
							$value_style[$i]=~s!\t(.*)$!!g;
							$value_style[$i]=~s!\f!!g;
							$value[$i]=~s/\f(.*?)\t//g;
						}
						if($tmp=~/(\,|\|)c$/) {
							$col_style[$i]=$value_style[$i];
						} else {
							$value[$i] = sprintf('<%s%s%s class="style_%s" style="%s%s">%s</%s>', $thflag,$align[$i], $colspan[$i], $thflag,$col_style[$i],$value_style[$i],&inline($value[$i]),$thflag);
#%> for Hidemaru
							$value_style[$i]="";
						}
					} else {
						$value[$i] = sprintf('<td%s%s class="style_td">%s</td>', $align[$i], $colspan[$i], &inline($value[$i]));
					}
				} else {
					$value[$i] = '';
				}
			}
			if($::usePukiWikiStyle eq 0) {
				push(@result, join('', '<tr>', @value, '</tr>'));
			} elsif($tmp=~/(\,|\|)h$/) {
				push(@result, join('', '<thead><tr>',@value,'</tr></thead>'));
			} elsif($tmp=~/(\,|\|)f$/) {
				push(@result, join('', '<tfoot><tr>',@value,'</tr></tfoot>'));
			} elsif($tmp!~/(\,|\|)c$/) {
				push(@result, join('', '<tr>', @value, '</tr>'));
			}



		} elsif (/^====/) {
			if ($::form{show} ne 'all') {
				push(@result, splice(@saved), "<a href=\"$::script?cmd=read&amp;mypage="
					. &encode($::form{mypage}) . "&show=all\">$::resource{continue_msg}</a>");
				last;
			}

		} elsif (/^\&\*lfmode\((\d+)\);$/o) {
			$::lfmode = $1;
			$_="";
			next;

		} elsif (/^$embedded_name$/o) {
			s/^$embedded_name$/&embedded_to_html($1)/gexo;
			&back_push('div', 1, \@saved, \@result);
			push(@result,$_);
		} else {

			push(@result, &inline($_, ("lfmode" => $::lfmode)));
		}
	}
	push(@result, splice(@saved));

	if ($editpart && $::partfirstblock eq 1) {
		unshift(@result, sprintf($editpart, 1));
	}
	return join("\n",@result);
}


sub pageanchorname {
	my ($page)=@_;
	return 'm' if($page eq $::MenuBar && $::MenuBar ne '');
	return 'r' if($page eq $::RightBar && $::RightBar ne '');
	return 'h' if($page eq $::Header && $::Header ne '');
	return 'f' if($page eq $::Footer && $::Footer ne '');
	return 'i';
}


sub back_push {
	my ($tag, $level, $savedref, $resultref, $attr, $before_open, $after_close,$after_open,$before_close) = @_;
	while (@$savedref > $level) {
		push(@$resultref, shift(@$savedref));
	}
	if ($savedref->[0] ne "$before_close</$tag>$after_close") {
		push(@$resultref, splice(@$savedref));
	}
	while (@$savedref < $level) {
		unshift(@$savedref, "$before_close</$tag>$after_close");
		push(@$resultref, "$before_open<$tag$attr>$after_open");
	}
}


$::_inline_attr="";

sub inline {

	my ($line, %option) = @_;
	$line =~ tr|\x08|:|;
	$line =~ tr|\x07|/|;
	$line =~ s|^//.*||g;
	$line = &htmlspecialchars($line);


	$line =~ s|'''(.+?)'''|<em>$1</em>|g;
	$line =~ s|''(.+?)''|<strong>$1</strong>|g;
	$line =~ s|%%%(.+?)%%%|<ins>$1</ins>|g;
	$line =~ s|%%(.+?)%%|<del>$1</del>|g;
	$line =~ s|\^\^(.+?)\^\^|<sup>$1</sup>|g;
	$line =~ s|__(.+?)__|<sub>$1</sub>|g;


	$line =~ s|(\d\d\d\d-\d\d-\d\d \(\w\w\w\) \d\d:\d\d:\d\d)|<span class="date">$1</span>|g;

	if($::usePukiWikiStyle eq 1) {
		if($line=~/~$/) {
			if($line=~/^(LEFT|CENTER|RIGHT|RED|BLUE|GREEN):/) {
				$::_inline_attr=$1;
				$line=~s/^$::_inline_attr://g;
			}
		} else {
			$::_inline_attr="";
		}
		if($::_inline_attr ne '') {
			$line="$::_inline_attr:$line";
		}
	}

	if ($option{"lfmode"}) {
		if ($line !~ /^$embedded_name$/o) {
			if (!($line =~ s/\\$//o)) {
				$line .= "<br />";
			}
		}
	} else {
		$line =~ s|~$|<br />|o;
		$line =~ s|\x06|<br />|g;
	}

	$line =~ s!^(LEFT|CENTER|RIGHT):(.*)$!<div style="text-align:$1">$2</div>!g;
	$line =~ s!^(RED|BLUE|GREEN):(.*)$!<font color="$1">$2</font>!g;# Tnx hash.

	if($::usePukiWikiStyle eq 1) {
		$line =~ s!BGCOLOR\((.*?)\)\s*\{\s*(.*)\s*\}!<span style="background-color:$1">$2</span>!g;
		$line =~ s!COLOR\((.*?)\)\s*\{\s*(.*)\}!<span style="color:$1">$2</span>!g;
		$line =~ s!SIZE\((.*?)\)\s*\{\s*(.*)\s*\}!<span style="font-size:$1px">$2</span>!g;
	}

	$line =~ s!&version;!$::version!g;
	$line =~ s!($::inline_regex)!&make_link($1)!geo;
	$line =~ s!($embedded_inline)!&embedded_inline($1)!geo
		if($::usePukiWikiStyle eq 1);

	$line =~ s|\(\((.*)\)\)|&note($1)|gex;
	$line =~ s|\(\((.*)\)\)||gex;

	$line =~ s|\[\#(.*)\]|<a class="anchor_super" id="$1" href="#$1" title="$1">$::_symbol_anchor</a>|g;

	if ($::usefacemark == 1) {
		$line=~s!($::_facemark)!<img src="$::image_url/face/$::_facemark{$1}.png" alt="$1" />!go;
	}
	return $line;
}


sub note {
	my ($msg) = @_;
	push(@::notes, $msg);

	return "<a @{[$::is_xhtml ? 'id' : 'name']}=\"notetext_" . @::notes . "\" "
		. "href=\"" . &make_cookedurl(&encode($::form{mypage})) . "#notefoot_" . @::notes . "\" class=\"note_super\">*"
		. @::notes . "</a>";
}


sub make_link {
	my $chunk = shift;
	my $orgchunk=$chunk;



	if ($chunk =~ /^$embedded_inline/o) {
		if($::usePukiWikiStyle eq 1) {
			return &embedded_inline($chunk,2);
		} else {
			return &embedded_inline($chunk);
		}
	}
	my $escapedchunk=&unarmor_name($chunk);
	$chunk=&unescape($escapedchunk);

	if ($chunk =~ /^$::isurl$/o) {
		my $tmp=&make_link_urlhref($chunk);
		if ($use_autoimg and $chunk =~ /\.$::image_extention$/o) {
			return &make_link_url("url",$tmp,$tmp,$tmp);
		} else {
			return &make_link_url("url",$tmp,$tmp);
		}
	}

	if ($chunk!~/>/ && $chunk =~ /^$interwiki_name2$/o && $chunk!~/$isurl|$ismail/o) {
		my $chunk1=&make_link_interwiki($1,$2,$3,$escapedchunk);
		return $chunk1 if($chunk1 ne '');

	} elsif ($chunk!~/>/ && $chunk =~ /^$interwiki_name1$/o && $chunk!~/$isurl|$ismail/o) {
		$escapedchunk=&make_link_interwiki($1,$2,$escapedchunk);
		return $chunk1 if($chunk1 ne '');
	}
 	if($chunk!~/>/ && $chunk=~/$ismail/o) {

	 	if($chunk=~/([Mm][Aa][Ii][Ll][Tt][Oo]):$::ismail/o) {
			$chunk=~s/[Mm][Aa][Ii][Ll][Tt][Oo]://g;
			return &make_link_mail($chunk,$escapedchunk);
		}

	 	if($chunk=~/^$::ismail$/o) {
			return &make_link_mail($chunk,$escapedchunk);
		}
	}

	if($chunk=~/^([^>]+)>(.+)$/) {
		$escapedchunk=$1;
		my $chunk2=$2;

		if ($use_autoimg && $escapedchunk=~/$isurl/o && $escapedchunk =~ /\.$::image_extention$/o) {
			$escapedchunk=&make_link_image($escapedchunk);
		} else {
			$escapedchunk=&htmlspecialchars($escapedchunk);
		}


		if($chunk2=~/$isurl/o) {
			return &make_link_url("link",$chunk2,$escapedchunk);

		} elsif($chunk2=~/$ismail/o) {
		 	if($chunk2=~/([Mm][Aa][Ii][Ll][Tt][Oo]):$ismail/o) {
				$chunk2=~s/[Mm][Aa][Ii][Ll][Tt][Oo]://g;
			}
			return &make_link_mail($chunk2,$escapedchunk);

		} elsif($chunk2=~/^$interwiki_name2$/o) {
			my $chunk1=&make_link_interwiki($1,$2,$3,$escapedchunk);
			return $chunk1 if($escapedchunk ne '');

		} elsif($chunk2=~/^$interwiki_name1$/o) {
			my $chunk1=&make_link_interwiki($1,$2,$escapedchunk);
			return $chunk1 if($escapedchunk ne '');
		} elsif($chunk=~/^$isurl/o) {
			if ($use_autoimg and $escapedchunk =~ /\.$::image_extention$/o) {
				return &make_link_url("image",$chunk,$chunk,$escapedchunk);
			} else {
				return &make_link_url("url",$chunk,$chunk);
			}
		}
	}

	if($chunk=~/^(.+?):(.+)$/ && $chunk!~/^file/) {
		$escapedchunk=$1;
		my $chunk2=$2;

		if ($use_autoimg && $escapedchunk=~/$isurl/o && $escapedchunk =~ /\.$::image_extention$/o) {
			$escapedchunk=&make_link_image($escapedchunk);
		} else {
			$escapedchunk=&htmlspecialchars($escapedchunk);
		}

		if($chunk2=~/$ismail/o) {
		 	if($chunk2=~/([Mm][Aa][Ii][Ll][Tt][Oo]):$ismail/o) {
				$chunk2=~s/[Mm][Aa][Ii][Ll][Tt][Oo]://g;
			}
			return &make_link_mail($chunk2,$escapedchunk);

		} elsif($chunk2=~/$isurl/o) {
			return &make_link_url("link",$chunk2,$escapedchunk);

		} elsif($chunk2=~/^$interwiki_name2$/o) {
			my $chunk1=&make_link_interwiki($1,$2,$3,$escapedchunk);
			return $chunk1 if($escapedchunk ne '');

		} elsif($chunk2=~/^$interwiki_name1$/o) {
			my $chunk1=&make_link_interwiki($1,$2,$escapedchunk);
			return $chunk1 if($escapedchunk ne '');
		} elsif($chunk=~/^$isurl/o) {
			if ($use_autoimg and $escapedchunk =~ /\.$::image_extention$/o) {
				return &make_link_url("image",$chunk,$chunk,$escapedchunk);
			} else {
				return &make_link_url("url",$chunk,$chunk);
			}
		}
	}


	if($chunk=~/^(.+?)>(.+?)$/) {
		$chunk=$2;
		$escapedchunk = &htmlspecialchars($1);
	} elsif($chunk=~/^(.+?):(.+?)$/) {
		$chunk=$2;
		$escapedchunk = &htmlspecialchars($1);
	}


	return &make_link_wikipage(get_fullname($chunk, $::form{mypage}),$escapedchunk);
}


sub make_link_wikipage {
	my($chunk1,$escapedchunk)=@_;
	my($chunk,$anchor)=$chunk1=~/^([^#]+)#?(.*)/;
	my $cookedchunk  = &encode($chunk);
	my $cookedurl=&make_cookedurl($cookedchunk);

	if (&is_exist_page($chunk)) {
		if($anchor eq '') {
			return qq(<a title="$chunk" href="$cookedurl">$escapedchunk</a>);
		} else {
			return qq(<a title="$chunk" href="$cookedurl#$anchor">$escapedchunk</a>);
		}
	} elsif (&is_editable($chunk)) {

		if ($::editchar eq 'this') {
			return qq(<a title="$::resource{editthispage}" class="editlink" href="$::script?cmd=edit&amp;mypage=$cookedchunk">$escapedchunk</a>);
		} elsif ($::editchar) {

			return qq($escapedchunk<a title="$::resource{editthispage}" class="editlink" href="$::script?cmd=edit&amp;mypage=$cookedchunk">$::editchar</a>);
		}
	}
	return $escapedchunk;
}


sub make_link_interwiki {
	my ($intername, $keyword, $anchor,$escapedchunk) = @_;
	if($escapedchunk eq '') {
		$escapedchunk=$anchor;
		$anchor="";
	}
	$intername=~tr/A-Z/a-z/;
	if(exists $::interwiki2{$intername}) {
		my ($code, $url) = %{$::interwiki2{$intername}};
		if($url=~/\$1/) {
			$url =~ s/\$1/&interwiki_convert($code, $keyword)/e;
		} else {
			$url.=&interwiki_convert($code, $keyword);
		}
		$url = &htmlspecialchars($url.$anchor);
		return &make_link_url("interwiki",$url,$escapedchunk);
	} else {
		my $remoteurl = $::interwiki{$intername};
		if ($remoteurl) {
			$remoteurl =~
			 s/\b(utf8|euc|sjis|ykwk|asis)\(\$1\)/&interwiki_convert($1, $localname)/e;
			return &make_link_url("interwiki",$remoteurl,$escapedcchunk);
		}
	}
}


sub make_cookedurl {
	my($cookedchunk)=@_;
	return "$::script" . "?" . "$cookedchunk";
}


sub make_link_mail {
	my($chunk,$escapedchunk)=@_;

	my $adr=$chunk;
	$adr=~s/^[Mm][Aa][Ii][Ll][Tt][Oo]://g;
	return qq(<a href="mailto:$adr" class="mail">$escapedchunk</a>);
}


sub make_link_url {
	my($class,$chunk,$escapedchunk,$img,$target)=@_;
	my $chunk2=&make_link_urlhref($chunk);
	$target="_blank" if($target eq '');
	if($img ne '') {
		$class.=($class eq '' ? 'img' : '');
		return &make_link_target($chunk2,$class,$target,"")
			. &make_link_image($img,$escapedchunk) . qq(</a>);
	}
	if($escapedchunk=~/^<img/) {
		return &make_link_target($chunk2,$class,$target,$chunk2)
			. qq($escapedchunk</a>);
	}
	return &make_link_target($chunk2,$class,$target,$escapedchunk)
			. qq($escapedchunk</a>);
}



sub make_link_target {
	my($url,$class,$target,$escapedchunk,$flag)=@_;
	$flag=$::use_popup if($flag eq '');
	$class=&htmlspecialchars($class);
	$target=&htmlspecialchars($target);
	my $popup_allow=$::setting_cookie{popup} ne '' ? $::setting_cookie{popup}
					: $flag+0 ? 1 : 0;
	my $target=$popup_allow != 0 ? $target : '';
	$target='' if($flag eq 2 && $url=~/ttp\:\/\/$ENV{HTTP_HOST}/);
	if($target ne '' && $flag eq 3) {
		my $tmp=$::basehref;
		$tmp=~s/\/.*//g;
		$target='' if($url=~/\Q$tmp/);
	}
	if($target eq '') {
		return qq(<a href="$url"@{[$class eq '' ? '' : qq(class="$class")]} title="$escapedchunk">);
	} elsif($::is_xhtml) {
		return qq(<a href="$url" @{[$class eq '' ? '' : qq(class="$class")]} title="$escapedchunk" onclick="return openURI('$url','$target');" onkeypress="return openURI('$url','$target');">);
	} else {
		return qq(<a href="$url" @{[$class eq '' ? '' : qq(class="$class")]} target="$target" title="$escapedchunk">);
	}
}


sub make_link_urlhref {
	my($url)=@_;
	return &htmlspecialchars(
		&unescape(
			&unescape($url)
		)
	);
}


sub make_link_image {
	my($img,$alt)=@_;
	$img=&htmlspecialchars($img);
	$alt=$img if($alt eq '');
	return qq(<img src="@{[&make_link_urlhref($img)]}" alt="$alt" />);
}


sub get_fullname {
	my ($name, $refer) = @_;

	return $refer if ($name eq '');
	if ($name eq '/') {
		$name = substr($name,1);
		return ($name eq '') ? $::FrontPage : $name;
	}
	return $refer if ($name eq './');
	if (substr($name,0,2) eq './') {
		return ($1) ? $refer . '/' . $1 : $refer;
	}
	if (substr($name,0,3) eq '../') {
		my @arrn = split('/', $name);
		my @arrp = split('/', $refer);

		while (@arrn > 0 and $arrn[0] eq '..') {
			shift(@arrn);
			pop(@arrp);
		}
		$name = @arrp ? join('/',(@arrp,@arrn)) :
			(@arrn ? "$::FrontPage/".join('/',@arrn) : $::FrontPage);
	}
	return $name;
}


sub message {
	my ($msg) = @_;
	return qq(<p><strong>$msg</strong></p>);
}


sub init_form {
	if ($qCGI->param()) {
		foreach my $var ($qCGI->param()) {
			$::form{$var} = $qCGI->param($var);
		}
	} else {
		$ENV{QUERY_STRING} = $::FrontPage;
	}


	my $query = $ENV{QUERY_STRING};
	if ($query =~ /&/) {
		my @querys = split(/&/, $query);
		foreach (@querys) {
			$_ = &decode($_);
			$::form{$1} = $2 if (/([^=]*)=(.*)$/);
		}
	} else {
		$query = &decode($query);
	}

	if ($query =~ /^($wiki_name)$/) {
		$::form{cmd} = 'read';
		$::form{mypage} = $1;
	} elsif (&is_exist_page($query)) {
		$::form{cmd} = 'read';
		$::form{mypage} = $query;
	}




	foreach (keys %::form) {
		if (/^mypreview_(.*)$/) {
			$::form{cmd} = $1;
			$::form{mypreview} = 1;
		}
	}

	$::form{mymsg} = &code_convert(\$::form{mymsg},   $::defaultcode,$::kanjicode);
	$::form{myname} = &code_convert(\$::form{myname}, $::defaultcode,$::kanjicode);
	$::form{mypage} = &code_convert(\$::form{mypage}, $::defaultcode);
	$::form{page} = &code_convert(\$::form{page}, $::defaultcode);
	$::form{refer} = &code_convert(\$::form{refer}, $::defaultcode);
}


sub getcookie {
	my($cookieID,%buf)=@_;
	my @pairs;
	my $pair;
	my $cname;
	my $value;
	my %DUMMY;

	@pairs = split(/;/,&decode($ENV{'HTTP_COOKIE'}));
	foreach $pair (@pairs) {
		($cname,$value) = split(/=/,$pair,2);
		$cname =~ s/ //g;
		$DUMMY{$cname} = $value;
	}
	@pairs = split(/,/,$DUMMY{$cookieID});
	foreach $pair (@pairs) {
		($cname,$value) = split(/:/,$pair,2);
		$buf{$cname} = $value;
	}
	return %buf;
}


sub setcookie {
	my($cookieID,$expire,%buf)=@_;
	my $date;
	my $data;
	if($expire+0 > 0) {
		$date=&date("D, j-M-Y H:i:s",time+&gettz*3600+$::cookie_expire);
	} elsif($expire+0 < 0) {
		$date=&date("D, j-M-Y H:i:s",1);
	}
	$buf{cookietime}=time;
	while(($name,$value)=each(%buf)) {
		$data.="$name:$value," if($name ne '');
	}
	$data=~s/,$//g;
	$data=&encode($data);
	$::HTTP_HEADER.=qq(Set-Cookie: $cookieID=$data;);
	$::HTTP_HEADER.=qq( path=$::basepath;);
	$::HTTP_HEADER.=" expires=$date GMT" if($expire ne 0);
	$::HTTP_HEADER.="\n";
}



sub update_recent_changes {
	my $update = "- @{[&get_now]} @{[&armor_name($::form{mypage})]} @{[&get_subjectline($::form{mypage})]}";
	my @oldupdates = split(/\r?\n/, $::database{$::RecentChanges});
	my @updates;
	foreach (@oldupdates) {
		/^\- \d\d\d\d\-\d\d\-\d\d \(...\) \d\d:\d\d:\d\d (.*?)\ \ \-/;
		my $name = &unarmor_name($1);
		if (&is_exist_page($name) and ($name ne $::form{mypage})) {
			push(@updates, $_);
		}
	}
	unshift(@updates, $update) if (&is_exist_page($::form{mypage}));
	splice(@updates, $::maxrecent + 1);
	$::database{$::RecentChanges} = join("\n", @updates);
}


sub get_subjectline {
	my ($page, $lines,%option) = @_;
	$lines=1 if($lines+0 < 1);
	my $line;
	if (not &is_editable($page)) {
		return "";
	}

	my $delim = $subject_delimiter;
	$delim = $option{delimiter} if (defined($option{delimiter}));

	my $subject = $::database{$page};
	my $i=1;
	foreach (split(/\n/,$subject)) {
		s/\(\((.*)\)\)//gex;
		my $tmp=&text_to_html($_);
		$tmp=~s/[\xd\xa]//g;
		$tmp=~s/<.*?>//g;
		$tmp=&trim($tmp);
		next if($tmp eq '');
		$line.=$i eq 1 ? $tmp : "\n$tmp";
		last if($line ne '' && $i++ >= $lines);
	}
	if($lines > 1) {
		return $line;
	}
	$line =~ s/\r?\n.*//s;
	return "$delim$line";
}


sub send_mail_to_admin {
	my($page, $mode, $data)=@_;
	&load_module("Nana::Mail");
	Nana::Mail::toadmin($mode, $page, $data);
}


sub open_db {
	&dbopen($::data_dir,\%::database);
	&dbopen($::info_dir,\%::infobase);
}


sub dbopen {
	my($dir,$db)=@_;
	if ($modifier_dbtype eq 'dbmopen') {
		dbmopen(%$db, $dir, 0666) or &print_error("(dbmopen) $dir");
	} elsif($modifier_dbtype eq 'AnyDBM_File') {
		tie(%$db, "AnyDBM_File", $dir, O_RDWR|O_CREAT, 0666) or &print_error("(tie AnyDBM_File) $dir");
	} else {
		tie(%$db, "$modifier_dbtype", $dir) or &print_error("(tie $modifier_dbtype) $dir");
	}
	return %db;
}


sub close_db {
	&dbclose(\%::database);
	&dbclose(\%infobase);
}


sub dbclose {
	my($db)=@_;
	if ($modifier_dbtype eq 'dbmopen') {
		dbmclose(%$db);
	} else {
		untie(%$db);
	}
}


sub open_diff {
	&dbopen($::diff_dir,\%::diffbase);
}


sub close_diff {
	&dbclose(\%::diffbase);
}


sub is_readable {
	my($page)=@_;
	return 0 if($page eq $::RecentChanges);
	return 1;
}


sub is_editable {
	my ($page) = @_;
	return 0 if($fixedpage{$page} || $fixedplugin{$::form{cmd}});
	return 0 if(
		$page=~/([\xa\xd\f\t\[\]])|(\.{1,3}\/)|^\s|\s$|^\#|^\/|\/$|^$|^$interwiki_name1$|^$::ismail$/o);
	return 0 if (not &is_readable($page));
	return 1;
}


sub armor_name {
	my ($name) = @_;
	return ($name =~ /^$wiki_name$/o) ? $name : "[[$name]]";
}


sub unarmor_name {
	my ($name) = @_;
	return ($name =~ /^$bracket_name$/o) ? $1 : $name;
}


sub is_bracket_name {
	my ($name) = @_;
	return ($name =~ /^$bracket_name$/o) ? 1 : 0;
}


sub dbmname {
	my ($name) = @_;
	$name =~ s/(.)/$::_dbmname_encode{$1}/g;
	return $name;
}


sub undbmname {
	my ($name) = @_;
	$name =~ s/([0-9A-F][0-9A-F])/$::_dbmname_decode{$1}/g;
	return $name;
}


sub decode {
	my ($s) = @_;
	$s =~ tr/+/ /;
	$s =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/chr(hex($1))/eg;
	return $s;
}


sub encode {
	my ($encoded) = @_;
	$encoded =~ s/(\W)/$::_urlescape{$1}/g;
	return $encoded;
}


sub read_resource {
	my ($file,%buf) = @_;
	return %buf if $::_resource_loaded{$file}++;
	open(FILE, $file) or &print_error("(resource:$file)");
	while (<FILE>) {
		s/[\r\n]//g;
		next if /^#/;
		s/\\n/\n/g;
		my ($key, $value) = split(/=/, $_, 2);
		$buf{$key}=$value;
		$buf{$key}=$::resource_patch{$key} if(defined($::resource_patch{$key}));
	}
	close(FILE);
	return %buf;
}


sub conflict {
	my ($page, $rawmsg) = @_;
	if ($::form{myConflictChecker} eq &get_info($page, $::info_ConflictChecker)) {
		return 0;
	}
	open(FILE, "$::res_dir/conflict.$::lang.txt") or &print_error("(conflict)");

	my $content;
	foreach(<FILE>) {
		$content.=$_ if(! /^#/);
	}
	close(FILE);

	my $body = &text_to_html($content);
	if (&exist_plugin('edit') == 1) {
		$body .= &plugin_edit_editform($rawmsg, $::form{myConflictChecker}, frozen=>0, conflict=>1);
	}

	&skinex($page, $body, 0);
	return 1;
}


sub get_now {
	my (@week) = qw(Sun Mon Tue Wed Thu Fri Sat);
	my ($sec, $min, $hour, $day, $mon, $year, $weekday) = localtime(time);
	$weekday = $week[$weekday];
	return sprintf("%d-%02d-%02d ($weekday) %02d:%02d:%02d",
		$year + 1900, $mon + 1, $day, $hour, $min, $sec);
}


sub init_InterWikiName {
	my $content = $::database{$InterWikiName};
	while ($content =~ /$interwiki_definition/g) {
		my ($name, $url) = ($1, $2);

		$name=~tr/A-Z/a-z/;
		$::interwiki{$name} = $url;
	}
	while ($content =~ /$interwiki_definition2/g) {

		my ($url,$name,$code)=($1,$2,$3);
		$name=~tr/A-Z/a-z/;
		$::interwiki2{$name}{$code} = $url;
	}
}


sub interwiki_convert {
	my ($type, $localname) = @_;
	if ($type eq 'sjis' or $type eq 'euc' or $type eq 'utf8') {
		$localname=&code_convert(\$localname, $type)
			if($localname=~/[\xa1-\xfe]/);
		return &encode($localname);
	} elsif (($type eq 'ykwk') || ($type eq 'yw')) {

		if ($localname =~ /^$wiki_name$/) {
			return $localname;
		} else {
			$localname=&code_convert(\$localname, 'sjis')
				if($localname=~/[\xa1-\xfe]/);
			return &encode("[[" . $localname . "]]");
		}
	} else {
		return $localname;
	}
}


sub get_info {
	my ($page, $key) = @_;
	my %info = map { split(/=/, $_, 2) } split(/\n/, $infobase{$page});
	return $info{$key};
}


sub set_info {
	my ($page, $key, $value) = @_;
	my %info = map { split(/=/, $_, 2) } split(/\n/, $infobase{$page});
	$info{$key} = $value;
	my $s = '';
	for (keys %info) {
		$s .= "$_=$info{$_}\n";
	}
	$infobase{$page} = $s;
}


sub frozen_reject {
	my ($isfrozen) = &get_info($::form{mypage}, $info_IsFrozen);
	my ($willbefrozen) = $::form{myfrozen};
	my %auth;
	if (not $isfrozen and not $willbefrozen) {

		return 0;
	} else {
		%auth=&authadminpassword(form,"","frozen");
		return ($auth{authed} eq 0 ? 1 : 0);
	}
	return 0;
}


sub is_frozen {
	my ($page) = @_;
	if($::newpage_auth eq 1) {
		return 1 if(!&is_exist_page($page));
	}
	return (&get_info($page, $info_IsFrozen)) ? 1 : 0;
}


sub exist_plugin {
	my ($plugin) = @_;

	if (!$_plugined{$plugin}) {
		my $path = "$::plugin_dir/$plugin" . '.inc.pl';
		if (-e $path) {
			require $path;
			$::debug.=$@;
			$_plugined{$1} = 1;

			$path="$::res_dir/$plugin.$::lang.txt";
			%::resource = &read_resource($path,%::resource) if(-r $path);
			return 1;
		} else {
			$path = "$::plugin_dir/$plugin" . '.pl';
			if (-e $path) {
				require $path;
				$::debug.=$@;
				$_plugined{$1} = 2;
				return 2;
			}
		}
		return 0;
	}
	return $_plugined{$plugin};
}


sub exist_explugin {
	my ($explugin) = @_;

	if (!$_exec_plugined{$explugin}) {
		my $path = "$::explugin_dir/$explugin" . '.inc.cgi';
		if (-e $path) {
			require $path;
			$::debug.=$@;
			$_exec_plugined{$1} = 1;
			$path="$::res_dir/$explugin.$::lang.txt";
			%::resource = &read_resource($path,%::resource) if(-r $path);
			return 1;
		}
		return 0;
	}
	return $_exex_plugined{$explugin};
}


sub embedded_to_html {
	my $embedded = shift;

	if ($embedded =~ /$embed_plugin/) {
		my $exist = &exist_plugin($1);
		my $action = '';
		if ($exist == 1) {
			$action = "\&plugin_" . $1 . "_convert('$3')";
		} elsif ($exist == 2) {
			$action = "\&$1::plugin_block('$3');";
		}
		if ($action ne '') {
			$_ = eval $action;
			$::debug.=$@;
			return ($_) ? $_ : &htmlspecialchars($embedded);
		}
	}
	return $embedded;
}


sub embedded_inline {
	my ($embedded,$opt)=@_;
	my($cmd,$arg);
	if($embedded=~/$::embedded_inline/g) {
		if($1 ne '') {
			$cmd=$1;
			$arg=$2;
		} elsif($3 ne '') {
			$cmd=$3;
		} elsif($4 ne '') {
			$cmd=$4;
			$arg=$5;
		} elsif($6 ne '') {
			$cmd=$6;
			$arg="$7,$8";
		}
		my $exist = &exist_plugin($cmd);
		my $action = '';
		if ($exist == 1) {
			$action = "\&plugin_" . $cmd . "_inline('$arg')";
		} elsif ($exist == 2) {
			$action = "\&" . $cmd . "::plugin_inline('$arg');";
		}
		if ($action ne '') {
			$_ = eval $action;
			$::debug.=$@;
			return $_ if ($_);
		}
	}
	return $embedded if($opt eq 2);
	return &unescape($embedded);
}


sub load_module{
	my $mod = shift;
	return $mod if $::_module_loaded{$mod}++;
	eval qq( require $mod; );
	$mod=undef if($@);
	return $mod;
}


sub code_convert {
	my ($contentref, $kanjicode, $icode) = @_;
	if($$contentref ne '') {
		if ($::lang eq 'ja') {
			if($::code_method{ja} eq 'jcode.pl') {
				require "jcode.pl";
				if($kanjicode=~/utf/ || $icode=~/utf/) {
					return $$contentref;
				}
				&jcode::convert($contentref, $kanjicode);
			} else {
				&load_module("Jcode");
				&Jcode::convert($contentref, $kanjicode, $icode);
			}
		}
	}
	return $$contentref;
}


sub is_exist_page {
	my ($name) = @_;
	foreach(keys %::fixedpage) {
		if($::fixedpage{$_} ne '' && $_ eq $name) {
			return 1;
		}
	}
	return ($use_exists) ? exists($::database{$name}) : $::database{$name};
}


sub trim {
	my ($s) = @_;
	$s =~ s/^\s*(\S+)\s*$/$1/o; # trim
	return $s;
}


sub escape {
	return &htmlspecialchars(shift);
}


sub unescape {
	my $s=shift;
	$s=~s/\&(amp|lt|gt|quot);/$::_unescape{$1}/g;
	return $s;
}


sub htmlspecialchars {
	my($s)=@_;
	$s=~s/([<>"&])/$::_htmlspecial{$1}/g;
	return $s;
}


sub javascriptspecialchars {
	my($s)=@_;
	$s=&htmlspecialchars($s);
	$s=~s|'|&apos;|g;
	return $s;
}




sub valid_password {
	my ($givenpassword,$type) = @_;
	my($pass,$salt);
	if($::adminpass{$type} eq '') {
		($pass,$salt)=split(/ /,$::adminpass);
		$salt="AA" if($salt eq '');
		return (crypt($givenpassword, $salt) eq $pass) ? 1 : 0;
	}
	($pass,$salt)=split(/ /,$::adminpass{$type});
	$salt="AA" if($salt eq '');
	return 1 if(crypt($givenpassword, $salt) eq $pass);

	($pass,$salt)=split(/ /,$::adminpass);
	$salt="AA" if($salt eq '');
	return (crypt($givenpassword, $salt) eq $pass) ? 1 : 0;
#
}


sub passwordform {
	my($default,$mode,$formname)=@_;
	$formname="mypassword" if($formname eq '');
	if($default eq '') {
		return qq(<input type="password" name="$formname" size="10" />);
	} elsif($mode eq 'hidden') {
		return qq(<input type="hidden" name="$formname" value="$default" />);
	} else {
		return qq(<input type="password" name="$formname" value="$default" size="10" />);
	}
}


sub authadminpassword {
	my($mode,$title,$type)=@_;
	my $body;

	$type=($type eq "attach" ? "attach" : $type eq "frozen" ? "frozen" : "admin");
	if($mode=~/submit|page|form/) {
		$title=$::resource{admin_passwd_prompt_title} if($title eq '');
		if(!&valid_password($::form{mypassword},$type)) {
			$body=<<EOM;
<h2>$title</h2>
@{[$ENV{REQUEST_METHOD} eq 'GET' && $::form{mypassword} eq '' ? '' : qq(<div class="error">$::resource{admin_passwd_prompt_error}</div>\n)]}
<form action="$::script" method="post" id="adminpasswordform" name="adminpasswordform">
$::resource{admin_passwd_prompt_msg}<input type="password" name="mypassword" size="10">
<input type="submit" value="$::resource{admin_passwd_button}" />
EOM
			foreach my $forms(keys %::form) {
				$body.=qq(<input type="hidden" name="$forms" value="$::form{$forms}" />\n);
			}
			$body.="</form>\n";
			return('authed'=>0,'html'=>$body);
		} else {
			$body.=qq(<input type="hidden" name="mypassword" value="$::form{mypassword}" />\n);
			return('authed'=>1,'html'=>$body);
		}
	} else {
		if(!&valid_password($::form{mypassword},$type)) {
			$body.=<<EOM;
@{[$ENV{REQUEST_METHOD} eq 'GET' && $::form{mypassword} eq '' ? '' : qq(<div class="error">$::resource{admin_passwd_prompt_error}</div>)]}
EOM
			$body.=qq(@{[$title ne '' ? $title : $::resource{admin_passwd_prompt_msg}]}<input type="password" name="mypassword" value="$::form{mypassword}" size="10" />\n);
			return('authed'=>0,'html'=>$body);
		} else {
			$body.=qq(<input type="hidden" name="mypassword" value="$::form{mypassword}" />\n);
			return('authed'=>1,'html'=>$body);
		}
	}
}


my $_tz='';
sub gettz {
	if($_tz eq '') {
		$_tz=(localtime(time))[2]+(localtime(time))[3]*24+(localtime(time))[4]*24
			+(localtime(time))[5]*24-(gmtime(time))[2]-(gmtime(time))[3]*24
			-(gmtime(time))[4]*24-(gmtime(time))[5]*24;
	}
	return $_tz;
}


sub getwday {
	my($year, $mon, $mday) = @_;

	if ($mon == 1 or $mon == 2) {
		$year--;
		$mon += 12;
	}
	return int($year + int($year / 4) - int($year / 100) + int($year / 400)
		+ int((13 * $mon + 8) / 5) + $mday) % 7;
}


sub lastday {
	my($year,$mon)=@_;
	return  (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$mon - 1]
		+ ($mon == 2 and $year % 4 == 0 and
		($year % 400 == 0 or $year % 100 != 0));
}


sub fopen {
	my ($fname, $fmode) = @_;
	my $_fname;
	my $fp;


	if ($fname =~ /^http:\/\//) {
		$fname =~ m!(http:)?(//)?([^:/]*)?(:([0-9]+)?)?(/.*)?!;
		my $host = ($3 ne "") ? $3 : "localhost";
		my $port = ($5 ne "") ? $5 : 80;
		my $path = ($6 ne "") ? $6 : "/";
		if ($::proxy_host) {
			$host = $::proxy_host;
			$port = $::proxy_port;
			$path = $fname;
		}
		my ($sockaddr, $ip);
		$fp = new FileHandle;
		if ($host =~ /^(\d+).(\d+).(\d+).(\d+)$/) {
			$ip = pack('C4', split(/\./, $host));
		} else {


			$ip = inet_aton($host) || return 0;
		}
		$sockaddr = pack_sockaddr_in($port, $ip) || return 0; # Can't Create Socket address.
		socket($fp, PF_INET, SOCK_STREAM, 0) || return 0;
		connect($fp, $sockaddr) || return 0;
		autoflush $fp(1);
		print $fp "GET $path HTTP/1.1\r\nHost: $host\r\n\r\n";
		return $fp;
	} else {
		$fmode = lc($fmode);

		if ($fmode eq 'w') {
			$_fname = ">$fname";
		} elsif ($fmode eq 'w+') {
			$_fname = "+>$fname";
		} elsif ($fmode eq 'a') {
			$_fname = ">>$fname";
		} elsif ($fmode eq 'r') {
			$_fname = $fname;
		} else {
			return 0;
		}
		if (open($fp, $_fname)) {
			return $fp;
		}
	}
	return 0;
}


sub dateinit {
	my $i=0;
	foreach(split(/,/,$::resource{"date_ampm_en"})) {
		$::_date_ampm[$i++]=$_;
	}
	$i=0;
	foreach(split(/,/,$::resource{"date_ampm_".$::lang})) {
		$::_date_ampm_locale[$i++]=$_;
	}
	$i=0;
	foreach(split(/,/,$::resource{"date_weekday_en"})) {
		$::_date_weekday[$i++]=$_;
	}
	$i=0;
	foreach(split(/,/,$::resource{"date_weekday_".$::lang})) {
		$::_date_weekday_locale[$i++]=$_;
	}
	$::_date_weekdaylength=$::resource{"date_weekdaylength_en"};
	$::_date_weekdaylength_locale=$::resource{"date_weekdaylength_".$::lang};
}


sub date {
	my ($format, $tm, $gmtime) = @_;
	my %weekday;
	my %ampm;


	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = 
		$gmtime ne '' && @_ > 2
			? ($tm+0 > 0 ? gmtime($tm) : gmtime(time))
			: ($tm+0 > 0 ? localtime($tm) : localtime(time));

	$year += 1900;
	my $hr12=$hour=>12 ? $hour-12:$hour;


	$ampm{en}=$::_date_ampm[$hour>11 ? 1 : 0];
	$ampm{$::lang}=$::_date_ampm_locale[$hour>11 ? 1 : 0];


	$weekday{en}=$::_date_weekday[$wday];
	$weekday{en}{length}=$::_date_weekdaylength;
	$weekday{$::lang}=$::_date_weekday_locale[$wday];
	$weekday{$::lang}{length}=$::_date_weekdaylength_locale;


	if($format=~/r/) {
		return &date("D, j M Y H:i:s O",$tm,$gmtime);
	}

	if($format=~/[OZB]/) {
		my $gmt=&gettz;
		$format =~ s/O/sprintf("%+03d:00", $gmt)/ge;
		$format =~ s/Z/sprintf("%d", $gmt*3600)/ge;
		my $swatch=(($tm-$gmt+90000)/86400*1000)%1000;

		$format =~ s/B/sprintf("%03d", int($swatch))/ge;# internet time
	}


	$format=~s/U/sprintf("%u",$tm)/ge;

	$format=~s/lL/\x2\x13/g;
	$format=~s/DL/\x2\x14/g;
	$format=~s/D/\x2\x12/g;
	$format=~s/aL/\x1\x13/g;
	$format=~s/AL/\x1\x14/g;
	$format=~s/l/\x2\x11/g;
	$format=~s/a/\x1\x11/g;
	$format=~s/A/\x1\x12/g;
	$format=~s/M/\x3\x11/g;
	$format=~s/F/\x3\x12/g;


	if($format=~/[Lt]/) {
		my $uru=($year % 4 == 0 and ($year % 400 == 0 or $year % 100 != 0)) ? 1 : 0;
		$format=~s/L/$uru/ge;
		$format=~s/t/(31, $uru ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[$mon]/ge;
	}


	$format =~ s/Y/$year/ge;
	$year = $year % 100;
	$year = "0" . $year if ($year < 10);
	$format =~ s/y/$year/ge;


	my $month = ('January','February','March','April','May','June','July','August','September','October','November','December')[$mon];
	$mon++;
	$format =~ s/n/$mon/ge;
	$mon = "0" . $mon if ($mon < 10);
	$format =~ s/m/$mon/ge;


	$format =~ s/j/$mday/ge;
	$mday = "0" . $mday if ($mday < 10);
	$format =~ s/d/$mday/ge;


	$format =~ s/g/$hr12/ge;
	$format =~ s/G/$hour/ge;
	$hr12 = "0" . $hr12 if ($hr12 < 10);
	$hour = "0" . $hour if ($hour < 10);
	$format =~ s/h/$hr12/ge;
	$format =~ s/H/$hour/ge;


	$format =~ s/k/$min/ge;
	$min = "0" . $min if ($min < 10);
	$format =~ s/i/$min/ge;


	$format =~ s/S/$sec/ge;
	$sec = "0" . $sec if ($sec < 10);
	$format =~ s/s/$sec/ge;

	$format =~ s/w/$wday/ge;


	$format =~ s/I/$isdst/ge;

	$format =~ s/\x1\x11/$ampm{en}/ge;
	$format =~ s/\x1\x12/uc $ampm{en}/ge;
	$format =~ s/\x1\x13/$ampm{$::lang}/ge;
	$format =~ s/\x1\x14/uc $ampm{$::lang}/ge;

	$format =~ s/\x2\x11/$weekday{en}/ge;
	$format =~ s/\x2\x12/substr($weekday{en},0,$weekday{en}{length})/ge;
	$format =~ s/\x2\x13/substr($weekday{$::lang},0,$weekday{$::lang}{length})/ge;
	$format =~ s/\x2\x14/$weekday{$::lang}/ge;

	$format =~ s/\x3\x11/substr($month,0,3)/ge;
	$format =~ s/\x3\x12/$month/ge;

	$format =~ s/z/$yday/ge;
	return $format;


}

1;
__END__

######################################################################
# opml.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: opml.inc.pl,v 1.46 2007/07/15 07:40:09 papu Exp $
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
use Nana::Cache;
use Nana::OPML;

$opml::pages_title="News"
	if(!defined($opml::pages_title));
$opml::related_title="Related site"
	if(!defined($opml::related_title));

sub plugin_opml_action {
	if($::_exec_plugined{lang} > 1) {
		$::modifier_rss_title=$::modifier_rss_title{$::lang} if($::modifier_rss_title{$::lang} ne '');
		$::modifier_rss_link=$::modifier_rss_link{$::lang} ne '' ? $::modifier_rss_link{$::lang}: $::modifier_rss_link ne '' ? $::modifier_rss_link : $::basehref;
		$::modifier_rss_description=$::modifier_rss_description{$::lang} if($::modifier_rss_description{$::lang} ne '');
	} else {
		$::modifier_rss_link=$::modifier_rss_link ne '' ? $::modifier_rss_link : $::basehref;
	}


	my $cache=new Nana::Cache (
		ext=>"showrss",
		files=>1000,
		dir=>$::cache_dir,
		size=>200000,
		use=>1,
		expire=>365*86400,
	);

	my $opml = new Nana::OPML(
		version => '1.0',
		encoding => $::charset,
	);
	$opml->channel(
		title => $::modifier_rss_title
				. ($::_exec_plugined{lang} > 1 ? "(" . (split(/,/,$::langlist{$::lang}))[0] . ")" : ""),
 		link  => $::modifier_rss_link,
		description => $::modifier_rss_description,
	);

	$opml->add_item(
		title => $::modifier_rss_title
				. ($::_exec_plugined{lang} > 1 ? "($::langlist{$::lang})" : ""),
		link  => $::modifier_rss_link,
		xmlurl => "$::basehref?cmd=rss10"
				. ($::_exec_plugined{lang} > 1 ? "&amp;lang=$::lang" : ""),
		type => "rss",
	);

	opendir(DIR,$::cache_dir) || die "$::cache_dir not found";
	my $flg=0;
	while(my $dir=readdir(DIR)) {
		if($dir=~/\.showrss$/  && $dir!~/^687474703A2F2F/) {
			$dir=~s/\.showrss//g;
			my $file=$dir;
			my $rssurl=$dir;
			$rssurl=~s/([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			$rssurl=$::modifier_rss_link . "?cmd=rss10page&amp;lang=$::lang&amp;mypage=" . $rssurl;
			my $buf=$cache->read($file,1);
			my %xml = &xmlParser($buf);
			my $title=$xml{'rdf:RDF/channel/title'};
			$title=$xml{'rss/channel/title'} if($title eq '');
			my $link=$xml{'rdf:RDF/channel/link'};
			$link=$xml{'rss/channel/link'} if($link eq '');
			if($flg eq 0) {
				$opml->add_item(
					title => $opml::pages_title,
				);
				$flg=1;
			}
			next if($title eq '');
			$opml->add_item(
				title => $title,
				link  => $link,
				xmlurl => $rssurl,
				type => "rss",
			);
		}
	}
	close(DIR);
	opendir(DIR,$::cache_dir) || die "$::cache_dir not found";
	my $flg=0;
	while(my $dir=readdir(DIR)) {
		if($dir=~/\.showrss$/ && $dir=~/^687474703A2F2F/) {
			$dir=~s/\.showrss//g;
			my $file=$dir;
			my $rssurl=$dir;
			$rssurl=~s/([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			my $buf=$cache->read($file,1);
			my %xml = &xmlParser($buf);
			my $title=$xml{'rdf:RDF/channel/title'};
			$title=$xml{'rss/channel/title'} if($title eq '');
			my $link=$xml{'rdf:RDF/channel/link'};
			$link=$xml{'rss/channel/link'} if($link eq '');
			if($flg eq 0) {
				$opml->add_item(
					title => $opml::related_title,
				);
				$flg=1;
			}
			next if($title eq '');
			$opml->add_item(
				title => $title,
				link  => $link,
				xmlurl => $rssurl,
				type => "rss",
			);
		}
	}
	close(DIR);

	my $body=$opml->as_string;
	if($::lang eq 'ja' && $::defaultcode ne $::kanjicode) {
		$body=&code_convert(\$body,   $::kanjicode);
	}
	print &http_header("Content-type: text/xml");
	print $body;
	&close_db;
	exit;
}

sub xmlParser {
	my ($stream) = @_;
	my ($i, $ch, $name, @node, $val, $key, %xml);
	my $flg = 0;
	foreach $i (0..length $stream) {
		$ch = substr($stream, $i, 1);
		if ($ch eq '<') {
			$flg = 1;
			undef $name;
			foreach (@node) {
				$name .= "$_/";
			}
			chop $name;
			$val =~ s/<//g;
			$val =~ s/>//g;
			$xml{$name} .= "$val\n";
			undef $val;
		}
		if ($flg) {
			$key .= $ch;
		} else {
			$val .= $ch;
		}
		if ($ch eq '>') {
			$flg = 0;
			if ($key =~ /\//) {
				pop @node;
			} else {
				$key =~ s/<//g;
				$key =~ s/>//g;
				push @node, $key;
			}
			undef $key;
		}
	}
	return %xml;
}
1;
__END__


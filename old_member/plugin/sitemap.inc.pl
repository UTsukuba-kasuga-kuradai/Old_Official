######################################################################
# sitemap.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: sitemap.inc.pl,v 1.59 2007/07/15 07:40:09 papu Exp $
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
# サイトマッププラグインでは「明示的」にユーザーをナビゲーション
# しやすくするプラグインです。
#
# 記述には、以下のようなルールがあります。
#
# MenuBarでは以下のように記述する
# ***項目名
# [[WikiName]]
# [[ページ]]
# (WikiNameだけでは動きません)
#
# MenuBarに登録されたページでは、以下のように記述する
# -[[WikiName]] (WikiNameだけでは動きません)
# -[[ページ]]~
# --[[ページ]]~
# ---[[ページ]]~
# -[[?cmd=プラグイン&.....]]~
#
# p.s. [[リンク>http://www.yahoo.co.jp/]] 等外部リンクははじきます。
#
# 使い方
# ?cmd=sitemap
# http://lineage.netgamers.jp/?cmd=sitemap
#
# 詳しくはwikiのソースみてください。
# http://lineage.netgamers.jp/?cmd=adminedit&mypage=MenuBar
# http://lineage.netgamers.jp/?cmd=adminedit&mypage=%bd%d0%b2%d4%a4%ae%a5%ea%a5%b9%a5%c8
# http://lineage.netgamers.jp/?cmd=edit&mypage=%bd%d0%b2%d4%a4%aeFPK%b9%b6%ce%ac
######################################################################

sub plugin_sitemap_convert {
	$::form{title}='no';
	$::form{level}=2;
	$::form{subject}=1;
	my %sitemap=&plugin_sitemap_action;
	return $sitemap{body};
}

sub plugin_sitemap_action {
	my $prev = '';
	my $char = '';
	my $idx = 1;
	my $menubar=$::MenuBar;
	my $name;
	my $menucount=0;
	my $submenu=0;
	my $basepage;
	my $nextpage;
	my $body="<h2>@{[$::wiki_title eq '' ? $::resource{sitemap_plugin_title} : $::wiki_title]}</h2>\n"
		if($::form{title} ne 'no');
	$::form{level}=5 if($::form{level}+0 eq 0);

	foreach $basepage(split(/\n/,$::database{$menubar})) {

		if ($basepage=~/^(\*{1,5})(.+)/) {
			$name=$basepage;
			$name=~s/^(\*{1,5})//g;
			$name=&plugin_sitemap_trim($name);
			$menucount++;
			push(@sitemap,$name);

		}elsif($basepage=~/$::bracket_name/ && $basepage!~/>(http:|https:|ftp:|mailto:|\?)/
			&& $basepage!~/($::interwiki_name1|$::interwiki_name2)/) {
			$basepage=~s/$::bracket_name/$1/g;
			$basepage=~s/.*>//g if($basepage=~/>/);
			$basepage=&plugin_sitemap_trim($basepage);
			if(&is_readable($basepage)) {
				$submenu++;
				$sitemap{$name}.=sprintf("%05d\t%05d\t%05d\t%05d\t%s\n",$menucount,$submenu,0,0,$basepage);

				$sitemap{$name}.=&submenu($basepage,$menucount,$submenu,0,1);
			}
		}
	}
	my $nest;
	my $nestorg;
	@viewed=();
	foreach my $menu(@sitemap) {
		if($sitemap{$menu} ne '') {
			if($menu=~/$bracket_name/) {
				$body.="<ul><li><strong>@{[&make_link($menu)]}</strong></li><ul>";
			} else {
				$body.="<ul><li><strong>$menu</strong></li><ul>";
			}
			$nestorg=0;
			foreach(split(/\n/,$sitemap{$menu})) {
				chomp;
				($menucount,$submenu,$nextmenu,$nest,$page)=split(/\t/,$_);
				if($nestorg<$nest) {
					for(my $i=$nestorg; $i<$nest; $i++) {
						$body.="<ul>";
					}
				}
				if($nestorg>$nest) {
					for(my $i=$nest; $i<$nestorg; $i++) {
						$body.="</ul>";
					}
				}
				my $view=0;
				foreach(@viewed) {
					$view=1 if($page eq $_);
				}
				if($view eq 0) {
					if(&is_readable($page) && &is_exist_page($page)) {
						push(@viewed,$page);
						$body.="<li>" . &make_link_wikipage($page,$page);
						if($::form{subject}+0 eq 1) {
							$body.="<br>";
							$body.=&plugin_sitemap_trim(&get_subjectline($page),60);
						}
						$body.="</li>";
					}
				}
				$nestorg=$nest;
			}
			$body.="</ul>";
		}
		for(my $i=$nestorg; $i>=0; $i--) {
			$body.="</ul>";
		}
	}
	return ('msg' => "\t$::resource{sitemap_plugin_title}", 'body' => $body);
}

sub submenu {
	my($pagename,$menucount,$submenu,$nextmenu,$nest)=@_;
	my $ret="";
	my $nextpage;
	return if($nest>=$::form{level}+0);
	foreach my $line(split(/\n/,$::database{$pagename})) {
		if($line=~/-{1,3}$::bracket_name/ && $line!~/>(http:|https:|ftp:|mailto:|\?)/
			&& $line!~/($::interwiki_name1|$::interwiki_name2)/
			|| $line=~/>\?cmd=.*/ && $line =~ /^-\[\[(.*?)\]\]/) {
			$nextpage=$line;
			$nextpage=~s/-{1,3}$::bracket_name/$1/g;
			$nextpage=&plugin_sitemap_trim($nextpage);
			$nextpage=~s/.*>//g if($nextpage=~/>/ && $nextpage !~/\?cmd=/);
			$nextmenu++;
			$ret.=sprintf("%05d\t%05d\t%05d\t%05d\t%s\n",$menucount,$submenu,$nextmenu,$nest,$nextpage);
			$ret.=&submenu($nextpage,$menucount,$submenu,$nextmenu+1,$nest+1);

		} elsif($line=~/^#include\((.*?)\)/ && $::form{include} eq '') {
			$ret.=&submenu((split(/,/,$1))[0],$menucount+1,$submenu,$nextmenu+1,$nest)

		}elsif(($line=~/^#ls2\((.*?)\)/ || $line=~/^#ls2/) && $::form{ls2} eq '') {
			my @ls2args = split(/,/, $1);
			my $ls2prefix;
			my $ls2reverse=0;
			if (@ls2args > 0) {
				$ls2prefix = shift(@ls2args);
				foreach my $ls2arg (@ls2args) {
					if (lc $ls2arg eq "reverse") {
						$ls2reverse = 1;
					}
				}
			}
			$ls2prefix = $pagename . "/" if ($ls2prefix eq '');
			@ls2pages=();
			foreach my $ls2page (sort keys %::database) {
				push(@ls2pages, $ls2page) if ($ls2page =~ /^$ls2prefix/ && &is_readable($ls2page));
			}
			@ls2pages = reverse(@ls2pages) if ($ls2reverse);
			foreach(@ls2pages) {
				$nextpage=$_;
				$nextmenu++;
				$ret.=sprintf("%05d\t%05d\t%05d\t%05d\t%s\n",$menucount,$submenu,$nextmenu,$nest,$nextpage);
				$ret.=&submenu($nextpage,$menucount+1,$submenu,$nextmenu+1,$nest+1)
			}
		}
	}
	return $ret;
}

sub plugin_sitemap_trim {
	my($str,$strlen)=@_;

	$Zspace = '(?:\xA1\xA1)'; # 全角スペース
	$eucpre = qr{(?<!\x8F)};

	if($strlen+0 > 0) {
		my $len=length($str);
		$str=substr($str,0,$strlen);
		if ($str =~ /\x8F$/ or $str =~ tr/\x8E\xA1-\xFE// % 2) {
			$str=substr($str,0,length($str)-1);
		}
		$str.="..." if($len ne length($str));
	}


	$str =~ s/^(?:\s|$Zspace)+//o; # $str が EUC-JP の場合
	$str =~ s/$eucpre(?:\s|$Zspace)+$//o; # $str が EUC-JP の場合(perl5.005以降)
	$str=~s/\~//g;
	$str=~s/[\r|\n]//g;
	return $str;
}
1;
__END__

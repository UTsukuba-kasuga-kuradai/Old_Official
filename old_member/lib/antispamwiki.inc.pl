######################################################################
# antispamwiki.inc.cgi - This is PyukiWiki, yet another Wiki clone.
# $Id: antispamwiki.inc.pl,v 1.15 2007/07/15 07:40:08 papu Exp $
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
# To use this plugin, rename to 'antispamwiki.inc.cgi'
######################################################################
#
# Wiki���ѥߥ��ɻ�
#
# JavaScript��cookie���Ѥ����ʰ�Ū�ʥ��ѥߥ��ɻߤǤ���
# ������������cookie�˵�Ͽ���ޤ���
# �ʲ��ξ��Ƕ���Ū��FrontPage�����Ф��ޤ�
# ������������狼��ͭ�����¤�ۤ�����
# ��$::form{mymsg} ��¸�ߤ��롢�ޤ��� POST�᥽�åɻ���
#   ͭ�����¤�ۤ������ޤ���cookie������ξ��
#
# �Ȥ�����
#   ��antispamwiki.inc.pl��antispamwiki.inc.cgi�˥�͡��ह������ǻȤ��ޤ�
#
######################################################################

# ͭ�����¡ʣ����֡�
$AntiSpamWiki::expire=1*60*60
	if(!defined($AntiSpamWiki::expire));

%::antispamwiki_cookie;
$::antispamwiki_cookie="PyukiWikiAntiSpamWiki_"
				. length($::basepath);

# Initlize

sub plugin_antispamwiki_init {
	my $stat=0;
	%::antispamwiki_cookie=();
	%::antispamwiki_cookie=&getcookie($::antispamwiki_cookie,%::antispamwiki_cookie);
	my $time=time;
	if($::antispamwiki_cookie{time} eq '') {
		$stat=1;
	} elsif($::antispamwiki_cookie{time}+0+$AntiSpamWiki::expire < $time) {
		$stat=-1;
	}
	if($stat+0 ne 0) {
		if($::form{mymsg} ne '' || $ENV{REQUEST_METHOD}=~/[Pp][Oo][Ss][Tt]/) {
			$::form{cmd}="read";
			$::form{mypage}=$::FrontPage;
		}
	}
	my $js=qq(<script type="text/javascript">@{[!$::is_xhtml ? "<!--\n" : '']}document.cookie="$::antispamwiki_cookie=time%3a$time; path=$::basepath";@{[!$::is_xhtml ? '//-->' : '']}</script>\n);
	return('init'=>1, 'header'=>$js);
}
1;
__DATA__
sub plugin_antispamwiki_setup {
	return(
	'ja'=>'Wiki���ѥߥ��ɻ�',
	'en'=>'Anti Spam for WikiPlugin',
	'override'=>'',
	'url'=>'http://pyukiwiki.sourceforge.jp/PyukiWiki/Plugin/ExPlugin/antispamwiki/'
	);
}
__END__


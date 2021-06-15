######################################################################
# pyukiwiki.ini.cgi - This is PyukiWiki, yet another Wiki clone.
# $Id: pyukiwiki.ini.cgi,v 1.134 2007/07/15 07:40:09 papu Exp $
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

use strict;

# ����
$::lang = "ja";				# ja:���ܸ�/en:�Ѹ�(����)
$::kanjicode = "euc";		# euc:EUC-JP/sjis:ShiftJIS/utf8:UTF-8
#$::charset = "utf-8";		# UTF8��ư������硢�������ͭ����

# ���쥳�����Ѵ�
$::code_method{ja}="Jcode";	# ja : Jcode / Unicode::Japanese(testing) / jcode.pl(nonsupport utf8)
#$::code_method{ja}="Unicode::Japanese";
#$::code_method{ja}="jcode.pl";

# �ǡ�����Ǽ�ǥ��쥯�ȥ�
$::data_home = '.';		# CGI����Τߥ�����������ǡ����Υǥ��쥯�ȥ�
$::data_pub = '.';		# �֥饦�����鸫���ǡ����Υǥ��쥯�ȥ�
$::data_url = '.';		# �֥饦����������С����Хǥ��쥯�ȥ�
$::bin_home = '.';		# �̾���ѹ����ʤ��ǲ�����

# cgi-bin���̤Υǥ��쥯�ȥ����
# for sourceforge.jp
# /home/groups/p/py/pyukiwiki/htdocs
# /home/groups/p/py/pyukiwiki/cgi-bin
#$::data_home = '.';
#$::data_pub = '../htdocs';
#$::data_url = '..';

# Windows NT Server (IIS+ActivePerl)�ξ�����
#$::data_home = 'C:/inetpub/cgi-bin/pyuki/';
#$::data_pub = 'C:/inetpub/cgi-bin/pyuki/';
#$::data_url = '.';

$::data_dir    = "$::data_home/wiki";		# �ڡ����ǡ�����¸��
$::diff_dir    = "$::data_home/diff";		# ��ʬ��¸��
$::cache_dir   = "$::data_pub/cache";		# �����
$::cache_url   = "$::data_url/cache";		# �����
$::upload_dir  = "$::data_pub/attach";		# ź����
$::upload_url  = "$::data_url/attach";		# ź����URL
$::counter_dir = "$::data_home/counter";	# ��������
$::plugin_dir  = "$::data_home/plugin";		# �ץ饰������
$::explugin_dir= "$::bin_home/lib";			# �ץ饰������
$::skin_dir    = "$::data_pub/skin";		# ��������
$::skin_url    = "$::data_url/skin";		# ��������URL
$::image_dir   = "$::data_pub/image";		# ������
$::image_url   = "$::data_url/image";		# ������URL
$::info_dir    = "$::data_home/info";		# ������
$::res_dir     = "$::data_home/resource";	# �꥽����

# ������̾��
$::skin_name   = "pyukiwiki";
$::use_blosxom=0;	# blosxom.css����Ѥ���Ȥ����ˤ���

# ưŪ���åȥ��åץե����� (0.1.6�Ǥϥѥ�����ѹ��Τ߻���)
# pyukiwiki.ini.cgi���ѹ���ʬ�Τߤ�setup.ini.cgi�˵��ܤ��뤳�Ȥǡ�
# ����Υ��åץǡ��Ȥ��ưפˤʤ�ޤ���
$::setup_file	= "$::info_dir/setup.ini.cgi" if($::setup_file eq '');

# �ץ�������
#$::proxy_host = '';
#$::proxy_port = 3128;

# wiki�������Ծ��� (���ѿ��θ���̾��Ϣ������ˤ���ȡ������̤ˤǤ��ޤ���
$::wiki_title = '';										# ������̾�ʤʤ��Ƥ�ġ�
#$::wiki_title{en}='';									# �Ѹ���Υ����ȥ�(sample)
$::modifier = 'anonymous';								# ������̾
$::modifierlink = '';									# ������URI
$::modifier_mail = '';									# �����ԥ᡼�륢�ɥ쥹
$::meta_keyword="$::wiki_title";						# �����������

# 1:�����ȥ�οƳ��ؤ��ά����, 0:��ά���ʤ�
$::short_title=0;

# ��
$::logo_url="$::image_url/pyukiwiki.png";				# URL
$::logo_width=80;										# ����
$::logo_height=80;										# �⤵
$::logo_alt="[PyukiWiki]";								# ��������ʸ��

# ������ץ�̾
# servererror��urlhack�ץ饰�������Ѥ�����ϡ���ư�����ǤϤʤ�
# $::script��ɬ�����ꤷ�Ʋ�������
#$::script			= 'index.cgi';
$::script			= '';								# ��ư����

# ���URL
#$::basehref		= 'http://hogehoge/path/index.cgi';	# ��ư����
$::basehref			= '';

# ���ѥ� (cookie��)
#$::basepath		= '/path';							# ��ư����
$::basepath			= '';

# �ǥե���ȥڡ���̾
$::FrontPage		= 'FrontPage';
$::RecentChanges	= 'RecentChanges';
$::MenuBar			= 'MenuBar';
$::SideBar			= ':SideBar';						# for feature
$::Header			= ':Header';
$::Footer			= ':Footer';
#$::rule_page		= "�����롼��";						# to resource
$::InterWikiName	= 'InterWikiName';
$::ErrorPage		= "ErrorPage";
$::AdminPage		= "AdminPage";
$::IndexPage		= "IndexPage";
$::SearchPage		= "SearchPage";
$::CreatePage		= "CreatePage";

# �����ԥѥ���� (�����̥ѥ���ɡ�
$::adminpass = crypt("pass", "AA");

# �ѥ���ɤ��̤ˤ�����
#�������̥ѥ���ɤǤ�ǧ�ڤ��ޤ��������̤���Ѥ��ʤ�����¬����ʥѥ������ϡ�
#$::adminpass = 'aetipaesgyaigygoqyiwgorygaeta';# �ǥե���Ȥ���ѻ��ѥǥ�������ǽ�ѥ�
#$::adminpass{admin} = crypt("admin","AA");		# �������ѥѥ���ɡ�������
#$::adminpass{frozen} = crypt("frozen","AA");	# ����ѥѥ����
#$::adminpass{attach} = crypt("attach","AA");	# ź���ѥѥ����

# ����ꥹ��
#$::lang_list="ja en cn";

# RSS����
$::rss_lines=15;								# RSS���ϹԿ�
$::rss_description_line=1;						# description�ιԿ������
												# 1��2�ʾ�Ǥ�ư��ۤʤ�


# RSS���� (���ѿ��θ���̾��Ϣ������ˤ���ȡ������̤ˤǤ��ޤ���
$::modifier_rss_title=$::wiki_title;			# RSSɽ��
$::modifier_rss_link='';						# RSS�����ʼ�ư������
$::modifier_rss_description = "Modified by $::modifier";	# RSS������

#$::modifier_rss_title = "PyukiWiki $::version";
#$::modifier_rss_link = 'http://pyukiwiki.sourceforge.jp/';
#$::modifier_rss_description = 'This is PyukiWiki.';

# Ex�ץ饰��������
$::useExPlugin = 0;		# explugin�� 1:�Ȥ�/0:�Ȥ�ʤ�

# HTML���ϥ⡼��
$::htmlmode="html4";	# html4        : //W3C//HTML 4.01 Transitional
						# xhtml10      : //W3C//XHTML 1.0 Strict
						# xhtml10t     : //W3C//XHTML 1.0 Transitional
						# xhtml11      : //W3C//XHTML 1.1
						# xhtmlbasic10 : //W3C//DTD XHTML Basic 1.0

# ɽ������
$::usefacemark = 0;		# �ե������ޡ����� 1:�Ȥ�/0:�Ȥ�ʤ���
$::use_popup = 0;   	# ������ 
						# 0:���̤˥�󥯤���
						# 1:�ݥåץ��å� (target=_blank)
						# 2:HTTP_HOST����Ӥ��ơ�Ʊ��ʤ����̤�
						# 3:$basehref����Ӥ���Ʊ��ʤ����̤�
						# (wiki�ʲ��Υڡ����Τߡ�ư��ʤ������С��⤢��ޤ�)
						# (�����Ԥ�cookie��0/1-3�����������)
$::line_break = 0;		# wikiʸ���ǥե���Ȥǲ��Ԥ������� 1
						# (0�ξ�硢&br;��~������Ū�˲��Ԥ�����ɬ�פ�����ޤ����ǥե����)
$::last_modified = 2;	# �ǽ������� 0:��ɽ��/1:���ɽ��/2:����ɽ��
$::lastmod_prompt = 'Last-modified:'; # �ǽ��������Υץ��ץ�
$::allview = 0;			# 1:���٤Ƥβ��̤�Header, MenuBar, Footer��ɽ������, 0:���ʤ�

$::notesview = 0;		# ���� 0:$body�β���ɽ�� ,1:footer�ξ��ɽ��, 2:footer�β���ɽ��
$::enable_convtime = 1;	# ����С��ȥ����� 1:ɽ��/0:��ɽ��(perlversion��ɽ������ޤ�)

# �����ե����ޥå�
$::date_format = 'Y-m-d'; 			# replace &date; to this format.
$::time_format = 'H:i:s'; 			# replace &time; to this format,
$::now_format="Y-m-d(lL) H:i:s";	# replace &now; to this format.
$::lastmod_format="Y-m-d(lL) H:i:s";# lastmod format
$::recent_format="Y-m-d(lL) H:i:s";	# RecentChanges(?cmd=recent) format
#$::lastmod_format="yǯn��j��(lL) ALg��kʬS��";	# ���ܸ�ɽ������

	# ǯ  :Y:����(4��)/y:����(2��)
	# ��  :n:1-12/m:01-12/M:Jan-Dec/F:January-December
	# ��  :j:1-31/J:01-31
	# ����:l:Sunday-Saturday/D:Sun-Sat/DL:������-������/lL:��-��
	# ampm:a:am or pm/A:AM or PM/AL:���� or ���
	# ��  : g:1-12/G:0-23/h:01-12/H/00-23
	# ʬ  : k:0-59/i:00-59
	# ��  : S:0-59/s:00-59
	# O   : ����˥å��Ȥλ��ֺ�
	# r RFC 822 �ե����ޥåȤ��줿���� ��: Thu, 21 Dec 2000 16:01:07 +0200 
	# Z �����ॾ����Υ��ե��å��ÿ��� -43200 ���� 43200 
	# L ��ǯ�Ǥ��뤫�ɤ�����ɽ�������͡� 1�ʤ鱼ǯ��0�ʤ鱼ǯ�ǤϤʤ��� 
	# lL:���ߤΥ�����θ���Ǥ�������û��
	# DL:���ߤΥ�����θ���Ǥ�������Ĺ��
	# aL:���ߤΥ�����θ���Ǥθ���������ʸ����
	# AL:���ߤΥ�����θ���Ǥθ������ʾ�ʸ����
	# t ���ꤷ����������� 28 ���� 31 
	# B Swatch ���󥿡��ͥåȻ��� 000 ���� 999 
	# U Unix ��(1970ǯ1��1��0��0ʬ0��)������ÿ� See also time() 

# �ڡ����Խ�
$::cols = 80;			# �ƥ����ȥ��ꥢ�Υ�����
$::rows = 25;			# �ƥ����ȥ��ꥢ�ιԿ�
$::extend_edit = 0;		# ��ĥ��ǽ(JavaScript) 1:����/0:̤����
$::pukilike_edit = 0;	# PukiWiki�饤�����Խ�����
						# 0:Pyukiwiki/1:PukiWiki/2:PukiWiki+�����ɤ߹��ߵ�ǽ
						# 3:PukiWiki+���������Τ߿����ɤ߹��ߵ�ǽ
$::edit_afterpreview=0;	# �ץ�ӥ塼�� 0:�Խ����̤ξ� 1:�Խ����̤β�
$::new_refer='[[$1]]';	# ���������ξ�硢��Ϣ�ڡ����Υ�󥯤����ͤȤ���ɽ��
$::new_refer='';			# ��ʸ���ˤ����ɽ������ޤ���
$::new_dirnavi=0;		# �����ڡ����������̤ǡ��ɤΥڡ����β��ؤ���뤫
						# ����Ǥ���褦�ˤ��� 1:����/0:̤����
$::write_location=0;	# �ڡ����Խ��塢location�ǰ�ư����
						# ̵���Ǥ���Ž񤭹��ߤˤϤʤ�ޤ��󤬡���äƥ���ɥܥ����
						# �������Ȥ��Υ֥饦�����ηٹ���˻ߤǤ��ޤ���
						# ̵�������С��ϤǤϡ�0�ˤ��ʤ���ư��ޤ���
$::partedit=0;			# ��ʬ�Խ���0:�Ȥ�ʤ� 1:�Ȥ� 2:���ڡ����� 3:
$::partfirstblock=0;	# 1:�ǽ�θ��Ф����������ʬ��1���ܤθ��Ф��Ȥߤʤ����Խ��Ǥ���褦�ˤ���
$::usePukiWikiStyle=0;	# PukiWIki�񼰤� 0:�Ȥ�ʤ� 1:�Ȥ�
$::writefrozenplugin = 0;# �Ǽ���������뤵��Ƥ���ڡ����Ǥ�ץ饰���󤫤�񤭹����褦�ˤ��롣
						# 0:�Բ� 1:��
$::newpage_auth=0;		# �����ڡ��������� 0:ï�Ǥ�Ǥ���, 1:���ѥ���ɤ�ɬ��
						# �������ץ饰���󤫤���������뿷���ڡ����ˤ�Ŭ�Ѥ��ޤ���

# ��ư���
$::nowikiname = 1;		# 0:WikiName��ư��� 1:����Ū�� [[ ]] ��ɬ��
$::autourllink = 1;		# URL�μ�ư��� ([[ ]] ������Ū�˻��ꤵ�줿��ΤϤΤ���)
$::automaillink = 0;	# �᡼�륢�ɥ쥹�μ�ư��� ([[ ]] ������Ū�˻��ꤵ�줿��ΤϤΤ���)
$::useFileScheme=0;		# 0:�̾�, 1:file:// �Υ������ޤ�ͭ���ˤ���ʥ���ȥ�ͥåȸ�����
$::IntraMailAddr = 0;	# 1:����ȥ�ͥåȸ����Υɥᥤ��ʤ��᡼�륢�ɥ쥹��ͭ��

# ���å���
$::cookie_expire=3*30*86400;	# ��¸cookie��ͭ������(3����)
$::cookie_refresh=86400;		# ��¸cookie�Υ�ե�å���ֳ�(����)


# �������������󥿡�
$::CounterVersion=1;	# 1:�����Ⱥ����Τ���¸��2:������ʬ��¸
$::CounterDates=365;	# ��¸��������(14��1000)
$::CounterHostCheck=1;	# 1:�����󥿡��Υ�⡼�ȥۥ��Ȥ�����å�/0:����ɤǤ⥫����Ȥ���

# ź��
$::file_uploads = 1;		# ź�դ� 0:�Ȥ�ʤ�/1:�Ȥ�/2:ǧ���դ�/3:����Τ�ǧ����
$::max_filesize = 1000000;	# ���åץ��ɥե����������
$::AttachFileCheck=1;		# ź�եե���������ƴƺ��� 0:��ĥ�ҤΤ�/1:���ƴƺ��⤹��
							# 0�ξ�硢�������ƥ����������ˤʤ�Τ�
							# ����Ǥ��륤��ȥ�(local)�ͥåȰʳ��Ǥϻ��Ѥ��ʤ��ǲ�������

# �إ��
$::use_HelpPlugin=1;	# �إ�פ�ץ饰����Ǽ¹Ԥ���ʥʥӥ��������Ѳ����ޤ���
						# �إ�ץڡ������Խ��������
						# ?cmd=adminedit&mypage=%a5%d8%a5%eb%a5%d7 ��

# ����
$::use_FuzzySearch=0;	# 0:�̾︡��/1:���ܸ줢���ޤ���������Ѥ���

# �����ȥޥå�
$::use_SiteMap=0;		# 0:List�Τ�/1:List,�����ȥޥå�ξ��

# �ʥӥ�����������
$::naviindex=1;			# 0:����ɡ� / 1:�ȥåס�

# �ڡ���̾�β���topicpath�λ���
$::useTopicPath=0;		# 0:���Ѥ��ʤ� / 1:���Ѥ���
						# �ڡ�������Υץ饰����ƤӽФ��ˤϱƶ�����ޤ���

# ���β����ġ���С�
$::toolbar=1;			# 0:ɽ�����ʤ� 1:RSS���Τ� 2:���٤�ɽ������ʬ�Խ��Υ���������

# �����ԴĶ����굡ǽ��Ȥ�
$::use_Setting=0;

# �����󥻥쥯����Ȥ�
$::use_SkinSel=0;

$::_symbol_anchor = '&dagger;';
$::maxrecent = 50;

# ���������������˴ޤ�ʤ��ڡ���̾(����ɽ����)
$::non_list = qq((^\:));
#$::non_list = qq((^\:|$::MenuBar\$)); # example of MenuBar

# gzip �ѥ������ꤷ�ơ�lib/gzip.inc.pl �� gzip.inc.cgi�˥�͡��ह��Ȱ��̤�ͭ���ˤʤ롣
#$::gzip_path = '/bin/gzip -1';
#$::gzip_path = '/usr/bin/gzip -1 -f';
#$::gzip_path = '';

# sendmail�ѥ��λ��� $::modifier_mail���Ƥ˥᡼������
$::modifier_sendmail = '';
#$::modifier_sendmail=<<EOM;
#/usr/sbin/sendmail -t
#/usr/bin/sendmail -t
#/usr/lib/sendmail -t
#/var/qmail/bin/sendmail -t
#EOM

# P3P�Υ���ѥ��ȥݥꥷ�� http://fs.pics.enc.or.jp/p3pwiz/p3p_ja.html
# ɬ�פǤ���� /w3c�ʲ��ǥ��쥯�ȥ�ˤ�Ŭ�ڤ˥ե���������֤���ͭ���ˤ��ޤ�
#$::P3P="NON DSP COR CURa ADMa DEVa IVAa IVDa OUR SAMa PUBa IND ONL UNI COM NAV INT CNT STA";

# �ʥӥ������˥�󥯤��ɲä��륵��ץ�
#push(@::addnavi,"link:help");		# help�������ɲ�
##push(@::addnavi,"link::help");	# help�θ����ɲ�
#$::navi{"link_title"}="��󥯽�";
#$::navi{"link_url"}="$::script?%a5%ea%a5%f3%a5%af";	# page of '���'
#$::navi{"link_name"}="��󥯽�";
#$::navi{"link_type"}="page";
#$::navi{"link_height"}=14;
#$::navi{"link_width"}=16;


# �񤭹��߶ػߥ������
$::disablewords=<<EOM;
zhangweijp.com
linjp.net
1102213.com
bibi520.com
dj5566.org
webnow.biz
oulianyong.com
yzlin.com
EOM
1;

__END__


######################################################################
# pyukiwiki.skin.cgi - This is PyukiWiki, yet another Wiki clone.
# $Id: pyukiwiki.skin.cgi,v 1.41 2007/07/15 07:40:09 papu Exp $
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
# Skin.ja:PyukiWiki…∏Ω‡
# Skin.en:PyukiWiki Default
######################################################################

sub skin {
	my ($pagename, $body, $is_page, $bodyclass, $editable, $admineditable, $basehref, $lastmod) = @_;

	my($page,$message,$errmessage)=split(/\t/,$pagename);	
	my $cookedpage = &encode($page);
	my $cookedurl=&make_cookedurl($cookedpage);
	my $escapedpage = &htmlspecialchars($page);
	my $escapedpage_short=$escapedpage;
	$escapedpage_short=~s/^.*\///g if($::short_title eq 1);
	my $HelpPage = &encode($::resource{help});
	my $htmlbody;
	my ($title,$headerbody,$menubarbody,$footerbody,$notesbody);


	if($::lang eq 'ja') {
		$csscharset=qq( charset="Shift_JIS");
	}
	if($::use_blosxom eq 1) {
		$::IN_HEAD.=<<EOD;
<link rel="stylesheet" href="$::skin_url/blosxom.css" type="text/css" media="screen"$csscharset />
EOD
	}


	if($::wiki_title ne '') {
		$title="$::wiki_title - ";
	}

	if($page eq '') {
		$title_tag="$title$message";
	} else {
		$title_tag="$title$escapedpage @{[&htmlspecialchars(&get_subjectline($page))]}";
	}


	if($is_page || $::allview eq 1) {
		$headerbody=&print_content($::database{$::Header}, $::form{mypage})
			if(&is_exist_page($::Header));
		$::pushedpage = $::form{mypage};
		$::form{mypage}=$::MenuBar;
		$menubarbody=&print_content($::database{$::MenuBar}, $::pushedpage)
			if(&is_exist_page($::MenuBar));
		$::form{mypage}=$::pushedpage;
		$::pushedpage="";
		$footerbody=&print_content($::database{$::Footer}, $::form{mypage})
			if(&is_exist_page($::Footer));
	}


	if (@::notes) {
		$notesbody.= << "EOD";
<div id="note">
<hr class="note_hr" />
EOD
		my $cnt = 1;
		foreach my $note (@::notes) {
			$notesbody.= << "EOD";
<a id="notefoot_$cnt" href="@{[&make_cookedurl($::form{mypage})]}#notetext_$cnt" class="note_super">*$cnt</a>
@{[$::notesview ne 0 ? qq(<span class="small">) : '']}@{[$note]}@{[$::notesview ne 0 ? qq(</span>) : '']}
<br />
EOD
			$cnt++;
		}
		$notesbody.="</div>\n";
	}


	$htmlbody=<<"EOD";
$::dtd
<title>$title_tag</title>
@{[$basehref eq '' ? '' : qq(<base href="$basehref" />)]}
<link rel="stylesheet" href="$::skin_url/$::skin{default_css}" type="text/css" media="screen"$csscharset />
<link rel="stylesheet" href="$::skin_url/$::skin{print_css}" type="text/css" media="print"$csscharset />
@{[$::AntiSpam ne "" ? '' : qq(<link rev="made" href="mailto:$::modifier_mail" />)]}
<link rel="top" href="$::script" />
<link rel="index" href="$::script?cmd=list" />
@{[$::use_SiteMap eq 1 ? qq(<link rel="contents" href="$::script?cmd=sitemap" />) : '']}
<link rel="search" href="$::script?cmd=search" />
<link rel="help" href="$::script?$HelpPage" />
<link rel="author" href="$::modifierlink" />
<meta name="description" content="$title$escapedpage @{[&htmlspecialchars(&get_subjectline($page))]}" />
<meta name="author" content="$::modifier" />
<meta name="copyright" content="$::modifier" />
<script type="text/javascript" src="$::skin_url/$::skin{common_js}"></script>
$::IN_HEAD</head>
<body class="$bodyclass">
<div id="container">
<div id="head">
<div id="header">
<a href="$::modifierlink"><img id="logo" src="$::logo_url" width="$::logo_width" height="$::logo_height" alt="$::logo_alt" title="$::logo_alt" /></a>
EOD


	if($errmessage ne '') {
		$htmlbody.=<<EOD;
<h1 class="error">$errmessage</h1>
EOD
	} elsif($page ne '') {
		$htmlbody.=<<EOD;
<h1 class="title"><a
    title="$::resource{searchthispage}"
    href="$::script?cmd=search&amp;mymsg=$cookedpage">$escapedpage_short</a>@{[$message eq '' ? '' : "&nbsp;$message"]}</h1>
<span class="small">@{[&topicpath($page)]}</span>
EOD
	} else {
		$htmlbody.=<<EOD;
<h1 class="title">$message</h1>
EOD
	}


	$htmlbody.=<<EOD;
</div>
<div id="navigator">[ 
EOD
	my $flg=0;
	foreach $name (@::navi) {
		if($name eq '') {
			$htmlbody.=" ] &nbsp; [ " if($flg ne 0);
			$flg=0;
		} else {
			if($::navi{"$name\_name"} ne '') {
				$htmlbody .= " | " if($flg eq 1);
				$flg=1;
				$htmlbody.=<<EOD;
<a title="@{[$::navi{"$name\_title"} eq '' ? $::navi{"$name\_name"} : $::navi{"$name\_title"}]}" href="$::navi{"$name\_url"}">$::navi{"$name\_name"}</a>
EOD
			}
		}
	}
	$htmlbody.=<<EOD;
]
</div>
<hr class="full_hr" />
@{[ $::last_modified == 1
  ? qq(<div id="lastmodified">$::lastmod_prompt $lastmod</div>)
  : q()
]}
</div>
EOD


	$htmlbody.= <<"EOD";
<dfn></dfn>
<div id="content">
<table class="content_table" border="0" cellpadding="0" cellspacing="0">
@{[$headerbody ne '' ? qq(<tr><td@{[$menubarbody ne '' ? qq( colspan="2") : '']}>$headerbody</td></tr>) : '']}
  <tr>
EOD


	if($menubarbody ne '') {
		$htmlbody.=<<"EOD";
    <td class="menubar" valign="top">
    <div id="menubar">
$menubarbody
    </div>
    </td>
EOD
	}


	$htmlbody.= <<"EOD";
    <td class="body" valign="top">
      <div id="body">$body</div>@{[$::notesview eq 0 ? $notesbody : '']}
    </td>
  </tr>
@{[$::notesview eq 1 ? qq(<tr><td@{[$menubarbody ne '' ? qq( colspan="2") : '']}>$notesbody</td></tr>) : '']}
@{[$footerbody ne '' ? qq(<tr><td@{[$menubarbody ne '' ? qq( colspan="2") : '']}>$footerbody</td></tr>) : '']}
</table>
EOD


	$htmlbody.=$::notesview eq 2 ? $notesbody : '';


	$htmlbody.= <<"EOD";
</div>
<div id="foot">
<hr class="full_hr" />
<div id="toolbar">
EOD
	if($::toolbar ne 0) {
		foreach $name (@::navi) {
			if($name eq '') {
				$htmlbody.=" &nbsp; ";
			} else {
				if(-f "$image_dir/$name.png") {
					if($::toolbar eq 2 || $::navi{"$name\_height"} ne '') {
						my $height=$::navi{"$name\_height"} eq '' ? 20 : $::navi{"$name\_height"};
						my $width=$::navi{"$name\_width"} eq '' ? 20 : $::navi{"$name\_width"};
						$htmlbody.=<<EOD;
	<a title="@{[$::navi{"$name\_title"} eq '' ? $::navi{"$name\_name"} : $::navi{"$name\_title"}]}" href="$::navi{"$name\_url"}"><img alt="@{[$::navi{"$name\_title"} eq '' ? $::navi{"$name\_name"} : $::navi{"$name\_title"}]}" src="$image_url/$name.png" height="$height" width="$width" /></a>
EOD
					}
				}
			}
		}
	}
	$htmlbody.=<<EOD;
</div>
@{[ $::last_modified == 2
 ? qq(<div id="lastmodified">$::lastmod_prompt $lastmod</div>)
 : qq()
]}
<div id="footer">
EOD



	if($::lang eq 'ja') {
		$footerbody=<<EOD;
@{[$::wiki_title ne '' ? qq(''[[$::wiki_title>$basehref]]'' ) : '']}Modified by [[$::modifier>$::modifierlink]]~
~
''[[PyukiWiki $::version>http://pyukiwiki.sourceforge.jp/]]''
Copyright&copy; 2004-2007 by [[Nekyo>http://nekyo.hp.infoseek.co.jp/]], [[PyukiWiki Developers Team>http://pyukiwiki.sourceforge.jp/]]
License is [[GPL>http://www.opensource.jp/gpl/gpl.ja.html]], [[Artistic>http://www.opensource.jp/artistic/ja/Artistic-ja.html]]~
Based on "[[YukiWiki>http://www.hyuki.com/yukiwiki/]]" 2.1.0 by [[yuki>http://www.hyuki.com/]]
and [[PukiWiki>http://pukiwiki.sourceforge.jp/]] by [[PukiWiki Developers Term>http://pukiwiki.sourceforge.jp/]]~
EOD
	} else {

		$footerbody=<<EOD;
@{[$::wiki_title ne '' ? qq(''[[$::wiki_title>$basehref]]'' ) : '']}Modified by [[$::modifier>$::modifierlink]]~
~
''[[PyukiWiki $::version>http://pyukiwiki.sourceforge.jp/en/]]''
Copyright&copy; 2004-2007 by [[Nekyo>http://nekyo.hp.infoseek.co.jp/]], [[PyukiWiki Developers Team>http://pyukiwiki.sourceforge.jp/en/]]
License is [[GPL>http://www.gnu.org/licenses/gpl.html]], [[Artistic>http://www.perl.com/language/misc/Artistic.html]]~
Based on "[[YukiWiki>http://www.hyuki.com/yukiwiki/]]" 2.1.0 by [[yuki>http://www.hyuki.com/]]
and [[PukiWiki>http://pukiwiki.sourceforge.jp/]] by [[PukiWiki Developers Term>http://pukiwiki.sourceforge.jp/]]~
EOD
	}
	$footerbody= &text_to_html($footerbody);
	$footerbody=~s/(<p>|<\/p>)//g;
	$htmlbody.= $footerbody;

	$htmlbody.= <<"EOD";
@{[&convtime]}
</div>
</div>
</div>
</body>
</html>
EOD
	return $htmlbody;
}

1;

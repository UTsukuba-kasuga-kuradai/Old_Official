######################################################################
# adminchangepassword.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: adminchangepassword.inc.pl,v 1.15 2007/07/15 07:40:09 papu Exp $
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

$adminchangepassword::dummypass="aetipaesgyaigygoqyiwgorygaeta";
$adminchangepassword::setupinicgi=$::setup_file;
$adminchangepassword::minlength=6;
$adminchangepassword::maxlength=32;
$adminchangepassword::tableleftwidth=150;

sub plugin_adminchangepassword_action {
	my $stat,$body;
	%::auth=&authadminpassword(submit);
	return('msg'=>"\t$::resource{adminchangepassword_plugin_title}",'body'=>$auth{html})
		if($auth{authed} eq 0);

	if(defined($::form{extpass})) {
		($stat,$body)=&plugin_adminchangepassword_set;
		$body.=&plugin_adminchangepassword_input
			if($stat ne 0);
	} else {
		$body=&plugin_adminchangepassword_input;
	}

	my $in_head=<<EOM;
<script  type="text/javascript"><!--
function Display(id,mode){
	if(document.all || document.getElementById){	//IE4, NN6 or later
		if(document.all){
			obj = document.all(id).style;
		}else if(document.getElementById){
			obj = document.getElementById(id).style;
		}
		if(mode == "view") {
			obj.display = "block";
		} else if(mode == "none") {
			obj.display = "none";
		} else if(obj.display == "block"){
			obj.display = "none";		//hidden
		}else if(obj.display == "none"){
			obj.display = "block";		//view
		}
	}
}
//--></script>
EOM
	return ('msg'=>"\t$::resource{adminchangepassword_plugin_title}", 'body'=>$body,
			'header'=>$in_head);
}

sub plugin_adminchangepassword_set {
	my($stat,$body);
	$stat=0;
	if($::form{extpass} eq 1) {
		($stat,$body)=&plugin_adminchangepassword_check("admin",$stat,$body);
		($stat,$body)=&plugin_adminchangepassword_check("frozen",$stat,$body);
		($stat,$body)=&plugin_adminchangepassword_check("attach",$stat,$body);
	} else {
		($stat,$body)=&plugin_adminchangepassword_check("common",$stat,$body);
	}
	$body.=&plugin_adminchangepassword_write if($stat eq 0);
	return($stat,$body);
}

sub plugin_adminchangepassword_write {
	my ($body,$write);
	if($::form{extpass} eq 1) {
		$write=<<EOM;
\$::adminpass = '$adminchangepassword::dummypass';
\$::adminpass{admin}='@{[&plugin_adminchangepassword_crypt($::form{passwd_admin})]}';
\$::adminpass{frozen}='@{[&plugin_adminchangepassword_crypt($::form{passwd_frozen})]}';
\$::adminpass{attach}='@{[&plugin_adminchangepassword_crypt($::form{passwd_attach})]}';
1;
EOM
	} else {
		$write=<<EOM;
\$::adminpass = '@{[&plugin_adminchangepassword_crypt($::form{passwd_common})]}';
\$::adminpass{admin}='';
\$::adminpass{frozen}='';
\$::adminpass{attach}='';
1;
EOM
	}
	if(open(W,">>$adminchangepassword::setupinicgi")) {
		print W $write;
		close(W);
		$body=<<EOM;
$::resource{adminchangepassword_plugin_msg_complete}<br />
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="adminchangepassword" />
<input type="submit" value="$::resource{adminchangepassword_plugin_btn_back}" />
</form>
EOM
	} else {
		my $msg=$::resource{adminchangepassword_plugin_err_write};
		$msg=~s/FILE/$adminchangepassword::setupinicgi/g;
		$body=<<EOM;
<div class="error">$msg<br />
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="adminchangepassword" />
<input type="submit" value="$::resource{adminchangepassword_plugin_btn_back}" />
</form>
EOM
	}
	return $body;
}

sub plugin_adminchangepassword_crypt {
}

sub plugin_adminchangepassword_check {
	my($form,$stat,$body)=@_;

	if($::form{"passwd_" . $form} eq '') {
		$stat=1;
		$body.=<<EOM;
<div class="error">
$::resource{"adminchangepassword_plugin_" . $form}
$::resource{adminchangepassword_plugin_err_nopass}
</div>
</br >
EOM
	} elsif(length($::form{"passwd_" . $form}) < $adminchangepassword::minlength
	|| length($::form{"passwd_" . $form}) > $adminchangepassword::maxlength) {
		$stat=1;
		my $msg=$::resource{adminchangepassword_plugin_err_strmin};
		$msg=~s/MIN/$adminchangepassword::minlength/g;
		$msg=~s/MAX/$adminchangepassword::maxlength/g;
		$body.=<<EOM;
<div class="error">
$::resource{"adminchangepassword_plugin_" . $form}$msg
</div>
</br >
EOM
	} elsif($::form{"passwd_" . $form} ne $::form{"passwd2_" . $form}) {
		$stat=1;
		$body.=<<EOM;
<div class="error">
$::resource{"adminchangepassword_plugin_" . $form}
$::resource{adminchangepassword_plugin_err_ignore}
</div>
</br >
EOM
	}
	if($stat eq 1) {
		$::form{"passwd_" . $form}="";
		$::form{"passwd2_" . $form}="";
	}
	return ($stat,$body);
}

sub plugin_adminchangepassword_input {
	my $body;
	$body=<<EOM;
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="adminchangepassword" />
$auth{html}
<table>
<tr>
<td width="$adminchangepassword::tableleftwidth">$::resource{adminchangepassword_plugin_extpass}:</td>
<td>
<input type="radio" name="extpass" value="0" onclick="Display('common','view');Display('admin','none');Display('frozen','none');Display('attach','none');"@{[!&plugin_adminchangepassword_checkmode ? " checked" : ""]} />
$::resource{adminchangepassword_plugin_nouse}
<input type="radio" name="extpass" value="1" onclick="Display('common','none');Display('admin','view');Display('frozen','view');Display('attach','view');"@{[&plugin_adminchangepassword_checkmode ? " checked" : ""]} />
$::resource{adminchangepassword_plugin_use}
</table>
EOM
	$body.=&plugin_adminchangepassword_makepasswdform("common"
		,!&plugin_adminchangepassword_checkmode ? "block" : "none");
	$body.=&plugin_adminchangepassword_makepasswdform("admin"
		,&plugin_adminchangepassword_checkmode ? "block" : "none");
	$body.=&plugin_adminchangepassword_makepasswdform("frozen"
		,&plugin_adminchangepassword_checkmode ? "block" : "none");
	$body.=&plugin_adminchangepassword_makepasswdform("attach"
		,&plugin_adminchangepassword_checkmode ? "block" : "none");

	$body.=<<EOM;
<table>
<tr>
<td width="$adminchangepassword::tableleftwidth">&nbsp;</td>
<td><input type="submit" value="$::resource{adminchangepassword_plugin_btn_submit}" />
</td>
</tr>
</table>
</form>
EOM
	return $body;
}

sub plugin_adminchangepassword_crypt {
	my($passwd)=@_;
	my ($sec, $min, $hour, $day, $mon, $year, $weekday) = localtime(time);
	my (@token) = ('0'..'9', 'A'..'Z', 'a'..'z');
	my $salt1 = $token[(time | $$) % scalar(@token)];
	my $salt2 = $token[($sec + $min*60 + $hour*60*60) % scalar(@token)];
	my $crypted = crypt($passwd, "$salt1$salt2");
	return "$crypted $salt1$salt2";
}

sub plugin_adminchangepassword_checkmode {
	return $::form{extpass} if(defined($::form{extpass}));
	return 1 if($::adminpass{admin} ne '');
	return 0;
}

sub plugin_adminchangepassword_makepasswdform {
	my ($v,$s)=@_;
	return <<EOM;
<table style="display: $s;" id="$v">
<tr>
<td width="$adminchangepassword::tableleftwidth">$::resource{"adminchangepassword_plugin_" . $v}:</td>
<td>@{[&passwordform($::form{"passwd_" . $v},"","passwd_" . $v)]}</td>
</tr>
<tr>
<td>$::resource{adminchangepassword_plugin_reinput}:</td>
<td>@{[&passwordform($::form{"passwd_" . $v},"","passwd2_" . $v)]}</td>
</tr>
</table>
EOM
}

1;
__END__


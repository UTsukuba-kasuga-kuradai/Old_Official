######################################################################
# deletecache.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: deletecache.inc.pl,v 1.22 2007/07/15 07:40:09 papu Exp $
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

$deletecache::ignore_regex=q(^$|^..?$|^index|htaccess$|\..{1,3}$);
$deletecache::nonselect_regex=q(showrss);

sub plugin_deletecache_action {
	my $body;

	my %auth=&authadminpassword(submit,"","admin");
	return('msg'=>"\t$::resource{deletecache_plugin_title}",'body'=>$auth{html})
		if($auth{authed} eq 0);

	if($::form{submit}) {
		$body=<<EOM;
<h2>$::resource{deletecache_plugin_msg_deleted}</h2>
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="deletecache" />
$auth{html}
<input type="submit" name="back" value="$::resource{deletecache_plugin_btn_back}" />
</form>
<hr />
EOM
		$body.=&deletecache_exec;
	} else {
		$body=<<EOM;
<h2>$::resource{deletecache_plugin_listmsg}</h2>
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="deletecache" />
$auth{html}
EOM
		$body.=&deletecache_list;
		$body.=<<EOM;
<input type="submit" name="submit" value="$::resource{deletecache_plugin_btn_delete}" />
</form>
EOM
	}
	return('msg'=>"\t$::resource{deletecache_plugin_title}",'body'=>$body);
}

sub deletecache_list {
	my $body;
	opendir(DIR,"$::cache_dir");
	@DIR=sort readdir(DIR);
	closedir(DIR);
	%exts=();
	foreach my $dir (@DIR) {
		if($dir!~/$deletecache::ignore_regex/) {
			$dir=~s/.*\.//g;
			$exts{$dir}++;
		}
	}
	foreach my $ext(sort keys %exts) {
		$body.=<<EOM;
<input type="checkbox" name="delete_$ext"@{[$ext=~/$deletecache::nonselect_regex/ ? '' : " checked"]} />
$ext ($exts{$ext}$::resource{deletecache_plugin_files})<br />
EOM
	}
	return $body;
}

sub deletecache_exec {
	my($delete_list,$err_list);
	opendir(DIR,"$::cache_dir");
	@DIR=sort readdir(DIR);
	closedir(DIR);
	my $regex='\.(';
	foreach(keys %::form) {
		my($d,$ext)=split(/\_/,$_);
		if($d eq 'delete' && $ext ne '') {
			$regex.="$ext|";
		}
	}
	$regex=~s/|$//g;
	$regex.=')$';

	foreach my $dir(@DIR) {
		if($dir!~/$deletecache::ignore_regex/) {
			if($dir=~/$regex/) {
				if(unlink("$::cache_dir/$dir")) {
					$delete_list.=qq($::resource{deletecache_plugin_deleted} : $dir<br />\n);
				} else {
					$err_list.=qq(<div class="error">$::resource{deletecache_plugin_error} : $dir</div><br />\n);
				}
			}
		}
	}
	return($err_list . "\n" . $delete_list);
}

1;
__END__


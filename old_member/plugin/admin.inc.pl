######################################################################
# admin.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: admin.inc.pl,v 1.19 2007/07/15 07:40:09 papu Exp $
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

$admin::ignore_plugin=q{^edit|^admin\.|^newpage|^attach};

sub plugin_admin_action {
	my $body;
	%::auth=&authadminpassword(submit);
	return('msg'=>"\t$::resource{adminbutton}",'body'=>$auth{html})
		if($auth{authed} eq 0);

	my @adminlist=();
	my @dir=();
	opendir(DIR,"$::plugin_dir");
	while(my $dir=readdir(DIR)) {
		push(@dir,$dir);
	}
	closedir(DIR);
	@dir=sort @dir;
	foreach my $dir(@dir) {
		if($dir=~/(.*?)\.inc\.pl$/ && $dir!~/($admin::ignore_plugin)/) {
			my $flag=0;
			my $res="";
			open(R, "$::plugin_dir/$dir");
			foreach my $line(<R>) {
				$flag++ if($line=~/^sub.*\_action/);
				$flag++ if($line=~/\&authadminpassword/);
				if($flag eq 2) {
					$dir=~s/\.inc\.pl$//g;
					push(@adminlist,$dir);
					last;
				}
			close(R);
			}
		}
	}

	foreach my $plugin(@adminlist) {
		open(R, "$::plugin_dir/$plugin.inc.pl");
		my $res=$plugin;
		foreach my $line(<R>) {
			if($line=~/resource:(.+)/) {
				$res=$1;
			}
		}
		close(R);
		my $path="$::res_dir/$res.$::lang.txt";
		%::resource = &read_resource($path,%::resource) if(-r $path);
		$msg="$plugin";
		$msg.=" - " . $::resource{$plugin . "_plugin_title"}
			if($::resource{$plugin . "_plugin_title"} ne '');
		$body.=<<EOM;
<div align="center">
<form action="$::script" method="POST">
<input type="hidden" name="cmd" value="$plugin" />
$auth{html}
<input type="submit" value="$msg" />
</form>
</div>
EOM
	}
	return ('msg'=>"\t$::resource{adminbutton}", 'body'=>$body);
}
1;
__END__


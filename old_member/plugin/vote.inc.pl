######################################################################
# vote.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: vote.inc.pl,v 1.57 2007/07/15 07:40:09 papu Exp $
#
# "PyukiWiki" version 0.1.7 $$
# Author: Nekyo
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
# 2004/12/06 v0.2 …‘∂ÒπÁΩ§¿µ»«
######################################################################

use strict;

sub plugin_vote_action
{
	my $lines = $::database{$::form{mypage}};
	my @lines = split(/\r?\n/, $lines);

	my $vote_no = 0;
	my $title = '';
	my $body = '';
	my $postdata = '';
	my @args = ();
	my $cnt = 0;
	my $write = 0;
	my $vote_str = '';

	foreach (@lines) {
		if (/^#vote\(([^\)]*)\)s*$/) {
			if (++$vote_no != $::form{vote_no}) {
				$postdata .= $_ . "\n";
				next;
			}
			@args = split(/,/, $1);
			$vote_str = '';
			foreach my $arg (@args) {
				$cnt = 0;
				if ($arg =~ /^(.+)\[(\d+)\]$/) {
					$arg = $1;
					$cnt = $2;
				}
				my $e_arg = &encode($arg);
				my $vote_e_arg = "vote_" . $e_arg;

				if ($::form{$vote_e_arg} && ($::form{$vote_e_arg} eq $::resource{vote_plugin_votes})) {
					$cnt++;
				}
				if ($vote_str ne '') {
					$vote_str .= ',';
				}
				$vote_str .= $arg . '[' . $cnt . ']';
			}
			$vote_str = '#vote(' . $vote_str . ")\n";
			$postdata .= $vote_str;
			$write = 1;
		} else {
			$postdata .= $_ . "\n";
		}
	}
	if ($write) {
		$::form{mymsg} = $postdata;
		$::form{mytouch} = 'on';
		&do_write("FrozenWrite");
	} else {
		$::form{cmd} = 'read';
		&do_read;
	}
	&close_db;
	exit;
}

my $vote_no = 0;

sub plugin_vote_convert
{
	$vote_no++;
	my @args = split(/,/, shift);
	return '' if (@args == 0);

	my $escapedmypage = &escape($::form{mypage});
	my $conflictchecker = &get_info($::form{mypage}, $::info_ConflictChecker);

	my $body = <<"EOD";
<form action="$::script" method="post">
 <div class="ie5">
 <table cellspacing="0" cellpadding="2" class="style_table" summary="vote">
  <tr>
   <td align="left" class="vote_label" style="padding-left:1em;padding-right:1em"><strong>$::resource{vote_plugin_choice}</strong>
    <input type="hidden" name="vote_no" value="$vote_no" />
    <input type="hidden" name="cmd" value="vote" />
    <input type="hidden" name="mypage" value="$escapedmypage" />
    <input type="hidden" name="myConflictChecker" value="$conflictchecker" />
    <input type="hidden" name="mytouch" value="on" />
   </td>
   <td align="center" class="vote_label"><strong>$::resource{vote_plugin_votes}</strong></td>
  </tr>
EOD

	my $tdcnt = 0;
	my $cnt = 0;
	my ($link, $e_arg, $cls);
	foreach (@args) {
		$cnt = 0;

		if (/^(.+)\[(\d+)\]$/) {
			$link = $1;
			$cnt = $2;
		} else {
			$link = $_;
		}
		$e_arg = &encode($link);
		$cls = ($tdcnt++ % 2)  ? 'vote_td1' : 'vote_td2';
		$body .= <<"EOD";
  <tr>
   <td align="left" class="$cls" style="padding-left:1em;padding-right:1em;">$link</td>
   <td align="right" class="$cls">$cnt&nbsp;&nbsp;
    <input type="submit" name="vote_$e_arg" value="$::resource{vote_plugin_votes}" class="submit" />
   </td>
  </tr>
EOD
	}

	$body .= <<"EOD";
 </table>
 </div>
</form>
EOD
	return $body;
}
1;
__END__

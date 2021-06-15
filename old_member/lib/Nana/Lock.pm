######################################################################
# Lock.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: Lock.pm,v 1.48 2007/07/15 07:40:09 papu Exp $
#
# "Nana::Lock" version 0.2 $$
# Author: Nanami
# http://lineage.netgamers.jp/
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
# Return:LF Code=Shift-JIS 1TAB=4Spaces
######################################################################
#
# 大崎氏のrenameファイルロックに対して、以下の改良点があります。
# ・ディレクトリを使わない
#   全体ロックではなく、各ファイルでロック
#
# YukiWikiDBから、以下の改良点があります。
# ・lock関係を共通化できるように、ファイル読み書きをこのファイルへ
#
# from http://www.din.or.jp/~ohzaki/perl.htm#File_Lock
#
######################################################################

package	Nana::Lock;
use 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.2';


$Nana::Lock::LOCK_SH=1;
$Nana::Lock::LOCK_EX=2;
$Nana::Lock::LOCK_NB=4;
$Nana::Lock::LOCK_DELETE=128;

# rename lock idea
# http://www.din.or.jp/~ohzaki/perl.htm#File_Lock

sub lock {
	my $timeout=5;
	my $trytime=2;

	my($fname,$method)=@_;
	my($d,$f,$e)=$fname=~/(.*)\/(.+)\.(.+)$/;
	$f=~s/[.%()[]:*,_]//g;
	my %lfh=(
		dir=>$d,
		basename=>$f,
		timeout=>$timeout,
		trytime=>($method & $Nana::Lock::LOCK_NB ? 0 : $trytime),
		fname=>$fname,
		method=>$method & 3,
		path=>"$d/$f.lk"
	);
	if($method eq $Nana::Lock::LOCK_DELETE) {
		return &lock_del(%lfh);
	}
	return if($lfh{method} eq 0);

	for(my $i=0; $i < $lfh{trytime}*10; $i++) {
		$lfh{current}=sprintf("%s/%s.%x.%x.%x.%d.lk"
			,$lfh{dir},$lfh{basename},$lfh{method},$$,time);
		return \%lfh if(rename($lfh{path},$lfh{current}));

		my @filelist=&lock_getdir(%lfh);
		my @locklist=();
		my $fcount=0;
		my $excount=0;
		my $shcount=0;
		foreach (@filelist) {
			if (/^$lfh{basename}\.(\d)\.(.+)\.(.+)\.lk$/) {
				push(@locklist,"$1\t$2\t$3");
				$fcount++;
				$shcount++ if($1 eq 1);
				$excount++ if($1 eq 2);
			}
		}
		if($fcount eq 0) {
			open(LFHF,">$lfh{path}");# or return undef;
			close(LFHF);
			next;
		} elsif($lfh{method} eq 1) {
			if($shcount > 0 && $excount eq 0) {
				foreach(@locklist) {
					my($method,$pid,$time)=split(/\t/,$_);
					my $orgf=sprintf("%s/%s.%x.%s.%s.lk"
						,$lfh{dir},$lfh{basename},$method,$pid,$time);
					return \%lfh if(rename($orgf,$lfh{current}));
				}
			}
		}
		eval("select undef, undef, undef, 0.1;");
		if($@) {
			sleep 1;
			$i+=9;
		}
	}
	my @filelist=&lock_getdir(%lfh);
	foreach (@filelist) {
		if (/^$lfh{basename}\.(\d)\.(.+)\.(.+)\.lk$/) {
			if (time - hex($3) > $lfh{timeout}) {
				my $orgf=sprintf("%s/%s.%s.%s.%s.lk"
					,$lfh{dir},$lfh{basename},$1,$2,$3);
				return \%lfh if(rename($orgf,$lfh{current}));
			}
		}
	}
	return undef;
}

sub unlock {
	rename($_[0]->{current}, $_[0]->{path});
}

sub lock_del {
	my(%lfh)=@_;
	unlink($lfh{path});
	my @filelist=&lock_getdir(%lfh);
	foreach (@filelist) {
		if (/^$lfh{basename}\.(\d)\.(.+)\.(.+)\.lk$/) {
			unlink($_);
		}
	}
}

sub lock_getdir {
	my(%lfh)=@_;
	opendir(LOCKDIR, $lfh{dir});
	my @filelist = readdir(LOCKDIR);
	closedir(LOCKDIR);
	return @filelist;
}

1;
__END__

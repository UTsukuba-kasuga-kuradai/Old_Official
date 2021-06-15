######################################################################
# File.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: File.pm,v 1.27 2007/07/15 07:40:09 papu Exp $
#
# "Nana::File" version 0.1 $$
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

package	Nana::File;
use 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.1';

use Fcntl ':flock';

$Nana::File::LOCK_SH=1;
$Nana::File::LOCK_EX=2;
$Nana::File::LOCK_NB=4;
$Nana::File::LOCK_DELETE=128;

$Nana::File::UseCache=1;

%Nana::File::_Cache=();

sub lock_store {
	my ($filename, $value) = @_;
	my $lfh;
	local $SIG{ALRM} = sub { die "time out" };

	if($Nana::File::UseCache eq 1) {
		$Nana::File::_Cache{$filename}=$value;
	}
	eval {
		if(open(FILE, "+<$filename") or open(FILE, ">$filename")) {
			alarm(5);
			eval("flock(FILE, LOCK_EX)");
			if ($@) {
				$lfh=&lock($filename,$Nana::File::LOCK_EX);
				if(!$lfh) {
					alarm(0);
					return undef;
				}
			}
			alarm(5);
			truncate(FILE, 0);

			print FILE $value;
			alarm(5);
			eval("flock(FILE, LOCK_UN)");
			if ($@) {
				&unlock($lfh);
			}
			alarm(0);
			close(FILE);
		} else {
			alarm(0);
			return undef;
		}
		alarm(0);
	};
	if ($@ =~ /time out/) {
		return undef;
	}
	return $value;
}

sub lock_fetch {
	my ($filename) = @_;
	if($Nana::File::UseCache eq 1) {
		my $buf=$Nana::File::_Cache{$filename};
		return $buf if($buf ne '');
	}
	my $lfh;
	open(FILE, "$filename") or return(undef);
	eval("flock(FILE, LOCK_SH)");
	if ($@) {
		$lfh=&lock($filename,$Nana::File::LOCK_SH);
	}
	local $/;
	my $value = <FILE>;
	eval("flock(FILE, LOCK_UN)");
	if ($@) {
		&unlock($lfh);
	}
	close(FILE);
	if($Nana::File::UseCache eq 1) {
		$Nana::File::_Cache{$filename}=$value;
	}
	return $value;
}

sub lock_delete {
	my ($filename) = @_;

	my $lfh;
	open(FILE, "$filename") or return(undef);
	eval("flock(FILE, LOCK_SH)");
	if ($@) {
		$lfh=&lock($filename,$Nana::File::LOCK_DELETE);
	}
	eval("flock(FILE, LOCK_UN)");
	close(FILE);
	unlink($filename);
	if($Nana::File::UseCache eq 1) {
		$Nana::File::_Cache{$filename}='';
	}
}

sub lock {
	&load_module("Nana::Lock");
	return Nana::Lock::lock(@_);
}

sub unlock {
	&load_module("Nana::Lock");
	return Nana::Lock::unlock(@_);
}

sub load_module {
	my $funcp = $::functions{"load_module"};
	return &$funcp(@_);
}

1;
__END__

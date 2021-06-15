######################################################################
# Cache.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: Cache.pm,v 1.46 2007/07/15 07:40:09 papu Exp $
#
# "Nana::Cache" version 0.2 $$
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
# Return:LF Code=EUC-JP 1TAB=4Spaces
######################################################################

package	Nana::Cache;
use 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.2';
use Nana::File;

sub new {
	my($class,%hash)=@_;
	my $self={
		ext=>$hash{ext},
		dir=>$hash{dir},
		files=>$hash{files},
		size=>$hash{size},
		use=>$hash{use},
		expire=>$hash{expire},
	};
	return bless $self, $class;
}

sub delete {
	my($self,$fname)=@_;
	my $f=sprintf("%s/%s.%s",$self->{dir},$fname,$self->{ext});
	unlink($f);
}

sub check {
	my $self=shift;
	my @chks=@_;
	my $tm;
	my $ext=$self->{ext};
	my $dir=$self->{dir};
	my $files=0;
	my $size=0;
	if(opendir(D,$dir)) {
		while(my $f=readdir(D)) {
			next if($f!~/\.$ext$/);
			my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size,
				$atime, $mtime, $ctime, $blksize, $blocks) = stat("$dir/$f");
			$tm=$mtime if($tm<$mtime);
			$files++;
			$size+=$size;
		}
		closedir(D);
	}
	my $flg=0;
	foreach(@chks) {
		if((stat($_))[9] > $tm) {
			$flg=1;
			last;
		}
	}
	if($flg eq 1 || $files > $self->{files} || $size > $self->{size}) {
		if(opendir(D,$dir)) {
			while(my $f=readdir(D)) {
				next if($f!~/\.$ext$/);
				Nana::File::lock_delete("$dir/$f");
			}
			closedir(D);
		}
	}
}

sub expire {
	my($self,$fname,$expire)=@_;
	return 0 if($expire+0 eq 0);
	my $f=sprintf("%s/%s.%s",$self->{dir},$fname,$self->{ext});
	if((stat($f))[9] + $expire+0 < time) {
		Nana::File::lock_delete($f);
		return 1;
	}
	return 0;
}

sub read {
	my($self,$fname,$nodelete)=@_;
	return if($self->{use} ne 1);
	if($nodelete+0 ne 1) {
		return if(&expire($self,$fname,$self->{expire}));
	}
	my $buf;
	my $f=sprintf("%s/%s.%s",$self->{dir},$fname,$self->{ext});
	if(-r $f) {
		$buf=Nana::File::lock_fetch($f);
		$buf=~s/(\r|\n)//g;
		return $buf;
	}
	return '';
}

sub write {
	my($self,$fname,$w)=@_;
	return if($self->{use} ne 1);
	my $f=sprintf("%s/%s.%s",$self->{dir},$fname,$self->{ext});
	return Nana::File::lock_store($f,$w);
}

sub hash_read {
	my($self,$fname,$nodelete)=@_;
	return if($self->{use} ne 1);
	if($nodelete+0 ne 1) {
		return if(&expire($self,$fname,$self->{expire}));
	}
	my %hash;
	my $f=sprintf("%s/%s.%s",$self->{dir},$fname,$self->{ext});
	if(-r $f) {
		my $buf=Nana::File::lock_fetch($f);
		$buf=~s/\x0D\x0A|\x0D|\x0A/\n/g;
		foreach(split(/\n/,$buf)) {
			chomp;
			my($buf1,$buf2)=split(/\t/,$_);
			$hash{$buf1}=$buf2;
		}
		return %hash;
	}
	return %hash;
}

sub hash_write {
	my($self,$fname,%hash)=@_;
	return if($self->{use} ne 1);
	my $f=sprintf("%s/%s.%s",$self->{dir},$fname,$self->{ext});
	my $buf;
	foreach(keys %hash) {
		$buf.="$_\t$hash{$_}\n";
	}
	return Nana::File::lock_store($f,$buf);
}

1;
__END__

######################################################################
# Pod2Wiki.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: Pod2Wiki.pm,v 1.22 2007/07/15 07:40:09 papu Exp $
#
# "Nana::Pod2Wiki" version 0.1 $$
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

package	Nana::Pod2Wiki;
use 5.005;
use strict;
use vars qw($VERSION @EXPORT_OK @ISA @EXPORT);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();
$VERSION = '0.1';

my $wiki_name = '\b([A-Z][a-z]+([A-Z][a-z]+)+)\b';

sub pod2wiki {
	my $file=shift;
	my $notitle=shift;
	my $body="";
	my $pod='';
	my $name="";
	my $tmp;
	my ($cmd,$data);
	my $anchor=0;

	if(!open(R,$file)) {
		return("File not found : $file");
	}
	foreach my $f(<R>) {
		chomp $f;
		if($f=~/^=/ && $pod eq '') {
			$pod="pod";
		}
		next if($f=~/^__/ || $pod eq '');
		if($f=~/^=cut/) {
			$pod='';
			next;
		} elsif($f eq '') {
			if($pod=~/wiki/) {
				$body.="\n";
			} elsif($pod eq 'dd') {
				$body.="&br;&br;";
			} elsif(!($pod eq 'name' || $pod=~/^d[d|t|l]/)) {
				$body.="\n\n";
				$pod='pod';
			} elsif($pod=~/for/) {
				$pod="pod";
			}
			next;
		}
		if($f!~/^\s/ && $pod!~/wiki/) {
			$f=~s/\#/\x5/g;
			$f=~s/\&/\x6/g;
			$f=~s/\:\/\//\x8/g;
			$f=~s/\:/\x4/g;
		}
		$f=~/^=([^\s]+)(.*)/;
		$cmd=$1;
		$data=$2;
		$data=~s/^\s*//g;
		if($f=~/^=encoding/) {
			next;
		} elsif($cmd eq 'lang') {
			next;
		} elsif($cmd eq 'head1' && $data eq 'NAME') {
			$pod='name';
			next;
		} elsif($pod eq 'name') {
			$body.="**NAME\n" . &pod2wiki_tags($f);
			$name=&pod2wiki_tags($f);
			$anchor++;
			$pod="pod";
			next;
		} elsif($cmd eq 'head1') {
			$pod="pod";
			$body.="**" . &pod2wiki_tags($data) . "\n";
			$anchor++;
		} elsif($cmd eq 'head2') {
			$pod="pod";
			$body.="***" . &pod2wiki_tags($data) . "\n";
			$anchor++;
		} elsif($cmd eq 'for') {
			if($data eq 'wiki') {
				$pod='for_wiki';
			} else {
				next;
			}
		} elsif($cmd eq 'begin') {
			if($data eq 'wiki') {
				$pod='begin_wiki';
			} else {
				next;
			}
		} elsif($cmd eq 'end') { 
			$pod="pod";
		} elsif($pod=~/wiki/) {
			$body.="$f\n";
		} elsif($cmd eq 'over') {
			$pod="dl";
		} elsif($cmd eq 'back') {
			$pod="pod";
		} elsif($cmd eq 'item') {
			$body=~s/\&br;$//g while($body=~/\&br;$/);
			$body.="&nbsp;" if($pod=~/d[dt]/);
			$body.="\n:" . &pod2wiki_tags($data) . ":";
			$pod="dt";
		} elsif($pod=~/d[dt]/) {
			if($f=~/^\s/) {
				$body.="\n" if($pod eq "dd");
				$body.="$f\n";
				$pod="ddpre";
			} else {
				$pod="dd";
				if($pod=~/pre/) {
					$body.=":&nbsp;:";
				}
				$body.=&pod2wiki_tags($f);
			}
		} else {
			if($f=~/^\s/) {
				$body.="$f\n";
			} else {
				$body.=&pod2wiki_tags($f);
			}
		}
	}

	$body=~s/\x8/\:\/\//g;
	$name=~s/($wiki_name)/&verb($1);/g;

	return ($name,$body);
}

sub pod2wiki_tags {
	my($str)=@_;

	$str=~s/L<\/([^>]+)>/$1/g;
	$str=~s/L<([^>]+)>/[[$1]]/g;
	$str=~s/I<([^>]+)>/'''$1'''/g;
	$str=~s/B<([^>]+)>/''$1''/g;
	$str=~s/S<([^>]+)>/\&verb($1);/g;
	$str=~s/C<([^>]+)>/$1/g;
	$str=~s/F<([^>]+)>/$1/g;
	$str=~s/X<([^>]+)>/$1/g;
	$str=~s/Z<([^>]+)>/$1/g;
	$str=~s/E<lt>/</g;
	$str=~s/E<gt>/>/g;
	$str=~s/E<sol>/\//g;
	$str=~s/E<verbar>/\|/g;
	$str=~s/E<\d+>/chr($1)/gex;

	return $str;
}
1;
__END__

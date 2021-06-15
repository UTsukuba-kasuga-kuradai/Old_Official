######################################################################
# Mail.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: Mail.pm,v 1.6 2007/07/15 07:40:09 papu Exp $
#
# "Nana::Mail" version 0.1 $$
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

package	Nana::Mail;
use 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.1';

# sendmail¥Ñ¥¹¸¡º÷¸õÊä
$Nana::Mail::sendmail=<<EOM;
EOM

######################################################################

use Jcode;

sub mime_conv {
	my($str)=@_;
	$str=Jcode->new($str)->jis;
	$str=Jcode->new($str)->mime_encode;
	return $str;
}

sub send {
	my(%hash)=@_;
	my $to=&mime_conv($hash{to});
	my $to_name=&mime_conv($hash{to_name});
	my $from=&mime_conv($hash{from});
	my $from_name=&mime_conv($hash{from_name});
	my $subject=&mime_conv($hash{subject});
	my $data=Jcode->new($hash{data})->jis;
	return 1 if($to eq '' || $from eq '' || $::modifier_sendmail eq '');
	$subject="[Wiki] $::basehref" if($subject eq '');

	$to=qq($to_name\n <$to>) if($to_name ne '');
	$from=qq($from_name\n <$from>) if($from_name ne '');
	my $mail=<<EOM;
To: $to
From: $from
Subject: $subject
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

$data
EOM

	foreach(split(/\n/,$::modifier_sendmail)) {
		my($exec,$opt1, $opt2, $opt3, $opt4, $opt5)=split(/ /,$_);
		if(-x $exec) {
			open(MAIL, "| $exec $opt1 $opt2 $opt3 $opt4 $opt5");
			print MAIL $mail;
			close(MAIL);
			return 0;
		}
	}
	return 1
}

sub toadmin {
	my($mode,$page,$data)=@_;
	$data=$::database{$page} if($data eq '');

	my $message = <<"EOD";
--------
WIKI = $::modifier_rss_title
MODE = $mode
REMOTE_ADDR = $ENV{REMOTE_ADDR}
REMOTE_HOST = $ENV{REMOTE_HOST}
--------
$page
--------
$data
--------
EOD

	&send(to=>$::modifier_mail, from=>$::modifier_mail, 
		  subject=>"[Wiki]$mode $::basehref", data=>$message);
}

1;
__END__

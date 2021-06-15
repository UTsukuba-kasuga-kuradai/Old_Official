######################################################################
# HTTP.pm - This is PyukiWiki, yet another Wiki clone.
# $Id: HTTP.pm,v 1.23 2007/07/15 07:40:09 papu Exp $
#
# "Nana::HTTP" version 0.2 $$
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

package	Nana::HTTP;
use 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.2';

# 0:付属エンジン 1:LWPが存在すればLWP、なければ付属エンジン
$Nana::HTTP::useLWP=0;

# ユーザーエージェント
$Nana::HTTP::UserAgent="$::package/$::version \@\@";

# タイムアウト
$Nana::HTTP::timeout=20;

# 再試行回数 (↑で割れる数で、LWPは未使用)
$Nana::HTTP::counter=2;

######################################################################

my $timeoutflag=0;
use Socket;

sub new {
	my ($class, %hash) = @_;
	my $self = {
		plugin => $hash{plugin},
		module => $hash{module},
		ua => $hash{ua},
		header => $hash{header},
		user => $hash{user},
		pass => $hash{pass},
	};
	$$self{lwp_ok}=0;
	if($Nana::HTTP::useLWP eq 1) {
		if(&load_module("LWP::UserAgent")) {
			$$self{lwp_ua}=LWP::UserAgent->new;
			$$self{_ua} = &makeua($$self{lwp_ua}->_agent,%hash),
			$$self{_header} = "User-Agent: " . $$self{_ua} . $$self{header};
			$$self{lwp_ua}->agent($$self{_ua});
			$$self{lwp_ua}->timeout($Nana::HTTP::timeout);
			foreach("http", "https", "ftp") {
				$$self{lwp_ua}->proxy($_,"http://$::proxy_host:$::proxy_port/")
			}
			$$self{lwp_ok}=1;
		}
	}
	if($$self{lwp_ok} ne 1) {
		$$self{lwp_ok}=0;
		$$self{_ua} = &makeua("",%hash),
		$$self{_header} = "User-Agent: " . $$self{_ua} . $$self{header};
	}
	return bless $self, $class;
}

sub load_module {
	my $funcp = $::functions{"load_module"};
	return &$funcp(@_);
}

sub get {
	my($self, $uri)=@_;
	if($$self{lwp_ok} eq 1) {
		my $req;
		if($$self{user} . $$self{pass} ne '') {
			my $header=HTTP::Headers->new;
			$header->authorization_basic($$self{user},$$self{pass});
			$req=HTTP::Request->new(GET => $uri, $header);
		} else {
			$req=HTTP::Request->new(GET => $uri);
		}
		my $res=$$self{lwp_ua}->request($req);
		if($res->is_success) {
			return(0,$res->content);
		} else {
			return(1,$res->status_line);
		}
	}
	return &httpcl($uri,"GET", $$self{_header});
}

sub post {
	my($self, $uri, $postdata)=@_;

	if($$self{lwp_ok} eq 1) {
		my $header;
		my $req;
		if($$self{user} . $$self{pass} ne '') {
			$header=HTTP::Headers->new;
			$header->authorization_basic($$self{user},$$self{pass});
		}
		$req=HTTP::Request->new(POST => $uri, $header);
		$req->content_type('application/x-www-form-urlencoded');
		$req->content($postdata);

		my $res=$$self{lwp_ua}->request($req);
		if($res->is_success) {
			return(0,$res->content);
		} else {
			return(1,$res->status_line);
		}
	}
	return &httpcl($uri,"POST", $$self{_header}, $postdata);
}

sub makeua {
	my($add,%self)=@_;
	my $ua;
	my $mods;
	if($self{ua} eq '') {
		$ua=$Nana::HTTP::UserAgent;
		if($self{plugin} ne '') {
			$mods=" Plugin $self{plugin};";
		} elsif($self{module} ne '') {
			$mods=" Module $self{module};";
		}
		$ua=~s/\@\@/$mods@{[$add ne '' ? " $add" : '']}/g;
	} else {
		$ua=$self{ua};
	}
	return $ua;
}

sub httpcl {
	my($url,$method,$header,$postdata)=@_;
	my($stat,$ret);
	my $timeoutcounter=$Nana::HTTP::counter;

	$SIG{ALRM}=\&httpcl_timeout;
	$ret="";

	while($timeoutcounter>0) {
		$timeoutflag=0;
		alarm($Nana::HTTP::alarmtime / $Nana::HTTP::counter);
		($stat,$ret)=&httpclsub($url,$method,$header,$postdata);
		alarm(0);
		$timeoutcounter--;
		$ret="" if($timeoutflag eq 1);
		if($ret eq '') {
			$timeoutcounter=0;
			$stat=5;
		}
	}
	if($stat ne 0) {
		$ret=("","Host not found","Can't Create Socket address"
			, "Socket Error", "Can't connect Server", "Timeout")[$stat];
	}
	return ($stat,$ret);
}

sub httpclsub {
	my($url,$method,$header,$postdata)=@_;
	my($ret);
	my($postlength);
	my($iaddr,$sock_addr);
	$ret="";
	if(uc $method=~/^(GET|POST|HEAD)$/) {
		if($url =~ m!(http:)?(//)?([^:/]*)?(:([0-9]+)?)?(/.*)?!) {
			my $host = ($3 ne "") ? $3 : "localhost";
			my $port = ($5 ne "") ? $5 : 80;
			my $path = ($6 ne "") ? $6 : "/";
			if($::proxy_host ne '' && $::proxy_port > 0) {
				$iaddr = inet_aton($::proxy_host) || return (1,"");
				$sock_addr = pack_sockaddr_in($::proxy_port, $iaddr) || return (2,"");
				socket(SOCKET, PF_INET, SOCK_STREAM, 0) || return (3,"");
				connect(SOCKET, $sock_addr) || return (4,"");
				select(SOCKET); $|=1; select(STDOUT);
				print SOCKET "$method $url HTTP/1.0\r\n";
			} else {
				$iaddr = inet_aton($host) || return (1,"");
				$sock_addr = pack_sockaddr_in($port, $iaddr) || return (2,"");
				socket(SOCKET, PF_INET, SOCK_STREAM, 0) || return (3,"");
				connect(SOCKET, $sock_addr) || return (4,"");
				select(SOCKET); $|=1; select(STDOUT);
				print SOCKET "$method /$path HTTP/1.0\r\n";
				print SOCKET "Host: $host:$port\r\n";
			}
			$postlength=length($postdata);
			foreach(split(/\n/,$header)) {
				print SOCKET "$_\r\n"
					if($_=~/:/);
			}
			print SOCKET "Content-Length: $postlength\r\n" if($method eq 'POST');
			print SOCKET "\r\n";
			print SOCKET $postdata if($method eq 'POST');
			print SOCKET "\r\n" if($method eq 'POST');
			if($method ne 'HEAD') {	
				while(<SOCKET>) {
					m/^\r\n$/ && last;
				}
			}
			while(<SOCKET>) {
				s/\r//g;
				$ret.=$_;
			}
		}
	}
	return (0,$ret);
}
sub httpcl_timeout {
	$timeoutflag=1;
}

1;
__END__

#$Id: MMagic.pm,v 1.42 2007/07/15 07:40:09 papu Exp $
# "File::MMagic" version 1.26 $$

# File::MMagic
#
# Id: MMagic.pm 198 2006-01-30 05:24:17Z knok
#
# This program is originated from file.kulp that is a production of The
# Unix Reconstruction Projct.
#    <http://language.perl.com/ppt/index.html>
# Copyright 1999,2000,2001,2002 NOKUBI Takatsugu <knok (at) daionet (dot) gr (dot) jp>.
#
# This product includes software developed by the Apache Group
# for use in the Apache HTTP server project (http://www.apache.org/).
#
# License for the program is followed the original software. The license is
# below.
#
# This program is copyright by dkulp 1999.
#
# This program is free and open software. You may use, copy, modify, distribute
# and sell this program (and any modified variants) in any way you wish,
# provided you do not restrict others to do the same, except for the following
# consideration.
#
#I read some of Ian F. Darwin's BSD C implementation, to
#try to determine how some of this was done since the specification
#is a little vague.  I don't believe that this perl version could
#be construed as an "altered version", but I did grab the tokens for
#identifying the hard-coded file types in names.h and copied some of
#the man page.
#
#Here's his notice:
#
#  * Copyright (c) Ian F. Darwin, 1987.
#  * Written by Ian F. Darwin.
#  *
#  * This software is not subject to any license of the American Telephone
#  * and Telegraph Company or of the Regents of the University of California.
#  *
#  * Permission is granted to anyone to use this software for any purpose on
#  * any computer system, and to alter it and redistribute it freely, subject
#  * to the following restrictions:
#  *
#  * 1. The author is not responsible for the consequences of use of this
#  *    software, no matter how awful, even if they arise from flaws in it.
#  *
#  * 2. The origin of this software must not be misrepresented, either by
#  *    explicit claim or by omission.  Since few users ever read sources,
#  *    credits must appear in the documentation.
#  *
#  * 3. Altered versions must be plainly marked as such, and must not be
#  *    misrepresented as being the original software.  Since few users
#  *    ever read sources, credits must appear in the documentation.
#  *
#  * 4. This notice may not be removed or altered.
#
# The following is the Apache License. This program contains the magic file
# that derived from the Apache HTTP Server.
#
#  * Copyright (c) 1995-1999 The Apache Group.  All rights reserved.
#  *
#  * Redistribution and use in source and binary forms, with or without
#  * modification, are permitted provided that the following conditions
#  * are met:
#  *
#  * 1. Redistributions of source code must retain the above copyright
#  *    notice, this list of conditions and the following disclaimer.
#  *
#  * 2. Redistributions in binary form must reproduce the above copyright
#  *    notice, this list of conditions and the following disclaimer in
#  *    the documentation and/or other materials provided with the
#  *    distribution.
#  *
#  * 3. All advertising materials mentioning features or use of this
#  *    software must display the following acknowledgment:
#  *    "This product includes software developed by the Apache Group
#  *    for use in the Apache HTTP server project (http://www.apache.org/)."
#  *
#  * 4. The names "Apache Server" and "Apache Group" must not be used to
#  *    endorse or promote products derived from this software without
#  *    prior written permission. For written permission, please contact
#  *    apache (at) apache (dot) org.
#  *
#  * 5. Products derived from this software may not be called "Apache"
#  *    nor may "Apache" appear in their names without prior written
#  *    permission of the Apache Group.
#  *
#  * 6. Redistributions of any form whatsoever must retain the following
#  *    acknowledgment:
#  *    "This product includes software developed by the Apache Group
#  *    for use in the Apache HTTP server project (http://www.apache.org/)."
#  *
#  * THIS SOFTWARE IS PROVIDED BY THE APACHE GROUP ``AS IS'' AND ANY
#  * EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#  * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE APACHE GROUP OR
#  * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
#  * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
#  * OF THE POSSIBILITY OF SUCH DAMAGE.

package File::MMagic;


use FileHandle;
use strict;

use vars qw(
%TEMPLATES %ESC $VERSION
$magicFile $checkMagic $followLinks $fileList
$allowEightbit
);

BEGIN {
# translation of type in magic file to unpack template and byte count
%TEMPLATES = (byte     => [ 'c', 1 ],
		 ubyte    => [ 'C', 1 ],
		 char     => [ 'c', 1 ],
		 uchar    => [ 'C', 1 ],
		 short    => [ 's', 2 ],
		 ushort   => [ 'S', 2 ],
		 long     => [ 'l', 4 ],
		 ulong    => [ 'L', 4 ],
		 date     => [ 'l', 4 ],
		 ubeshort => [ 'n', 2 ],
		 beshort  => [ [ 'n', 'S', 's' ], 2 ],
		 ubelong  => [   'N',             4 ],
		 belong   => [ [ 'N', 'I', 'i' ], 4 ],
		 bedate   => [   'N',             4 ],
		 uleshort => [   'v',             2 ],
		 leshort  => [ [ 'v', 'S', 's' ], 2 ],
		 ulelong  => [   'V',             4 ],
		 lelong   => [ [ 'V', 'I', 'i' ], 4 ],
		 ledate   => [   'V',             4 ],
		 string   => undef);

# for letter escapes in magic file
%ESC = ( n => "\n",
	    r => "\r",
	    b => "\b",
	    t => "\t",
	    f => "\f");

$VERSION = "1.26";
$allowEightbit = 1;
}

sub new {
    my $self = {};
    my $proto = shift;
    my $class = ref($proto) || $proto;
    $self->{MF} = [];
    $self->{magic} = [];
    if (! @_) {
	my $fh = *File::MMagic::DATA{IO};
	binmode($fh);
	bless $fh, 'FileHandle' if ref $fh ne 'FileHandle';
	my $dataLoc;

	{
	    no strict 'refs';
	    my $instance = \${ "$class\::_instance" };
	    $$instance = $fh->tell() unless $$instance;
	    $dataLoc = $$instance;
	}

	$fh->seek($dataLoc, 0);
	&readMagicHandle($self, $fh);
    } else {
	my $filename = shift;
	my $fh = new FileHandle;
	if ($fh->open("< $filename")) {
	    binmode($fh);
	    &readMagicHandle($self, $fh);
	} else {
	    warn __PACKAGE__ . " couldn't load specified file $filename";
	}
    }

# from the BSD names.h, some tokens for hard-coded checks of
# different texts.  This isn't rocket science.  It's prone to
# failure so these checks are only a last resort.

# removSpecials() can be used to remove those afterwards.
    $self->{SPECIALS} = {
		 "message/rfc822" => [ "^Received:",   
			     "^>From ",       
			     "^From ",       
			     "^To: ",
			     "^Return-Path: ",
			     "^Cc: ",
			     "^X-Mailer: "],
		 "message/news" => [ "^Newsgroups: ", 
			     "^Path: ",       
			     "^X-Newsreader: "],
		 "text/html" => [ "<html[^>]*>",
			     "<HTML[^>]*>",
			     "<head[^>]*>",
			     "<HEAD[^>]*>",
			     "<body[^>]*>",
			     "<BODY[^>]*>",
			     "<title[^>]*>",
			     "<TITLE[^>]*>",
			     "<h1[^>]*>",
			     "<H1[^>]*>",
			],
		 "text/x-roff" => [
			      '^\\.\\\\"',
			      "^\\.SH ",
			      "^\\.PP ",
			      "^\\.TH ",
			      "^\\.BR ",
			      "^\\.SS ",
			      "^\\.TP ",
			      "^\\.IR ",
				   ],
		};

    $self->{FILEEXTS} = {
	     '\.gz$' => 'application/x-gzip',
	     '\.bz2$' => 'application/x-bzip2',
	     '\.Z$' => 'application/x-compress',
	     '\.txt$' => 'text/plain',
	     '\.html$' => 'text/html',
	     '\.htm$' => 'text/html',
    };
    bless($self);
    return $self;
}

sub addSpecials {
    my $self = shift;
    my $mtype = shift;
    $self->{SPECIALS}->{"$mtype"} = [@_];
    return $self;
}

sub removeSpecials {
    my $self = shift;
    # Remove all keys if no arguments given
    my @mtypes = (@_ or keys %{$self->{SPECIALS}});
    my %returnmtypes;
    foreach my $mtype (@mtypes) {
      $returnmtypes{"$mtype"} = delete $self->{SPECIALS}->{"$mtype"};
    }
    return %returnmtypes;
}

sub addFileExts {
    my $self = shift;
    my $filepat = shift;
    my $mtype = shift;
    $self->{FILEEXTS}->{"$filepat"} = $mtype;
    return $self;
}

sub removeFileExts {
    my $self = shift;
    # Remove all keys if no arguments given
    my @filepats = (@_ or keys %{$self->{FILEEXTS}}); 
    my %returnfilepats;
    foreach my $filepat (@filepats) {
      $returnfilepats{"$filepat"} = delete $self->{FILEEXTS}->{"$filepat"};
    }
    return %returnfilepats;
}

sub addMagicEntry {
    my $self = shift;
    my $entry = shift;
    if ($entry =~ /^>/) {
	$entry =~ s/^>//;
	my $depth = 1;
	my $entref = ${${$self->{magic}}[0]}[2];
	while ($entry =~ /^>/) {
	    $entry =~ s/^>//;
	    $depth ++;
	    $entref = ${${$entref}[0]}[2];
	}
	$entry = '>' x $depth . $entry;
	unshift @{$entref}, [$entry, -1, []];
	return $self;
    }
    unshift @{$self->{magic}}, [$entry, -1, []];
    return $self;
}

sub readMagicHandle {
    my $self = shift;
    my $fh = shift;
    $self->{MF}->[0] = $fh;
    $self->{MF}->[1] = undef;
    $self->{MF}->[2] = 0;
    readMagicEntry($self->{magic}, $self->{MF});
}

# Not implimented.
#
#sub readMagicFile {
#    my $self = shift;
#    my $mfile = shift;
#}

sub checktype_filename {
    my $self = shift;

# iterate over each file explicitly so we can seek
    my $file = shift;

    # the description line.  append info to this string
    my $desc;
    my $mtype;

    # 0) check permission
    if (! -r $file) {
	$desc .= " can't read `$file': Permission denied.";
	return "x-system/x-error; $desc";
    }

    # 1) check for various special files first
    if ($^O eq 'MSWin32') {
	stat($file);
    } else {
	if ($followLinks) { stat($file); } else { lstat($file); }
    }
    if (! -f _  or -z _) {
	if ( $^O ne 'MSWin32' && !$followLinks && -l _ ) { 
	    $desc .= " symbolic link to ".readlink($file); 
	}
	elsif ( -d _ ) { $desc .= " directory"; }
	elsif ( -p _ ) { $desc .= " named pipe"; }
	elsif ( -S _ ) { $desc .= " socket"; }
	elsif ( -b _ ) { $desc .= " block special file"; }
	elsif ( -c _ ) { $desc .= " character special file"; }
	elsif ( -z _ ) { $desc .= " empty"; }
	else { $desc .= " special"; }

	return "x-system/x-unix; $desc";
    }

    # current file handle.  or undef if checkMagic (-c option) is true.
    my $fh;

#    $fh = new FileHandle "< $file" or die "$F: $file: $!\n" ;
    $fh = new FileHandle "< $file" or return "x-system/x-error; $file: $!\n" ;

    binmode($fh); # for MSWin32

    # 2) check for script
    if (-x $file && -T _) {




	my $line1 = <$fh>;
	if ($line1 =~ /^\#!\s*(\S+)/) {
	    $desc .= " executable $1 script text";
	}
	else { $desc .= " commands text"; }

	$fh->close();

	return "x-system/x-unix; $desc";

    }

    my $out = checktype_filehandle($self, $fh, $desc);
    undef $fh;

    return $out;
}

sub checktype_filehandle {
    my $self = shift;
    my ($fh, $desc) = @_;
    my $mtype;

    binmode($fh); # for MSWin32 architecture.

    # 3) iterate over each magic entry.
    my $matchFound = 0;
    my $m;
    for ($m = 0; $m <= $#{$self->{magic}}; $m++) {



	if (magicMatch($self->{magic}->[$m],\$desc,$fh)) {
	    if (defined $desc && $desc ne '') {
		$matchFound = 1;
		$mtype = $desc;
		last;
	    }
	}




	if ($m == $#{$self->{magic}} && !$self->{MF}->[0]->eof()) {
	    readMagicEntry($self->{magic}, $self->{MF});
	}
    }

    # 4) check if it's text or binary.
    # if it's text, then do a bunch of searching for special tokens
    if (!$matchFound) {
	my $data;
	$fh->seek(0,0);
	$fh->read($data, 0x8564);
	$mtype = checktype_data($self, $data);
    }

    $mtype = 'text/plain' if (! defined $mtype);

    return $mtype;
}

sub checktype_contents {
    my $self = shift;
    my $data = shift;
    my $mtype;

    return 'application/octet-stream' if (length($data) <= 0);

    $mtype = checktype_magic($self, $data);

    # 4) check if it's text or binary.
    # if it's text, then do a bunch of searching for special tokens
    if (!defined $mtype) {
	$mtype = checktype_data($self, $data);
    }

    $mtype = 'text/plain' if (! defined $mtype);

    return $mtype;
}

sub checktype_magic {
    my $self = shift;
    my $data = shift;
    my $desc;
    my $mtype;

    return 'application/octet-stream' if (length($data) <= 0);

    # 3) iterate over each magic entry.
    my $m;
    for ($m = 0; $m <= $#{$self->{magic}}; $m++) {



	if (magicMatchStr($self->{magic}->[$m],\$desc,$data)) {
	    if (defined $desc && $desc ne '') {
		$mtype = $desc;
		last;
	    }
	}




	if ($m == $#{$self->{magic}} && !$self->{MF}->[0]->eof()) {
	    readMagicEntry($self->{magic}, $self->{MF});
	}
    }

    return $mtype;
}

sub checktype_data {
    my $self = shift;
    my $data = shift;
    my $mtype;

    return undef if (length($data) <= 0);

    # truncate data
    $data = substr($data, 0, 0x8564);

    # at first, check SPECIALS
    {


	my %val;
	foreach my $type (keys %{$self->{SPECIALS}}) {
	    my $matched_pos = undef;
	    foreach my $token (@{$self->{SPECIALS}->{$type}}){ 
		pos($data) = 0;
		if ($data =~ /$token/mg) {
		    my $tmp =  pos($data);
		    if ((! defined $matched_pos) || ($matched_pos > $tmp)) {
			$matched_pos = $tmp;
		    }
		}
	    }
	    $val{$type} = $matched_pos if $matched_pos;
	}

	if (%val) {
	    my @skeys = sort { $val{$a} <=> $val{$b} } keys %val;
	    $mtype = $skeys[0];
	}
	
    }
    if (! defined $mtype && check_binary($data)) {
	$mtype = "application/octet-stream";
    }
	
#    $mtype = 'text/plain' if (! defined $mtype);
    return $mtype;
}

sub checktype_byfilename {
    my $self = shift;
    my $fname = shift;
    my $type;

    $fname =~ s/^.*\///;
    for my $regex (keys %{$self->{FILEEXTS}}) {
	if ($fname =~ /$regex/i) {
	    if ((defined $type && $type !~ /;/) || (! defined $type)) {
		$type = $self->{FILEEXTS}->{$regex}; # has no x-type param
	    }
	}
    }
    $type = 'application/octet-stream' unless defined $type;
    return $type;
}

sub check_binary {
    my ($data) = @_;
    my $len = length($data);
    if ($allowEightbit) {
	my $count = ($data =~ tr/\x00-\x08\x0b-\x0c\x0e-\x1a\x1c-\x1f//); # exclude TAB, ESC, nl, cr
        return 1 if ($len <= 0); # no contents
        return 1 if (($count/$len) > 0.1); # binary
    } else {
	my $count = ($data =~ tr/\x00-\x08\x0b-\x0c\x0e-\x1a\x1c-\x1f\x80-\xff//); # exclude TAB, ESC, nl, cr
        return 1 if ($len <= 0); # no contents
        return 1 if (($count/$len) > 0.3); # binary
    }
    return 0;
}

sub check_magic {
    my $self = shift @_;
    # read the whole file if we haven't already
    while (!$self->{MF}->[0]->eof()) {
	readMagicEntry($self->{magic}, $self->{MF});
    }
    dumpMagic($self->{magic});
}

####### SUBROUTINES ###########

# compare the magic item with the filehandle.
# if success, print info and return true.  otherwise return undef.
#
# this is called recursively if an item has subitems.
sub magicMatch {
    my ($item, $p_desc, $fh) = @_;

    # delayed evaluation.  if this is our first time considering
    # this item, then parse out its structure.  @$item is just the
    # raw string, line number, and subtests until we need the real info.
    # this saves time otherwise wasted parsing unused subtests.
    $item = readMagicLine(@$item) if @$item == 3;

    # $item could be undef if we ran into troubles while reading
    # the entry.
    return unless defined($item);

    # $fh is not be defined if -c.  that way we always return
    # false for every item which allows reading/checking the entire
    # magic file.
    return unless defined($fh);
    
    my ($offtype, $offset, $numbytes, $type, $mask, $op, $testval, 
	$template, $message, $subtests) = @$item;

    # bytes from file
    my $data;

    # set to true if match
    my $match = 0;

    # offset = [ off1, sz, template, off2 ] for indirect offset
    if ($offtype == 1) {
	my ($off1, $sz, $template, $off2) = @$offset;
	$fh->seek($off1,0) or return;
	if ($fh->read($data,$sz) != $sz) { return };
	$off2 += unpack($template,$data);
	$fh->seek($off2,0) or return;
    }
    elsif ($offtype == 2) {

	$fh->seek($offset,1) or return;
    }
    else {

	$fh->seek($offset,0) or return;
    }

    if ($type =~ /^string/) {



	if ($numbytes > 0) {
	    if ($fh->read($data,$numbytes) != $numbytes) { return; }
	}
	else {
	    my $ch = $fh->getc();
	    while (defined($ch) && $ch ne "\0" && $ch ne "\n") {
		$data .= $ch;
		$ch = $fh->getc();
	    }
	}


	if ($op eq '=') {
	    $match = ($data eq $testval);
	}
	elsif ($op eq '<') {
	    $match = ($data lt $testval);
	}
	elsif ($op eq '>') {
	    $match = ($data gt $testval);
	}


	if ($checkMagic) {
	    print STDERR "STRING: $data $op $testval => $match\n";
	}

    }
    else {



	if ($fh->read($data,$numbytes) != $numbytes) { return; }





	if (ref($template)) {
	    $data = unpack($$template[2],
			   pack($$template[1],
				unpack($$template[0],$data)));
	}
	else {
	    $data = unpack($template,$data);
	}


	if (defined($mask)) {
	    $data &= $mask;
	}


	if ($op eq '=') {
	    $match = ($data == $testval);
	}
	elsif ($op eq 'x') {
	    $match = 1;
	}
	elsif ($op eq '!') {
	    $match = ($data != $testval);
	}
	elsif ($op eq '&') {
	    $match = (($data & $testval) == $testval);
	}
	elsif ($op eq '^') {
	    $match = ((~$data & $testval) == $testval);
	}
	elsif ($op eq '<') {
	    $match = ($data < $testval);
	}
	elsif ($op eq '>') {
	    $match = ($data > $testval);
	}


	if ($checkMagic) {
	    print STDERR "NUMERIC: $data $op $testval => $match\n";
	}

    }

    if ($match) {



	if ($message =~ s/^\\b//) {
	    $$p_desc .= sprintf($message,$data);
	}
	else {
	    $$p_desc .= sprintf($message,$data) if $message;
	}

	my $subtest;
	foreach $subtest (@$subtests) {
	    magicMatch($subtest,$p_desc,$fh);
	}

	return 1;
    }
    
}

sub magicMatchStr {
    my ($item, $p_desc, $str) = @_;
    my $origstr = $str;

    # delayed evaluation.  if this is our first time considering
    # this item, then parse out its structure.  @$item is just the
    # raw string, line number, and subtests until we need the real info.
    # this saves time otherwise wasted parsing unused subtests.
    if (@$item == 3){
	my $tmp = readMagicLine(@$item);



	return unless defined($tmp);

	@$item = @$tmp;
    }

    # $fh is not be defined if -c.  that way we always return
    # false for every item which allows reading/checking the entire
    # magic file.
    return unless defined($str);
    return if ($str eq '');
    
    my ($offtype, $offset, $numbytes, $type, $mask, $op, $testval, 
	$template, $message, $subtests) = @$item;
    return unless defined $op;

    # bytes from file
    my $data;

    # set to true if match
    my $match = 0;

    # offset = [ off1, sz, template, off2 ] for indirect offset
    if ($offtype == 1) {
	my ($off1, $sz, $template, $off2) = @$offset;
	return if (length($str) < $off1);
	$data = pack("a$sz", $str);
	$off2 += unpack($template,$data);
	return if (length($str) < $off2);
    }
    elsif ($offtype == 2) {

	return;
    }
    else {

	return if ($offset > length($str));
	$str = substr($str, $offset);
    }

    if ($type =~ /^string/) {



	if ($numbytes > 0) {
	    $data = pack("a$numbytes", $str);
	}
	else {
	    $str =~ /^(.*)\0|$/;
	    $data = $1;
	}


	if ($op eq '=') {
	    $match = ($data eq $testval);
	}
	elsif ($op eq '<') {
	    $match = ($data lt $testval);
	}
	elsif ($op eq '>') {
	    $match = ($data gt $testval);
	}


	if ($checkMagic) {
	    print STDERR "STRING: $data $op $testval => $match\n";
	}

    }
    else {



        return if (length($str) < 4);
	$data = substr($str, 0, 4);





	if (ref($template)) {
	    $data = unpack($$template[2],
			   pack($$template[1],
				unpack($$template[0],$data)));
	}
	else {
	    $data = unpack($template,$data);
	}


	if (defined($mask)) {
	    $data &= $mask;
	}


	if ($op eq '=') {
	    $match = ($data == $testval);
	}
	elsif ($op eq 'x') {
	    $match = 1;
	}
	elsif ($op eq '!') {
	    $match = ($data != $testval);
	}
	elsif ($op eq '&') {
	    $match = (($data & $testval) == $testval);
	}
	elsif ($op eq '^') {
	    $match = ((~$data & $testval) == $testval);
	}
	elsif ($op eq '<') {
	    $match = ($data < $testval);
	}
	elsif ($op eq '>') {
	    $match = ($data > $testval);
	}


	if ($checkMagic) {
	    print STDERR "NUMERIC: $data $op $testval => $match\n";
	}

    }

    if ($match) {



	if ($message =~ s/^\\b//) {
	    $$p_desc .= sprintf($message,$data);
	}
	else {
	    $$p_desc .= sprintf($message,$data) if $message;
	}

	my $subtest;
	foreach $subtest (@$subtests) {
	    # finish evaluation when matched.
	    magicMatchStr($subtest,$p_desc,$origstr);
	}

	return 1;
    }
    
}

# readMagicEntry($pa_magic, $MF, $depth)
#
# reads the next entry from the magic file and stores it as
# a ref to an array at the end of @$pa_magic.
#
# $MF = [ filehandle, last buffered line, line count ]
#
# This is called recursively with increasing $depth to read in sub-clauses
#
# returns the depth of the current buffered line.
#
sub readMagicEntry {
    my ($pa_magic, $MF, $depth) = @_;

    # for some reason I need a local var because <$$MF[0]> doesn't work.(?)
    my $magicFH = $$MF[0];

    # a ref to an array containing a magic line's components
    my ($entry, $line);

    $line = $$MF[1];
    while (1) {
	$line = '' if (! defined $line);
	if ($line =~ /^\#/ || $line =~ /^\s*$/) {
	    last if $magicFH->eof();
	    $line = <$magicFH>;
	    $$MF[2]++;
	    next;
	}
	
	my ($thisDepth) = ($line =~ /^(>+)/);
	$thisDepth = '' if (! defined $thisDepth);
	$depth = 0 if (! defined $depth);

	if (length($thisDepth) > $depth) {
	    $$MF[1] = $line;

	    # call ourselves recursively.  will return the depth
	    # of the entry following the nested group.
	    if ((readMagicEntry($entry->[2], $MF, $depth+1) || 0) < $depth ||
		$$MF[0]->eof())
	    {
		return;
	    }
	    $line = $$MF[1];
	}
	elsif (length($thisDepth) < $depth) {
	    $$MF[1] = $line;
	    return length($thisDepth);
	}
	elsif (defined(@$entry)) {
	    # already have an entry.  this is not a continuation.
	    # save this line for the next call and exit.
	    $$MF[1] = $line;
	    return length($thisDepth);
	}
	else {
	    # we're here if the number of '>' is the same as the
	    # current depth and we haven't read a magic line yet.

	    # create temp entry
	    # later -- if we ever get around to evaluating this condition --
	    # we'll replace @$entry with the results from readMagicLine.
	    $entry = [ $line , $$MF[2], [] ];

	    # add to list
	    push(@$pa_magic,$entry);

	    # read the next line
	    last if $magicFH->eof();
	    $line = <$magicFH>;
	    $$MF[2]++;
	}
    }
}

# readMagicLine($line, $line_num, $subtests)
#
# parses the match info out of $line.  Returns a reference to an array.
#
#  Format is:
#
# [ offset, bytes, type, mask, operator, testval, template, sprintf, subtests ]
#     0      1      2       3        4         5        6        7      8
#
# subtests is an array like @$pa_magic.
#
sub readMagicLine {
    my ($line, $line_num, $subtests) = @_;

    my ($offtype, $offset, $numbytes, $type, $mask, 
	$operator, $testval, $template, $message);
    
    # this would be easier if escaped whitespace wasn't allowed.

    # grab the offset and type.  offset can either be a decimal, oct,
    # or hex offset or an indirect offset specified in parenthesis
    # like (x[.[bsl]][+-][y]), or a relative offset specified by &.
    # offtype : 0 = absolute, 1 = indirect, 2 = relative
    if ($line =~ s/^>*([&\(]?[a-flsx\.\+\-\d]+\)?)\s+(\S+)\s+//) {
	($offset,$type) = ($1,$2);

	if ($offset =~ /^\(/) {
	    # indirect offset.  
	    $offtype = 1;

	    # store as a reference [ offset1 type template offset2 ]

	    my ($o1,$type,$o2);
	    if (($o1,$type,$o2) = ($offset =~ /\((\d+)(\.[bsl])?([\+\-]?\d+)?\)/))
	    {
		$o1 = oct($o1) if $o1 =~ /^0/o;
		$o2 = oct($o2) if $o2 =~ /^0/o;

		$type =~ s/\.//;
		if ($type eq '') { $type = 'l'; }  # default to long
		$type =~ tr/b/c/; # type will be template for unpack

		my $sz = $type;	  # number of bytes
		$sz =~ tr/csl/124/;

		$offset = [ $o1,$sz,$type,int($o2) ];
	    } else {
		warn "Bad indirect offset at line $line_num. '$offset'\n";
		return;
	    }
	}
	elsif ($offset =~ /^&/o) {
	    # relative offset
	    $offtype = 2;

	    $offset = substr($offset,1);
	    $offset = oct($offset) if $offset =~ /^0/o;
	}
	else {
	    # normal absolute offset
	    $offtype = 0;

	    # convert if needed
	    $offset = oct($offset) if $offset =~ /^0/o;
	}
    }
    else {
	warn "Bad Offset/Type at line $line_num. '$line'\n";
	return;
    }
    
    # check for & operator on type
    if ($type =~ s/&(.*)//) {
	$mask = $1;


	$mask = oct($mask) if $mask =~ /^0/o;
    }
    
    # check if type is valid
    if (!exists($TEMPLATES{$type}) && $type !~ /^string/) {
	warn "Invalid type '$type' at line $line_num\n";
	return;
    }
    
    # take everything after the first non-escaped space
    if ($line =~ s/([^\\])\s+(.*)/$1/) {
	$message = $2;
    }
    else {
	warn "Missing or invalid test condition or message at line $line_num\n";
	return;
    }
    
    # remove the return if it's still there
    $line =~ s/\n$//o;

    # get the operator.  if 'x', must be alone.  default is '='.
    if ($line =~ s/^([><&^=!])//o) {
	$operator = $1;
    }
    elsif ($line eq 'x') {
	$operator = 'x';
    }
    else { $operator = '='; }
    

    if ($type =~ /string/) {
	$testval = $line;


	$testval =~ s/\\([x0-7][0-7]?[0-7]?)/chr(oct($1))/eg;


	$testval =~ s/\\(.)/$ESC{$1}||$1/eg;



	if ($operator =~ /[>x]/o) {
	    $numbytes = 0;
	}
	elsif ($operator =~ /[=<]/o) {
	    $numbytes = length($testval);
	}
	elsif ($operator eq '!') {
	    # annoying special case.  ! operator only applies to numerics so
	    # put it back.
	    $testval = $operator . $testval;
	    $numbytes = length($testval);
	    $operator = '=';
	}
	else {
	    # there's a bug in my magic file where there's
	    # a line that says "0	string	^!<arc..." and the BSD
	    # file program treats the argument like a numeric.  To minimize
	    # hassles, complain about bad ops only if -c is set.
	    warn "Invalid operator '$operator' for type 'string' at line $line_num.\n"
	      if $checkMagic;
	    return;
	}
    }
    else {

	if ($operator ne 'x') {
	    # this conversion is very forgiving.  it's faster and
	    # it doesn't complain about bugs in popular magic files,
	    # but it will silently turn a string into zero.
	    if ($line =~ /^0/o) {
		$testval = oct($line);
	    } else {
		$testval = int($line);
	    }
	}

	($template,$numbytes) = @{$TEMPLATES{$type}};


	if (ref($template)) {
	    $template = $$template[0]
	      unless $operator eq '>' || $operator eq '<';
	}
    }
    
    return [ $offtype, $offset, $numbytes, $type, $mask,
	    $operator, $testval, $template, $message, $subtests ];
}

# recursively write the magic file to stderr.  Numbers are written
# in decimal.
sub dumpMagic {
    my ($magic,$depth) = @_;
    $magic = [] unless defined $magic;
    $depth = 0 unless defined $depth;

    my $entry;
    foreach $entry (@$magic) {

	$entry = readMagicLine(@$entry) if @$entry == 3;

	next if !defined($entry);

	my ($offtype, $offset, $numbytes, $type, $mask, $op, $testval, 
	    $template, $message, $subtests) = @$entry;

	print STDERR '>'x$depth;
	if ($offtype == 1) {
	    $offset->[2] =~ tr/c/b/; 
	    print STDERR "($offset->[0].$offset->[2]$offset->[3])";
	}
	elsif ($offtype == 2) {
	    print STDERR "&",$offset;
	}
	else {
	    # offtype == 0
	    print STDERR $offset;
	}
	print STDERR "\t",$type;
	if ($mask) { print STDERR "&",$mask; }
	print STDERR "\t",$op,$testval,"\t",$message,"\n";

	if ($subtests) {
	    dumpMagic($subtests,$depth+1);
	}
    }
}

1;

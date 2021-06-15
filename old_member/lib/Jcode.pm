#
# Id: Jcode.pm,v 2.5 2006/05/16 05:00:19 dankogai Exp dankogai $
# $Id: Jcode.pm,v 1.52 2007/07/15 07:40:08 papu Exp $
# "Jcode.pm" version 2.5 $$
#

package Jcode;
use 5.005; # fair ?
use Carp;
use strict;
use vars qw($RCSID $VERSION $DEBUG);

$RCSID = q$Id: Jcode.pm,v 1.52 2007/07/15 07:40:08 papu Exp $;
$VERSION = do { my @r = (q$Revision: 1.52 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
$DEBUG = 0;

# we no longer use Exporter
use vars qw($USE_ENCODE);
$USE_ENCODE = ($] >= 5.008001);

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA         = qw(Exporter);
@EXPORT      = qw(jcode getcode);
@EXPORT_OK   = qw($RCSID $VERSION $DEBUG);
%EXPORT_TAGS = ( all       => [ @EXPORT, @EXPORT_OK ] );

use overload 
    q("") => sub { $_[0]->euc },
    q(==) => sub { overload::StrVal($_[0]) eq overload::StrVal($_[1]) },
    q(.=) => sub { $_[0]->append( $_[1] ) },
    fallback => 1,
    ;

if ($USE_ENCODE){
    $DEBUG and warn "Using Encode";
    my $data = join("", <DATA>);
    eval $data;
    $@ and die $@;
}else{
    $DEBUG and warn "Not Using Encode";
    require Jcode::_Classic;
    use vars qw/@ISA/;
    unshift @ISA, qw/Jcode::_Classic/;
    for my $sub (qw/jcode getcode convert load_module/){
	no strict 'refs';
	*{$sub} = \&{'Jcode::_Classic::' . $sub };
    }
    for my $enc (qw/sjis jis ucs2 utf8/){
	no strict 'refs';
	*{"euc_" . $enc} = \&{"Jcode::_Classic::" . "euc_" . $enc};
	*{$enc . "_euc"} = \&{"Jcode::_Classic::" . $enc . "_euc"};
    }
}

1;
__DATA__
#
# This idea was inspired by JEncode
# http://www.donzoko.net/cgi/jencode/
#
package Jcode;
use Encode;
use Encode::Alias;
use Encode::Guess;
use Encode::JP::H2Z;
use Scalar::Util; # to resolve from_to() vs. 'constant' issue.

my %jname2e = (
	       sjis        => 'shiftjis',
	       euc         => 'euc-jp',
	       jis         => '7bit-jis',
	       iso_2022_jp => 'iso-2022-jp',
	       ucs2        => 'UTF-16BE',
	      );

my %ename2j = reverse %jname2e;

our $FALLBACK = Encode::LEAVE_SRC;
sub FB_PERLQQ()   { Encode::FB_PERLQQ() };
sub FB_XMLCREF()  { Encode::FB_XMLCREF() };
sub FB_HTMLCREF() { Encode::FB_HTMLCREF() };
#for my $fb (qw/FB_PERLQQ FB_XMLCREF FB_HTMLCREF/){
#    no strict 'refs';
#    *{$fb} = \&{"Encode::$fb"};
#}


#######################################
# Functions
#######################################

sub jcode { return __PACKAGE__->new(@_); }

#
# Used to be in Jcode::Constants
#

my %_0208 = (
	     1978 => '\e\$\@',
	     1983 => '\e\$B',
	     1990 => '\e&\@\e\$B',
	    );
my %RE = (
       ASCII     => '[\x00-\x7f]',
       BIN       => '[\x00-\x06\x7f\xff]',
       EUC_0212  => '\x8f[\xa1-\xfe][\xa1-\xfe]',
       EUC_C     => '[\xa1-\xfe][\xa1-\xfe]',
       EUC_KANA  => '\x8e[\xa1-\xdf]',
       JIS_0208  =>  "$_0208{1978}|$_0208{1983}|$_0208{1990}",
       JIS_0212  => "\e" . '\$\(D',
       JIS_ASC   => "\e" . '\([BJ]',     
       JIS_KANA  => "\e" . '\(I',
       SJIS_C    => '[\x81-\x9f\xe0-\xfc][\x40-\x7e\x80-\xfc]',
       SJIS_KANA => '[\xa1-\xdf]',
       UTF8      => '[\xc0-\xdf][\x80-\xbf]|[\xe0-\xef][\x80-\xbf][\x80-\xbf]'
      );

sub _max {
    my $result = shift;
    for my $n (@_){
	$result = $n if $n > $result;
    }
    return $result;
}

sub getcode {
    my $arg = shift;
    my $r_str = ref $arg ? $arg : \$arg;
    Encode::is_utf8($$r_str) and return 'utf8';
    my ($code, $nmatch, $sjis, $euc, $utf8) = ("", 0, 0, 0, 0);
    if ($$r_str =~ /$RE{BIN}/o) {
	my $ucs2;
	$ucs2 += length($1)
	    while $$r_str =~ /(\x00$RE{ASCII})+/go;
	if ($ucs2){      # smells like raw unicode 
	    ($code, $nmatch) = ('ucs2', $ucs2);
	}else{
	    ($code, $nmatch) = ('binary', 0);
	 }
    }
    elsif ($$r_str !~ /[\e\x80-\xff]/o) {
	($code, $nmatch) = ('ascii', 1);
    }
    elsif ($$r_str =~ 
	   m[
	     $RE{JIS_0208}|$RE{JIS_0212}|$RE{JIS_ASC}|$RE{JIS_KANA}
	   ]ox)
    {
	($code, $nmatch) = ('jis', 1);
    } 
    else { # should be euc|sjis|utf8

	$sjis += length($1) 
	    while $$r_str =~ /((?:$RE{SJIS_C})+)/go;
	$euc  += length($1) 
	    while $$r_str =~ /((?:$RE{EUC_C}|$RE{EUC_KANA}|$RE{EUC_0212})+)/go;
	$utf8 += length($1) 
	    while $$r_str =~ /((?:$RE{UTF8})+)/go;

	$nmatch = _max($utf8, $sjis, $euc);
	carp ">DEBUG:sjis = $sjis, euc = $euc, utf8 = $utf8" if $DEBUG >= 3;
	$code = 
	    ($euc > $sjis and $euc > $utf8) ? 'euc' :
		($sjis > $euc and $sjis > $utf8) ? 'sjis' :
		    ($utf8 > $euc and $utf8 > $sjis) ? 'utf8' : undef;
    }
    return wantarray ? ($code, $nmatch) : $code;
}

sub convert{
    my $r_str = (ref $_[0]) ? $_[0] : \$_[0];
    my (undef,$ocode,$icode,$opt) = @_;
    Encode::is_utf8($$r_str) and utf8::encode($$r_str);
    defined $icode or $icode = getcode($r_str) or return;
    $icode eq 'binary' and return $$r_str;

    $jname2e{$icode} and $icode = $jname2e{$icode};
    $jname2e{$ocode} and $ocode = $jname2e{$ocode};

    if ($opt){
	return $opt eq 'z' 
	    ? jcode($r_str, $icode)->h2z->$ocode
		: jcode($r_str, $icode)->z2h->$ocode ;
	    
    }else{
	if (Scalar::Util::readonly($$r_str)){
	    my $tmp = $$r_str;
	    Encode::from_to($tmp, $icode, $ocode);
	    return $tmp;
	}else{
	    Encode::from_to($$r_str, $icode, $ocode);
	    return $$r_str;
	}
    }
}

#######################################
# Constructors
#######################################

sub new{
    my $class = shift;
    my $self  = {};
    bless $self => $class;
    defined $_[0] or $_[0] = '';
    $self->set(@_);
}

sub set{
    my $self  = shift;
    my $str   = $_[0];
    my $r_str = (ref $str) ? $str : \$str;
    my $code  = $_[1] if(defined $_[1]);
    my $icode =  $code || getcode($r_str) || 'euc';
    $self->{icode}  = $jname2e{$icode} || $icode;
    # binary and flagged utf8 are stored as-is
    unless (Encode::is_utf8($$r_str) || $icode eq 'binary'){
	$$r_str = decode($self->{icode}, $$r_str);
    }
    $self->{r_str}  = $r_str;
    $self->{nmatch} = 0;
    $self->{method} = 'Encode';
    $self->{fallback} = $FALLBACK;
    $self;
}

sub append{
    my $self  = shift;
    my $str   = $_[0];
    my $r_str = (ref $str) ? $str : \$str;
    my $code  = $_[1] if(defined $_[1]);
    my $icode =  $code || getcode($r_str) || 'euc';
    $self->{icode}  = $jname2e{$icode} || $icode;
    # binary and flagged utf8 are stored as-is
    unless (Encode::is_utf8($$r_str) || $icode eq 'binary'){
	$$r_str = decode($self->{icode}, $$r_str);
    }
    ${ $self->{r_str} }  .= $$r_str;
    $self->{nmatch} = 0;
    $self->{method} = 'internal';
    $self;
}

#######################################
# Accessors
#######################################

for my $method (qw/r_str icode nmatch error_m error_r error_tr/){
    no strict 'refs';
    *{$method} = sub { $_[0]->{$method} };
}

sub fallback{
    my $self = shift;
    @_ or return $self->{fallback};
    $self->{fallback} =  $_[0]|Encode::LEAVE_SRC;
    return $self;
}

#######################################
# Converters
#######################################

sub utf8 { encode_utf8( ${$_[0]->{r_str}} ) }

#
#  Those supported in Jcode 0.x are defined as default
#

for my $enc (keys %jname2e){
    no strict 'refs';
    my $name = $jname2e{$enc} || $enc;
    my $e = find_encoding($name) or croak "$enc not supported";
    *{$enc} = sub {
	my $r_str = $_[0]->{r_str};
	Encode::is_utf8($$r_str) ? 
		$e->encode($$r_str, $_[0]->{fallback}) : $$r_str;
    };
}

#
# The rest is defined on the fly
#

sub DESTROY {};

sub AUTOLOAD {
    our $AUTOLOAD;
    my $self = shift;
    my $type = ref $self
        or confess "$self is not an object";
    my $myname = $AUTOLOAD;
    $myname =~ s/.*:://;  # strip fully-qualified portion
    $myname eq 'DESTROY' and return;
    my $e = find_encoding($myname) 
	or confess __PACKAGE__, ": unknown encoding: $myname";
    $DEBUG and warn ref($self), "->$myname defined";
    no strict 'refs';
    *{$myname} =
	sub {
	    my $str = ${ $_[0]->{r_str} };
            Encode::is_utf8($str) ?
		      $e->encode($str, $_[0]->{fallback}) : $str;
	  };
    $myname->($self);
}

#######################################
# Length, Translation and Fold
#######################################

sub jlength{
    length(  ${$_[0]->{r_str}} );
}

sub tr{
    my $self = shift;
    my $str  = ${$self->{r_str}};
    my $from = Encode::is_utf8($_[0]) ? $_[0] : decode('euc-jp', $_[0]);
    my $to   = Encode::is_utf8($_[1]) ? $_[1] : decode('euc-jp', $_[1]);
    my $opt  = $_[2] || '';
    $from =~ s,\\,\\\\,og; $from =~ s,/,\\/,og;
    $to   =~ s,\\,\\\\,og; $to   =~ s,/,\\/,og;
    my $match = eval qq{ \$str =~ tr/$from/$to/$opt };
    if ($@){
        $self->{error_tr} = $@;
        return $self;
    }
    $self->{r_str} = \$str;
    $self->{nmatch} = $match || 0;
    return $self;
}

sub jfold{
    my $self = shift;
    my $r_str  = $self->{r_str};
    my $bpl = shift || 72;
    my $nl  = shift || "\n";
    my $kin = shift;

    my @lines = ();
    my %kinsoku = ();
    my ($len, $i) = (0,0);

    if( defined $kin and (ref $kin) eq 'ARRAY' ){
	%kinsoku = map { my $k = Encode::is_utf8($_) ? 
			     $_ : decode('euc-jp' =>  $_);
			 ($k, 1) } @$kin;
    }

    while($$r_str =~ m/(.)/sg){
	my $char = $1;


	my $ord = ord($char);
	my $clen =  $ord < 128 ? 1
	    : $ord <  0xff61 ? 2 
	    : $ord <= 0xff9f ? 1 : 2; 
	if ($len + $clen > $bpl){
	    unless($kinsoku{$char}){
		$i++; 
		$len = 0;
	    }
	}
	$lines[$i] .= $char;
	$len += $clen;
    }
    defined($lines[$i]) or pop @lines;
    $$r_str = join($nl, @lines);

    $self->{r_str} = $r_str;
    my $e = find_encoding($self->{icode});
    @lines = map {
	Encode::is_utf8($_) ? $e->encode($_, $self->{fallback}) : $_
    } @lines;

    return wantarray ? @lines : $self;
}

#######################################
# Full and Half
#######################################

sub h2z{
    my $self = shift;
    my $euc  = $self->euc;
    Encode::JP::H2Z::h2z(\$euc, @_);
    $self->set($euc => 'euc');
    $self;
}

sub z2h{
    my $self = shift;
    my $euc =  $self->euc;
    Encode::JP::H2Z::z2h(\$euc, @_);
    $self->set($euc => 'euc');
    $self;
}

#######################################
# MIME-Encoding
#######################################

sub mime_decode{
    my $self = shift;
    my $utf8  = Encode::decode('MIME-Header', $self->utf8);
    $self->set($utf8 =>'utf8');
}

sub mime_encode{
    my $self = shift;
    my $str = $self->euc;
    my $r_str = \$str;
    my $lf  = shift || "\n";
    my $bpl = shift || 76;
    my ($trailing_crlf) = ($$r_str =~ /(\n|\r|\x0d\x0a)$/o);
    $str  = _mime_unstructured_header($$r_str, $lf, $bpl);
    not $trailing_crlf and $str =~ s/(\n|\r|\x0d\x0a)$//o;
    $str;
}

#
# shamelessly stolen from
# http://www.din.or.jp/~ohzaki/perl.htm#JP_Base64
#

sub _add_encoded_word {
    require MIME::Base64;
    my($str, $line, $bpl) = @_;
    my $result = '';
    while (length($str)) {
	my $target = $str;
	$str = '';
	if (length($line) + 22 +
	    ($target =~ /^(?:$RE{EUC_0212}|$RE{EUC_C})/o) * 8 > $bpl) {
	    $line =~ s/[ \t\n\r]*$/\n/;
	    $result .= $line;
	    $line = ' ';
	}
	while (1) {
	    my $iso_2022_jp = jcode($target, 'euc')->iso_2022_jp;
	    if (my $count = ($iso_2022_jp =~ tr/\x80-\xff//d)){
		$DEBUG and warn $count;
		$target = jcode($iso_2022_jp, 'iso_2022_jp')->euc;
	    }
	    my $encoded = '=?ISO-2022-JP?B?' .
	      MIME::Base64::encode_base64($iso_2022_jp, '')
		      . '?=';
	    if (length($encoded) + length($line) > $bpl) {
		$target =~ 
		    s/($RE{EUC_0212}|$RE{EUC_KANA}|$RE{EUC_C}|$RE{ASCII})$//o;
		$str = $1 . $str;
	    } else {
		$line .= $encoded;
		last;
	    }
	}
    }
    return $result . $line;
}

sub _mime_unstructured_header {
    my ($oldheader, $lf, $bpl) = @_;
    my(@words, @wordstmp, $i);
    my $header = '';
    $oldheader =~ s/\s+$//;
    @wordstmp = split /\s+/, $oldheader;
    for ($i = 0; $i < $#wordstmp; $i++) {
	if ($wordstmp[$i] !~ /^[\x21-\x7E]+$/ and
	    $wordstmp[$i + 1] !~ /^[\x21-\x7E]+$/) {
	    $wordstmp[$i + 1] = "$wordstmp[$i] $wordstmp[$i + 1]";
	} else {
	    push(@words, $wordstmp[$i]);
	}
    }
    push(@words, $wordstmp[-1]);
    for my $word (@words) {
	if ($word =~ /^[\x21-\x7E]+$/) {
	    $header =~ /(?:.*\n)*(.*)/;
	    if (length($1) + length($word) > $bpl) {
		$header .= "$lf $word";
	    } else {
		$header .= $word;
	    }
	} else {
	    $header = _add_encoded_word($word, $header, $bpl);
	}
	$header =~ /(?:.*\n)*(.*)/;
	if (length($1) == $bpl) {
	    $header .= "$lf ";
	} else {
	    $header .= ' ';
	}
    }
    $header =~ s/\n? $/\n/;
    $header;
}

#######################################
# Matching and Replacing
#######################################

no warnings 'uninitialized';

sub m{
    use utf8;
    my $self    = shift;
    my $r_str   = $self->{r_str};
    my $pattern = Encode::is_utf8($_[0]) ? shift : decode("euc-jp" => shift);
    my $opt     = shift || '' ;
    my @match;
    
    eval qq{ \@match = (\$\$r_str =~ m/$pattern/$opt) };
    if ($@){
	$self->{error_m} = $@;
	return;
    }
    # print @match, "\n";
    wantarray ?  map {encode('euc-jp' => $_)} @match : scalar @match;
}

sub s{
    use utf8;
    my $self    = shift;
    my $r_str   = $self->{r_str};
    my $pattern = Encode::is_utf8($_[0]) ? shift : decode("euc-jp" => shift);
    my $replace = Encode::is_utf8($_[0]) ? shift : decode("euc-jp" => shift);
    my $opt     = shift;
    eval qq{ (\$\$r_str =~ s/$pattern/$replace/$opt) };
    if ($@){
	$self->{error_s} = $@;
    }
    $self;
}

1;
__END__




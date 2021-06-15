######################################################################
# attach.inc.pl - This is PyukiWiki, yet another Wiki clone.
# $Id: attach.inc.pl,v 1.77 2007/07/15 07:40:09 papu Exp $
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

#use strict;
use CGI qw(:standard);
use Digest::MD5 qw(md5_hex);
#use Digest::Perl::MD5 qw(md5_hex);
# if your system has not Digest::MD5, swap comment.
use File::MMagic;

@magic_files=(


	"$::explugin_dir/File/magic.txt",
	"$::explugin_dir/File/magic_compact.txt",
	"/etc/magic",
	"/usr/etc/magic",
	"/usr/share/etc/magic",
	"/usr/share/misc/magic",
);


my %mime = (

	'\.(zip|nar|jar)'	=> "application/x-zip|ZIP",
	'\.(lzh|lha)'		=> "application/x-lha|LHa",
	'\.(tgz|gz)'		=> "application/x-gzip|gzip compressed data",
	'\.(bz|tbz|bz2)'	=> "application/x-bzip2|bzip2 compressed data",
	'\.tar'				=> "application/x-tar|tar archive",
	'\.cab'				=> "application/octet-stream|Cabinet",
	'\.rar'				=> "application/octet-stream|RAR",
	'\.7z'				=> "application/octet-stream|7z",
	'\.hqx'				=> "application/mac-binhex40|BinHex",
	'\.sit'				=> "application/x-stuffit|StuffIt",


	'\.(do[ct]|docx)'		=> "application/msword|Word|Office",
	'\.(ppt|pps|pot|pptx)'	=> "application/mspowerpoint|Office",
	'\.(xls|csv|xlsx)'		=> "application/vnd.ms-excel|Excel|Office",
	'\.mpp'				=> "application/vnd.ms-project|Office", # project

	'\.(md[baentwz])'	=> "application/vnd.ms-access|G3", # access
	'\.(vs[dstw])'		=> "application/vnd.ms-visio|Office", # visio
	'\.pub'				=> "application/vnd.ms-publisher|Office", # publisher
	'\.one'				=> "application/vnd.ms-onenote|data", # one note


	'\.odb'				=> "application/vnd.sun.xml.base|Zip",
	'\.(o[dt]s)|(s[tx]c)'=>"application/vnd.sun.xml.calc|Zip",
	'\.(o[dt]g)|(s[tx]d)'=>"application/vnd.sun.xml.draw|Zip",
	'\.(o[dt]p)|(s[tx]i)'=>"application/vnd.sun.xml.impress|Zip",
	'\.(odf)(sxm)'		=> "application/vnd.sun.xml.math|Zip",
	'\.(o[dt]t)|(s[tx]w)'=>"application/vnd.sun.xml.writer|Zip",


	'\.pdf'				=> "application/pdf|PDF document",
	'\.swf'				=> "application/x-shockwave-flash|Flash",
	'\.iso'				=> "application/octet-stream|ISO",


	'\.(midi?|kar|rmi)'	=> "audio/midi|audio/unknown|MIDI",
	'\.(mp[23]|mpga)'	=> "audio/mpeg|MP3|MPEG|audio|voice",
	'\.(wav|wma)'		=> "audio/x-wav|PCM|ITU|GSM|MPEG|audio|voice",
	'\.(aif[fc]?)'		=> "audio/x-aiff|AIFF|audio|voice|patch",
	'\.ram?'			=> "audio/x-pn-realaudio|Real",
	'\.ogg'				=> "application/ogg|Ogg",
	'\.(au|snd)'		=> "audio/basic|audio",


	'\.mmf'				=> "application/vnd.smaf|SMAF", #Voda/au/Tu-Ka


	'\.bmp'				=> "image/bmp|bitmap",
	'\.gif'				=> "image/gif|GIF",
	'\.jpe?g'			=> "image/jpeg|JPEG",
	'\.png'				=> "image/png|PNG",
	'\.tiff?'			=> "image/tiff|TIFF",


	'\.mpe?g'			=> "video/mpeg|MPEG|Microsoft|ASF|AVI|Div|video",
	'\.(avi|asf|wmv)'	=> "video/x-msvideo|Microsoft|ASF",
	'\.rmm?'			=> "application/vnd.rn-realmedia|Real",
	'\.(qt|mov)'		=> "video/quicktime|Apple|QuickTime",


	'\.txt'				=> "text/plain|text",
	'\.([ch]p?p?)'		=> "text/plain|text",
	'\.(js)'			=> "text/x-javascript|text",
	'\.(cgi|p[lm])'		=> "text/plain|text",
	'\.(php|rb)'		=> "text/plain|text",







);

#--------------------------------------------------------
# 2005.12.19 pochi: mod_perlで実行可能に {
$::functions{"md5_file"} = \&md5_file;
$::functions{"attach_mime_content_type"} = \&attach_mime_content_type;
$::functions{"attach_magic"} = \&attach_magic;
$::functions{"attach_form"} = \&attach_form;
$::functions{"authadminpassword"} = \&authadminpassword;

# file icon image
if (!$::file_icon) {
	$::file_icon = '<img src="'
		. $::image_url
		. '/file.png" width="20" height="20" alt="file" style="border-width:0px" />';
}

sub attach_magic {
	my ($file)=@_;
	my $buf;
	my $magic_file;
	foreach(@magic_files) {
		if(-r $_) {
			my $mm = File::MMagic->new($_);
			if(open(R,$file)) {
				if(sysread(R,$buf,0x8564)) {
					close(R);
					return $mm->checktype_contents($buf);
				}
				close(R);
			}
		return "";
		}
	}
	return &attach_mime_content_type($file);
}

#-------- convert
sub plugin_attach_convert
{
	if (!$::file_uploads) {
		return 'file_uploads disabled';
	}

	my $nolist = 0;
	my $noform = 0;

	my @arg = split(/,/, shift);
	if (@arg > 0) {
		foreach (@arg) {
			$_ = lc $_;
			$nolist |= ($_ eq 'nolist');
			$noform |= ($_ eq 'noform');
		}
	}
	my $ret = '';
	if (!$nolist) {


	}
	if (!$noform) {
		$ret .= &attach_form($::form{mypage});
	}
	return $ret;
}

my %_attach_messages;

#アップロードフォーム
sub attach_form
{
	my $page = $::form{mypage};
	my $r_page = $page;
	my $s_page = &htmlspecialchars($page);
	my $navi =<<"EOD";
  <span class="small">
   [<a href="$::script?cmd=attach&amp;mypage=@{[&encode($page)]}&amp;pcmd=list&amp;refer=@{[&encode($r_page)]}">$::resource{'attach_plugin_msg_listpagelink'}</a>]
   [<a href="$::script?cmd=attach&amp;mypage=@{[&encode($page)]}&amp;pcmd=list">$::resource{'attach_plugin_msg_listall'}</a>]
  </span><br />
EOD
	return $navi if (!$::file_uploads);

	my $maxsize = $::max_filesize;
	my $msg_maxsize = $::resource{attach_plugin_msg_maxsize};
	my $kb = $maxsize / 1000 . "kb";

	$msg_maxsize =~ s/%s/$kb/g;

	my $pass = '';
	if ($::file_uploads == 2) {
		$pass='<br />' . &authadminpassword("input",$::resource{attach_plugin_msg_password},"attach");
	}
	return <<"EOD";
<form enctype="multipart/form-data" action="$::script" method="post">
 <div>
  <input type="hidden" name="cmd" value="attach" />
  <input type="hidden" name="pcmd" value="post" />
  <input type="hidden" name="refer" value="$s_page" />
  <input type="hidden" name="mypage" value="$page" />
  <input type="hidden" name="max_file_size" value="$maxsize" />
  $navi
  <span class="small">
   $msg_maxsize
  </span><br />
  $::resource{'attach_plugin_msg_file'}: <input type="file" name="attach_file" />
  $pass
  <input type="submit" value="$::resource{'attach_plugin_btn_upload'}" />
 </div>
</form>
EOD
}

sub plugin_attach_action
{

	if ($::form{'openfile'} ne '') {
		$::form{'pcmd'} = 'open';
		$::form{'file'} = $::from{'openfile'};
	}
	if ($::form{'delfile'} ne '') {
		$::form{'pcmd'} = 'delete';
		$::form{'file'} = $::form{'delfile'};
	}

	my $age = $::form{age} ? $::form{age} : 0;
	my $pcmd = $::form{pcmd} ? $::form{pcmd} : '';




	if ($::form{attach_file} ne '') {

		return &attach_upload($::form{attach_file}, $::form{refer}, $::form{mypassword});
	}

	if ($pcmd eq 'info') {
		return &attach_info;
	} elsif ($pcmd eq 'delete') {
		return &attach_delete;
	} elsif ($pcmd eq 'open') {
		return &attach_open;
	} elsif ($pcmd eq 'list') {
		return &attach_list;
	} elsif ($pcmd eq 'freeze') {
		return &attach_freeze(1);
	} elsif ($pcmd eq 'unfreeze') {
		return &attach_freeze(0);
	} elsif ($pcmd eq 'upload') {
		return &attach_showform;
	}
	return &attach_list if ($::form{mypage} eq '' or !$::database{$::form{mypage}});
	return ('msg'=>"$::form{mypage}\t$::resource{attach_plugin_msg_upload}", 'body'=>&attach_form, 'ispage'=>1);
}

# 詳細フォームを表示
sub attach_info
{
	my $obj = new AttachFile($::form{refer}, $::form{file}, $::form{age});
	return $obj->getstatus() ? $obj->info()
		: ('msg'=>$::form{refer}, 'body'=>"error:" . $::resource{attach_plugin_err_notfound}, 'ispage'=>1);
}

# 削除
sub attach_delete
{
	my %auth=&authadminpassword("input","","attach");
	if ($::file_uploads >= 2 && $auth{authed} eq 0) {
		return ('msg'=>$::form{refer}, 'body'=>$::resource{attach_plugin_err_password});
	}

	my $obj = new AttachFile($::form{refer}, $::form{file}, $::form{age});
	return $obj->getstatus()
		? $obj->delete()
		: ('msg'=>"$::form{mypage}\t$::resource{attach_plugin_err_notfound}",, 'body'=>&attach_form, 'ispage'=>1);
}

# ダウンロード
sub attach_open
{
	my $obj = new AttachFile($::form{refer}, $::form{file}, $::form{age});
	return $obj->getstatus() ? $obj->open()
		: ('msg'=>$::form{refer}, 'body'=>"error:" . $::resource{attach_plugin_err_notfound});
}

# 一覧取得
sub attach_list
{
	my $refer = $::form{refer};
	my $obj = new AttachPages($refer);
	my $msg = $refer eq '' ? "\t$::resource{attach_plugin_msg_listall}" : "$refer\t$::resource{attach_plugin_msg_listpage}";
	my $body = $obj->toString(0, 1);
	undef $obj;
	return ('msg'=>$msg,'body'=>$body, 'ispage'=>$refer eq '' ? 0 : 1);
}

# ファイルアップロード
sub attach_upload
{
	my ($filename, $page, $pass) = @_;

	my %auth=&authadminpassword("input","","attach");
	if ($::file_uploads == 2 && $auth{authed} eq 0) {
		return ('msg'=>$::form{mypage}, 'body'=>$::resource{attach_plugin_err_password});
	}
	my ($parsename, $path, $ffile);
	$parsename = $filename;
	$parsename =~ s#\\#/#g;
	$parsename =~ s/^http:\/\///;
	$parsename =~ /([^:\/]*)(:([0-9]+))?(\/.*)?$/;
	$path = $4 || '/';
	$path =~ /(.*\/)(.*)/;
	$ffile = $2;
	if($ffile eq '') {
		$ffile=$parsename;
		$ffile=~s/.*\///g;
	}
	$ffile =~ s/#.*$//;
	$ffile = &code_convert(\$ffile, $::defaultcode);

	my $obj = new AttachFile($page, $ffile);
	if ($obj->{exist}) {
		return ('msg'=>"$::form{mypage}\t$::resource{attach_plugin_err_exists}",'body'=>&attach_form);
	}

	unless (open (FILE, ">" . $obj->{filename})) {
		return('msg'=>$::form{mypage}, 'body'=>"$::resource{attach_plugin_err_upload}<br />$!:@{[$obj->{filename}]}");

		exit;
	}
	binmode(FILE);
	my $fsize = 0;
	my ($byte, $buffer);
	while ($byte = read($filename, $buffer, 1024)) {
		print FILE $buffer;
		$fsize += $byte;
		if ($fsize > $::max_filesize) {
			close FILE;
			unlink $obj->{filename};
			return ('msg'=>"\t$::resource{attach_plugin_err_exceed}",'body'=>&attach_form);
		}
	}
	close FILE;
	if(&attach_mime_content_type($ffile) eq '') {
		unlink $obj->{filename};
		return ('msg'=>"\t$::resource{attach_plugin_err_ignoretype}",'body'=>&attach_form);
	}
	my $flag=0;
	foreach(split(/\|/,&attach_mime_content_type($ffile,1))) {
		my $regex=lc $_;
		my $magic=lc &attach_magic($obj->{filename});
		$flag=1 if($magic=~/$regex/);
	}
	if($flag eq 0 && $::AttachFileCheck eq 1) {
		unlink $obj->{filename};
		return ('msg'=>"\t$::resource{attach_plugin_err_ignoremime}",'body'=>&attach_form);
	}
	return ('msg'=>"$::form{mypage}\t$::resource{attach_plugin_msg_uploaded}", 'body'=>&attach_form);


}

# ファイル名からmimeタイプ取得。
sub attach_mime_content_type
{
	my $filename = lc shift;
	my $check = shift;
	my $mime_type;
	foreach (keys %mime) {
		next unless ($_ && defined($mime{$_}));
		if ($filename =~ /$_$/i) {
			$mime_type = $mime{$_};
			last;
		}
	}
	$mime_type=~s/\|.*//g if($check+0 eq 0);
	return ($mime_type) ? $mime_type : ''; #default
}


# php互換関数。
sub md5_file {
	my ($path) = @_;
	open(FILE, $path);
	binmode(FILE);
	my $contents;
	read(FILE, $contents, $::max_filesize);
	close(FILE);
	return md5_hex($contents);
}

#----------------------------------------------------
# 1ファイル単位のコンテナ
package AttachFile;

sub dbmname {
	my $funcp = $::functions{"dbmname"};
	return &$funcp(@_);
}

sub md5_file {
	my $funcp = $::functions{"md5_file"};
	return &$funcp(@_);
}

sub htmlspecialchars {
	my $funcp = $::functions{"htmlspecialchars"};
	return &$funcp(@_);
}

sub attach_mime_content_type {
	my $funcp = $::functions{"attach_mime_content_type"};
	return &$funcp(@_);
}

sub attach_magic {
	my $funcp = $::functions{"attach_magic"};
	return &$funcp(@_);
}

sub encode {
	my $funcp = $::functions{"encode"};
	return &$funcp(@_);
}

sub http_header {
	my $funcp = $::functions{"http_header"};
	return &$funcp(@_);
}

sub authadminpassword {
	my $funcp = $::functions{"authadminpassword"};
	return &$funcp(@_);
}

sub attach_form {
	my $funcp = $::functions{"attach_form"};
	return &$funcp(@_);
}

sub code_convert {
	my $funcp = $::functions{"code_convert"};
	return &$funcp(@_);
}

sub new
{
	my $this = bless {};
	shift;
	$this->{page} = shift;
	$this->{file} = shift;
	$this->{age}  = shift;
	$this->{basename} = "$::upload_dir/"
		. &dbmname($this->{page}) . '_' . &dbmname($this->{file});
	$this->{filename} = $this->{basename} . ($this->{age} ? '.' . $this->{age} : '');
	$this->{exist} = (-e $this->{filename}) ? 1 : 0;
	$this->{logname}  = $this->{basename} . ".log";

	$this->{time} = (stat($this->{filename}))[10];
	$this->{md5hash} = ($this->{exist} == 1) ? &md5_file($this->{filename}) : '';
	return $this;
}

# 添付ファイルのオープン
sub open
{
	my $this = shift;
	my $query = new CGI;
	my $http_header;
	my $filename=$this->{file};


	if($filename=~/[\x81-\xfe]/) {
		if($ENV{HTTP_USER_AGENT}=~/Opera/) {
			$filename=&code_convert(\$filename,"utf8",$::defaultcode);
			$filename=qq(filename="$filename");
			$filename=~s/%2e/\./g;
		} elsif($ENV{HTTP_USER_AGENT}=~/MSIE/) {
			$filename=qq{filename="} . &code_convert(\$filename,"sjis") . qq{"};
		} else {
			$filename=&code_convert(\$filename,$::kanjicode);
			$filename=qq(filename="$filename");
		}
	} else {
		$filename=qq(filename="$filename");
	}
	$http_header=$query->header(
		-type=>"$this->{type}",
		-Content_disposition=>"attachment; $filename",
		-Content_length=>$this->{size},
		-expires=>"now",
		-P3P=>""
	);

	print &http_header($http_header);

	open(FILE, $this->{filename}) || die $!;
	binmode(FILE);
	my $buffer;
	print $buffer while (read(FILE, $buffer, 4096));
	close(FILE);
	exit;
}

# 情報表示
sub info
{
	my $this = shift;

	my $msg_delete = '<input type="radio" name="pcmd" value="delete" />'
		 . $::resource{attach_plugin_msg_delete} . $::resource{attach_plugin_msg_require} . '<br />';

	my $info = $this->toString(1, 0);
	my %retval;

	$retval{msg} = "\t$::resource{attach_plugin_msg_info}";
	$retval{body} =<<EOD;
<p class="small">
 [<a href="$::script?cmd=attach&amp;mypage=@{[&encode($::form{mypage} eq '' ? $::form{refer} : $::form{mypage})]}&amp;pcmd=list&amp;refer=@{[&encode("$::form{refer}")]}">$::resource{attach_plugin_msg_listpagelink}</a>]
 [<a href="$::script?cmd=attach&amp;pcmd=list">$::resource{attach_plugin_msg_listall}</a>]
</p>
<dl>
 <dt>$info</dt>
 <dd>$::resource{attach_plugin_msg_page}: $::form{refer}</dd>
 <dd>$::resource{attach_plugin_msg_filename}:$ this->{filename}</dd>
 <dd>$::resource{attach_plugin_msg_md5hash}: $this->{md5hash}</dd>
 <dd>$::resource{attach_plugin_msg_filesize}: $this->{size_str} ($this->{size} bytes)</dd>
 <dd>Content-type: $this->{type}</dd>
 <dd>Magic: $this->{magic}</dd>
 <dd>$::resource{attach_plugin_msg_date}: $this->{time_str}</dd>
</dl>
EOD

	if ($::file_uploads) {
		my $msg_pass;

		if ($::file_uploads >= 2) {
			$msg_pass='<br />' . &authadminpassword("input",$::resource{attach_plugin_msg_password},"attach");
		}

		my $s_page = &htmlspecialchars($this->{page});

		$retval{body} .=<<EOD;
<hr />
<form action="$::script" method="get">
 <div>
  <input type="hidden" name="cmd" value="attach" />
  <input type="hidden" name="mypage" value="$this->{page}" />
  <input type="hidden" name="refer" value="$s_page" />
  <input type="hidden" name="file" value="$this->{file}" />
  <input type="hidden" name="age" value="$this->{age}" />
  $msg_delete
  $msg_pass
  <input type="submit" value="$::resource{attach_plugin_btn_submit}" />
 </div>
</form>
EOD
	}
	return %retval;
}

sub delete
{
	my $this = shift;


	if ($this->{age}) {
		unlink($this->{filename});
	} else {
		my $age;
		do {
			$age = ++$this->{age};
		} while (-e $this->{basename} . '.' . $age);

		if (!rename($this->{basename}, $this->{basename} . '.' . $age)) {

			return ('msg'=>$this->{page}, 'body'=>$::resource{attach_plugin_err_delete});
		}
	}
	return ('msg'=>"$this->{page}\t$::resource{attach_plugin_msg_deleted}", 'body'=>&attach_form);
}

# ステータス取得
sub getstatus
{
	my $this = shift;

	return 0 if (!$this->{exist});


	if (-e $this->{logname}) {






	}
	my ($sec, $min, $hour, $day, $mon, $year) = localtime($this->{time});
	$this->{time_str} = sprintf("%d/%02d/%02d %02d:%02d:%02d",
			$year + 1900, $mon + 1, $day, $hour, $min, $sec);
	$this->{size} = -s $this->{filename};
	$this->{size_str} = sprintf('%01.1f', $this->{size}/1000) . 'KB';
	$this->{type} = &attach_mime_content_type($this->{file});
	$this->{magic} = &attach_magic($this->{filename});
	return 1;
}

# ステータス保存
sub putstatus
{
}

# ファイルのリンクを作成
sub toString {
	my $this = shift;
	my $showicon = shift;
	my $showinfo = shift;

	my $body;
	my $finfo = "&amp;file=" . &encode($this->{file})
		. "&amp;mypage=" . &encode($::form{mypage})
		. "&amp;refer="  . &encode($this->{page})
		. ($this->{age} >= 1 ? "&amp;age=$this->{age}" : "");

	$body .= $::file_icon if ($showicon);
	$body .= "<a href=\"$::script?cmd=attach&amp;pcmd=open$finfo\">$this->{file} "
		. ($this->{age} >= 1 ? "(Backup No.$this->{age})" : "") . "</a>";

	if ($showinfo) {
		$body .= " [<a href=\"$::script?cmd=attach&amp;pcmd=info"
		. "$finfo\">$::resource{attach_plugin_msg_description}</a>]";
	}
	return $body;
}

#----------------------------------------------------
# ファイル一覧コンテナ作成
package AttachFiles;
my %files;

sub make_link {
	my $funcp = $::functions{"make_link"};
	return &$funcp(@_);
}

sub new {
	my $this = bless {};
	shift;
	$this->{page} = shift;
	return $this;
}

sub add {
	my $this = shift;
	my $file = shift;
	my $age  = shift;


	$files{$this->{page}}{$file}{$age} = new AttachFile($this->{page}, $file, $age);
}

# ページ単位の一覧表示
sub toString {
	my $this = shift;
	my $flat = shift;
	my $page = $this->{page};

	my $ret = "";
	my $files = $this->{files};
	$ret .= "<li>" . &make_link($this->{page}) . "\n<ul>\n";
	my ($target, $notarget, $backup);
	foreach my $key (sort keys %{$files{$page}}) {
		$target = '';
		$notarget = '';
		$backup = '';
		foreach (sort keys %{$files{$page}{$key}}) {
			if ($_ >= 1) {
				$backup .= "<li>" . $files{$page}{$key}{$_}->toString(0, 1) . "</li>\n";
				$notarget = $files{$page}{$key}{$_}->{file};
			} else {
				$target .= $files{$page}{$key}{$_}->toString(0, 1);
			}
		}
		$ret .= "<li>" . ($target ? $target : $notarget);
		$ret .= "\n<ul>\n$backup\n</ul>\n" if ($backup);
		$ret .= "</li>\n";
	}
	return $ret . "</ul>\n</li>\n";
}

sub to_flat {
	my $this = shift;
	my $flat = shift;
	my $ret = "";
	my %files = $this->{files};
	foreach my $key (sort keys %files) {
		foreach (sort keys %{$files{$key}}) {
			$ret .= $key . "." . $_ . $files{$key}{$_}->toString(1, 1) . ' ';
		}
	}
	return $ret;
}

#-------------------------------------------------
# ページコンテナ作成
package AttachPages;

sub dbmname {
	my $funcp = $::functions{"dbmname"};
	return &$funcp(@_);
}

my %pages;

# ページコンテナ作成
sub new {
	my $this = bless {};
	shift;
	$this->{page} = shift;
	my $age = shift;

	opendir(DIR, "$::upload_dir/")
		or die('directory ' . $::upload_dir . ' is not exist or not readable.');
	my @file = readdir(DIR);
	closedir(DIR);

	my $page_pattern = ($this->{page} eq '')
		? '(?:[0-9A-F]{2})+' : &dbmname($::form{mypage});
	my $age_pattern = ($age eq '') ? '(?:\.([0-9]+))?' : ($age ? "\.($age)" : '');
	my $pattern = "^($page_pattern)_((?:[0-9A-F]{2})+)$age_pattern\$";

	my ($_page, $_file, $_age);

	foreach (@file) {
		next if (!/$pattern/);
		$_page = pack("H*", $1);
		$_file = pack("H*", $2);
		$_age = $3 ? $3 : 0;

		$pages{$_page} = new AttachFiles($_page) if (!exists($pages{$_page}));
		$pages{$_page}->add($_file, $_age);
	}
	return $this;
}

# 全ページの添付一覧表示
sub toString {
	my $this = shift;
	my $page = shift;
	my $flat = shift;


	my $body = "";
	foreach (sort keys %pages) {
		$body .= $pages{$_}->toString($flat);
	}
	return "\n<div id=\"body\">" . $::resource{attach_plugin_err_noexist} . "</div>\n"
			if ($body eq "");
	return "\n<ul>\n$body</ul>\n";
}

1;
__END__


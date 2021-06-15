<?php
// PyukiWiki PHP wrapper sample
// $Id: index.php,v 1.22 2007/07/15 07:40:09 papu Exp $
// Code: EUC-JP

// URLを変更
define('LOCATION', "http://pyukiwiki.sourceforge.jp/cgi-bin/wiki.cgi");


/////////////////////////////////////////////////
// QUERY_STRINGを取得 from PukiWiki

$arg = '';
if (isset($_SERVER['QUERY_STRING']) && $_SERVER['QUERY_STRING']) {
	$arg = & $_SERVER['QUERY_STRING'];
} else if (isset($_SERVER['argv']) && ! empty($_SERVER['argv'])) {
	$arg = & $_SERVER['argv'][0];
}

if($arg == "") {
	$url=LOCATION;
} else {
	$url=LOCATION . '?' . $arg;
}
header('HTTP/1.1 302 Moved Temporarily');
header("Location: $url");

?>


# htmlタグを埋め込むためのプラグイン
#
# #html(htmlタグ等)
# &html(htmlタグ等);
#
# なんのチェックもなく()内の文字列を, 生成するhtmlに埋め込みます。
# 以前の版のhtm.inc.plと違い、'<' '>' もつけず、ただ、埋め込むだけです。
#  使用例> &html(<span class="hoge">hoge</span>);
#
# PukiWiki に同様の plugin があるようなので、それの仕様をあわせてみました。
# が、細かい事情は違うでしょう。(PukiWikiで使用したことないし^^;)
#
# かなり本末転倒で、危険なので、使わないにこしたことはない.
# commentフォーム等やBBSを含め完全に第3者の書き込みを禁止できない限りは
# 使用しちゃ駄目でしょう.
# 2006-03 by tenk*
#
# 2006-03-22 ななみ氏のアイデアに従って凍結頁でしか使えないように修正.
#   		 ※ $::writefrozenplugin != 0 も弾くから、己のサイトでは使用できないけれどon_


sub plugin_html_convert {
	return &plugin_html_inline(@_);
}

sub plugin_html_inline {
	# 凍結ページでしか使えないようにする. 
	my $frozen = &is_frozen($::form{mypage});
	# return '\n[!!!未凍結頁ではhtmlプラグインは使えない!!!]\n' if ($frozen == 0 || $::writefrozenplugin != 0);
	my $args = &unescape(join('', @_));
	return ' ' if ($args eq '');
	return $args;
}

1;
__END__

# html�����������ि��Υץ饰����
#
# #html(html������)
# &html(html������);
#
# �ʤ�Υ����å���ʤ�()���ʸ�����, ��������html�������ߤޤ���
# �������Ǥ�htm.inc.pl�Ȱ㤤��'<' '>' ��Ĥ���������������������Ǥ���
#  ������> &html(<span class="hoge">hoge</span>);
#
# PukiWiki ��Ʊ�ͤ� plugin ������褦�ʤΤǡ�����λ��ͤ򤢤碌�Ƥߤޤ�����
# �����٤�������ϰ㤦�Ǥ��礦��(PukiWiki�ǻ��Ѥ������Ȥʤ���^^;)
#
# ���ʤ�����ž�ݤǡ����ʤΤǡ��Ȥ�ʤ��ˤ��������ȤϤʤ�.
# comment�ե���������BBS��ޤᴰ������3�Ԥν񤭹��ߤ�ػߤǤ��ʤ��¤��
# ���Ѥ��������ܤǤ��礦.
# 2006-03 by tenk*
#
# 2006-03-22 �ʤʤ߻�Υ����ǥ��˽��ä�����ǤǤ����Ȥ��ʤ��褦�˽���.
#   		 �� $::writefrozenplugin != 0 ���Ƥ����顢�ʤΥ����ȤǤϻ��ѤǤ��ʤ������on_


sub plugin_html_convert {
	return &plugin_html_inline(@_);
}

sub plugin_html_inline {
	# ���ڡ����Ǥ����Ȥ��ʤ��褦�ˤ���. 
	my $frozen = &is_frozen($::form{mypage});
	# return '\n[!!!̤����ǤǤ�html�ץ饰����ϻȤ��ʤ�!!!]\n' if ($frozen == 0 || $::writefrozenplugin != 0);
	my $args = &unescape(join('', @_));
	return ' ' if ($args eq '');
	return $args;
}

1;
__END__

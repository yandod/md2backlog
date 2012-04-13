# これは何？
markdown形式で書かれたテキストを[NuLab](http://www.nulab.co.jp/)の[backlog](http://www.backlog.jp/)のWikiの形式に変換するスクリプトです。
kramdownを使ってmarkdownをパースし、HTMLに出力する流れをフックして作成しています。

# 使い方
コマンドラインから実行する場合

	$ ./ruby convert.rb input.md

コードとして実行する場合

	require 'rubygems'
	require 'kramdown'
	require 'cgi'
	require 'rexml/parsers/baseparser'
	require 'kramdown/converter/backlog'
	mdown_src = File.read(filename)
	Kramdown::Document.new(mdown_src).to_backlog

# サンプル
同梱されている<code>input.md</code>を変換したのが<code>output.txt</code>となっています。

# 制限事項
とりあえず自分が必要だった書式にだけ対応している為、未対応の書式が多数あります。

# ライセンス
kramdownと同様にGPLv3となります。
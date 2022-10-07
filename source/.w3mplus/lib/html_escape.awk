#!/usr/bin/awk -f

### Script: html_escape.awk
##
## HTML の特殊文字を変換する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'html_escape.awk'
## ------------------
##
## ------ Text ------
## @include "html_escape.awk"
## ------------------
##
## Metadata:
##
##   id - 5a18e1a6-f2c9-4239-b2ef-41cb8f647bfb
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-09-02
##   since - 2022-07-26
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

### Function: html_escape
##
## 文字列内の HTML 特殊文字を実態参照に変換する。
##
## Parameters:
##
##   string - 実態参照に変換する文字列。
##
## Returns:
##
##   変換された文字列。

function html_escape(string) {
	gsub(/&/, "\\&amp;", string)
	gsub(/</, "\\&lt;", string)
	gsub(/</, "\\&gt;", string)
	gsub(/'/, "\\&#39;", string)
	gsub(/"/, "\\&quot;", string)

	return string
}

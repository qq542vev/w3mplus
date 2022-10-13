#!/usr/bin/env sh

### Script: html_escape.sh
##
## HTML の特殊文字を変換する関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'html_escape.sh'
## ------------------
##
## Metadata:
##
##   id - fb308c89-82a5-4363-aa5b-afd0725f8134
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2022-09-10
##   since - 2022-07-26
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

. 'replace_all.sh'

### Function: html_escape
##
## 文字列内の HTML 特殊文字を実態参照に変換する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 実態参照に変換する文字列。

html_escape() {
	replace_multiple "${1}" "${2}" '&' '&amp;' '<' '&lt;' '>' '&gt;' "'" '&#39;' '"' '&quot;'
}

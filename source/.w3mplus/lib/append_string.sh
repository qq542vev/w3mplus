#!/usr/bin/env sh

### Script: append_string.sh
##
## 文字列を追加する関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'append_string.sh'
## ------------------
##
## Metadata:
##
##   id - f1d7dfdd-8a31-4a8e-9e73-e30f779b55bb
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-10-18
##   since - 2022-10-18
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

### Function: append_string
##
## 終端に文字列を追加する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 追加する文字列。
##   $3 - 区切り文字列。

append_string() {
	eval "${1}=\"\${${1}-}\${${1}:+\${3-}}\${2}\""
}

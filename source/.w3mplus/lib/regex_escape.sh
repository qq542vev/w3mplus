#!/usr/bin/env sh

### Script: regex_escape.sh
##
## 正規表現をエスケープする関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'regex_escape.sh'
## ------------------
##
## Metadata:
##
##   id - 54eb1b25-f085-4489-8b71-f37107caa7d7
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-10-06
##   since - 2022-07-26
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

. 'character_escape.sh'

### Function: regex_escape
##
## 正規表現文字列をエスケープする。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - エスケープする文字列。
##   $3 - エスケープする正規表現の種類。

regex_escape() {
	case "${3:-}" in
		'ERE') character_escape "${1}" "${2}" '^$.[]*+?{}()|';;
		'SED-ERE') character_escape "${1}" "${2}" '^$.[]*+?{}()|/';;
		'SED-BRE') character_escape "${1}" "${2}" '^$.[]*/';;
		*) character_escape "${1}" "${2}" '^$.[]*';;
	esac
}

#!/usr/bin/awk -f

### Script: remove_control_character.awk
##
## 制御文字を削除する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'remove_control_character.awk'
## ------------------
##
## ------ Text ------
## @include "remove_control_character.awk"
## ------------------
##
## Metadata:
##
##   id - 174f7d3a-4105-49b0-9262-a78e0603114c
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-09-10
##   since - 2022-09-10
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

### Function: remove_control_character
##
## 文字列内の C0, C1 制御文字を削除する。
##
## Parameters:
##
##   string - 対象の文字列。
##   except - 除外する制御文字。
##
## Returns:
##
##   制御文字が削除された文字列。

function remove_control_character(string, except,  cc,char) {
	cc = "\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\028\029\030\031\032\033\034\035\036\037\177\200\201\202\203\204\205\206\207\210\211\212\213\214"

	gsub(except, "", cc)

	for(char = ""; cc != ""; cc = substr(cc, 2)) {
		gsub(substr(cc, 1, 1), "", string)
	}

	return string
}

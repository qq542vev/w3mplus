#!/usr/bin/awk -f

### Script: safe_string.awk
##
## 制御文字を削除する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'safe_string.awk'
## ------------------
##
## ------ Text ------
## @include "safe_string.awk"
## ------------------
##
## Metadata:
##
##   id - 8e4e67d2-eb12-4d17-aa03-b9253c5fa9a6
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
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

@include "remove_control_character.awk"

### Function: safe_string
##
## 文字列内の水平タブ、改行、復帰以外の制御文字を削除する。
##
## Parameters:
##
##   string - 対象の文字列。
##
## Returns:
##
##   制御文字が削除された文字列。

function safe_string(string) {
	return remove_control_character(string, "\011\012\015")
}

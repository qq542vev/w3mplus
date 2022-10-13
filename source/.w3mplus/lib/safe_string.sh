#!/usr/bin/env sh

### Script: safe_string.sh
##
## 制御文字を削除する関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'safe_string.sh'
## ------------------
##
## Metadata:
##
##   id - 4ca4ce14-c456-4f42-b545-28d9575c0aa9
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2022-09-28
##   since - 2022-09-12
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

. 'remove_control_character.sh'

### Function: safe_string
##
## 文字列内の水平タブ、改行、復帰以外の制御文字を削除する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 対象の文字列。

safe_string() {
	remove_control_character "${1}" "${2}" "$(printf '\t\n\r')"
}

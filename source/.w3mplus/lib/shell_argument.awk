#!/usr/bin/awk -f

### Script: shell_argument.awk
##
## Shell Script 用の引数を生成する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'shell_argument.awk'
## ------------------
##
## ------ Text ------
## @include "shell_argument.awk"
## ------------------
##
## Metadata:
##
##   id - 9ea3d3d8-ffef-4667-b7ab-04a859bb42cd
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 2.0.0
##   date - 2022-09-16
##   since - 2022-07-26
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

### Function: shell_argument
##
## 安全な Shell Script 用の引数を生成する。
##
## Parameters:
##
##   string - 引数となる文字列。
##
## Returns:
##
##   Shell Script 用の引数。

function shell_argument(string) {
	gsub(/'+/, "'\"&\"'", string)

	return "'" string "'"
}

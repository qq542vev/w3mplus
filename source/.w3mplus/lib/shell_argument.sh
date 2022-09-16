#!/usr/bin/env sh

### Script: shell_argument.sh
##
## Shell Script 用の引数を生成する関数を定義する。
##
## Metadata:
##
##   id - de6c71d9-3897-4d7f-9e76-3e2bbed4484a
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
##   $1 - 結果を代入する変数名。
##   $2 - 引数となる文字列。

shell_argument() {
	set "${1}" "${2-}" ''

	until [ "${2#*\'}" = "${2}" ]; do
		set -- "${1}" "${2#*\'}" "${3}${2%%\'*}'\"'\"'"
	done

	eval "${1}=\"'\${3}\${2}'\""
}

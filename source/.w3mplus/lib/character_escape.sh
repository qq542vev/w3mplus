#!/usr/bin/env sh

### Script: character_escape.sh
##
## 任意の文字をエスケープする関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'character_escape.sh'
## ------------------
##
## Metadata:
##
##   id - e0d03bf0-5892-4544-9bdb-a5204d88837e
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-10-06
##   since - 2022-10-06
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

. 'replace_all.sh'

### Function: character_escape
##
## 文字列内の任意の文字をエスケープする。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 対象の文字列。
##   $3 - エスケープする文字。
##   $4 - エスケープに使用する文字。

character_escape() {
	eval "${1}=\"\${2}\""

	set -- "${1}" "${4:-\\}${3}" "${4:-\\}"

	while [ -n "${2}" ]; do
		eval 'replace_all "${1}"' "\"\${${1}}\"" '"${2%%${2#?}}" "${3}${2%%${2#?}}"'

		set -- "${1}" "${2#?}" "${3}"
	done
}

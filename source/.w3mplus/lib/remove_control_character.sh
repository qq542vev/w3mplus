#!/usr/bin/env sh

### Script: remove_control_character.sh
##
## 制御文字を削除する関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'remove_control_character.sh'
## ------------------
##
## Metadata:
##
##   id - ad45ec88-2f89-4831-a123-ad246982f09f
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.2
##   date - 2022-10-26
##   since - 2022-09-10
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

. 'replace_all.sh'

### Function: remove_control_character
##
## 文字列内の C0, C1 制御文字を削除する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 対象の文字列。
##   $3 - 除外する制御文字。

remove_control_character() {
	set -- "${1}" "${2}" "${3}" "$(printf '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177\200\201\202\203\204\205\206\207\210\211\212\213\214')"

	while [ -n "${3}" ]; do
		replace_all "${1}" "${4}" "${3%%${3#?}}" ''

		eval 'set -- "${1}" "${2}" "${3#?}"' "\"\${${1}}\""
	done

	set -- "${1}" "${2}" "${4}" ''

	while [ -n "${3}" ]; do
		set -- "${1}" "${2}" "${3#?}" "${4} '${3%%${3#?}}' ''"
	done

	eval 'replace_multiple "${1}" "${2}"' "${4}"
}

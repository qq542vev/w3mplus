#!/usr/bin/env sh

### Script: append_array_posix.sh
##
## Metadata:
##
##   id - 268058c5-28d0-4645-8308-1ab1a6ad7e7a
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-09-02
##   since - 2022-07-26
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

### Function: append_array_posix
##
## POSXI 準拠の配列風文字列に要素を追加する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $@ - 追加する要素。

append_array_posix() {
	while [ 2 -le "${#}" ]; do
		__append_array_posix "${1}" "${2}"
		eval "shift 2; set -- '${1}' \"\${@}\""
	done
}

__append_array_posix() {
	set "${1}" "${2-}" ''

	until [ "${2#*\'}" = "${2}" ]; do
		set -- "${1}" "${2#*\'}" "${3}${2%%\'*}'\"'\"'"
	done

	eval "${1}=\"\${${1}-}\${${1}:+ }'\${3}\${2}'\""
}

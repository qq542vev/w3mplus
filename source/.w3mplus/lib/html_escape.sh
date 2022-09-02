#!/usr/bin/env sh

### Script: html_escape.sh
##
## HTML エスケープする関数を定義する。
##
## Metadata:
##
##   id - fb308c89-82a5-4363-aa5b-afd0725f8134
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

### Function: html_escape
##
## HTML の特殊文字をエスケープする。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - エスケープする文字列。

html_escape() {
	set -- "${1}" "${2}" ''
	until [ "${2#*&}" = "${2}" ]; do
		set -- "${1}" "${2#*&}" "${3}${2%%&*}&amp;"
	done

	set -- "${1}" "${3}${2}" ''
	until [ "${2#*<}" = "${2}" ]; do
		set -- "${1}" "${2#*<}" "${3}${2%%<*}&lt;"
	done

	set -- "${1}" "${3}${2}" ''
	until [ "${2#*>}" = "${2}" ]; do
		set -- "${1}" "${2#*>}" "${3}${2%%>*}&gt;"
	done

	set -- "${1}" "${3}${2}" ''
	until [ "${2#*\'}" = "${2}" ]; do
		set -- "${1}" "${2#*\'}" "${3}${2%%\'*}&#39;"
	done

	set -- "${1}" "${3}${2}" ''
	until [ "${2#*\"}" = "${2}" ]; do
		set -- "${1}" "${2#*\"}" "${3}${2%%\"*}&quot;"
	done

	eval "${1}=\"\${3}\${2}\""
}

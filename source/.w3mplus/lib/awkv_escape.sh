#!/usr/bin/env sh

### Script: awkv_escape.sh
##
## AWK 特殊文字をエスケープする関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'awkv_escape.sh'
## ------------------
##
## Metadata:
##
##   id - c4b0dd21-a21f-4aca-8b98-7d9b0caa3f64
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-09-02
##   since - 2022-07-26
##   copyright - Public Domain.
##   license - <CC0 at https://creativecommons.org/publicdomain/zero/1.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

### Function: awkv_escape
##
## 文字列内の AWK 特殊文字をエスケープする。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - エスケープする文字列。
##
## See Also:
##
##   * <4.2 POSIX 準拠シェル 用 at https://qiita.com/ko1nksm/items/a22c0ce88e39c9f2dcb0#42-posix-%E6%BA%96%E6%8B%A0%E3%82%B7%E3%82%A7%E3%83%AB-%E7%94%A8>

awkv_escape() {
	set -- "${1}" "${2}" ''
	until [ "${2#*\\}" = "${2}" ]; do
		set -- "${1}" "${2#*\\}" "${3}${2%%\\*}\\\\"
	done

	set -- "${1}" "${3}${2}"
	case "${2}" in
		@*) set -- "${1}" "\\100${2#?}";;
	esac

	eval "${1}=\${2}"
}

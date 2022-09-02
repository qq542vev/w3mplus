#!/usr/bin/env sh

### Script: abspath.sh
##
## 相対パスを絶対パスに変換する関数を定義する。
##
## Metadata:
##
##   id - 78fa36b1-64b6-4c15-a164-2b89c16b5c01
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

### Function: abspath
##
## 相対パスを絶対パスに変換する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 相対パス。
##   $3 - ベースとする絶対パス。
##
## See Also:
##
##   * <シェルスクリプトで相対パスと絶対パスを相互に変換する関数 at https://qiita.com/ko1nksm/items/88d5b7ac3b1db8778452>

abspath() {
	case "${2}" in
		'/'*) set -- "${1}" "${2}/" '';;
		*) set -- "${1}" "${3:-$PWD}/$2/" '';;
	esac

	while [ -n "${2}" ]; do
		case "${2%%/*}" in
			'' | '.') set -- "${1}" "${2#*/}" "${3}";;
			'..') set -- "${1}" "${2#*/}" "${3%/*}";;
			*) set -- "${1}" "${2#*/}" "${3}/${2%%/*}";;
		esac
	done

	eval "${1}=\"/\${3#/}\""
}

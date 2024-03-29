#!/usr/bin/env sh

### Script: path_to_fileurl.sh
##
## File URL に変換する関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'path_to_fileurl.sh'
## ------------------
##
## Metadata:
##
##   id - f3f49375-d530-4a94-863f-6100acde7719
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
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

. 'abspath.sh'

### Function: path_to_fileurl
##
## パス文字列を File URL に変換する。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - 変換するパス文字列。

path_to_fileurl() {
	abspath "${1}" "${2}"

	eval "${1}=\"file://\$(printf '%s' \"\${${1}}\" | urlencode | sed -e 's/%2F/\//g')\""
}

#!/usr/bin/env sh

### Script: singlequote_escape.sh
##
## Metadata:
##
##   id - de6c71d9-3897-4d7f-9e76-3e2bbed4484a
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

### Function: singlequote_escape
##
## 文字列内のシングルクォートをエスケープする。
##
## Parameters:
##
##   $1 - 結果を代入する変数名。
##   $2 - エスケープする文字列。
##
## Returns:
##
##   0か1の真理値。

singlequote_escape() {
	set "${1}" "${2-}" ''

	until [ "${2#*\'}" = "${2}" ]; do
		set -- "${1}" "${2#*\'}" "${3}${2%%\'*}'\"'\"'"
	done

	eval "${1}=\"\${3}\${2}\""
}

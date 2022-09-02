#!/usr/bin/env sh

### Script: option_error.sh
##
## オプションエラー用の関数を定義する。
##
## Metadata:
##
##   id - e7ead215-bfcb-4727-ace1-9fc6d99b9479
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

### Function: option_error
##
## エラーメッセージを出力する。
##
## Parameters:
##
##   $1 - エラーメッセージ。
##
## Returns:
##
##   終了コード64。

option_error() {
	printf '%s: %s\n' "${0##*/}" "${1}" >&2
	printf '%s\n' "詳細については '${0##*/} --help' を実行してください。" >&2

	endCall "${EX_USAGE}"
}

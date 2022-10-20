#!/usr/bin/awk -f

### Script: getline_exec.awk
##
## コマンドの実行結果を取得する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'getline_exec.awk'
## ------------------
##
## ------ Text ------
## @include "getline_exec.awk"
## ------------------
##
## Metadata:
##
##   id - 97b29ec6-9e07-4359-93d5-bda0574faad1
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-10-20
##   since - 2022-10-20
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

### Function: getline_exec
##
## コマンドの実行結果を取得する。
##
## Parameters:
##
##   string - 引数となる文字列。
##   result - 結果を代入する変数。

function getline_exec(command, result,  tmpvar,i) {
	split("", result)

	result["stdout"] = ""
	command = sprintf("(\n%s\n)\n%s", command, "printf '%3d' \"${?}\"")

	for(i = 1; 0 < (command | getline tmpvar); i++) {
		result["stdout"] = result["stdout"] (i == 1 ? "" : "\n") tmpvar
	}

	close(command)

	result["status"] = substr(result["stdout"], length(result["stdout"]) - 2)
	gsub(/ /, "", result["status"])

	result["stdout"] = substr(result["stdout"], 1, length(result["stdout"]) - 3)
}

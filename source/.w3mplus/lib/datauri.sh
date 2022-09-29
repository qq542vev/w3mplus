#!/usr/bin/env sh

### Script: datauri.sh
##
## Data URI を生成する関数を定義する。
##
## Usage:
##
## ------ Text ------
## . 'datauri.sh'
## ------------------
##
## Metadata:
##
##   id - 0d689f12-f2f2-4264-8410-c2a341ff02c6
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

### Function: datauri
##
## Data URI を生成する。
##
## Parameters:
##
##   $1 - MIME タイプ。
##   $@ - ファイルパス。

datauri() {
	printf 'data:%s;base64,' "${1}"
	shift
	base64 -- ${@+"${@}"} | tr -d '\n'
}

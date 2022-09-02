#!/usr/bin/awk -f

### Script: singlequote_escape.awk
##
## シングルクォートをエスケープする関数を定義する。
##
## Metadata:
##
##   id - 9ea3d3d8-ffef-4667-b7ab-04a859bb42cd
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
##   string - エスケープする文字列。
##
## Returns:
##
##   0か1の真理値。

function singlequote_escape(string) {
	gsub(/'+/, "'\"&\"'", string)

	return string
}

#!/usr/bin/awk -f

### Script: array_print.awk
##
## 配列を文字列に変換する関数を定義する。
##
## Metadata:
##
##   id - 7096c7ed-48ce-4c8d-9e6e-84a3986d4c32
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

@include "array_length.awk"

### Function: array_print
##
## 番号付き配列を文字列に変換する。
##
## Parameters:
##
##   array - 変換する配列。
##   start - 最後の要素のキー番号。
##   end - 最後の要素のキー番号。
##   separator - 配列要素の区切り文字列。
##   format - フォーマット文字列。printf の形式に従う。
##
## Returns:
##
##   変換した文字列。

function array_print(array, start, end, separator, format,  result) {
	if(start == "") {
		start = 1
	}

	if(end == "") {
		end = array_length(array)
	}

	if(format == "") {
		format = "%s"
	}

	for(result = ""; start <= end; start++) {
		if(start in array) {
			result = result separator sprintf(format, array[start])
		}
	}

	return substr(result, length(separator) + 1)
}

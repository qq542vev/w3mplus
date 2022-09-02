#!/usr/bin/awk -f

### Script: uri_query_parse.awk
##
## URI クエリを分離する関数を定義する。
##
## Metadata:
##
##   id - 0dd0c8ab-eb71-4574-9f38-068ecea41136
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

### Function: uri_query_parse
##
## URI クエリを分離する。
##
## Parameters:
##
##   string - 分離する URI クエリ。
##   result - 結果を代入する配列。
##   separator - 区切り文字。
##
## Returns:
##
##   分離されたクエリの要素数。

@include "url_decode.awk"

function uri_query_parse(string, result, separator,  query,queryCount,i,count,position) {
	split("", result)
	count = 0

	if(separator == "") {
		separator = "&"
	}

	queryCount = split(string, query, separator)

	for(i = 1; i <= queryCount; i++) {
		if(query[i] != "") {
			count++
			position = index(query[i], "=")

			if(position) {
				result[count, "name"] = url_decode(substr(query[i], 1, position - 1), 1)
				result[count, "value"] = url_decode(substr(query[i], position + 1), 1)
			} else {
				result[count, "name"] = url_decode(query[i], 1)
				result[count, "value"] = ""
			}
		}
	}
	
	return count
}

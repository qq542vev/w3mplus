#!/usr/bin/awk -f

### Script: uri_parse.awk
##
## URI 構成要素を分離する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'uri_parse.awk'
## ------------------
##
## ------ Text ------
## @include "uri_parse.awk"
## ------------------
##
## Metadata:
##
##   id - cc87746b-4d55-46f9-8a72-067b0c8109c3
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

### Function: uri_parse
##
## URI の構成要素を分離する。
##
## Parameters:
##
##   uri - 分離する URI。
##   element - 構成要素格納する配列。

function uri_parse(uri, element,  pattern,key,i,auth,result) {
	split("^[^:/?#]*: ^//[^/?#]* ^[^?#]* ^\\?[^#]* ^#.* ^[^@/?#]*@ ^[^:/?#]* ^:[^/?#]*", pattern, " ")
	split("scheme authority path query fragment userinfo host port", key, " ")
	split("", element)

	for(i = 1; i <= 5; i++) {
		element[key[i]] = ""

		if(match(uri, pattern[i])) {
			element[key[i]] = substr(uri, RSTART, RLENGTH)
			uri = substr(uri, RSTART + RLENGTH)
		}
	}

	element["userinfo"] = ""
	element["host"] = ""
	element["port"] = ""

	if(element["authority"]) {
		auth = substr(element["authority"], 3)

		for(i = 6; i <= 8; i++) {
			if(match(auth, pattern[i])) {
				element[key[i]] = substr(auth, RSTART, RLENGTH)
				auth = substr(auth, RSTART + RLENGTH)
			}
		}
	}
}

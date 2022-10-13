#!/usr/bin/awk -f

### Script: uri_normalize.awk
##
## URI の正規化を行う関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'uri_normalize.awk'
## ------------------
##
## ------ Text ------
## @include "uri_normalize.awk"
## ------------------
##
## Metadata:
##
##   id - 4d29eba9-eeb7-4ebe-8363-41d979420ee1
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

@include "uri_parse.awk"
@include "url_encode_normalize.awk"
@include "uri_path_remove_dot_segments.awk"

### Function: uri_normalize
##
## URI 文字列の正規化を行う。
##
## Parameters:
##
##   uri - 正規化を行う URI 文字列。
##
## Returns:
##
##   正規化が行われた URI 文字列。

function uri_normalize(uri,  element) {
	uri_parse(url_encode_normalize(uri), element)
	element["path"] = uri_path_remove_dot_segments(element["path"])

	return element["scheme"] element["authority"] element["path"] element["query"] element["fragment"]
}

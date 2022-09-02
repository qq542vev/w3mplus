#!/usr/bin/awk -f

### Script: uri_normalize.awk
##
## URI を正規化する関数を定義する。
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
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

### Function: uri_normalize
##
## URI 文字列を正規化する。
##
## Parameters:
##
##   uri - 正規化する URI 文字列。
##
## Returns:
##
##   正規化された URI 文字列。

@include "uri_parse.awk"
@include "url_encode_normalize.awk"
@include "uri_path_remove_dot_segments.awk"

function uri_normalize(uri,  element) {
	uri_parse(url_encode_normalize(uri), element)
	element["path"] = uri_path_remove_dot_segments(element["path"])

	return element["scheme"] element["authority"] element["path"] element["query"] element["fragment"]
}

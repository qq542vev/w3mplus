#!/usr/bin/awk -f

### Script: uri_path_remove_dot_segments.awk
##
## ドットセグメントを除去する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'uri_path_remove_dot_segments.awk'
## ------------------
##
## ------ Text ------
## @include "uri_path_remove_dot_segments.awk"
## ------------------
##
## Metadata:
##
##   id - b6b08b94-3623-4ace-a0a5-48aa3ad777a8
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

### Function: uri_path_remove_dot_segments
##
## パス文字列内からドットセグメントを除去する。
##
## Parameters:
##
##   path - パス文字列。
##
## Returns:
##
##   ドットセグメントが除去された文字列。
##
## See Also:
##
##   * <5.2.4. Remove Dot Segments at https://www.rfc-editor.org/rfc/rfc3986#section-5.2.4>

function uri_path_remove_dot_segments(path,  result) {
	if(!index(path, ".")) {
		return path
	}

	result = ""

	while(path != "") {
		if(index(path, "./") == 1) {
			path = substr(path, 3)
		} else if(index(path, "../") == 1) {
			path = substr(path, 4)
		} else if(index(path, "/./") == 1) {
			path = substr(path, 3)
		} else if(path == "/.") {
				path = "/"
		} else if(index(path, "/../") == 1) {
			path = substr(path, 4)
			gsub(/\/?[^\/]*$/, "", result)
		} else if(path == "/..") {
			path = "/"
			gsub(/\/?[^\/]*$/, "", result)
		} else if(path == "." || path == "..") {
			path = ""
		} else {
			match(path, /^.[^\/]*/)

			result = result substr(path, RSTART, RLENGTH)
			path = substr(path, RLENGTH + 1)
		}
	}

	return result
}

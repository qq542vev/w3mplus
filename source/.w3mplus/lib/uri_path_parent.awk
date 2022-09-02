#!/usr/bin/awk -f

### Script: uri_path_parent.awk
##
## Metadata:
##
##   id - 634bb520-4fbf-4468-9076-d77405f82091
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

### Function: uri_path_parent
##
## パス文字列から上位ディレクトリのパスを求める。
##
## Parameters:
##
##   path - パス文字列。
##   count - 何段階上位のパスを求めるか。
##
## Returns:
##
##   path の上位ディレクトリのパス文字列。

@include "uri_path_remove_dot_segments.awk"

function uri_path_parent(path, count) {
	path = uri_path_remove_dot_segments(path)
	gsub(/[/]+/, "/", path)

	for(; 1 <= count && path != "" && path != "/"; count--) {
		gsub(/[^/]*[/]?$/, "", path)
	}

	return path
}

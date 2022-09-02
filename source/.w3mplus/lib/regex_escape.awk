#!/usr/bin/awk -f

### Script: regex_escape.awk
##
## Metadata:
##
##   id - 1e5e8b52-1ac9-4d76-8822-561d0cadbd24
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

### Function: regex_escape
##
## 正規表現文字列をエスケープする。
##
## Parameters:
##
##   string - エスケープする文字列。
##   type - エスケープする正規表現の種類。
##
## Returns:
##
##   エスケープされた文字列。

function regex_escape(string, type) {
	if(type == "" || type == "BRE") {
		gsub(/[].\\*[^$]/, "\\\\&", string)
	} else if(type == "ERE") {
		gsub(/[].\\*+?|(){}[^$]/, "\\\\&", string)
	}

	return string
}

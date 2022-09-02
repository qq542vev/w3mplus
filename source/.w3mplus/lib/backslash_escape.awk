#!/usr/bin/awk -f

### Script: backslash_escape.awk
##
## Metadata:
##
##   id - 92149acc-262e-41c6-8fb4-296193ea08a2
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

### Function: backslash_escape
##
## ASCII 制御文字をバックスラッシュでエスケープする。
##
## Parameters:
##
##   string - エスケープする文字列。
##
## Returns:
##
##   バックスラッシュでエスケープされた文字列。

function backslash_escape(string) {
	gsub("\\\\", "\\\\", string)
	gsub("\\001", "\\001", string)
	gsub("\\002", "\\002", string)
	gsub("\\003", "\\003", string)
	gsub("\\004", "\\004", string)
	gsub("\\005", "\\005", string)
	gsub("\\006", "\\006", string)
	gsub("\\007", "\\007", string)
	gsub("\\010", "\\010", string)
	gsub("\\011", "\\011", string)
	gsub("\\012", "\\012", string)
	gsub("\\013", "\\013", string)
	gsub("\\014", "\\014", string)
	gsub("\\015", "\\015", string)
	gsub("\\016", "\\016", string)
	gsub("\\017", "\\017", string)
	gsub("\\020", "\\020", string)
	gsub("\\021", "\\021", string)
	gsub("\\022", "\\022", string)
	gsub("\\023", "\\023", string)
	gsub("\\024", "\\024", string)
	gsub("\\025", "\\025", string)
	gsub("\\026", "\\026", string)
	gsub("\\027", "\\027", string)
	gsub("\\030", "\\030", string)
	gsub("\\031", "\\031", string)
	gsub("\\032", "\\032", string)
	gsub("\\033", "\\033", string)
	gsub("\\034", "\\034", string)
	gsub("\\035", "\\035", string)
	gsub("\\036", "\\036", string)
	gsub("\\037", "\\037", string)
	gsub("\\177", "\\177", string)

	return string
}

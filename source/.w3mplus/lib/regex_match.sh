#!/usr/bin/env sh

### Script: regex_match.sh
##
## Metadata:
##
##   id - 5e34fa84-f22f-401b-9172-5269c481c8aa
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

### Function: regex_match
##
## 文字列が正規表現に一致するか検査する。
##
## Parameters:
##
##   $1 - 検査する文字列。
##   $@ - 正規表現。
##
## Returns:
##
##   0か1の真理値。

regex_match() {
	awk -- '
		BEGIN {
			for(i = 2; i < ARGC; i++) {
				if(ARGV[1] !~ ARGV[i]) {
					exit 1
				}
			}

			exit
		}
	' ${@+"${@}"} || return 1

	return 0
}

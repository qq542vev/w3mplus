#!/usr/bin/awk -f

### Script: domain_check.awk
##
## ドメインであるか検査する関数を定義する。
##
## Metadata:
##
##   id - e55d7295-c8f1-4514-bab2-e4a510f31ad6
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

### Function: domain_check
##
## 文字列がドメインであるか検査する。
##
## Parameters:
##
##   domain - 検査する文字列。
##
## Returns:
##
##   0か1の真理値。

function domain_check(domain) {
	return domain ~ /^[0-9A-Za-z]([0-9A-Za-z-]*[0-9A-Za-z])?(\.[0-9A-Za-z]([0-9A-Za-z-]*[0-9A-Za-z])?)+$/
}

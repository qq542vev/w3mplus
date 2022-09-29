#!/usr/bin/awk -f

### Script: array_length.awk
##
## 配列の要素数を求める関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'array_length.awk'
## ------------------
##
## ------ Text ------
## @include "array_length.awk"
## ------------------
##
## Metadata:
##
##   id - e6f21357-6315-4445-ab1e-07d3ed30a131
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

### Function: array_length
##
## 配列の要素数を求める。
##
## Parameters:
##
##   array - 要素数を求める配列。
##
## Returns:
##
##   array の要素数。
##
## See Also:
##
##   * <length関数では配列の要素数を調べられない場合がある at https://qiita.com/richmikan@github/items/bd4b21cf1fe503ab2e5c#length%E9%96%A2%E6%95%B0%E3%81%A7%E3%81%AF%E9%85%8D%E5%88%97%E3%81%AE%E8%A6%81%E7%B4%A0%E6%95%B0%E3%82%92%E8%AA%BF%E3%81%B9%E3%82%89%E3%82%8C%E3%81%AA%E3%81%84%E5%A0%B4%E5%90%88%E3%81%8C%E3%81%82%E3%82%8B>

function array_length(array,  count,key) {
	count = 0

	for(key in array) {
		count++
	}

	return count
}

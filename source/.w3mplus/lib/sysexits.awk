#!/usr/bin/awk -f

### Script: sysexits.awk
##
## sysexits の終了コードを返す関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'sysexits.awk'
## ------------------
##
## ------ Text ------
## @include "sysexits.awk"
## ------------------
##
## Metadata:
##
##   id - 2b88844d-5c62-43e9-85e4-3f68b88c8ed2
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

### Function: sysexits
##
## sysexits の終了コードを返す。
##
## Parameters:
##
##   code - sysexits で定義された終了コード。
##
## Returns:
##
##   終了コードの番号。
##
## See Also:
##
##   * <sysexits(3) at https://www.freebsd.org/cgi/man.cgi?sektion=3&query=sysexits>

function sysexits(code) {
	if(code == "EX_OK") {
		return 0
	} else if(code == "EX_USAGE") {
		return 64
	} else if(code == "EX_DATAERR") {
		return 65
	} else if(code == "EX_NOINPUT") {
		return 66
	} else if(code == "EX_NOUSER") {
		return 67
	} else if(code == "EX_NOHOST") {
		return 68
	} else if(code == "EX_UNAVAILABLE") {
		return 69
	} else if(code == "EX_SOFTWARE") {
		return 70
	} else if(code == "EX_OSERR") {
		return 71
	} else if(code == "EX_OSFILE") {
		return 72
	} else if(code == "EX_CANTCREAT") {
		return 73
	} else if(code == "EX_IOERR") {
		return 74
	} else if(code == "EX_TEMPFAIL") {
		return 75
	} else if(code == "EX_PROTOCOL") {
		return 76
	} else if(code == "EX_NOPERM") {
		return 77
	} else if(code == "EX_CONFIG") {
		return 78
	}

	return 1
}

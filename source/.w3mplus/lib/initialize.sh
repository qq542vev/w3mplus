#!/usr/bin/env sh

### Script: initialize.sh
##
## Shell Script の初期設定を行う。
##
## Usage:
##
## ------ Text ------
## . 'initialize.sh'
## ------------------
##
## Metadata:
##
##   id - c64bc63a-9c95-4270-82b5-50b57df02fb4
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

set -efu
umask '0022'
LC_ALL='C'
IFS=$(printf ' \t\n_'); IFS="${IFS%_}"
PATH="${PATH-}${PATH:+:}$(command -p getconf 'PATH')"
UNIX_STD='2003' # HP-UX POSIX mode
XPG_SUS_ENV='ON' # AIX POSIX mode
XPG_UNIX98='OFF' # AIX UNIX 03 mode
POSIXLY_CORRECT='1' # GNU Coreutils POSIX mode
COMMAND_MODE='unix2003' # macOS UNIX 03 mode
export 'IFS' 'LC_ALL' 'PATH' 'UNIX_STD' 'XPG_SUS_ENV' 'XPG_UNIX98' 'POSIXLY_CORRECT' 'COMMAND_MODE'

. 'sysexits.sh'

trap 'case "${?}" in 0) end_call;; *) end_call "${EX_SOFTWARE}";; esac' 0 # EXIT
trap 'end_call 129' 1  # SIGHUP
trap 'end_call 130' 2  # SIGINT
trap 'end_call 131' 3  # SIGQUIT
trap 'end_call 143' 15 # SIGTERM

### Function: end_call
##
## 一時ディレクトリを削除しスクリプトを終了する。
##
## Parameters:
##
##   $1 - 終了ステータス。
##
## Returns:
##
##   $1 の終了ステータス。

end_call() {
	trap '' 0 # EXIT
	rm -fr -- ${tmpDir:+"${tmpDir}"}
	exit "${1:-0}"
}

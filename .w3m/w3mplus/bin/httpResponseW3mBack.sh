#!/usr/bin/env sh

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'exit 129' 1 # SIGHUP
trap 'exit 130' 2 # SIGINT
trap 'exit 131' 3 # SIGQUIT
trap 'exit 143' 15 # SIGTERM

{
	echo 'W3m-control: BACK'

	if [ "${1-}" = '-' ]; then
		cat
	else
		printf '%s' "${1-}"
	fi
} | httpResponseNoCache.sh '' -

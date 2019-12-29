#!/usr/bin/env sh

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

{
	echo 'W3m-control: BACK'

	if [ "${1-}" = '-' ]; then
		cat
	else
		printf '%s' "${1-}"
	fi
} | httpResponseNoCache.sh '' -

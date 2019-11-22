#!/usr/bin/env sh

set -eu

{
	echo 'W3m-control: BACK'

	if [ "${1-}" = '-' ]; then
		cat
	else
		printf '%s' "${1-}"
	fi
} | httpResponseNoCache.sh '' -

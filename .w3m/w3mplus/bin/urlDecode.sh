#!/usr/bin/env sh

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

decodeURI () (
	sed -e 's/+/%20/g' -e 's/%/\\x/g' | xargs -0 printf '%b'
)

if [ "${#}" -eq 0 ]; then
	set -- -
fi

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-')
				decodeURI
				shift
			;;
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				decodeURI <"${1}"
				shift
			done
			;;
		*)
			decodeURI <"${1}"
			shift
			;;
	esac
done

#!/usr/bin/env sh

set -eu

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

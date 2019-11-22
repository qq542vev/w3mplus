#!/usr/bin/env sh

set -eu

quoteEscape () (
	sed -e "s/'/'\"'\"'/g"
)

getQuery () (
	IFS='&'
	set -- $(cat)

	while [ 1 -le "${#}" ]; do
		if [ -n "${1}" ]; then
			key=$(printf '%s' "${1%%=*}" | urlDecode.sh | quoteEscape)
			value=$(
				if [ "${1}" != "${1#*=}" ]; then
					printf '%s' "${1#*=}" | urlDecode.sh | quoteEscape
				fi
			)

			printf "'%s' '%s'" "${key}" "${value}"

			if [ "${#}" -eq 1 ]; then
				printf '\n'
			else
				printf ' '
			fi
		fi

		shift
	done
)

if [ "${#}" -eq 0 ]; then
	set -- -
fi

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-')
				getQuery
				shift
			;;
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				getQuery <"${1}"
				shift
			done
			;;
		*)
			getQuery <"${1}"
			shift
			;;
	esac
done

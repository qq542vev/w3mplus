#!/usr/bin/env sh

set -eu

trim () (
	tr -d '\r\n' | sed -E -e 's/^[\t ]*|[\t ]*$//g'
)

printHeader () (
	name=$(printf '%s' "${1-}" | trim)
	value=$(printf '%s' "${2-}" | trim)

	if [ -n "${name}" ] && [ -n "${value}" ]; then
		printf '%s: %s\r\n' "${name}" "${value}"
	fi
)

printHeaders () (
	printf '%s\n' "${1:-}" | while IFS=':'; read -r 'name' 'value'; do
		printHeader "${name}" "${value}"
	done
)

if [ "${#}" -eq 0 ]; then
	printHeaders "$(cat)"
else
	while [ 1 -le "${#}" ]; do
		case "${1}" in
			*:*)
				printHeaders "${1}"
				shift
				;;
			*)
				printHeader "${1}" "${2-}"
				shift 2
				;;
		esac
	done
fi

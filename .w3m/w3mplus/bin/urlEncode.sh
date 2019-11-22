#!/usr/bin/env sh

set -eu

LC_ALL='C'
LANG='C'
export 'LC_ALL' 'LANG'

encodeURI () (
	eval set -- "$(sed -e "s/./'&' /g; s/'''/\"'\"/g" | sed -e ":loop; N; \$!b loop; s/\n/'&' /g")"

	for character; do
		case "${character}" in
			[*-.0-9A-Z_a-z])
				printf "${character}"
				;;
			*)
				printf '%s' "${character}" | od -A 'n' -t 'x1' -v | tr -d '\n' | sed -e 'y/abcdef/ABCDEF/; s/ /%/g'
				;;
		esac
	done

	printf '\n'
)

if [ "${#}" -eq 0 ]; then
	set -- -
fi

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-')
				encodeURI
				shift
			;;
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				encodeURI <"${1}"
				shift
			done
			;;
		*)
			encodeURI <"${1}"
			shift
			;;
	esac
done

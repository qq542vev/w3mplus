#!/usr/bin/env sh

##
# Display HTTP Response that moves to n% with w3m.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

percent='50'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			case "${2}" in
				[0-9] | [1-9][0-9] | '100')
					percent="${2}"
					shift 2
					;;
				*)
					printf 'The value must be a number between 0 and 100\n' 1>&2
					exit 64 # EX_USAGE
					;;
			esac
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Display HTTP Response that moves to n% with w3m.

				 -n, --number  percent 0 - 100
				 -h, --help    display this help and exit
			EOF
			exit
			;;
		'-'[!-]* | '--'?*)
			cat <<- EOF 1>&2
				${0}: invalid option -- '${1}'
				Try '${0} --help' for more information.
			EOF

			exit 64 # EX_USAGE
			;;
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				args="${args} $(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
				shift
			done
			;;
		*)
			args="${args} $(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
			shift
			;;
	esac
done

eval set -- "${args}"

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

file="${1}"
lineCount=$(grep -c -e '^' "${file}")

printf 'W3m-control: GOTO_LINE %d' "$((( ( lineCount - 1 ) * percent / 100 ) + 1))" | httpResponseW3mBack.sh -
rm -f "${file}"

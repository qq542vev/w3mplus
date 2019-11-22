#!/usr/bin/env sh

##
#	Close the tab and record the URI.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

file="${W3MPLUS_PATH}/tabRestore"
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			file="${2}"
			shift 2
			;;
	'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... URI
				Close the tab and record the URI.

				 -f, --file  restore file
				 -h, --help  display this help and exit
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

mkdir -p "$(dirname "${file}")"
: >>"${file}"

eval set -- "${args}"

uri="${1}"

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

if [ -n "${uri}" ]; then
	if [ "${uri}" = "$(tail -n 1 "${file}" | cut -d ' ' -f 1)" ]; then (
			tmp=$(cat "${file}")
			printf '%s\n' "${tmp}" | sed -e '/^$/d;$d' >"${file}"
	) fi

	printf '%s %s\n' "${uri}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >>"${file}"
fi

printf 'W3m-control: CLOSE_TAB' | httpResponseW3mBack.sh -

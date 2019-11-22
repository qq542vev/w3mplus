#!/usr/bin/env sh

##
# Restore w3m tabs.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-22
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

file="${W3MPLUS_PATH}/tabRestore"
count='1'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			file="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE
			fi

			count="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]...
				Restore w3m tabs.

				 -f, --file    restore file
				 -n, --number  restore count
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

mkdir -p "$(dirname "${file}")"
: >>"${file}"

eval set -- "${args}"

if [ 0 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

restoreData=$(cat "${file}")
date=$(($(date -u '+%Y%m%d%H%M%S' | utconv) - W3MPLUS_UNDO_TIMEOUT))

while [ -n "${restoreData}" ] && [ 1 -le "${count}" ]; do
	restore=$(printf '%s' "${restoreData}" | sed -n -e '$p')
	restoreUri=$(printf '%s' "${restore}" | cut -d ' ' -f 1)
	restoreDate=$(printf '%s' "${restore}" | cut -d ' ' -f 2 | tr -d 'TZ:-' | utconv)

	if [ "${date}" -lt "${restoreDate}" ]; then
		printf 'W3m-control: TAB_GOTO %s\n' "${restoreUri}"
		count=$((count - 1))
		restoreData=$(printf '%s' "${restoreData}" | sed -e '$d')
	else
		restoreData=''
	fi
done | httpResponseW3mBack.sh -

printf '%s\n' "${restoreData}" | sed -e '/^$/d' >"${file}"

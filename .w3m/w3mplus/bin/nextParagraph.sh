#!/usr/bin/env sh

##
#	Move to the next paragraph.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-16
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

line='1'
prevFlag='0'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE
			fi

			line="${2}"
			shift 2
			;;
		'-p' | '--paragraph')
			prevFlag='1'
			shift
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Move to the next paragraph.

				 -l, --line      line number
				 -p, --previous  previous paragraph
				 -h, --help      display this help and exit
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

file="${1}"

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

if [ "${prevFlag}" -eq 1 ]; then
	gotoLine=$(sed -n "1{/./=}; ${line}Q; /^\$/{N; ${line}Q; /^\\n*\$/D; =}" "${file}" | tail -n '1')
else
	gotoLine=$(sed -n -e "${line},\$!d; /^\$/{N; /^\\n$/D; =; Q}" "${file}")
fi

if [ -n "${gotoLine}" ]; then
	lineBegin.sh -l "${gotoLine}" "${file}"
else
	httpResponseW3mBack.sh
fi

rm -f "${file}"

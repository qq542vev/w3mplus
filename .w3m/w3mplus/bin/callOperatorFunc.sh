#!/usr/bin/env sh

##
#	Call OperatorFunc.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-20
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

number='$'
line='1'
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
		'-n' | '--number')
			if [ "${2}" != '$' ] && [ "${2}" != '0' ] && [ "$(expr "${2}" ':' '[+-]\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE
			fi

			number="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Call OperatorFunc.

				 -l, --line    line number
				 -n, --number  cut line
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

file="${1}"

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

tmpFile=$(mktemp)

if expr "${number}" ':' '[0+-]' >'/dev/null'; then
	number=$((line + number))

	if [ "${number}" -lt 1 ]; then
		number='1'
	fi
fi

if [ "${number}" = '$' ] || [ "${line}" -le "${number}" ]; then
	startLine="${line}"
	endLine="${number}"
else
	startLine="${number}"
	endLine="${line}"
fi

sed -e "${startLine},${endLine}!d" "${file}" >"${tmpFile}"

httpResponseW3mBack.sh "W3m-control: EXEC_SHELL cat ${tmpFile} | ${W3MPLUS_OPERATORFUNC}; rm -f ${tmpFile}"

rm -f "${file}"
#!/usr/bin/env sh

##
# Start visual mode.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

config="${W3MPLUS_PATH}/visualStart"
line='1'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-l' | '--line')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE
			fi

			line="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Start visual mode.

				 -c, --config  configuration file
				 -l, --line    line number
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
				args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
				shift
			done
			;;
		*)
			args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
			shift
			;;
	esac
done

mkdir -p "$(dirname "${config}")"
: >>"${config}"

eval set -- "${args}"

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

file="${1}"
checksum=$(cksum "${file}" | cut -d " " -f '1-2' | tr ' ' '-')

[ -e "${config}" ] || printf '  0\n' >"${config}"

startChecksum=$(cut -d ' ' -f 1 "${config}")
startLine=$(cut -d ' ' -f 2 "${config}")
startTime=$(cut -d ' ' -f 3 "${config}" | tr -d 'TZ:-' | utconv)

if [ "${checksum}" = "${startChecksum}" ] && [ "$(date -u '+%Y%m%d%H%M%S' | utconv)" -lt "$((startTime + W3MPLUS_VISUAL_TIMEOUT))" ]; then
	if [ "${startLine}" -le "${line}" ]; then
		endLine="${line}"
	else
		endLine="${startLine}"
		startLine="${line}"
	fi

	sed -n -e "${startLine},${endLine}p" "${file}" | yank.sh

	: >"${config}"
else
	printf '%s %d %s\n' "${checksum}" "${line}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >"${config}"

	httpResponseW3mBack.sh "W3m-control: EXEC_SHELL echo 'Start visual mode from line ${line}'"
fi

rm -f "${file}"

#!/usr/bin/env sh

##
#	Get a quick mark.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

markFile="${W3MPLUS_PATH}/quickmark"
gotoLine='0'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			markFile="${2}"
			shift 2
			;;
		'-l' | '--line')
			gotoLine='1'
			shift
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION] KEY
				Get a quick mark.

				 -f, --file  quick mark file
				 -l, --line  jump to line
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

mkdir -p "$(dirname "${markFile}")"
: >>"${markFile}"

eval set -- "${args}"

key="${1}"

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

if mark=$(grep -m 1 -e "^${key} " "${markFile}"); then
	uri=$(printf '%s' "${mark}" | cut -d ' ' -f 2)
	line=$(printf '%s' "${mark}" | cut -d ' ' -f 3)

	if [ "${gotoLine}" -eq 1 ]; then
		printRedirect.sh "${uri}" "W3m-control: GOTO_LINE ${line}"
	else
		printRedirect.sh "${uri}"
	fi

	exit
fi

httpResponseW3mBack.sh

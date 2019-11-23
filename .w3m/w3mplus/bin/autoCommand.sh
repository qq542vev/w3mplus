#!/usr/bin/env sh

##
# Execute the command according to the site.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

file="${W3MPLUS_PATH}/autoCommand"
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			file="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... [CALL] [URI]3]
				Execute the command according to the site.

				 -c, --config  configuration file
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

mkdir -p "$(dirname "${file}")"
: >>"${file}"

eval set -- "${args}"

call="${1-manual}"
uri="${2-${W3M_URL}}"

if [ 2 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

while read -r 'autoCall' 'autoRegType' 'autoPattern' 'autoCommand'; do
	if [ "${call}" = "${autoCall}" ] && expr "${autoRegType}" : '^!\{0,1\}[EFG]$'; then
		grepOption=$(printf '%s' "${autoRegType}" | sed -E -e 's/!/ -v/; s/[FEG]/ -&/g')

		if printf '%s' "${uri}" | grep ${grepOption} -q -e "${autoPattern}"; then
			printf 'W3m-control: COMMAND %s\n' "${autoCommand}"
			break
		fi
	fi
done <"${file}" | httpResponseW3mBack.sh -

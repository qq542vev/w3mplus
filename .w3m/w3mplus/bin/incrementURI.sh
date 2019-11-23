#!/usr/bin/env sh

##
# Increments the URI.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-20
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

number='+1'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			if [ "${2}" != '0' ] && [ "$(expr "${2}" ':' '[+-]\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2

				exit 64 # EX_USAGE
			fi

			number="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... URI [URI]...
				Increments the URI.

				 -n, --number  increment number
				 -h, --help    display this help and exit
			EOF

			exit
			;;
		'-')
			args="${args}$(tr '\t ' '\n\n' | while IFS= read -r uri; do
				printf ' '
				printf '%s' "${uri}" | sed -e "s/./'&'/g; s/'''/\"'\"/g"
			done)"
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

if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

for uri in ${@+"${@}"}; do
	parts=$(printf '%s' "${uri}" | sed -e 's/\([:\/?#@&*=_-]\)\([0-9]\{1,\}\)/\1\n\2\n/g')
	line=$(printf '%s' "${parts}" | sed -n -e '/^[0-9]\{1,\}$/=' | tail -n '1')

	if [ -n "${line}" ]; then
		page=$(printf '%s' "${parts}" | sed -n -e "${line}p")

		if printf '%s' "${number}" | grep -q -e '^[0-9]\{1,\}$'; then
			page="${number}"
		else
			page="$((page + number))"

			if [ "${page}" -lt 0 ]; then
				page='0'
			fi
		fi

		printf '%s' "${parts}" | sed -e "${line}c ${page}" | tr -d '\n'
		printf '\n'
	fi
done

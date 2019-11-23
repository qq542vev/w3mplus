#!/usr/bin/env sh

##
# Access the parent directory.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-11
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

count='1'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			if [ "${2}" != '0' ] && [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2

				exit 64 # EX_USAGE
			fi

			count="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... URI [URI]...
				Access the parent directory.

				 -n, --number  number of go up
				 -h, --help    display this help and exit
			EOF

			exit
			;;
		'-')
			args="${args}$(tr '[:space:]' '\n' | while IFS= read -r uri; do
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

eval set -- "${args}"

pattern='^\(\([^:\/?#]\{1,\}\):\)\{0,1\}\(\/\/\([^\/?#]*\)\)\{0,1\}\([^?#]*\)\(?\([^#]*\)\)\{0,1\}\(#\(.*\)\)\{0,1\}$'

if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

for uri in ${@+"${@}"}; do
	path=$(printf '%s' "${uri}" | sed -e "s/${pattern}/\\5/")

	tmpCount="${count}"

	while [ "${tmpCount}" -ne 0 ] && [ "${path}" != '/' ]; do
		if expr "${path}" ':' '.*/$' >'/dev/null'; then
			path="${path%/*}"
		fi

		path="${path%/*}/"

		tmpCount=$((tmpCount - 1))
	done

	printf '%s%s\n' "$(printf '%s' "${uri}" | sed -e "s/${pattern}/\\1\\3/")" "${path}"
done

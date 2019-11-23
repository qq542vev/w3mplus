#!/usr/bin/env sh

##
# Set a quick mark.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

markFile="${W3MPLUS_PATH}/quickmark"
line="${3-${W3M_CURRENT_LINE-1}}"
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			markFile="${2}"
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
				Usage: ${0} [OPTION]... KEY URL
				Set the quick mark.

				 -f, --file  quick mark file
				 -l, --line  line number
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

mkdir -p "$(dirname "${markFile}")"
: >>"${markFile}"

eval set -- "${args}"

key="${1}"
uri="${2-${W3M_URL}}"

if [ 2 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

if [ -n "${key}" ] && [ -n "${uri}" ]; then
	escaped=$(printf '%s' "${uri}" | htmlEscape.sh)
	date=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

	oldMarks=$(htmlEscape.sh "${markFile}" | awk '
		/^'"${key}"' /{
			printf "<p>Old Quick Mark \047<kbd>%s</kbd>\047: <a href=\"%s\">%s</a> <date>%s</date></p>\n", $1, $2, $2, $4
		}
	')

	if [ -n "${oldMarks}" ]; then
		printHtml.sh "Updated Quick Mark '${key}'" "<p>Updated Quick MarK '<kbd>${key}</kbd>': <a href=\"${escaped}\">${escaped}<a> <date>${date}</date></p>${oldMarks}"
	else
		printHtml.sh "Added Quick Mark '${key}'" "<p>Added Quick MarK '<kbd>${key}</kbd>': <a href=\"${escaped}\">${escaped}<a> <date>${date}</date></p>"
	fi

	{
		sed -e '/^$/d' -e "/^${key} /d" "${markFile}"
		printf '%s %s %d %s\n' "${key}" "${uri}" "${line}" "${date}"
	} | sort -o "${markFile}"
else
	httpResposeW3mBack.sh
fi

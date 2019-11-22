#!/usr/bin/env sh

##
#	Move to the beginning of the line.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

end='0'
line='1'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-e' | '--end')
			end='1'

			shift
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
				Move to the beginning of the line.

				 -e, --end   move to end of line.
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

{
	printf 'W3m-control: GOTO_LINE %d\n' "${line}"

	if [ "${end}" -eq 1 ]; then
		printf 'W3m-control: LINE_END\n'
		sed -n -e "${line}{s/^\\(.*[^ ]\\)\\{0,1\\}\\( *\\)\$/\\2/; s/ /W3m-control: MOVE_LEFT1\\n/gp; Q}" "${file}"
	else
		sed -n -e "${line}{s/^\\( *\\).*\$/\\1/; s/ /W3m-control: MOVE_RIGHT1\\n/gp; Q}" "${file}"
	fi
} | httpResponseW3mBack.sh -

rm -f "${file}"

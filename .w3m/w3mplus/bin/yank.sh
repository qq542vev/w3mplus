#!/usr/bin/env sh

##
# Yank text with w3m.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-08
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

yankFile=$(date "+${W3MPLUS_YANK_FILE}")
yankHeader=$(date "+${W3MPLUS_YANK_HEADER}")
yankFooter=$(date "+${W3MPLUS_YANK_FOOTER}")
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			yankFile="${2}"
			shift 2
			;;
		'-F' | '--footer')
			yankFooter="${2}"
			shift 2
			;;
		'-H' | '--header')
			yankHeader="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION] TEXT [TEXT]
				Yank text with w3m.

				 -f, --file    yank file
				 -F, --footer  footer text
				 -H, --header  header text
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

mkdir -p "$(dirname "${yankFile}")"

eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

number=$(for yankText in ${@+"${@}"}; do
	if [ -n "${yankHeader}" ]; then
		printf '%s\n' "${yankHeader}" | tee -a "${yankFile}"
	fi

	printf '%s\n' "${yankText}" | tee -a "${yankFile}"

	if [ -n "${yankFooter}" ]; then
		printf '%s\n' "${yankFooter}" | tee -a "${yankFile}"
	fi
done | grep -c -e '^')

httpResponseW3mBack.sh "W3m-control: EXEC_SHELL tail -n '${number}' '${yankFile}'; printf 'Add to %s\\n' '${yankFile}'"

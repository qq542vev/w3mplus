#!/usr/bin/env sh

##
# Search for a word.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-20
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

command='SEARCH'
exactFlag='0'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-b' | '--back')
			command='SEARCH_BACK'
			shift
			;;
		'-e' | '--exact')
			exactFlag='1'
			shift
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... WORD [WORD]...
				Search for a word.

				 -b, --back   backward search
				 -e, --exact  exact search
				 -h, --help   display this help and exit
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

eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

keyword=''

for word in ${@+"${@}"}; do
	if [ -n "${word}" ]; then
		keyword="${keyword}${keyword:+|}$(printf '%s' "${word}" | sed -e 's/[].\*+?|(){}[]/\\&/g; 1s/^^/\\^/; $s/$$/\\$/')
"
	fi
done

if [ -n "${keyword}" ]; then
	if [ "${exactFlag}" -eq 1 ]; then
		keyword="(^|[	 ])${keyword}([	 ]|\$)"
	fi

	printf 'W3m-control: %s %s' "${command}" "${keyword}"
fi | httpResponseW3mBack.sh -

#!/usr/bin/env sh

##
# Change w3m image_scale.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-21
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

configFile="${HOME}/.w3m/config"
zoom='100'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			configFile="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "$(expr "${2}" ':' '[+-]\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE
			fi

			zoom="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]...
				Change w3m image_scale.

				 -c, --config  w3m config file
				 -n, --number  image scale
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

if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE
fi

if scale=$(grep -m '1' -e '^image_scale[\t ]\{1,\}\([0-9]\{1,\}\)$' "${configFile}" | grep -o -e '[0-9]\{1,\}'); then
	if expr "${zoom}" ':' '[+-]' >'/dev/null'; then
		newScale=$((scale + zoom))
	else
		newScale="${zoom}"
	fi

	if [ "${W3MPLUS_ZOOM_MAX}" -lt "${newScale}" ]; then
		newScale="${W3MPLUS_ZOOM_MAX}"
	elif [ "${newScale}" -lt "${W3MPLUS_ZOOM_MIN}" ]; then
		newScale="${W3MPLUS_ZOOM_MIN}"
	fi

	sed -i -e "/^image_scale[\\t ]/c image_scale ${newScale}" "${configFile}"

	printf 'W3m-control: REINIT'
fi | httpResponseW3mBack.sh -

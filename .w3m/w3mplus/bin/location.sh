#!/usr/bin/env sh

##
#	Access the resource and execute the command.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... SUBCOMMAND [URL]
				Access the resource and execute the command.

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

action="${1}"
uri="${2-}"

if [ -n "${uri}" ]; then
	case "${action}" in
		'addBookmark')
			printRedirect.sh "${uri}" '' 'W3m-control: ADD_BOOKMARK'
			;;
		'decrementURI')
			printRedirect.sh "$(incrementURI.sh -n '-1' "${uri}")"
			;;
		'incrementURI')
			printRedirect.sh "$(incrementURI.sh "${uri}")"
			;;
		'parentPath')
			printRedirect.sh "$(parentPath.sh "${uri}")"
			;;
		'prevTab')
			printRedirect.sh "${uri}" '' 'W3m-control: PREV_TAB'
			;;
		'sendEmail')
			printRedirect.sh "mailto:?body=$(printf '%s' "${uri}" | urlEncode.sh)"
			;;
		'viewSource')
			printRedirect.sh "${uri}" '' 'W3m-control: VIEW'
			;;
		'viewSourceExternally')
			printRedirect.sh "${uri}" '' "$(
				cat <<- 'EOF'
					W3m-control: VIEW
					W3m-control: EDIT_SCREEN
					W3m-control: VIEW
				EOF
			)"
			;;
		'yank')
			yank.sh "${uri}"
			;;
		*)
			printHtml.sh 'Problem loading page' - <<- 'EOF'
				<h1>The address isn't valid</h1>

				<p>The URL is not valid and cannot be loaded.</p>

				<ul>
					<li>Web addresses are usually written like <strong>http://www.example.com/</strong></li>
					<li>Make sure that you're using forward slashes (i.e. /).</li>
				</ul>
			EOF
			;;
	esac
else
	httpResponseW3mBack.sh -
fi

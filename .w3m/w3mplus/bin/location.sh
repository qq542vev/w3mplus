#!/usr/bin/env sh

## File: location.sh
##
## Access the resource and execute the command.
##
## Usage:
##
##   (start code)
##   location.sh [OPTION]... SUBCOMMAND URI
##   (end)
##
## Options:
##
##   -h, --help    - display this help and exit.
##   -v, --version - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.4
##   date - 2020-02-19
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# initファイルの読み込み
: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-h' | '--help')
			usage
			exit
			;;
		# バージョン情報を表示して終了する
		'-v' | '--version')
			version
			exit
			;;
		'-'[!-]* | '--'?*)
			cat <<- EOF 1>&2
				${0##*/}: invalid option -- '${1}'
				Try '${0##*/} --help' for more information.
			EOF

			exitStatus="${EX_USAGE}"; exit
			;;
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				args="${args}${args:+ }$(printf '%s\n' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
				shift
			done
			;;
		*)
			args="${args}${args:+ }$(printf '%s\n' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
			shift
			;;
	esac
done

eval set -- "${args}"

action="${1}"
uri="${2}"

if [ -z "${uri}" ]; then
	httpResponseW3mBack.sh
	exit
fi

case "${action}" in
	'addBookmark')
		printRedirect.sh --header-field 'W3m-control: ADD_BOOKMARK' "${uri}"
		;;
	'decrementURI')
		printRedirect.sh "$(incrementURI.sh -n '-1' -- "${uri}")"
		;;
	'incrementURI')
		printRedirect.sh "$(incrementURI.sh -- "${uri}")"
		;;
	'parentPath')
		printRedirect.sh "$(parentPath.sh -- "${uri}")"
		;;
	'prevTab')
		printRedirect.sh --header-field 'W3m-control: PREV_TAB' "${uri}"
		;;
	'sendEmail')
		printRedirect.sh "mailto:?body=$(printf '%s' "${uri}" | urlencode)"
		;;
	'viewSource')
		printRedirect.sh --header-field 'W3m-control: VIEW' "${uri}"
		;;
	'viewSourceExternally')
		printRedirect.sh --header-field "$(
			cat <<- 'EOF'
				W3m-control: VIEW
				W3m-control: EDIT_SCREEN
				W3m-control: VIEW
			EOF
		)" "${uri}"
		;;
	*)
		printHtml.sh --title 'Problem loading page' <<- 'EOF'
			<h1>The address isn't valid</h1>

			<p>The URL is not valid and cannot be loaded.</p>

			<ul>
				<li>Web addresses are usually written like <strong>http://www.example.com/</strong></li>
				<li>Make sure that you're using forward slashes (i.e. /).</li>
			</ul>
		EOF
		;;
esac

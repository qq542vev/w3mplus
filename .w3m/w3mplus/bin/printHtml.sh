#!/usr/bin/env sh

##
# Print HTTP message for HTML.
#
# @author qq542vev
# @version 2.0.0
# @date 2020-02-08
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'endCall' 0 # EXIT
trap 'endCall; exit 129' 1 # SIGHUP
trap 'endCall; exit 130' 2 # SIGINT
trap 'endCall; exit 131' 3 # SIGQUIT
trap 'endCall; exit 143' 15 # SIGTERM

endCall () {
	rm -fr ${tmpFile+"${tmpFile}"}
}

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/config"

title='No title'
headerFields=''
statusCode="200 OK"
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-H' | '--header-field')
			headerFields="${2}"
			shift 2
			;;
		'-m' | '--meta-data')
			metaData="${2}"
			shift 2
			;;
		'-s' | '--status-code')
			statusCode="${2}"
			shift 2
			;;
		'-t' | '--title')
			title="${2}"
			shift 2
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [FILE]...
				$(sed -e '/^##$/,/^##$/!d; /^# /!d; s/^# //; q' -- "${0}")

				 -H, --header-field=HEADER     HTTP header fields
				 -m, --meta-data=ELEMENT       HTML elements in head element
				 -s, --status-code=STATUSCODE  HTTP status code
				 -t, --title=TITLE             page title in title element
				 -h, --help                    display this help and exit
				 -v, --version                 output version information and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //1p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //1p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //1p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //1p' -- "${0}")
			EOF

			exit
			;;
		'-')
			tmpFile=$(mktemp)
			cat >"${tmpFile}"
			shift

			set -- "${tmpFile}" ${@+"${@}"}
			;;
		# `--name=value` 形式のロングオプション
		'--'[!-]*'='*)
			option="${1}"
			shift
			# `--name value` に変換して再セットする
			set -- "${option%%=*}" "${option#*=}" ${@+"${@}"}
			;;
		# 以降はオプション以外の引数
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

				args="${args}${args:+ }'${arg%?$}'"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option=$(printf '%s\n' "${1}" | cut -c '2'; printf '$')
			options=$(printf '%s\n' "${1}" | cut -c '3-'; printf '$')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%?$}" "-${options%?$}" ${@+"${@}"}
			;;
		# その他の無効なオプション
		'-'*)
			cat <<- EOF 1>&2
				${0##*/}: invalid option -- '${1}'
				Try '${0##*/} --help' for more information.
			EOF

			exit 64 # EX_USAGE </usr/include/sysexits.h>
			;;
		# その他のオプション以外の引数
		*)
			arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
			shift
			;;
	esac
done

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	tmpFile=$(mktemp)
	cat >"${tmpFile}"

	set -- "${tmpFile}"
fi

mainContent=$(cat -- ${@+"${@}"}; printf '$')
mainContent="${mainContent%$}"

headerFields=$(printf 'Content-Type: text/html; charset=UTF-8\n%s\n' "${headerFields}" | sed -e "/^$(printf '\r')*\$/d" | normalizeHttpMessage.sh -u 'W3m-control'; printf '$')
headerFields="${headerFields%$}"

messageBody=$("${W3MPLUS_TEMPLATE_HTML}" -t "${title}" -c "${mainContent}"; printf '$')
messageBody="${messageBody%$}"

"${W3MPLUS_TEMPLATE_HTTP}" -b "${messageBody}" -h "${headerFields}" -s "${statusCode}"

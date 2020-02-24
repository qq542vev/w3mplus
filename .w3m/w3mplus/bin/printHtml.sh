#!/usr/bin/env sh

## File: printHtml.sh
##
## Print HTTP message for HTML.
##
## Usage:
##
##   (start code)
##   printHtml.sh [OPTION]... [FILE]...
##   (end)
##
## Options:
##
##   -H, --header-field=HEADER     - HTTP header fields
##   -m, --meta-data=ELEMENT       - HTML elements in head element
##   -s, --status-code=STATUS_CODE - HTTP status code
##   -t, --title=TITLE             - page title in title element
##   -h, --help                    - display this help and exit.
##   -v, --version                 - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 2.0.1
##   date - 2020-02-20
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


: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

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
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			usage
			exit
			;;
		# バージョン情報を表示して終了する
		'-v' | '--version')
			version
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

			exitStatus="${EX_USAGE}"; exit
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

headerFields=$(printf 'Content-Type: text/html; charset=UTF-8\n%s\n' "${headerFields}" | sed -e "/^$(printf '\r')*\$/d" | normalizeHttpMessage.sh --uncombined 'W3m-control'; printf '$')
headerFields="${headerFields%$}"

messageBody=$("${W3MPLUS_TEMPLATE_HTML}" -t "${title}" -c "${mainContent}"; printf '$')
messageBody="${messageBody%$}"

"${W3MPLUS_TEMPLATE_HTTP}" -b "${messageBody}" -h "${headerFields}" -s "${statusCode}"

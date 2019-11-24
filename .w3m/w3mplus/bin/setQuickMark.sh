#!/usr/bin/env sh

##
# Set a quick mark.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-24
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
markFile="${W3MPLUS_PATH}/quickmark"
line="${3-${W3M_CURRENT_LINE-1}}"
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			markFile="${2}"
			shift 2
			;;
		'-l' | '--line')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			line="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
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
				args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option="${1}"
			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-$(printf '%s' "${option}" | cut -c 2)" "-$(printf '%s' "${option}" | cut -c 3-)" ${@+"${@}"}
			;;
		# その他の無効なオプション
		'-'*)
			cat <<- EOF 1>&2
				${0}: invalid option -- '${1}'
				Try '${0} --help' for more information.
			EOF

			exit 64 # EX_USAGE </usr/include/sysexits.h>
			;;
		# その他のオプション以外の引数
		*)
			args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
			shift
			;;
	esac
done

mkdir -p "$(dirname "${markFile}")"
: >>"${markFile}"

# オプション以外の引数を再セットする
eval set -- "${args}"

key="${1}"
uri="${2-${W3M_URL}}"

# 引数の個数が過大である
if [ 2 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
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

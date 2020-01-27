#!/usr/bin/env sh

##
# Set a quick mark.
#
# @author qq542vev
# @version 1.1.1
# @date 2020-01-24
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'exit 129' 1 # SIGHUP
trap 'exit 130' 2 # SIGINT
trap 'exit 131' 3 # SIGQUIT
trap 'exit 143' 15 # SIGTERM

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/quickmark"
colmun='1'
line='1'
fileds=''
addList=''
date=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--congig')
			config="${2}"
			shift 2
			;;
		'-C' | '--colmun')
			if [ "${2}" != '0' ] && [ "$(expr -- "${2}" ':' '-\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			colmun="${2}"
			shift 2
			;;
		'-l' | '--line')
			if [ "${2}" != '0' ] && [ "$(expr -- "${2}" ':' '-\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			line="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... KEY [URI]...
				Set the quick mark.

				 -c, --config=FILE    quick mark file
				 -C, --colmun=NUMBER  colmun number
				 -l, --line=NUMBER    line number
				 -h, --help           display this help and exit
				 -v, --version        output version information and exit
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
			case "${pattern+1}" in
				'1')
					fileds=$(printf '%s%s\t%s\t%d\t%d\t%s\n$' "${fileds}" "${pattern}" "${1}" "${line}" "${colmun}" "${date}")
					fileds="${fileds%$}"
					escapedURI=$(printf '%s' "${1}" | htmlEscape.sh)
					addList=$(printf '%s<li><a href="%s">%s</a></li>' "${addList}" "${escapedURI}" "${escapedURI}")
					;;
				*)
					pattern="${1}"
					;;
				esac

				shift
			;;
	esac
done

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

deleteList=$(grep -e "^${pattern}	" -- "${config}" | while IFS='	' read -r 'key' 'uri' 'line' 'colmun' 'date'; do
	escapedURI=$(printf '%s' "${uri}" | htmlEscape.sh)
	printf '<li><a href="%s">%s</a></li>' "${escapedURI}" "${escapedURI}"
done)

if [ -z "${addList}" ] && [ -z "${deleteList}" ]; then
	httpResposeW3mBack.sh
	exit
fi

{
	sed -e "/^\$/d; /^$(printf '%s' "${pattern}" | sed -e 's#/#\\/#g')	/d" -- "${config}"
	printf '%s' "${fileds}"
} | sort -o -- "${config}"

if [ -n "${addList}" ]; then
	addList="<h1>Added Quick Mark</h1><ul>${addList}</ul>"
fi

if [ -n "${deleteList}" ]; then
	deleteList="<h1>Deleted Quick Mark</h1><ul>${deleteList}</ul>"
fi

printHtml.sh "Set Quick Mark '${pattern}'" "${addList}${deleteList}"

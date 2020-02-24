#!/usr/bin/env sh

## File: movePercent.sh
##
## Display HTTP Response that moves to n% with w3m.
##
## Usage:
##
##   (start code)
##   movePercent.sh [OPTION]... FILE
##   (end)
##
## Options:
##
##   -l, --line    - line number
##   -n, --number  - move percent 0 - 100
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
##   version - 1.1.3
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'


: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

# 各変数に既定値を代入する
line='1'
percent='50'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if expr -- "${2}" ':' '[1-9][0-9]*$' >'/dev/null'; then
				line="${2}"
				shift 2
			else
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exitStatus="${EX_USAGE}"; exit
			fi
			;;
		'-n' | '--number')
			case "${2}" in
				[0-9] | [1-9][0-9] | '100' | [+-][0-9] | [+-][0-9][0-9] | [+-]'100')
					percent="${2}"
					shift 2
					;;
				*)
					printf 'The value must be a number between 0 and 100\n' 1>&2
					exitStatus="${EX_USAGE}"; exit
					;;
			esac
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

file="${1}"
lineCount=$(grep -c -e '^' -- "${file}" || :)

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exitStatus="${EX_USAGE}"; exit
fi

case "${percent}" in [+-]*)
	percent=$(((((line - 1) * 100) / (lineCount - 1)) + percent))

	if [ "${percent}" -lt 0 ]; then
		percent='0'
	elif [ 100 -lt "${percent}" ]; then
		percent='100'
	fi
	;;
esac

printf 'W3m-control: GOTO_LINE %d' "$((( ( lineCount - 1 ) * percent / 100 ) + 1))" | httpResponseW3mBack.sh -

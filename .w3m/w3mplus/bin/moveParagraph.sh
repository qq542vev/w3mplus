#!/usr/bin/env sh

## File: moveParagraph.sh
##
## Move to the next paragraph.
##
## Usage:
##
##   (start code)
##   moveParagraph.sh [OPTION]... FILE
##   (end)
##
## Options:
##
##   -l, --line=NUMBER   - line number
##   -n, --number=NUMBER - number of paragraph moves
##   -h, --help          - display this help and exit
##   -v, --version       - output version information and exit
##
## Exit Status:
##
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.5
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

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

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

# 各変数に既定値を代入する
line='1'
number='+1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if [ "$(expr -- "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			line="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "$(expr -- "${2}" ':' '[+-][1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
			fi

			number="${2}"
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
			args="${args}$(quoteEscape ${@+"${@}"})"
			shift "${#}"
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
			args="${args}$(quoteEscape "${1}")"
			shift
			;;
	esac
done

# オプション以外の引数を再セットする
eval set -- "${args}"

file="${1}"

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

while [ "${number}" -ne 0 ]; do
	if [ 0 -lt "${number}" ]; then
		line=$(sed -n -e "${line},\$!d; /^\$/{N; /^\\n$/D; =; q}" -- "${file}")

		if [ -z "${line}" ]; then
			line=$(grep -c -e '^' -- "${file}")
			break
		fi

		number=$((number - 1))
	else
		line=$(sed -n "1{/./=}; ${line}q; /^\$/{N; ${line}q; /^\\n*\$/D; =}" -- "${file}" | tail -n '1')

		if [ -z "${line}" ]; then
			line='1'
			break
		fi

		number=$((number + 1))
	fi
done

moveColmun.sh -l "${line}" -n '0' -s "${file}"

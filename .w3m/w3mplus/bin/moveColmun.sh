#!/usr/bin/env sh

## File: moveColmun.sh
##
## Move column n%.
##
## Usage:
##
##   (start code)
##   moveColmun.sh [OPTION]... FILE
##   (end)
##
## Options:
##
##   -l, --line=NUNBER   - line number
##   -n, --number=NUMBER - move column percent
##   -s, --skip          - ignores whitespace at the beginning and end of lines
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
number='0'
skipFlag='0'
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
			case "${2}" in
				[0-9] | [1-9][0-9] | '100')
					number="${2}"
					shift 2
					;;
				*)
					printf 'The value must be a number between 0 and 100\n' 1>&2
					exit 64 # EX_USAGE </usr/include/sysexits.h
					;;
			esac
			;;
		'-s' | '--skip')
			skipFlag='1'
			shift
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			usage
			exit
			;;
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

file="${1}"

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

{
	row=$(sed -n -e "${line}{p; q}" -- "${file}")

	printf 'W3m-control: GOTO_LINE %d\n' "${line}"

	if [ "${skipFlag}" -eq 1 ]; then
		printf '%s' "${row}" | sed -e 's/^\([\t ]*\).*$/\1/; s/[\t ]/W3m-control: MOVE_RIGHT1\n/g'
		row=$(printf '%s' "${row}" | sed -e 's/^[\t ]*//; s/[\t ]*$//')
	fi

	if [ -n "${row}" ]; then
		moveCount=$((($(printf '%s' "${row}" | wc -m) - 1) * number / 100))

		printf 'W3m-control: MOVE_RIGHT1 %d\n' "${moveCount}"
	fi
} | httpResponseW3mBack.sh -

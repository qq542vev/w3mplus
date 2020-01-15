#!/usr/bin/env sh

##
# Move to the next paragraph.
#
# @author qq542vev
# @version 1.1.0
# @date 2020-01-15
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 各変数に既定値を代入する
line='1'
number='+1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			line="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "$(expr "${2}" ':' '[+-][1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... FILE
				Move to the next paragraph.

				 -l, --line=NUMBER    line number
				 -n, --number=NUMBER  number of paragraph moves
				 -h, --help           display this help and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //1p' "${0}") (Last update: $(sed -n -e 's/^# @date //1p' "${0}"))
				$(sed -n -e 's/^# @copyright //1p' "${0}")
				License: $(sed -n -e 's/^# @licence //1p' "${0}")
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

while [ "${number}" -ne 0 ]; do
	if [ 0 -lt "${number}" ]; then
		line=$(sed -n -e "${line},\$!d; /^\$/{N; /^\\n$/D; =; Q}" "${file}")

		if [ -z "${line}" ]; then
			line=$(grep -c -e '^' "${file}")
			break
		fi

		number=$((number - 1))
	else
		line=$(sed -n "1{/./=}; ${line}Q; /^\$/{N; ${line}Q; /^\\n*\$/D; =}" "${file}" | tail -n '1')

		if [ -z "${line}" ]; then
			line='1'
			break
		fi

		number=$((number + 1))
	fi
done

moveColmun.sh -l "${line}" -n '0' -s "${file}"

#!/usr/bin/env sh

##
# Move to the beginning of the line.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
line='1'
number='0'
skipFlag='0'
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
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Move to the beginning of the line.

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
				arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '_');

				args="${args}${args:+ }'${arg%?_}'"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option=$(printf '%s' "${1}" | cut -c '2'; printf '_')
			options=$(printf '%s' "${1}" | cut -c '3-'; printf '_')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%_}" "-${options%_}" ${@+"${@}"}
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
			arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '_');

			args="${args}${args:+ }'${arg%?_}'"
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
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

{
	row=$(sed -n -e "${line}{p; Q}" "${file}")

	printf 'W3m-control: GOTO_LINE %d\n' "${line}"

	if [ "${skipFlag}" -eq 1 ]; then
		printf '%s' "${row}" | sed -e 's/^\([\t ]*\).*$/\1/; s/[\t ]/W3m-control: MOVE_RIGHT1\n/g'
		row=$(printf '%s' "${row}" | sed -e 's/^[\t ]*//; s/[\t ]*$//')
	fi

	if [ -n "${row}" ]; then
		columnCount=$(printf "${row}" | wc -m)

		yes 'W3m-control: MOVE_RIGHT1' 2>'/dev/null' | head -n "$(( ( columnCount - 1 ) * number / 100 ))"
	fi
} | httpResponseW3mBack.sh -

rm -f "${file}"